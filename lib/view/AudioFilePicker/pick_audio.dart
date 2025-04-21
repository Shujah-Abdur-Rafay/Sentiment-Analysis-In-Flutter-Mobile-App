import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/services/voice_emotion_service.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ChooseAudioScreen extends StatefulWidget {
  const ChooseAudioScreen({super.key});

  @override
  _ChooseAudioScreenState createState() => _ChooseAudioScreenState();
}

class _ChooseAudioScreenState extends State<ChooseAudioScreen> {
  String? _audioFileName; // Variable to hold the selected audio file name
  File? _audioFile; // Variable to hold the selected audio file for mobile
  Uint8List? _audioBytes; // Variable to hold the selected audio bytes for web
  bool _isLoading = false; // Loading state variable
  bool _isAnalyzing = false; // Analyzing state variable
  EmotionAnalysisResult? _analysisResult; // Analysis result
  final VoiceEmotionService _emotionService = VoiceEmotionService();
  
  // Audio player variables
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _audioLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
          _audioLoaded = true;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Listen for playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _pickAudioFile() async {
    // Stop any playing audio first
    await _stopAudio();
    
    // Reset analysis results when picking a new file
    setState(() {
      _analysisResult = null;
      _audioLoaded = false;
    });
    
    // Open the file picker for audio files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      // If the user selected a file, update the state with the file name and file
      setState(() {
        _audioFileName = result.files.first.name; // Get the file name
        
        if (kIsWeb) {
          // For web, use bytes
          _audioBytes = result.files.first.bytes;
        } else {
          // For mobile, use path
          _audioFile = File(result.files.first.path!);
        }
      });
      
      // Load the audio for preview
      await _loadAudio();
    }
  }

  Future<void> _loadAudio() async {
    try {
      if (kIsWeb && _audioBytes != null) {
        // For web, load from bytes
        await _audioPlayer.setSourceBytes(_audioBytes!);
      } else if (!kIsWeb && _audioFile != null) {
        // For mobile, load from file
        await _audioPlayer.setSourceDeviceFile(_audioFile!.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio: $e')),
      );
    }
  }

  Future<void> _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // If we're at the end, restart from beginning
      if (_position >= _duration) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.resume();
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    }
  }

  Future<void> _seekAudio(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    await _audioPlayer.seek(newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _analyzeAudioFile() async {
    // Stop any playing audio first
    await _stopAudio();

    if (_audioFile == null && _audioBytes == null) {
      // Ensure a file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file first.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true; // Set analyzing to true
    });

    try {
      String tempFilePath;
      
      if (kIsWeb) {
        // For web, need to create a temporary file
        tempFilePath = 'temp_${DateTime.now().millisecondsSinceEpoch}.mp3';
        // Note: In a real implementation, you'd need to handle this differently
        // as direct file system access isn't possible in web
      } else {
        // For mobile, get the actual file path
        tempFilePath = _audioFile!.path;
      }

      // Analyze the audio file
      final result = await _emotionService.analyzeVoiceEmotion(tempFilePath);
      
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing audio: $e')),
      );
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveAnalysisResult() async {
    // Stop any playing audio first
    await _stopAudio();

    if (_analysisResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No analysis result to save.')),
      );
      return;
    }

    // Get the current user from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserData();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    // Upload the audio file to Firebase Storage
    try {
      String filePath = 'myaudios/${currentUser.uid}/$_audioFileName';
      String downloadUrl = '';
      
      if (kIsWeb) {
        // For web, use putData with bytes
        await FirebaseStorage.instance.ref(filePath).putData(_audioBytes!);
        downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      } else {
        // For mobile, use putFile
        await FirebaseStorage.instance.ref(filePath).putFile(_audioFile!);
        downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      }

      // Create a reference to the Firestore collection
      final audioRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('myaudios');

      // Add audio file info and analysis result to the Firestore collection
      await audioRef.add({
        'fileName': _audioFileName,
        'uploadedAt': FieldValue.serverTimestamp(),
        'downloadUrl': downloadUrl,
        'analysis': {
          'emotion': _analysisResult!.emotion,
          'sentiment': _analysisResult!.sentiment,
          'confidence': _analysisResult!.confidence,
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis result saved successfully!')),
      );

      // Clear the selected audio file
      setState(() {
        _audioFileName = null;
        _audioFile = null;
        _audioBytes = null;
        _analysisResult = null;
        _audioLoaded = false;
      });

      // Navigate back after upload
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving analysis: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.darkblack : AppColors.homescreen,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode
            ? AppColors.whitecolor
            : AppColors.darkblack,
        title: Text(
          'Choose Audio File',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? AppColors.darkblack
                : AppColors.whitecolor,
            fontSize: 19.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode
              ? AppColors.darkblack
              : AppColors.whitecolor,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.h),
              Text(
                'Please Select Audio File from your phone so we can tell you about your emotions',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? AppColors.whitecolor
                      : AppColors.textfieldheading,
                  fontSize: 15.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              GestureDetector(
                onTap: _pickAudioFile,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : AppColors.whitecolor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.audio_file,
                        size: 50,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        _audioFileName ??
                            'Choose an audio file from your phone (small size recommended)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkMode
                              ? AppColors.whitecolor
                              : AppColors.textfieldheading,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_audioFileName != null)
                        Text(
                          'Selected: $_audioFileName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Audio Player UI
              if (_audioFileName != null && _audioLoaded)
                Container(
                  margin: EdgeInsets.only(top: 20.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preview Audio',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Time position indicator and slider
                      Row(
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: themeProvider.isDarkMode
                                  ? Colors.white60
                                  : Colors.black45,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: _position.inSeconds.toDouble().clamp(
                                    0,
                                    _duration.inSeconds.toDouble(),
                                  ),
                              min: 0,
                              max: _duration.inSeconds.toDouble(),
                              onChanged: (value) => _seekAudio(value),
                              activeColor: Colors.purple,
                              inactiveColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          Text(
                            _formatDuration(_duration - _position),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: themeProvider.isDarkMode
                                  ? Colors.white60
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      // Playback controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Restart button
                          IconButton(
                            onPressed: () => _seekAudio(0),
                            icon: Icon(
                              Icons.replay,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          // Play/Pause button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _playPauseAudio,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                              iconSize: 36,
                              color: Colors.white,
                            ),
                          ),
                          // Stop button
                          IconButton(
                            onPressed: _stopAudio,
                            icon: Icon(
                              Icons.stop,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 30.h),
              
              // Analyze button
              if (_audioFileName != null && _analysisResult == null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeAudioFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      elevation: 5,
                    ),
                    child: _isAnalyzing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Analyze Audio',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              
              // Analysis results
              if (_analysisResult != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotion Analysis Results',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Divider(height: 30.h),
                      
                      // Primary emotion
                      _buildResultRow(
                        'Detected Emotion',
                        _analysisResult!.emotion.toUpperCase(),
                        _getEmotionColor(_analysisResult!.emotion),
                        themeProvider.isDarkMode,
                      ),
                      SizedBox(height: 15.h),
                      
                      // Sentiment
                      _buildResultRow(
                        'Sentiment',
                        _analysisResult!.sentiment.toUpperCase(),
                        _getSentimentColor(_analysisResult!.sentiment),
                        themeProvider.isDarkMode,
                      ),
                      SizedBox(height: 15.h),
                      
                      // Confidence
                      Text(
                        'Confidence: ${(_analysisResult!.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      
                      // Confidence bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: _analysisResult!.confidence,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: _getConfidenceColor(_analysisResult!.confidence),
                          minHeight: 10.h,
                        ),
                      ),
                      
                      // Emotion scores
                      if (_analysisResult!.emotionScores != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text(
                              'Emotion Breakdown',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ..._analysisResult!.emotionScores!.entries
                                .toList()
                                .where((e) => e.value > 0.01) // Filter out very small values
                                .map((entry) => _buildEmotionBar(
                                      entry.key,
                                      entry.value,
                                      _getEmotionColor(entry.key),
                                      themeProvider.isDarkMode,
                                    ))
                                .toList(),
                          ],
                        ),
                    ],
                  ),
                ),
              
              SizedBox(height: 20.h),
              
              // Save button (only if we have results)
              if (_analysisResult != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAnalysisResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode
                          ? Colors.indigo
                          : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 10.w),
                              Text(
                                'Save Result',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResultRow(String label, String value, Color color, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmotionBar(String emotion, double value, Color color, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotion,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: color,
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.amber;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'fear':
        return Colors.purple;
      case 'disgust':
        return Colors.green;
      case 'surprise':
        return Colors.orange;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.5) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}

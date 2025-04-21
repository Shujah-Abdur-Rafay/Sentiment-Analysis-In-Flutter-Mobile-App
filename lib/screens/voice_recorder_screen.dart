import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart' as record_pkg;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/widgets/professional_components.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/audio_recorder.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vocal_emotion/services/voice_emotion_service.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({Key? key}) : super(key: key);

  @override
  State<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends State<VoiceRecorderScreen>
    with SingleTickerProviderStateMixin {
  // Recording functionality
  final _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final VoiceEmotionService _emotionService = VoiceEmotionService();
  final ScrollController _scrollController = ScrollController();

  // Speech to text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _transcription = '';
  bool _isTranscribing = false;

  // UI state management
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlayingBack = false;
  String? _recordedFilePath;
  String _recordingName = "New Recording";

  // Emotion analysis results
  EmotionAnalysisResult? _emotionResult;
  bool _isAnalyzing = false;

  // Timer related variables
  Timer? _timer;
  int _recordingDuration = 0;
  int _playbackPosition = 0;
  Timer? _playbackTimer;

  // Animation controllers
  late AnimationController _waveformController;
  final List<double> _waveformLevels = List.generate(30, (_) => 0.1);

  // Amplitude tracking
  double _currentAmplitude = 0;
  double _maxAmplitude = 1;
  Timer? _amplitudeTimer;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);

    // Check permissions when screen loads
    _checkPermissions();

    // Start listening to amplitude if recorder is available
    _setupAmplitudeListener();

    // Initialize speech to text
    _initSpeech();
  }

  // Initialize speech recognition
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: ${error.errorMsg}');
          // Try to restart listening on error
          if (_isTranscribing) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _startListening();
            });
          }
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          // If the recognition is done, restart it to keep listening continuously
          if (status == 'done' && _isRecording && !_isPaused) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _startListening();
            });
          }
        },
      );

      if (_speechEnabled) {
        print('Speech recognition initialized successfully');
      } else {
        print('Speech recognition failed to initialize');
      }

      setState(() {});
    } catch (e) {
      print('Error initializing speech: $e');
      _speechEnabled = false;
      setState(() {});
    }
  }

  // Start listening for speech
  Future<void> _startListening() async {
    if (!mounted) return;
    
    setState(() {
      _isTranscribing = true;
      // Don't reset transcription when starting a new session to preserve partial results
    });

    try {
      if (!_speechToText.isListening) {
        bool available = await _speechToText.initialize(
          onStatus: (status) {
            print('Speech recognition status: $status');
            if (status == 'done' && _isRecording && !_isPaused) {
              // Restart listening after a short delay
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted && _isRecording && !_isPaused) {
                  _startListening();
                }
              });
            }
          },
          onError: (error) {
            print('Speech recognition error: ${error.errorMsg}');
            if (_isTranscribing && _isRecording && !_isPaused) {
              // Try to restart listening on error after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _isRecording && !_isPaused) {
                  _startListening();
                }
              });
            }
          },
        );

        if (available) {
          await _speechToText.listen(
            onResult: (result) {
              if (!mounted) return;
              setState(() {
                // Only update transcription if there are recognized words
                if (result.recognizedWords.isNotEmpty) {
                  _transcription = result.recognizedWords;
                }
              });
            },
            listenFor: const Duration(minutes: 2),
            pauseFor: const Duration(seconds: 5),
            partialResults: true,
            onSoundLevelChange: (level) => print('Sound level: $level'),
            cancelOnError: false, // Don't cancel on error, just try to restart
            listenMode: stt
                .ListenMode.dictation, // Use dictation mode for better results
          );
        } else {
          print('Speech recognition not available');
          if (mounted) {
            setState(() {
              _isTranscribing = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _isTranscribing = false;
        });
      }
    }
  }

  // Stop listening for speech and keep the transcription
  void _stopListening() async {
    // Make sure we get the final transcription before stopping
    final wasListening = _speechToText.isListening;

    await _speechToText.stop();

    if (mounted) {
      setState(() {
        _isTranscribing = false;

        // If there's no transcription and we were listening, show a message
        if (_transcription == 'Listening...' && wasListening) {
          _transcription = 'No speech detected';
        }
      });
    }
  }

  Future<void> _setupAmplitudeListener() async {
    _amplitudeTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (_isRecording && !_isPaused && mounted) {
        try {
          // Simulate amplitude for waveform visualization
          final random = DateTime.now().millisecondsSinceEpoch % 10 / 10;
          setState(() {
            _currentAmplitude = 0.3 + (random * 0.7);
            if (_currentAmplitude > _maxAmplitude) {
              _maxAmplitude = _currentAmplitude;
            }

            // Update waveform levels
            _updateWaveform();
          });
        } catch (e) {
          // Handle amplitude retrieval errors silently
        }
      }
    });
  }

  void _updateWaveform() {
    // Normalize amplitude to values between 0.1 and 1.0
    double normalized = _currentAmplitude;

    // Add a bit of randomness for visual effect
    normalized = normalized *
        (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 10) / 10);

    // Limit to valid range
    normalized = normalized.clamp(0.1, 1.0);

    // Shift waveform levels and add new level
    _waveformLevels.removeAt(0);
    _waveformLevels.add(normalized);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    _playbackTimer?.cancel();
    _amplitudeTimer?.cancel();
    _waveformController.dispose();
    _audioRecorder.dispose();
    _stopListening();
    _scrollController.dispose();
    super.dispose();
  }

  // Check and request microphone permission
  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Show error message if permission is denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Microphone permission is required to record audio'),
              duration: Duration(seconds: 5)),
        );
      }
    }
  }

  // Start recording
  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      try {
        // Start recording
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          // Show error if permission is denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Microphone permission is required to record')),
          );
          return;
        }

        // Generate file path for recording
        String path;
        if (kIsWeb) {
          // For web, we don't need a real file path as record package handles it internally
          path = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        } else {
          // For mobile, get a real file path
          final appDir = await getApplicationDocumentsDirectory();
          path = '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }
        
        if (mounted) {
          setState(() {
            _isRecording = true;
            _isPaused = false;
            _recordingDuration = 0;
            _recordedFilePath = path;
            _recordingName = "Recording ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}";
            // Reset emotion analysis results when starting a new recording
            _emotionResult = null;
          });
        }

        // Start the timer to track recording duration
        _startTimer();

        // Start recording
        await _audioRecorder.start(path: path);

        // Start speech to text if available
        if (_speechEnabled) {
          _startListening();
        }
      } catch (e) {
        print('Error starting recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting recording: $e')),
          );
        }
      }
    } else {
      // Stop recording
      try {
        await _audioRecorder.stop();
        _stopTimer();
        _stopListening();
        
        if (mounted) {
          setState(() {
            _isRecording = false;
            _isPaused = false;
          });
        }

        // Analyze the recorded audio for emotions
        _analyzeRecordedAudio();
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  // Analyze the recorded audio for emotions
  Future<void> _analyzeRecordedAudio() async {
    if (_recordedFilePath == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _emotionService.analyzeVoiceEmotion(_recordedFilePath!);
      
      if (mounted) {
        setState(() {
          _emotionResult = result;
          _isAnalyzing = false;
        });
        
        // Scroll to show the analysis results
        if (_scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          });
        }
      }
    } catch (e) {
      print('Error analyzing audio: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing audio: $e')),
        );
      }
    }
  }

  // Start timer for recording duration
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  // Stop timer for recording duration
  void _stopTimer() {
    _timer?.cancel();
  }

  // Play or pause recorded audio
  Future<void> _togglePlayback() async {
    if (_recordedFilePath == null) return;

    if (_isPlayingBack) {
      await _audioPlayer.pause();
      _playbackTimer?.cancel();
    } else {
      // Start from beginning if at the end
      if (_playbackPosition >= _recordingDuration) {
        _playbackPosition = 0;
      }

      // Set position and play
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));

      // Start playback timer
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_playbackPosition < _recordingDuration) {
            _playbackPosition++;
          } else {
            _isPlayingBack = false;
            _playbackTimer?.cancel();
          }
        });
      });
    }

    setState(() {
      _isPlayingBack = !_isPlayingBack;
    });
  }

  // Reset playback to beginning
  Future<void> _restartPlayback() async {
    await _audioPlayer.pause();
    await _audioPlayer.seek(const Duration(seconds: 0));
    setState(() {
      _playbackPosition = 0;
      _isPlayingBack = false;
    });
    _playbackTimer?.cancel();
  }

  // Format seconds into mm:ss format
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Save the recorded audio with emotion analysis and navigate back
  void _saveRecording() {
    if (_recordedFilePath == null) return;

    // Here you would typically save to your database,
    // upload to server, or pass back to previous screen

    // For now we'll show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording saved: $_recordingName'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate back with the file path, transcription, and emotion analysis
    Navigator.of(context).pop({
      'filePath': _recordedFilePath,
      'transcription': _transcription,
      'emotionAnalysis': _emotionResult != null ? {
        'emotion': _emotionResult!.emotion,
        'sentiment': _emotionResult!.sentiment,
        'confidence': _emotionResult!.confidence,
      } : null,
    });
  }

  // Rename the recording
  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempName = _recordingName;

        return AlertDialog(
          title: const Text('Rename Recording'),
          content: TextField(
            onChanged: (value) {
              tempName = value;
            },
            controller: TextEditingController(text: _recordingName),
            decoration: const InputDecoration(
              labelText: 'Recording Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _recordingName =
                      tempName.isEmpty ? "New Recording" : tempName;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
        elevation: 0,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_recordedFilePath != null && !_isRecording)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showRenameDialog,
              tooltip: 'Rename Recording',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Recording name and info
              ProfessionalCard(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _recordingName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? (_isPaused
                                    ? AppColors.warning
                                    : AppColors.error)
                                : AppColors.success,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _isRecording
                                ? (_isPaused ? 'PAUSED' : 'RECORDING')
                                : (_recordedFilePath != null ? 'READY' : 'NEW'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Duration: ${_formatDuration(_recordingDuration)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Emotion Analysis Results Card
              if (_emotionResult != null || _isAnalyzing)
                _buildEmotionAnalysisCard(),

              // Transcription card
              if (_transcription.isNotEmpty || _isRecording)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h, top: 16.h),
                  child: ProfessionalCard(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transcription',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_isTranscribing)
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.tertiary),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          constraints: BoxConstraints(maxHeight: 100.h),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundAlt.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.surfaceDark.withOpacity(0.2),
                            ),
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: SingleChildScrollView(
                            child: Text(
                              _transcription.isNotEmpty
                                  ? _transcription
                                  : _isRecording && _isTranscribing
                                      ? "Listening for speech..."
                                      : "No transcription available.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Waveform Visualization
              Container(
                height: 300.h,
                margin: EdgeInsets.symmetric(vertical: 16.h),
                child: ProfessionalCard(
                  backgroundColor: AppColors.backgroundAlt.withOpacity(0.5),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _waveformController,
                            builder: (context, child) {
                              return Center(
                                child: _isRecording
                                    ? _buildWaveform()
                                    : _recordedFilePath != null
                                        ? _buildPlaybackInterface()
                                        : _buildReadyToRecord(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Control buttons
              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isRecording)
                      // Pause/Resume button
                      ModernButton(
                        text: _isPaused ? 'Resume' : 'Pause',
                        icon: _isPaused ? Icons.play_arrow : Icons.pause,
                        onPressed: _toggleRecording,
                        primaryColor: AppColors.secondary,
                        height: 50.h,
                        width: 120.w,
                      ),

                    // Record/Stop button
                    Material(
                      elevation: 8,
                      shape: const CircleBorder(),
                      color: _isRecording ? AppColors.error : AppColors.tertiary,
                      child: GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 70.w,
                          height: 70.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording
                                        ? AppColors.error
                                        : AppColors.tertiary)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 32.r,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_recordedFilePath != null && !_isRecording)
                      // Save button
                      ModernButton(
                        text: 'Save',
                        icon: Icons.save_alt,
                        onPressed: _saveRecording,
                        primaryColor: AppColors.primary,
                        height: 50.h,
                        width: 120.w,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionAnalysisCard() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: ProfessionalCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emotion Analysis',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_isAnalyzing)
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.tertiary),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            _isAnalyzing 
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40.w,
                          height: 40.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.tertiary),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Analyzing your voice...",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmotionIndicator(
                        'Detected Emotion', 
                        _emotionResult!.emotion,
                        _getEmotionColor(_emotionResult!.emotion)
                      ),
                      SizedBox(height: 12.h),
                      _buildEmotionIndicator(
                        'Sentiment', 
                        _emotionResult!.sentiment,
                        _getSentimentColor(_emotionResult!.sentiment)
                      ),
                      SizedBox(height: 12.h),
                      _buildConfidenceBar(_emotionResult!.confidence),
                      if (_emotionResult!.emotionScores != null)
                        ..._buildEmotionScoreBars(_emotionResult!.emotionScores!),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color, width: 1.w),
          ),
          child: Text(
            value.toUpperCase(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEmotionScoreBars(Map<String, double> scores) {
    // Sort emotions by score (descending)
    final sortedEmotions = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return [
      SizedBox(height: 16.h),
      Text(
        'Emotion Breakdown',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 8.h),
      ...sortedEmotions.take(4).map((entry) { // Only show top 4 emotions
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(entry.value * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: entry.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getEmotionColor(entry.key),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }

  // Widget for the waveform visualization during recording
  Widget _buildWaveform() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.background.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_waveformLevels.length, (index) {
          // Create a pulsing effect when paused
          double level = _isPaused
              ? _waveformLevels[index] * (0.5 + 0.5 * _waveformController.value)
              : _waveformLevels[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: 6.w,
            height: (70.h * level) + 10.h,
            decoration: BoxDecoration(
              color: _isPaused 
                ? AppColors.secondary
                : _getWaveformColor(level),
              borderRadius: BorderRadius.circular(3.r),
            ),
          );
        }),
      ),
    );
  }

  Color _getWaveformColor(double level) {
    // Create a gradient effect based on level
    if (level > 0.8) {
      return AppColors.tertiary;
    } else if (level > 0.4) {
      return AppColors.tertiary.withOpacity(0.8);
    } else {
      return AppColors.tertiary.withOpacity(0.6);
    }
  }

  // Widget for displaying playback controls when recording is complete
  Widget _buildPlaybackInterface() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recording Complete',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(
            Icons.multitrack_audio,
            size: 60.r,
            color: AppColors.primary,
          ),
        ),
        if (_transcription.isNotEmpty &&
            _transcription != 'Listening...' &&
            _transcription != 'No speech detected')
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: Text(
              'Transcription available',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _restartPlayback,
              icon: Icon(Icons.replay, size: 24.r),
              color: AppColors.secondary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
              ),
            ),
            SizedBox(width: 16.w),
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _isPlayingBack
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 48.r,
              ),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Playback progress
        Container(
          width: double.infinity,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              Container(
                width: (_playbackPosition / _recordingDuration) * 320.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${_formatDuration(_playbackPosition)} / ${_formatDuration(_recordingDuration)}',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Widget to show when ready to record but not yet started
  Widget _buildReadyToRecord() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PulseAnimation(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.mic,
              size: 80.r,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Tap the record button to start',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Helper methods for colors
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
        return AppColors.textSecondary;
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
        return AppColors.textSecondary;
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

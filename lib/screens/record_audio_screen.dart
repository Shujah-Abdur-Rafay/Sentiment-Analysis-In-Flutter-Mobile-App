import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/colors.dart';
import '../widgets/professional_components.dart';
import '../widgets/professional_text.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({Key? key}) : super(key: key);

  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _transcription = '';
  bool _isRecording = false;
  Timer? _timer;
  int _recordingDuration = 0;
  double _confidenceLevel = 0.0;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Initialize the speech recognition functionality
  Future<void> _initSpeechRecognizer() async {
    bool available = await _speechToText.initialize();
    setState(() {
      _speechEnabled = available;
    });
  }

  // Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Toggle recording on/off
  Future<void> _toggleRecording() async {
    if (!_speechEnabled) {
      bool available = await _speechToText.initialize();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
        return;
      }
    }

    if (!_isRecording) {
      bool hasMicPermission = await _requestMicrophonePermission();
      if (!hasMicPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });

      // Start listening
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
            _confidenceLevel = result.confidence;
          });
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          // Could use this to show sound level visualization
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      setState(() {
        _isRecording = false;
      });
      _timer?.cancel();
      _speechToText.stop();
    }
  }

  // Clear the current transcription
  void _clearTranscription() {
    setState(() {
      _transcription = '';
    });
  }

  // Save the transcription (would connect to processing logic)
  void _saveTranscription() {
    if (_transcription.isNotEmpty) {
      // Here you would typically save the transcription to be processed
      // by the NLP model or store it for later use
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription saved')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to save')),
      );
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recording'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Recording status and timer
              Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppColors.surfaceDark,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_off,
                          color: _isRecording
                              ? AppColors.tertiary
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _isRecording ? 'Recording' : 'Not Recording',
                          style: TextStyle(
                            color: _isRecording
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: TextStyle(
                        color: _isRecording
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Transcription display
              Expanded(
                child: ProfessionalCard(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: AppColors.surface,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transcription',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        _transcription.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    'Start recording to see transcription here',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : FadeInText(
                                text: _transcription,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  height: 1.5,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              // Confidence meter
              if (_confidenceLevel > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recognition Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: LinearProgressIndicator(
                          value: _confidenceLevel,
                          backgroundColor: AppColors.surfaceDark,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _confidenceLevel > 0.7
                                ? AppColors.tertiary
                                : _confidenceLevel > 0.4
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                          minHeight: 6.0,
                        ),
                      ),
                    ],
                  ),
                ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Clear button
                    ModernButton(
                      onPressed: _clearTranscription,
                      text: 'Clear',
                      icon: Icons.delete_outline,
                      primaryColor: AppColors.secondary,
                      labelColor: Colors.white,
                    ),

                    // Record button
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          height: 68.0,
                          width: 68.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? AppColors.error
                                : AppColors.tertiary,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording
                                        ? AppColors.error
                                        : AppColors.tertiary)
                                    .withOpacity(0.3),
                                blurRadius: 8.0,
                                spreadRadius: 1.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 28.0,
                          ),
                        ),
                      ),
                    ),

                    // Save button
                    ModernButton(
                      onPressed: _saveTranscription,
                      text: 'Save',
                      icon: Icons.save_alt,
                      primaryColor: AppColors.primary,
                      labelColor: Colors.white,
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
}

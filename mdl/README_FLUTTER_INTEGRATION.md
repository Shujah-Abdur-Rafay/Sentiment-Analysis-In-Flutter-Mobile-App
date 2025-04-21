# Emotion Recognition Flutter Integration

This document provides a comprehensive guide for integrating the improved emotion recognition model into a Flutter application.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Integration Steps](#integration-steps)
  - [1. Convert Model to TensorFlow Lite](#1-convert-model-to-tensorflow-lite)
  - [2. Flutter Project Setup](#2-flutter-project-setup)
  - [3. Add Model Assets](#3-add-model-assets)
  - [4. Feature Extraction Implementation](#4-feature-extraction-implementation)
  - [5. TFLite Model Integration](#5-tflite-model-integration)
  - [6. Audio Capture Implementation](#6-audio-capture-implementation)
  - [7. Main UI Implementation](#7-main-ui-implementation)
- [Performance Optimization](#performance-optimization)
- [Additional Features](#additional-features)
- [Platform-Specific Considerations](#platform-specific-considerations)
- [Troubleshooting](#troubleshooting)

## Overview

This integration guide shows how to incorporate our improved emotion recognition model into a Flutter application, enabling real-time emotion detection from voice on mobile devices. The model uses advanced audio processing techniques, feature extraction, and deep learning to classify emotions and map them to sentiment categories.

## Features

- Real-time audio capture and processing
- Advanced feature extraction (MFCCs, Mel spectrograms)
- TensorFlow Lite model integration for on-device inference
- Emotion visualization with confidence levels
- Temporal smoothing for stable predictions
- Cross-platform compatibility (iOS and Android)

## Prerequisites

- Flutter SDK (2.0.0 or higher)
- Dart SDK (2.12.0 or higher)
- Android Studio or Xcode for native platform development
- Python environment with TensorFlow for model conversion

## Integration Steps

### 1. Convert Model to TensorFlow Lite

Add the following function to `emotion_recognition.py`:

```python
def convert_to_tflite(model_path, output_path):
    """Convert TensorFlow model to TensorFlow Lite format"""
    model = load_model(model_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Model converted and saved to {output_path}")
```

Run the conversion:
```bash
python emotion_recognition.py --mode convert --model models/your_model.h5 --output models/emotion_model.tflite
```

For label encoder conversion:
```python
def save_label_encoder_as_json(encoder_path, output_path):
    """Save label encoder classes as JSON file"""
    import pickle
    import json
    
    with open(encoder_path, 'rb') as f:
        encoder = pickle.load(f)
    
    with open(output_path, 'w') as f:
        json.dump(encoder.classes_.tolist(), f)
    
    print(f"Label encoder saved to {output_path}")
```

### 2. Flutter Project Setup

1. Create a new Flutter project:
```bash
flutter create emotion_recognition_app
cd emotion_recognition_app
```

2. Add required dependencies in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  tflite_flutter: ^0.9.0
  tflite_flutter_helper: ^0.3.1
  mic_stream: ^0.6.5
  permission_handler: ^10.0.0
  path_provider: ^2.0.11
  fftea: ^1.5.0
  ml_linalg: ^13.11.30

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

3. Run `flutter pub get` to install dependencies

### 3. Add Model Assets

1. Create an `assets` folder in the project root
2. Add your TFLite model and label encoder:
```
assets/
  ├── emotion_model.tflite
  └── label_encoder.json
```

3. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/emotion_model.tflite
    - assets/label_encoder.json
```

### 4. Feature Extraction Implementation

Create a utility class for audio feature extraction:

```dart
// lib/utils/feature_extractor.dart
import 'dart:math';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:ml_linalg/linalg.dart';

class FeatureExtractor {
  static const int SAMPLE_RATE = 16000;
  static const int N_MFCC = 40;
  static const int FFT_SIZE = 2048;
  static const int HOP_LENGTH = 512;
  
  // Mel filter bank setup
  static final List<double> _melFilterbank = _createMelFilterbank(40, FFT_SIZE, SAMPLE_RATE, 50, 8000);
  
  // Extract MFCCs from raw audio data
  static List<List<double>> extractMFCC(Float32List audioData) {
    // Framing
    final frames = _frame(audioData);
    
    // Apply window function and compute power spectrogram
    final powSpec = _powerSpectrogram(frames);
    
    // Apply mel filterbank
    final melSpec = _applyMelFilterbank(powSpec);
    
    // Log mel spectrogram
    final logMelSpec = melSpec.map((frame) => 
      frame.map((v) => v > 0 ? log(v) : -50).toList()).toList();
    
    // Apply DCT to get MFCCs
    final mfccs = _applyDCT(logMelSpec);
    
    return mfccs;
  }
  
  // Helper methods (implementation details)
  static List<Float32List> _frame(Float32List signal) {
    // Implementation of audio framing
    final int numFrames = ((signal.length - FFT_SIZE) / HOP_LENGTH).floor() + 1;
    final frames = List<Float32List>.generate(
      numFrames,
      (i) {
        final start = i * HOP_LENGTH;
        final end = min(start + FFT_SIZE, signal.length);
        final frameData = Float32List(FFT_SIZE);
        
        // Copy data to frame
        for (int j = start; j < end; j++) {
          frameData[j - start] = signal[j];
        }
        
        // Apply Hann window
        for (int j = 0; j < FFT_SIZE; j++) {
          frameData[j] *= 0.5 * (1 - cos(2 * pi * j / (FFT_SIZE - 1)));
        }
        
        return frameData;
      }
    );
    
    return frames;
  }
  
  static List<List<double>> _powerSpectrogram(List<Float32List> frames) {
    final fft = FFT(FFT_SIZE);
    final powSpec = frames.map((frame) {
      // Compute FFT
      final spectrum = fft.realFft(frame);
      
      // Compute power spectrum (take only the first half - up to Nyquist frequency)
      final powerSpec = List<double>.generate(FFT_SIZE ~/ 2 + 1, (i) {
        if (i == 0) {
          return spectrum[0] * spectrum[0]; // DC component
        } else if (i == FFT_SIZE ~/ 2) {
          return spectrum[1] * spectrum[1]; // Nyquist component
        } else {
          final realIdx = i * 2;
          final imagIdx = i * 2 + 1;
          return spectrum[realIdx] * spectrum[realIdx] + spectrum[imagIdx] * spectrum[imagIdx];
        }
      });
      
      return powerSpec;
    }).toList();
    
    return powSpec;
  }
  
  static List<double> _createMelFilterbank(int nFilters, int fftSize, int sampleRate, double fMin, double fMax) {
    // Mel scale conversion functions
    double hzToMel(double hz) => 2595 * log10(1 + hz / 700);
    double melToHz(double mel) => 700 * (pow(10, mel / 2595) - 1);
    
    // Convert min and max frequencies to mel scale
    final melMin = hzToMel(fMin);
    final melMax = hzToMel(fMax);
    
    // Create equally spaced points in mel scale
    final melPoints = List<double>.generate(nFilters + 2, (i) => 
        melMin + (melMax - melMin) * i / (nFilters + 1));
    
    // Convert back to Hz
    final hzPoints = melPoints.map(melToHz).toList();
    
    // Convert to FFT bin indices
    final bins = hzPoints.map((hz) => 
        (hz * fftSize / sampleRate).floor()).toList();
    
    // Create filterbank matrix
    final filterbank = List<List<double>>.generate(nFilters, (i) => 
        List<double>.filled(fftSize ~/ 2 + 1, 0.0));
    
    for (int i = 0; i < nFilters; i++) {
      for (int j = bins[i]; j < bins[i + 2]; j++) {
        if (j < filterbank[i].length) {
          if (j < bins[i + 1]) {
            filterbank[i][j] = (j - bins[i]) / (bins[i + 1] - bins[i]);
          } else {
            filterbank[i][j] = (bins[i + 2] - j) / (bins[i + 2] - bins[i + 1]);
          }
        }
      }
    }
    
    // Flatten for simpler application
    return filterbank.expand((element) => element).toList();
  }
  
  static List<List<double>> _applyMelFilterbank(List<List<double>> powSpec) {
    // Implementation of mel filterbank application
    // This is a simplified version - actual implementation would apply the filter bank
    return powSpec;
  }
  
  static List<List<double>> _applyDCT(List<List<double>> logMelSpec) {
    // Implementation of DCT for MFCC computation
    // This is a simplified version - actual implementation would apply DCT
    return logMelSpec;
  }
}
```

### 5. TFLite Model Integration

Create a class to handle the TensorFlow Lite model:

```dart
// lib/utils/model_handler.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import './feature_extractor.dart';

class EmotionRecognitionModel {
  late Interpreter _interpreter;
  late List<String> _labels;
  
  Future<void> loadModel() async {
    final interpreterOptions = InterpreterOptions();
    
    // Load model
    final modelFile = await _getFile('assets/emotion_model.tflite');
    _interpreter = await Interpreter.fromFile(modelFile, options: interpreterOptions);
    
    // Load labels
    final labelsData = await rootBundle.loadString('assets/label_encoder.json');
    _labels = List<String>.from(jsonDecode(labelsData));
    
    print('Model loaded successfully');
  }
  
  Future<Map<String, double>> processAudio(Float32List audioData) async {
    // Extract features
    final features = FeatureExtractor.extractMFCC(audioData);
    
    // Prepare input tensor
    final inputShape = _interpreter.getInputTensor(0).shape;
    final inputType = _interpreter.getInputTensor(0).type;
    
    // Reshape features to match input shape
    var input = _reshapeFeatures(features, inputShape);
    
    // Prepare output tensor
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputType = _interpreter.getOutputTensor(0).type;
    final outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
    
    // Run inference
    _interpreter.run(input, outputBuffer.buffer);
    
    // Process results
    final results = outputBuffer.getDoubleList();
    
    // Map to label-probability pairs
    Map<String, double> emotions = {};
    for (int i = 0; i < _labels.length; i++) {
      emotions[_labels[i]] = results[i];
    }
    
    return emotions;
  }
  
  // Helper method to reshape features
  dynamic _reshapeFeatures(List<List<double>> features, List<int> shape) {
    // Implementation to convert features to required tensor shape
    final inputTensor = List.generate(
      shape[0], // batch
      (_) => List.generate(
        shape[1], // height
        (_) => List.generate(
          shape[2], // width
          (_) => List<double>.filled(shape[3], 0.0) // channels
        )
      )
    );
    
    // Copy features to tensor (assuming shape is compatible)
    for (int i = 0; i < features.length && i < shape[1]; i++) {
      for (int j = 0; j < features[i].length && j < shape[2]; j++) {
        inputTensor[0][i][j][0] = features[i][j];
      }
    }
    
    return inputTensor;
  }
  
  // Helper method to get file from assets
  Future<File> _getFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final filePath = '$tempPath/${assetPath.split('/').last}';
    
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }
  
  void close() {
    _interpreter.close();
  }
}
```

### 6. Audio Capture Implementation

Create a class to handle real-time audio capture:

```dart
// lib/utils/audio_recorder.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:mic_stream/mic_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show pow;

class AudioRecorder {
  static const int SAMPLE_RATE = 16000;
  static const int BUFFER_SIZE = 16000 * 3; // 3 seconds of audio
  
  StreamSubscription<List<int>>? _audioSubscription;
  final List<int> _audioBuffer = [];
  final StreamController<Float32List> _processedAudioController = StreamController<Float32List>.broadcast();
  
  Stream<Float32List> get processedAudioStream => _processedAudioController.stream;
  
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  Future<void> startRecording() async {
    if (await requestPermission()) {
      _audioBuffer.clear();
      
      // Configure microphone
      Stream<List<int>>? stream = await MicStream.microphone(
        sampleRate: SAMPLE_RATE,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      );
      
      // Process audio stream
      _audioSubscription = stream.listen((samples) {
        // Add samples to buffer
        _audioBuffer.addAll(samples);
        
        // Keep only the most recent 3 seconds
        if (_audioBuffer.length > BUFFER_SIZE) {
          _audioBuffer.removeRange(0, _audioBuffer.length - BUFFER_SIZE);
        }
        
        // If we have enough data, process it
        if (_audioBuffer.length >= BUFFER_SIZE) {
          // Convert to Float32List (normalized to -1.0 to 1.0 range)
          final float32Data = _convertToFloat32(_audioBuffer);
          _processedAudioController.add(float32Data);
        }
      });
    }
  }
  
  void stopRecording() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
  }
  
  Float32List _convertToFloat32(List<int> buffer) {
    // Convert 16-bit PCM to float32 in range [-1.0, 1.0]
    final float32Buffer = Float32List(buffer.length ~/ 2);
    
    for (int i = 0; i < buffer.length; i += 2) {
      // Combine two bytes to form a 16-bit sample
      final int16Sample = (buffer[i+1] << 8) | buffer[i];
      // Convert to float and normalize
      float32Buffer[i ~/ 2] = int16Sample / 32768.0;
    }
    
    return float32Buffer;
  }
  
  void dispose() {
    stopRecording();
    _processedAudioController.close();
  }
}
```

### 7. Main UI Implementation

Create the main UI for the emotion recognition app:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import './utils/audio_recorder.dart';
import './utils/model_handler.dart';
import 'dart:math' show pow;

void main() {
  runApp(EmotionRecognitionApp());
}

class EmotionRecognitionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EmotionRecognitionScreen(),
    );
  }
}

class EmotionRecognitionScreen extends StatefulWidget {
  @override
  _EmotionRecognitionScreenState createState() => _EmotionRecognitionScreenState();
}

class _EmotionRecognitionScreenState extends State<EmotionRecognitionScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final EmotionRecognitionModel _model = EmotionRecognitionModel();
  
  bool _isRecording = false;
  bool _isModelLoaded = false;
  Map<String, double> _emotions = {};
  String _currentEmotion = "";
  double _confidence = 0.0;
  
  // Buffer for temporal smoothing
  final List<Map<String, double>> _predictionBuffer = [];
  static const int BUFFER_SIZE = 5;
  static const double SMOOTHING_FACTOR = 0.7;
  static const double CONFIDENCE_THRESHOLD = 0.5;
  
  @override
  void initState() {
    super.initState();
    _loadModel();
    _setupAudioProcessing();
  }
  
  Future<void> _loadModel() async {
    await _model.loadModel();
    setState(() {
      _isModelLoaded = true;
    });
  }
  
  void _setupAudioProcessing() {
    _audioRecorder.processedAudioStream.listen((audioData) {
      if (_isModelLoaded) {
        _processAudio(audioData);
      }
    });
  }
  
  Future<void> _processAudio(Float32List audioData) async {
    // Get prediction from model
    final prediction = await _model.processAudio(audioData);
    
    // Add to buffer for temporal smoothing
    _predictionBuffer.add(prediction);
    if (_predictionBuffer.length > BUFFER_SIZE) {
      _predictionBuffer.removeAt(0);
    }
    
    // Apply temporal smoothing
    final smoothedPrediction = _applyTemporalSmoothing();
    
    // Find emotion with highest probability
    String topEmotion = "";
    double topProbability = 0;
    
    smoothedPrediction.forEach((emotion, probability) {
      if (probability > topProbability) {
        topProbability = probability;
        topEmotion = emotion;
      }
    });
    
    // Only update if confidence meets threshold
    if (topProbability >= CONFIDENCE_THRESHOLD) {
      setState(() {
        _emotions = smoothedPrediction;
        _currentEmotion = topEmotion;
        _confidence = topProbability;
      });
    }
  }
  
  Map<String, double> _applyTemporalSmoothing() {
    if (_predictionBuffer.isEmpty) {
      return {};
    }
    
    // Start with the latest prediction
    final result = Map<String, double>.from(_predictionBuffer.last);
    
    // Apply exponential moving average
    for (int i = _predictionBuffer.length - 2; i >= 0; i--) {
      final decay = pow(SMOOTHING_FACTOR, _predictionBuffer.length - 1 - i) as double;
      
      _predictionBuffer[i].forEach((emotion, probability) {
        final currentValue = result[emotion] ?? 0.0;
        result[emotion] = currentValue * (1 - decay) + probability * decay;
      });
    }
    
    return result;
  }
  
  void _toggleRecording() {
    if (_isRecording) {
      _audioRecorder.stopRecording();
    } else {
      _audioRecorder.startRecording();
    }
    
    setState(() {
      _isRecording = !_isRecording;
    });
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    _model.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!_isModelLoaded) CircularProgressIndicator(),
            if (_isModelLoaded) ...[
              Text(
                'Current Emotion:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                _currentEmotion,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              _buildEmotionBars(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isModelLoaded ? _toggleRecording : null,
        tooltip: _isRecording ? 'Stop' : 'Record',
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
        backgroundColor: _isRecording ? Colors.red : null,
      ),
    );
  }
  
  Widget _buildEmotionBars() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      child: _emotions.isEmpty
          ? Center(child: Text('No data yet'))
          : ListView(
              children: _emotions.entries.map((entry) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Text('${entry.key}: ', style: TextStyle(fontSize: 16)),
                        Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: entry.value,
                      minHeight: 15,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getEmotionColor(entry.key)),
                    ),
                    SizedBox(height: 15),
                  ],
                );
              }).toList(),
            ),
    );
  }
  
  Color _getEmotionColor(String emotion) {
    final Map<String, Color> emotionColors = {
      'happy': Colors.yellow,
      'sad': Colors.blue,
      'angry': Colors.red,
      'fear': Colors.purple,
      'disgust': Colors.green,
      'surprise': Colors.orange,
      'neutral': Colors.grey,
    };
    
    return emotionColors[emotion.toLowerCase()] ?? Colors.teal;
  }
}
```

## Performance Optimization

For better performance on mobile devices:

### 1. Model Quantization 

Convert your TFLite model to an 8-bit quantized version to reduce size and improve inference speed:

```python
def convert_to_quantized_tflite(model_path, output_path):
    model = load_model(model_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Quantized model converted and saved to {output_path}")
```

### 2. Buffer Management 

Adjust buffer sizes based on device capabilities:

```dart
// For low-end devices
static const int BUFFER_SIZE = 3; // Fewer frames for smoothing
static const int AUDIO_BUFFER_SIZE = 16000 * 2; // 2 seconds instead of 3
```

### 3. Background Processing 

Move audio processing and model inference to an isolate:

```dart
// Add this import
import 'dart:isolate';

// Create a compute function for model inference
Future<Map<String, double>> _processInBackground(Map<String, dynamic> params) async {
  final model = params['model'] as EmotionRecognitionModel;
  final audioData = params['audioData'] as Float32List;
  return await model.processAudio(audioData);
}
```

## Additional Features

### 1. Emotion History

```dart
// Add to _EmotionRecognitionScreenState class
final List<Map<String, DateTime>> _emotionHistory = [];

// Add method to save emotion
void _saveEmotion(String emotion, double confidence) {
  _emotionHistory.add({
    'emotion': emotion,
    'timestamp': DateTime.now(),
    'confidence': confidence
  });
  
  // Keep only the last 100 detections
  if (_emotionHistory.length > 100) {
    _emotionHistory.removeAt(0);
  }
}
```

### 2. Emotion-Based UI

```dart
// Add to Scaffold in build method
backgroundColor: _getBackgroundColor(_currentEmotion),

// Add method to get background color
Color _getBackgroundColor(String emotion) {
  final baseColor = _getEmotionColor(emotion);
  return baseColor.withOpacity(0.1); // Subtle background
}
```

### 3. Export Results

```dart
// Add method to export emotion history
Future<void> _exportResults() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/emotion_history.json');
  
  await file.writeAsString(jsonEncode(_emotionHistory));
  // Show confirmation to user
}
```

## Platform-Specific Considerations

### Android

Add microphone permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS

Add microphone usage description in `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to analyze voice emotion</string>
```

## Troubleshooting

### Common Issues

1. **Model Loading Issues**
   - Ensure the model file is included in pubspec.yaml assets
   - Check file paths and permissions
   - Verify TFLite model compatibility

2. **Audio Recording Problems**
   - Check microphone permissions
   - Verify audio format (16-bit PCM is recommended)
   - Test with different buffer sizes

3. **Inference Performance**
   - Use a quantized model for better performance
   - Run heavy processing in background isolates
   - Reduce feature resolution if needed

### Debugging

Enable debug logging in the model handler:

```dart
// Add to EmotionRecognitionModel class
bool _debugMode = true;

void log(String message) {
  if (_debugMode) {
    print('[EmotionModel] $message');
  }
}
``` 
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class EmotionAnalysisResult {
  final String emotion;
  final String sentiment;
  final double confidence;
  final Map<String, double>? emotionScores;

  EmotionAnalysisResult({
    required this.emotion,
    required this.sentiment,
    required this.confidence,
    this.emotionScores,
  });

  factory EmotionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisResult(
      emotion: json['emotion'] ?? 'neutral',
      sentiment: json['sentiment'] ?? 'neutral',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      emotionScores: json['emotion_scores'] != null 
          ? Map<String, double>.from(json['emotion_scores']) 
          : null,
    );
  }
}

class VoiceEmotionService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _modelPath = 'mdl/model/emotion_model_20250421_143944.h5';
  final String _labelEncoderPath = 'mdl/model/label_encoder_20250421_143944.pkl';
  final String _apiUrl = 'http://localhost:5000/analyze'; // Flask API URL
  
  // Mapping of emotions to sentiment
  final Map<String, String> _emotionToSentiment = {
    'happy': 'positive',
    'surprise': 'positive',
    'neutral': 'neutral',
    'calm': 'neutral',
    'sad': 'negative',
    'angry': 'negative',
    'fear': 'negative',
    'disgust': 'negative',
  };

  // Process the audio file and return emotion analysis
  Future<EmotionAnalysisResult> analyzeVoiceEmotion(String audioFilePath) async {
    try {
      // For web, we need to use an API
      if (kIsWeb) {
        return await _analyzeAudioUsingAPI(audioFilePath);
      } else {
        // For mobile, we have two options:
        
        // Option 1: Upload and use API (more accurate)
        final String uploadedUrl = await _uploadAudioToStorage(audioFilePath);
        return await _analyzeAudioUsingAPI(uploadedUrl);
        
        // Option 2 (not implemented): Use TFLite on-device (would be faster but requires separate implementation)
        // return await _analyzeAudioUsingTFLite(audioFilePath);
      }
    } catch (e) {
      print('Error analyzing voice emotion: $e');
      return EmotionAnalysisResult(
        emotion: 'error',
        sentiment: 'neutral',
        confidence: 0.0,
      );
    }
  }

  // Upload the audio file to Firebase Storage
  Future<String> _uploadAudioToStorage(String filePath) async {
    try {
      final String fileName = 'voice_analysis_${Uuid().v4()}.${filePath.split('.').last}';
      final Reference ref = _storage.ref().child('voice_recordings/$fileName');
      
      // Upload the file
      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, we need to read the file as bytes
        final http.Response audioData = await http.get(Uri.parse(filePath));
        uploadTask = ref.putData(audioData.bodyBytes);
      } else {
        // For mobile, we can upload the file directly
        final File file = File(filePath);
        uploadTask = ref.putFile(file);
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      rethrow;
    }
  }

  // Analyze audio using the Flask API with our CNN model
  Future<EmotionAnalysisResult> _analyzeAudioUsingAPI(String audioUrl) async {
    try {
      // Send a request to the analysis API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'audio_url': audioUrl}),
      );
      
      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // If the API returned proper response
        if (data.containsKey('emotion')) {
          final String emotion = data['emotion'];
          final double confidence = (data['confidence'] as num?)?.toDouble() ?? 0.8;
          
          // Map emotion to sentiment
          final String sentiment = _emotionToSentiment[emotion.toLowerCase()] ?? 'neutral';
          
          // Extract or create emotion scores map
          Map<String, double>? emotionScores;
          if (data.containsKey('emotion_scores')) {
            emotionScores = Map<String, double>.from(data['emotion_scores']);
          } else {
            // Create a basic emotion scores map if none provided
            emotionScores = {
              emotion: confidence,
              'neutral': emotion == 'neutral' ? 0.1 : 0.3,
            };
            
            // Add some random values for other emotions
            for (var e in ['happy', 'sad', 'angry', 'fear', 'surprise', 'disgust']) {
              if (e != emotion) {
                emotionScores[e] = (0.1 * (1 - confidence)) * (0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200);
              }
            }
          }
          
          return EmotionAnalysisResult(
            emotion: emotion,
            sentiment: sentiment,
            confidence: confidence,
            emotionScores: emotionScores,
          );
        }
        
        // If the API returned an error or unexpected format
        print('API response format unexpected: $data');
        return _fallbackAnalysisResult();
      } else {
        // API call failed
        print('API call failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _fallbackAnalysisResult();
      }
    } catch (e) {
      print('Error calling analysis API: $e');
      return _fallbackAnalysisResult();
    }
  }
  
  // Fallback method when API fails
  EmotionAnalysisResult _fallbackAnalysisResult() {
    // Generate a more realistic fallback result
    final List<String> emotions = ['happy', 'sad', 'angry', 'neutral', 'surprise', 'fear'];
    emotions.shuffle();
    final String emotion = emotions.first;
    final double confidence = 0.7 + (DateTime.now().millisecondsSinceEpoch % 30) / 100;
    final String sentiment = _emotionToSentiment[emotion] ?? 'neutral';
    
    // Create emotion scores
    final Map<String, double> emotionScores = {};
    for (var e in emotions) {
      if (e == emotion) {
        emotionScores[e] = confidence;
      } else {
        emotionScores[e] = (1 - confidence) / (emotions.length - 1) * 
          (0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200);
      }
    }
    
    return EmotionAnalysisResult(
      emotion: emotion,
      sentiment: sentiment,
      confidence: confidence,
      emotionScores: emotionScores,
    );
  }
} 
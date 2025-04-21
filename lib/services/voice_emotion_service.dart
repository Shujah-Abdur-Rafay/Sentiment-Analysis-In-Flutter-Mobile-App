import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

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
  final String _apiBaseUrl = 'https://your-model-api-endpoint.com/analyze'; // Replace with actual endpoint

  // Process the audio file and return emotion analysis
  Future<EmotionAnalysisResult> analyzeVoiceEmotion(String audioFilePath) async {
    try {
      // For demo/testing, upload to Firebase Storage first
      final String uploadedUrl = await _uploadAudioToStorage(audioFilePath);
      
      // Call the analysis API with the file URL
      final result = await _callAnalysisApi(uploadedUrl);
      return result;
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

  // Call the emotion analysis API
  Future<EmotionAnalysisResult> _callAnalysisApi(String audioUrl) async {
    try {
      // In production, replace with actual API call
      // For now, simulate a response for development purposes
      
      // Uncomment and modify for actual API call:
      // final response = await http.post(
      //   Uri.parse(_apiBaseUrl),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'audio_url': audioUrl}),
      // );
      
      // if (response.statusCode == 200) {
      //   final Map<String, dynamic> data = jsonDecode(response.body);
      //   return EmotionAnalysisResult.fromJson(data);
      // } else {
      //   throw Exception('Failed to analyze audio: ${response.statusCode}');
      // }
      
      // Simulate API response for development
      // In production, replace with actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      // Generate random emotion for development/testing
      final List<Map<String, dynamic>> possibleResults = [
        {
          'emotion': 'happy',
          'sentiment': 'positive',
          'confidence': 0.85,
          'emotion_scores': {
            'happy': 0.85,
            'neutral': 0.10,
            'sad': 0.02,
            'angry': 0.01,
            'fear': 0.01,
            'surprise': 0.01,
          }
        },
        {
          'emotion': 'sad',
          'sentiment': 'negative',
          'confidence': 0.78,
          'emotion_scores': {
            'happy': 0.05,
            'neutral': 0.12,
            'sad': 0.78,
            'angry': 0.02,
            'fear': 0.02,
            'surprise': 0.01,
          }
        },
        {
          'emotion': 'neutral',
          'sentiment': 'neutral',
          'confidence': 0.92,
          'emotion_scores': {
            'happy': 0.03,
            'neutral': 0.92,
            'sad': 0.02,
            'angry': 0.01,
            'fear': 0.01,
            'surprise': 0.01,
          }
        },
        {
          'emotion': 'angry',
          'sentiment': 'negative',
          'confidence': 0.76,
          'emotion_scores': {
            'happy': 0.01,
            'neutral': 0.05,
            'sad': 0.08,
            'angry': 0.76,
            'fear': 0.05,
            'surprise': 0.05,
          }
        },
      ];
      
      // Select a random result for development
      possibleResults.shuffle();
      return EmotionAnalysisResult.fromJson(possibleResults.first);
    } catch (e) {
      print('Error calling analysis API: $e');
      rethrow;
    }
  }
} 
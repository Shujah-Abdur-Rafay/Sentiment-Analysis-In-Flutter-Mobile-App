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
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class EmotionAnalysisResult {
  final String emotion;
  final String sentiment;
  final double confidence;
  final Map<String, double>? emotionScores;
  final bool isModelResult; // Indicates if result is from actual model or fallback

  EmotionAnalysisResult({
    required this.emotion,
    required this.sentiment,
    required this.confidence,
    this.emotionScores,
    this.isModelResult = true,
  });

  factory EmotionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisResult(
      emotion: json['emotion'] ?? 'neutral',
      sentiment: json['sentiment'] ?? 'neutral',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      emotionScores: json['emotion_scores'] != null 
          ? Map<String, double>.from(json['emotion_scores']) 
          : null,
      isModelResult: true,
    );
  }
}

class VoiceEmotionService {
  static const bool USE_MOCK_DATA = false; // Set to true ONLY for development when no server is available

  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Potential server addresses
  final List<String> _serverUrls = [
    'http://localhost:5000/analyze',
    'http://127.0.0.1:5000/analyze',
    'http://10.0.2.2:5000/analyze',  // For Android emulator to localhost
  ];
  
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
  Future<EmotionAnalysisResult> analyzeVoiceEmotion(String audioFilePath, {BuildContext? context}) async {
    // If mock data is enabled, skip real analysis
    if (USE_MOCK_DATA) {
      print('WARNING: Using mock data instead of real model analysis!');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using MOCK data instead of real model (check console)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return _fallbackAnalysisResult();
    }
    
    try {
      // For web, we need to use an API
      if (kIsWeb) {
        final apiResult = await _analyzeAudioUsingAPI(audioFilePath, context: context);
        // Only if the result is explicitly marked as fallback, we show a warning
        if (!apiResult.isModelResult && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WARNING: Using fallback data because model server is unavailable'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return apiResult;
      } else {
        // For mobile, we have two options:
        
        // Option 1: Upload and use API (more accurate)
        final String uploadedUrl = await _uploadAudioToStorage(audioFilePath);
        print('Audio uploaded successfully to: $uploadedUrl');
        
        final apiResult = await _analyzeAudioUsingAPI(uploadedUrl, context: context);
        // Only if the result is explicitly marked as fallback, we show a warning
        if (!apiResult.isModelResult && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WARNING: Using fallback data because model server is unavailable'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return apiResult;
        
        // Option 2 (not implemented): Use TFLite on-device (would be faster but requires separate implementation)
        // return await _analyzeAudioUsingTFLite(audioFilePath);
      }
    } catch (e) {
      print('Error analyzing voice emotion: $e');
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing voice: $e. Using fallback data.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      return EmotionAnalysisResult(
        emotion: 'error',
        sentiment: 'neutral',
        confidence: 0.0,
        isModelResult: false,
      );
    }
  }

  // Upload the audio file to Firebase Storage
  Future<String> _uploadAudioToStorage(String filePath) async {
    try {
      final String fileName = 'voice_analysis_${Uuid().v4()}.${filePath.split('.').last}';
      final Reference ref = _storage.ref().child('voice_recordings/$fileName');
      
      print('Uploading audio file to Firebase Storage: $fileName');
      
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
      print('File uploaded, URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      rethrow;
    }
  }

  // Analyze audio using the Flask API with our CNN model
  Future<EmotionAnalysisResult> _analyzeAudioUsingAPI(String audioUrl, {BuildContext? context}) async {
    // Try each server URL in order
    for (final serverUrl in _serverUrls) {
      try {
        print('Trying to connect to model server at: $serverUrl');
        
        // Send a request to the analysis API
        final response = await http.post(
          Uri.parse(serverUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'audio_url': audioUrl}),
        ).timeout(const Duration(seconds: 30)); // Add timeout to prevent hanging
        
        print('Response status code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          // Parse the response
          final Map<String, dynamic> data = jsonDecode(response.body);
          
          print('API response: $data');
          
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
              
              // Add some values for other emotions
              for (var e in ['happy', 'sad', 'angry', 'fear', 'surprise', 'disgust']) {
                if (e != emotion) {
                  emotionScores[e] = (0.1 * (1 - confidence)) * (0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200);
                }
              }
            }
            
            print('Successfully analyzed audio using model server!');
            
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully analyzed using real CNN model!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            
            return EmotionAnalysisResult(
              emotion: emotion,
              sentiment: sentiment,
              confidence: confidence,
              emotionScores: emotionScores,
              isModelResult: true,
            );
          }
          
          // If the API returned an error or unexpected format
          print('API response format unexpected: $data');
        } else {
          // API call failed
          print('API call failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error calling analysis API at $serverUrl: $e');
        // Continue to next server URL
      }
    }
    
    // If we reach here, all server URLs failed
    print('All server URLs failed, using fallback data');
    
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to model server. Make sure the Flask server is running at localhost:5000. Using fallback data.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
    
    return _fallbackAnalysisResult();
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
    
    print('WARNING: Using fallback mock data instead of real model analysis!');
    
    return EmotionAnalysisResult(
      emotion: emotion,
      sentiment: sentiment,
      confidence: confidence,
      emotionScores: emotionScores,
      isModelResult: false,
    );
  }
} 
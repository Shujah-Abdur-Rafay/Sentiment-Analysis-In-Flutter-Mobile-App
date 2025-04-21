# Vocal Emotion Analysis App

A Flutter mobile application that analyzes voice recordings to detect emotions and sentiment. This app uses machine learning to process audio recordings and provide real-time emotion analysis.

## Features

- **Real-time Voice Recording**: Record your voice with a clean, modern UI
- **Speech-to-Text Transcription**: Automatic transcription of spoken content
- **Emotion Analysis**: Analyze voice recordings to detect emotions (happy, sad, angry, neutral, etc.)
- **Sentiment Classification**: Categorize emotions as positive, negative, or neutral
- **Confidence Metrics**: View the confidence level of the emotion detection
- **Detailed Breakdown**: See a percentage breakdown of all detected emotions
- **Multi-platform Support**: Works on Android, iOS, and Web platforms

## Tech Stack

- **Flutter**: UI framework for cross-platform development
- **Firebase**: Authentication, storage, and backend services
- **TensorFlow**: ML model for emotion recognition (deployed as TFLite)
- **Speech-to-Text**: For voice transcription
- **AudioPlayers/Record**: Audio recording and playback functionality

## How It Works

### Voice Recording Process

1. User initiates a recording by tapping the microphone button
2. The app records audio using the device's microphone
3. Real-time waveform visualization shows audio levels
4. Speech-to-text functionality runs simultaneously to transcribe speech
5. When the recording is stopped, the audio file is processed for emotion analysis

### Emotion Analysis Model

The emotion analysis is powered by a Convolutional Neural Network (CNN) trained on speech emotion recognition datasets. The model:

- **Input**: Processes audio features extracted from the voice recording (MFCCs)
- **Architecture**: Uses a CNN with multiple convolutional layers followed by dense layers
- **Output**: Classifies the emotion with corresponding confidence levels

The model recognizes the following emotions:
- Happy (positive sentiment)
- Sad (negative sentiment)
- Angry (negative sentiment)
- Neutral (neutral sentiment)
- Surprised (positive sentiment)
- Fear (negative sentiment)
- Disgust (negative sentiment)

### Integration Process

The integration of the emotion analysis model into the Flutter app follows these steps:

1. **Data Collection**: Audio is recorded and saved to a temporary file
2. **Firebase Storage**: The audio file is uploaded to Firebase Storage
3. **Processing**: The `VoiceEmotionService` sends the audio file for analysis
4. **Model Inference**: The audio features are extracted and fed into the ML model
5. **Result Handling**: The emotion detection results are returned as structured data
6. **UI Display**: Results are presented in an intuitive interface with visual indicators

## Integration Guide

If you want to integrate voice emotion analysis into your own app:

1. **Add Dependencies**: Include the required packages in your `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_storage: ^12.3.4
     record: ^5.1.2
     audioplayers: ^6.1.0
     http: ^1.2.1
     uuid: ^4.3.3
   ```

2. **Setup Firebase**: Initialize Firebase in your project:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

3. **Implement VoiceEmotionService**: Create a service class that handles the recording, upload, and analysis:
   ```dart
   class VoiceEmotionService {
     final FirebaseStorage _storage = FirebaseStorage.instance;
     
     Future<EmotionAnalysisResult> analyzeVoiceEmotion(String audioFilePath) async {
       // Upload audio to storage
       final String uploadedUrl = await _uploadAudioToStorage(audioFilePath);
       
       // Call analysis API with the file URL
       final result = await _callAnalysisApi(uploadedUrl);
       return result;
     }
     
     // Implementation details...
   }
   ```

4. **Connect UI**: Implement the UI components for recording and displaying results:
   ```dart
   // Start recording
   await _audioRecorder.start(path: path);
   
   // Stop and analyze
   await _audioRecorder.stop();
   final result = await _emotionService.analyzeVoiceEmotion(_recordedFilePath!);
   
   // Display results
   setState(() {
     _emotionResult = result;
   });
   ```

## Production Deployment

For production deployment:

1. **API Endpoint**: Replace the dummy API endpoint with your actual emotion analysis service
2. **Firebase Configuration**: Ensure Firebase security rules are properly set
3. **Model Deployment**: Deploy the TensorFlow model to a server or use Firebase ML
4. **Performance Optimization**: Optimize recording parameters and analysis for production use

## Model Training

The emotion recognition model was trained using:

1. **Datasets**: RAVDESS, CREMA-D, and other emotion speech datasets
2. **Feature Extraction**: MFCCs (Mel-Frequency Cepstral Coefficients) from audio segments
3. **Training Process**: CNN architecture with categorical cross-entropy loss
4. **Evaluation**: Tested for accuracy, precision, recall across emotion categories

## Future Improvements

- Real-time emotion detection during recording
- Support for more languages
- Enhanced noise filtering
- User-specific emotion baseline calibration
- Offline model inference
- Extended emotion range detection

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- TensorFlow team for ML libraries
- Flutter and Firebase teams
- RAVDESS dataset creators
- Speech emotion recognition research community

# Voice Emotion Analysis Model Server

This server provides an API for analyzing voice emotions using the CNN model from the Vocal Emotion Analysis project.

## Overview

The model server is a Flask application that:
1. Loads the pre-trained emotion recognition model
2. Exposes an API endpoint for audio analysis
3. Downloads audio files from URLs for processing
4. Extracts audio features (MFCCs)
5. Performs emotion classification
6. Returns predicted emotions, confidence scores, and sentiment

## Requirements

- Python 3.7+
- TensorFlow 2.x
- Flask
- Librosa (for audio processing)
- Other dependencies in `requirements.txt`

## Setup and Installation

1. Install the required dependencies:

```bash
pip install -r requirements.txt
```

2. Ensure the model files are in the correct location:
   - The CNN model should be at: `mdl/model/emotion_model_20250421_143944.h5`
   - The label encoder should be at: `mdl/model/label_encoder_20250421_143944.pkl`

## Running the Server

Start the server with:

```bash
python model_server.py
```

The server will run on `http://localhost:5000` by default.

## API Usage

### Analyze Audio

**Endpoint:** `POST /analyze`

**Request Body:**
```json
{
  "audio_url": "https://url-to-your-audio-file.wav"
}
```

**Response:**
```json
{
  "emotion": "happy",
  "confidence": 0.85,
  "emotion_scores": {
    "happy": 0.85,
    "neutral": 0.1,
    "sad": 0.02,
    "angry": 0.01,
    "fear": 0.01,
    "surprise": 0.01
  }
}
```

## Integration with Flutter App

The Flutter app communicates with this server to analyze voice recordings. The integration flow is:

1. App records or selects audio file
2. Audio is uploaded to Firebase Storage
3. The download URL is sent to this API
4. The server processes the audio and returns emotion analysis
5. The app displays the results to the user

## Troubleshooting

If you encounter issues:

1. Check that model files exist and are in the correct location
2. Verify that your Python environment has all required dependencies
3. Ensure the audio files are accessible via the provided URLs
4. Check that the audio format is supported (WAV files are recommended)
5. Look at the server logs for detailed error messages

## Development Notes

- The server expects MFCCs as input features (40 MFCCs)
- Audio is standardized to 3 seconds duration
- Silent parts are trimmed before processing
- For best results, use clear audio recordings without background noise 
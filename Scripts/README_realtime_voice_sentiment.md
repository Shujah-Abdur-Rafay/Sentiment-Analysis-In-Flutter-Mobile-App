# Real-time Voice Sentiment Analysis

This script performs real-time sentiment analysis on your voice input through the microphone, classifying the emotional content as positive, negative, or neutral.

## Requirements

- Python 3.6+
- Required packages:
  ```
  numpy
  librosa
  tensorflow
  scikit-learn
  pyaudio
  scipy
  ```

## Installation

1. Install the required dependencies:
   ```bash
   pip install numpy librosa tensorflow scikit-learn pyaudio scipy
   ```

   Note: PyAudio installation might be tricky on some systems:
   - **Windows**: You might need Microsoft Visual C++ Build Tools
   - **macOS**: Try `brew install portaudio` first
   - **Linux**: Install `portaudio19-dev` and `python-pyaudio` packages using your package manager

2. Make sure you have a trained model in the `models/` directory. If you don't have one yet, train a model using the `emotion_recognition.py` script.

## Usage

### Basic Usage

Start real-time voice analysis:

```bash
python realtime_voice_sentiment.py
```

This will listen to your microphone and analyze your voice sentiment in real-time.

### Advanced Options

```bash
# Save audio clips of different sentiments
python realtime_voice_sentiment.py --save-clips --clips-dir my_voice_clips

# Run for a specific duration (60 seconds)
python realtime_voice_sentiment.py --duration 60

# Use a different feature extraction method
python realtime_voice_sentiment.py --feature melspec
```

### Command-line Arguments

| Argument | Description |
|----------|-------------|
| `--model` | Path to a specific model file (default: most recent in models/) |
| `--encoder` | Path to a specific label encoder file (default: models/label_encoder.pkl) |
| `--feature` | Feature extraction method to use: "mfcc", "melspec", or "combined" (default: mfcc) |
| `--save-clips` | Flag to save audio clips when sentiment changes |
| `--clips-dir` | Directory to save audio clips (default: voice_clips/) |
| `--duration` | Duration in seconds to run analysis (default: unlimited) |

## Output

The script continuously updates the detected emotion and sentiment on the console:

```
Starting real-time voice sentiment analysis...
Using model: models/sentiment_model_20250420_144941.h5
Loading model...
Loading label encoder...
Recording started... Speak now
Press Ctrl+C to stop
Voice detected: male_happy (Sentiment: positive) - Confidence: 85.4%
```

When you stop the analysis (using Ctrl+C), it shows a summary of the detected sentiments over time:

```
Stopping real-time analysis...
Recording stopped

Analysis Summary:
----------------
1. 14:58:26 - female_neutral (Sentiment: neutral) - Confidence: 78.3%
2. 14:58:35 - male_happy (Sentiment: positive) - Confidence: 85.4%
3. 14:58:42 - male_angry (Sentiment: negative) - Confidence: 92.1%
```

## Feature Extraction Methods

- **MFCC**: Mel-Frequency Cepstral Coefficients (default, good for speech)
- **Melspec**: Mel spectrogram (captures more tonal information)
- **Combined**: Combines both MFCC and Mel spectrogram features for potentially better results

## Saving Audio Clips

With the `--save-clips` option, the script will save audio clips to disk whenever:
- Your sentiment changes (e.g., from neutral to positive)
- At least 10 seconds have passed since the last saved clip

Clips are saved with filenames including the timestamp and detected sentiment:
`sentiment_positive_20250420_145835.wav`

## Tips for Best Results

1. Use a good quality microphone
2. Speak clearly and naturally
3. Minimize background noise
4. Try different emotions with varying intensities
5. Start with neutral speech and transition to different emotions

## Troubleshooting

- If you encounter microphone access issues, make sure your system allows microphone access to the application
- If PyAudio fails to initialize, check your audio drivers and ensure your microphone is properly connected
- For low confidence scores, try speaking more clearly or adjusting your microphone volume
- If no voice is detected, check that your microphone is working and properly selected as the default input device 
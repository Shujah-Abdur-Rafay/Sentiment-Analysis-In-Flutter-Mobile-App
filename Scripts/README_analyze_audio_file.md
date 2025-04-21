# Audio File Sentiment Analysis

This script performs sentiment analysis on audio files using a trained deep learning model. It extracts audio features and classifies the emotional content as positive, negative, or neutral.

## Requirements

- Python 3.6+
- Required packages:
  ```
  numpy
  librosa
  tensorflow
  scikit-learn
  ```

## Installation

1. Ensure you have the required dependencies:
   ```bash
   pip install numpy librosa tensorflow scikit-learn
   ```

2. Make sure you have a trained model in the `models/` directory. If you don't have one yet, train a model using the `emotion_recognition.py` script.

## Usage

### Basic Usage

Analyze a single audio file:

```bash
python analyze_audio_file.py path/to/your/audio_file.wav
```

### Advanced Options

```bash
python analyze_audio_file.py path/to/your/audio_file.wav --feature melspec --model models/your_custom_model.h5 --encoder models/your_custom_encoder.pkl
```

### Command-line Arguments

| Argument | Description |
|----------|-------------|
| `file` | Path to the audio file for analysis (required) |
| `--model` | Path to a specific model file (default: most recent in models/) |
| `--encoder` | Path to a specific label encoder file (default: models/label_encoder.pkl) |
| `--feature` | Feature extraction method to use: "mfcc", "melspec", or "combined" (default: mfcc) |

## Output

The script displays the following information:

```
Analyzing file: your_audio_file.wav
Using model: models/sentiment_model_XXXXXXXX_XXXXXX.h5
Loading audio file...
Extracting mfcc features...
Predicting sentiment...

Results:
Detected emotion: male_happy
Sentiment category: positive
Confidence: 92.4%
Analysis completed in 1.24 seconds
```

## Supported Audio Formats

The script supports all audio formats that librosa can read, including:
- WAV
- MP3
- FLAC
- OGG
- and more

## Feature Extraction Methods

- **MFCC**: Mel-Frequency Cepstral Coefficients (default, good for speech)
- **Melspec**: Mel spectrogram (captures more tonal information)
- **Combined**: Combines both MFCC and Mel spectrogram features for potentially better results

## Integration

You can also import and use the functions in your own Python scripts:

```python
from analyze_audio_file import analyze_audio_file

result = analyze_audio_file("audio_sample.wav")
print(f"Detected sentiment: {result['sentiment']} with {result['confidence']}% confidence")
```

## Troubleshooting

- If you get an error about missing models, make sure you've trained a model using the `emotion_recognition.py` script.
- For audio file errors, check that your file is a valid audio file that librosa can read.
- For best results, use clear audio with minimal background noise. 
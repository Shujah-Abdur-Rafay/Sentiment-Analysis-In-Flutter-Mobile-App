# Real-Time Voice Sentiment Analysis

A deep learning system for analyzing emotional sentiment from voice recordings in real-time. This project uses Convolutional Neural Networks (CNNs) to classify emotions from audio features and maps them to sentiment categories (positive, negative, neutral).

## Features

- **Real-time voice processing**: Capture and analyze voice input in real-time
- **Pre-recorded audio analysis**: Process audio files from datasets (RAVDESS, etc.)
- **Multiple feature extraction methods**:
  - Mel-Frequency Cepstral Coefficients (MFCC)
  - Mel Spectrograms
  - Combined features
- **Automatic model training and evaluation**
- **Detailed performance metrics and visualizations**
- **Organized results and model storage**

## Project Structure

```
├── data_path.py           # Script to create CSV of audio files in the Data folder
├── emotion_recognition.py # Main script for training and real-time analysis
├── Data/                  # Directory containing audio dataset
├── models/                # Directory storing trained models
└── results/               # Directory storing evaluation results and metrics
```

## Requirements

- Python 3.6+
- TensorFlow 2.x
- Librosa
- PyAudio
- NumPy
- Pandas
- Scikit-learn
- Matplotlib
- Seaborn

## Model Architecture

The system uses a CNN architecture with the following structure:

1. **Input Layer**: Takes audio features (MFCC, Mel spectrogram or combined)
2. **Convolutional Layers**:
   - First block: 32 filters (3x3), ReLU activation, batch normalization, max pooling, dropout (20%)
   - Second block: 64 filters (3x3), ReLU activation, batch normalization, max pooling, dropout (30%)
   - Third block: 128 filters (3x3), ReLU activation, batch normalization, max pooling, dropout (40%)
3. **Fully Connected Layers**:
   - Flatten layer
   - Dense layer (256 units), ReLU activation, batch normalization, dropout (50%)
4. **Output Layer**: Dense layer with softmax activation (number of classes)

## Feature Extraction

The system extracts the following audio features:

1. **MFCC (default)**: Mel-Frequency Cepstral Coefficients represent the short-term power spectrum of a sound based on a linear cosine transform of a log power spectrum on a nonlinear mel scale of frequency.

2. **Mel Spectrogram**: A spectrogram where the frequencies are converted to the mel scale, which better approximates human auditory perception.

3. **Combined**: Combines both MFCC and Mel spectrogram features for potentially better performance.

Audio is preprocessed by:
- Resampling to 16kHz
- Trimming silence
- Standardizing duration to 3 seconds (padding or truncating)
- Normalizing features

## Training Process

1. **Data Preparation**: 
   - Load audio files and labels from CSV
   - Extract features (MFCC, Mel spectrogram, or combined)
   - Balance dataset to prevent class imbalance
   - Split into training and testing sets (80%-20%)

2. **Model Training**:
   - Uses categorical cross-entropy loss and Adam optimizer
   - Implements early stopping to prevent overfitting
   - Reduces learning rate on plateaus
   - Uses model checkpointing to save best model

3. **Evaluation**:
   - Accuracy, precision, recall, and F1 score metrics
   - Confusion matrix visualization
   - Detailed classification report
   - Training and validation curves

## Sentiment Analysis Approach

The model maps detected emotions to sentiment categories:
- **Positive**: happy, surprise
- **Negative**: sad, angry, fear, disgust
- **Neutral**: neutral, calm

This mapping simplifies the emotional analysis into a sentiment context that's more applicable to general use cases.

## Usage

### Train a new model

```bash
python emotion_recognition.py --mode train --data Data_path.csv --feature mfcc
```

### Run real-time analysis

```bash
python emotion_recognition.py --mode analyze --feature mfcc
```

### Options

- `--mode`: "train" or "analyze"
- `--data`: Path to CSV file with audio paths and labels (for training)
- `--feature`: Feature extraction method ("mfcc", "melspec", or "combined")
- `--model`: Path to saved model (for analyze mode)
- `--encoder`: Path to saved label encoder (for analyze mode)

## Results and Performance

Training results, including accuracy metrics, confusion matrices, and training curves, are saved in the `results/` directory. Each training run creates a timestamped set of files:

- `metrics_[timestamp].json`: Contains accuracy, precision, recall, and F1 score
- `confusion_matrix_[timestamp].png`: Visual representation of model predictions
- `training_history_[timestamp].png`: Training and validation accuracy/loss curves

Models are saved in the `models/` directory with timestamp identifiers.


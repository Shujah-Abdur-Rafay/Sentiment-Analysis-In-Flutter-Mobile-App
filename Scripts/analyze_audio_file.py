#!/usr/bin/env python
# analyze_audio_file.py
# This script performs sentiment analysis on any audio file provided as input

import os
import numpy as np
import librosa
import tensorflow as tf
from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler
import pickle
import argparse
import time

# Define constants
SAMPLE_RATE = 16000  # 16kHz sampling rate for speech
DURATION = 3.0       # 3 seconds per sample
N_MFCC = 40          # Number of MFCC coefficients
MODELS_DIR = "models"  # Directory where models are stored

def extract_features_from_audio(audio, feature_type='mfcc', sr=SAMPLE_RATE, n_mfcc=N_MFCC):
    """Extract features from an audio array"""
    if feature_type == 'mfcc':
        # Extract Mel-Frequency Cepstral Coefficients
        mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=n_mfcc)
        
        # Normalize the MFCCs
        mfccs = StandardScaler().fit_transform(mfccs.T).T
        return mfccs
        
    elif feature_type == 'melspec':
        # Extract Mel spectrogram
        melspec = librosa.feature.melspectrogram(y=audio, sr=sr, n_mels=128)
        
        # Convert to decibels
        melspec_db = librosa.power_to_db(melspec, ref=np.max)
        return melspec_db
        
    elif feature_type == 'combined':
        # Extract both MFCCs and Mel spectrogram
        mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=n_mfcc)
        mfccs = StandardScaler().fit_transform(mfccs.T).T
        
        melspec = librosa.feature.melspectrogram(y=audio, sr=sr, n_mels=128)
        melspec_db = librosa.power_to_db(melspec, ref=np.max)
        
        # Combine features
        combined = np.concatenate([mfccs, melspec_db[:n_mfcc]])
        return combined
    
    else:
        raise ValueError(f"Unknown feature type: {feature_type}")

def analyze_audio_file(file_path, model_path=None, encoder_path=None, feature_type='mfcc'):
    """Analyze a single audio file for sentiment"""
    print(f"\nAnalyzing file: {file_path}")
    start_time = time.time()
    
    # Load the model and label encoder
    if model_path is None:
        # Find the most recent model
        model_files = [f for f in os.listdir(MODELS_DIR) if f.endswith('.h5')]
        if model_files:
            model_file = max(model_files, key=lambda x: os.path.getmtime(os.path.join(MODELS_DIR, x)))
            model_path = os.path.join(MODELS_DIR, model_file)
            print(f"Using model: {model_path}")
        else:
            print("No model found in models directory. Please train a model first.")
            return
    
    if encoder_path is None:
        # Try to find the label encoder
        default_encoder = os.path.join(MODELS_DIR, 'label_encoder.pkl')
        if os.path.exists(default_encoder):
            encoder_path = default_encoder
    
    # Load model
    model = load_model(model_path)
    
    # Load label encoder
    with open(encoder_path, 'rb') as f:
        label_encoder = pickle.load(f)
    
    try:
        # Load and preprocess audio
        print("Loading audio file...")
        audio, _ = librosa.load(file_path, sr=SAMPLE_RATE)
        
        # Trim silence
        audio, _ = librosa.effects.trim(audio, top_db=20)
        
        # Standardize length
        target_length = int(DURATION * SAMPLE_RATE)
        if len(audio) > target_length:
            audio = audio[:target_length]
        else:
            audio = np.pad(audio, (0, max(0, target_length - len(audio))), 'constant')
        
        # Extract features
        print(f"Extracting {feature_type} features...")
        features = extract_features_from_audio(audio, feature_type)
        
        # Reshape for model input (add batch and channel dimensions)
        features = features[np.newaxis, ..., np.newaxis]
        
        # Make prediction
        print("Predicting sentiment...")
        prediction = model.predict(features, verbose=0)
        predicted_class = np.argmax(prediction, axis=1)[0]
        
        # Get label
        predicted_label = label_encoder.inverse_transform([predicted_class])[0]
        confidence = np.max(prediction) * 100
        
        # Map to sentiment category
        sentiment = "unknown"
        if "_happy" in predicted_label or "_surprise" in predicted_label:
            sentiment = "positive"
        elif "_sad" in predicted_label or "_angry" in predicted_label or "_fear" in predicted_label or "_disgust" in predicted_label:
            sentiment = "negative"
        elif "_neutral" in predicted_label:
            sentiment = "neutral"
        
        # Print results
        print("\nResults:")
        print(f"Detected emotion: {predicted_label}")
        print(f"Sentiment category: {sentiment}")
        print(f"Confidence: {confidence:.1f}%")
        print(f"Analysis completed in {time.time() - start_time:.2f} seconds")
        
        # Return results as a dictionary
        return {
            "file": file_path,
            "emotion": predicted_label,
            "sentiment": sentiment,
            "confidence": float(confidence),
            "processing_time": float(time.time() - start_time)
        }
        
    except Exception as e:
        print(f"Error analyzing file: {e}")
        return None

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Audio File Sentiment Analysis")
    parser.add_argument("file", type=str, help="Path to audio file for analysis")
    parser.add_argument("--model", type=str, default=None, help="Path to model file (default: most recent in models/)")
    parser.add_argument("--encoder", type=str, default=None, help="Path to label encoder file (default: models/label_encoder.pkl)")
    parser.add_argument("--feature", type=str, default="mfcc", choices=["mfcc", "melspec", "combined"], 
                        help="Feature extraction method (default: mfcc)")
    
    args = parser.parse_args()
    
    # Analyze the file
    analyze_audio_file(args.file, args.model, args.encoder, args.feature)

if __name__ == "__main__":
    main() 
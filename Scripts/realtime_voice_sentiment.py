#!/usr/bin/env python
# realtime_voice_sentiment.py
# This script performs real-time sentiment analysis on voice input

import os
import numpy as np
import librosa
import tensorflow as tf
from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler
import pyaudio
import wave
import time
import threading
import pickle
import argparse
import datetime

# Define constants
SAMPLE_RATE = 16000       # 16kHz sampling rate for speech
DURATION = 3.0            # 3 seconds per sample
CHUNK_SIZE = 1024         # Audio chunks for processing
N_MFCC = 40               # Number of MFCC coefficients
MODELS_DIR = "models"     # Directory where models are stored

class VoiceRecorder:
    """Class to handle real-time audio recording and processing"""
    def __init__(self, sample_rate=SAMPLE_RATE, chunk_size=CHUNK_SIZE, channels=1, 
                 format=pyaudio.paFloat32, duration=DURATION):
        self.sample_rate = sample_rate
        self.chunk_size = chunk_size
        self.channels = channels
        self.format = format
        self.duration = duration
        self.frames_per_buffer = int(self.sample_rate * self.duration)
        self.audio = pyaudio.PyAudio()
        self.stream = None
        self.is_recording = False
        self.audio_data = np.array([])
        
    def start_recording(self):
        """Start audio stream for recording"""
        if self.stream is not None:
            self.stop_recording()
        
        self.stream = self.audio.open(
            format=self.format,
            channels=self.channels,
            rate=self.sample_rate,
            input=True,
            frames_per_buffer=self.chunk_size
        )
        
        self.is_recording = True
        self.audio_data = np.array([])
        
        # Start a thread to continuously record audio
        threading.Thread(target=self._record_audio).start()
        
        print("Recording started... Speak now")
    
    def _record_audio(self):
        """Record audio in the background"""
        while self.is_recording:
            try:
                data = self.stream.read(self.chunk_size)
                audio_chunk = np.frombuffer(data, dtype=np.float32)
                
                if len(self.audio_data) == 0:
                    self.audio_data = audio_chunk
                else:
                    self.audio_data = np.append(self.audio_data, audio_chunk)
                
                # Keep only the most recent frames to maintain real-time processing
                if len(self.audio_data) > self.frames_per_buffer:
                    self.audio_data = self.audio_data[-self.frames_per_buffer:]
            except Exception as e:
                print(f"Error recording audio: {e}")
                break
    
    def stop_recording(self):
        """Stop audio recording"""
        if self.stream:
            self.is_recording = False
            self.stream.stop_stream()
            self.stream.close()
            self.stream = None
            print("Recording stopped")
    
    def get_last_audio(self):
        """Get the last recorded audio segment"""
        # Ensure we have enough audio data
        if len(self.audio_data) < self.sample_rate * self.duration:
            return None
        
        # Return the last N seconds of audio
        return self.audio_data[-int(self.sample_rate * self.duration):]
    
    def save_audio(self, filename="recorded_audio.wav"):
        """Save the recorded audio to a WAV file"""
        if len(self.audio_data) == 0:
            print("No audio data to save")
            return
        
        # Ensure audio is float32 for saving
        audio_to_save = np.copy(self.audio_data).astype(np.float32)
        
        # Normalize to -1.0 to 1.0 range if needed
        max_val = np.max(np.abs(audio_to_save))
        if max_val > 1.0:
            audio_to_save = audio_to_save / max_val
        
        # Save using scipy.io.wavfile to handle float32
        from scipy.io import wavfile
        wavfile.write(filename, self.sample_rate, audio_to_save)
        print(f"Audio saved to {filename}")
    
    def close(self):
        """Close the PyAudio instance"""
        self.stop_recording()
        self.audio.terminate()

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

def run_realtime_analysis(model_path=None, encoder_path=None, feature_type='mfcc', 
                          save_clips=False, clips_dir=None, duration=None):
    """Run real-time voice sentiment analysis"""
    print("Starting real-time voice sentiment analysis...")
    
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
        else:
            print("No label encoder found. Please train a model first.")
            return
    
    # Load model
    print("Loading model...")
    model = load_model(model_path)
    
    # Load label encoder
    print("Loading label encoder...")
    with open(encoder_path, 'rb') as f:
        label_encoder = pickle.load(f)
    
    # Create clips directory if saving clips
    if save_clips and clips_dir:
        os.makedirs(clips_dir, exist_ok=True)
    
    # Initialize voice recorder
    recorder = VoiceRecorder(
        sample_rate=SAMPLE_RATE,
        chunk_size=CHUNK_SIZE,
        duration=DURATION
    )
    
    # Start recording
    recorder.start_recording()
    
    try:
        # Track time for duration limit
        start_time = time.time()
        last_save_time = time.time()
        current_sentiment = None
        sentiment_history = []
        
        print("Press Ctrl+C to stop")
        
        while True:
            # Check if duration limit reached
            if duration and (time.time() - start_time) > duration:
                print(f"\nReached time limit of {duration} seconds.")
                break
                
            # Get the last audio segment
            audio_data = recorder.get_last_audio()
            
            if audio_data is not None and len(audio_data) >= SAMPLE_RATE * DURATION:
                # Extract features
                features = extract_features_from_audio(audio_data, feature_type)
                
                # Reshape for model input (add batch and channel dimensions)
                features = features[np.newaxis, ..., np.newaxis]
                
                # Make prediction
                prediction = model.predict(features, verbose=0)
                predicted_class = np.argmax(prediction, axis=1)[0]
                
                # Get label
                predicted_label = label_encoder.inverse_transform([predicted_class])[0]
                confidence = np.max(prediction) * 100
                
                # Determine sentiment category
                sentiment = "unknown"
                if "_happy" in predicted_label or "_surprise" in predicted_label:
                    sentiment = "positive"
                elif "_sad" in predicted_label or "_angry" in predicted_label or "_fear" in predicted_label or "_disgust" in predicted_label:
                    sentiment = "negative"
                elif "_neutral" in predicted_label:
                    sentiment = "neutral"
                
                # Save sentiment to history
                if sentiment != current_sentiment:
                    current_sentiment = sentiment
                    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
                    sentiment_history.append((timestamp, predicted_label, sentiment, confidence))
                
                # Save audio clip if enabled and sentiment changed or it's been a while
                if save_clips and (sentiment != current_sentiment or time.time() - last_save_time > 10):
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    clip_filename = os.path.join(clips_dir, f"sentiment_{sentiment}_{timestamp}.wav")
                    from scipy.io import wavfile
                    wavfile.write(clip_filename, SAMPLE_RATE, audio_data)
                    last_save_time = time.time()
                
                # Display result
                print(f"\rVoice detected: {predicted_label} (Sentiment: {sentiment}) - Confidence: {confidence:.1f}%", end="")
            
            # Sleep to reduce CPU usage
            time.sleep(0.1)
    
    except KeyboardInterrupt:
        print("\n\nStopping real-time analysis...")
    
    finally:
        # Clean up and display summary
        recorder.stop_recording()
        recorder.close()
        
        print("\nAnalysis Summary:")
        print("----------------")
        for i, (timestamp, emotion, sentiment, confidence) in enumerate(sentiment_history):
            print(f"{i+1}. {timestamp} - {emotion} ({sentiment}) - Confidence: {confidence:.1f}%")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Real-time Voice Sentiment Analysis")
    parser.add_argument("--model", type=str, default=None, 
                      help="Path to model file (default: most recent in models/)")
    parser.add_argument("--encoder", type=str, default=None, 
                      help="Path to label encoder file (default: models/label_encoder.pkl)")
    parser.add_argument("--feature", type=str, default="mfcc", choices=["mfcc", "melspec", "combined"], 
                      help="Feature extraction method (default: mfcc)")
    parser.add_argument("--save-clips", action="store_true", 
                      help="Save audio clips when sentiment changes")
    parser.add_argument("--clips-dir", type=str, default="voice_clips", 
                      help="Directory to save audio clips (default: voice_clips/)")
    parser.add_argument("--duration", type=int, default=None, 
                      help="Duration in seconds to run analysis (default: unlimited)")
    
    args = parser.parse_args()
    
    # Run real-time analysis
    run_realtime_analysis(
        model_path=args.model,
        encoder_path=args.encoder,
        feature_type=args.feature,
        save_clips=args.save_clips,
        clips_dir=args.clips_dir,
        duration=args.duration
    )

if __name__ == "__main__":
    main() 
import os
import numpy as np
import tensorflow as tf
import librosa
import pickle
import tempfile
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load the CNN model
MODEL_PATH = 'mdl/model/emotion_model_20250421_143944.h5'
LABEL_ENCODER_PATH = 'mdl/model/label_encoder_20250421_143944.pkl'

# Audio parameters
SAMPLE_RATE = 16000
DURATION = 3  # seconds
N_MFCC = 40
HOP_LENGTH = 512
N_FFT = 2048

# Global variables for model and label encoder
model = None
label_encoder = None

def load_model_and_encoder():
    """Load the trained model and label encoder"""
    global model, label_encoder
    try:
        model = tf.keras.models.load_model(MODEL_PATH)
        with open(LABEL_ENCODER_PATH, 'rb') as f:
            label_encoder = pickle.load(f)
        print(f"Model loaded successfully from {MODEL_PATH}")
        print(f"Label encoder loaded successfully from {LABEL_ENCODER_PATH}")
        print(f"Available classes: {label_encoder.classes_}")
    except Exception as e:
        print(f"Error loading model or encoder: {e}")
        raise

def download_audio_file(url):
    """Download audio file from URL"""
    try:
        # Create a temporary file
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
        temp_file.close()
        
        # Download the file
        response = requests.get(url, stream=True)
        with open(temp_file.name, 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
        
        return temp_file.name
    except Exception as e:
        print(f"Error downloading file: {e}")
        raise

def extract_features(file_path):
    """Extract MFCC features from audio file"""
    try:
        # Load audio file
        y, sr = librosa.load(file_path, sr=SAMPLE_RATE, mono=True)
        
        # Trim silent parts
        y, _ = librosa.effects.trim(y, top_db=25)
        
        # Make sure audio is exactly DURATION seconds long
        if len(y) > SAMPLE_RATE * DURATION:
            y = y[:SAMPLE_RATE * DURATION]
        else:
            y = np.pad(y, (0, max(0, SAMPLE_RATE * DURATION - len(y))), 'constant')
        
        # Extract MFCCs
        mfccs = librosa.feature.mfcc(
            y=y, 
            sr=SAMPLE_RATE, 
            n_mfcc=N_MFCC, 
            n_fft=N_FFT, 
            hop_length=HOP_LENGTH
        )
        
        # Transpose to get time steps as the first dimension
        mfccs = mfccs.T
        
        # Reshape for model input (add batch dimension)
        mfccs = np.expand_dims(mfccs, axis=0)
        
        return mfccs
    except Exception as e:
        print(f"Error extracting features: {e}")
        raise

def predict_emotion(audio_features):
    """Predict emotion using loaded model"""
    # Make prediction
    predictions = model.predict(audio_features)
    
    # Get the index of the highest probability
    predicted_index = np.argmax(predictions, axis=1)[0]
    
    # Get the emotion label
    emotion = label_encoder.inverse_transform([predicted_index])[0]
    
    # Get the confidence
    confidence = float(predictions[0][predicted_index])
    
    # Get all emotion scores
    emotion_scores = {}
    for i, emotion_class in enumerate(label_encoder.classes_):
        emotion_scores[emotion_class] = float(predictions[0][i])
    
    return {
        'emotion': emotion,
        'confidence': confidence,
        'emotion_scores': emotion_scores
    }

@app.route('/analyze', methods=['POST'])
def analyze_audio():
    """API endpoint to analyze audio file"""
    # Check if model is loaded
    if model is None or label_encoder is None:
        try:
            load_model_and_encoder()
        except Exception as e:
            return jsonify({
                'error': f'Failed to load model: {str(e)}'
            }), 500
    
    # Parse request
    if not request.is_json:
        return jsonify({'error': 'Request must be JSON'}), 400
    
    data = request.get_json()
    if 'audio_url' not in data:
        return jsonify({'error': 'No audio_url provided'}), 400
    
    audio_url = data['audio_url']
    
    try:
        # Download the audio file
        file_path = download_audio_file(audio_url)
        
        # Extract features
        features = extract_features(file_path)
        
        # Make prediction
        result = predict_emotion(features)
        
        # Clean up temporary file
        if os.path.exists(file_path):
            os.remove(file_path)
        
        return jsonify(result)
    except Exception as e:
        return jsonify({
            'error': f'Analysis failed: {str(e)}'
        }), 500

if __name__ == '__main__':
    # Load model on startup
    load_model_and_encoder()
    
    # Start the Flask server
    app.run(host='0.0.0.0', port=5000, debug=True) 
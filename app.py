from flask import Flask, request, jsonify
import requests
import os
from dotenv import load_dotenv
from flask_cors import CORS
from geopy.geocoders import Nominatim
import pandas as pd
import joblib
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.losses import MeanSquaredError  
from datetime import datetime, timedelta
import random


app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configuration
OPENWEATHERMAP_API_KEY = os.getenv('OPENWEATHERMAP_API_KEY')
WEATHER_FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast"
WEATHER_CURRENT_URL = "https://api.openweathermap.org/data/2.5/weather"

# Initialize Geolocator
geolocator = Nominatim(user_agent="WeatherRainApp")

# Load Models and Encoders
try:
    LOCATION_ENCODER = joblib.load('models/location_encoder.pkl')
    RAIN_TODAY_MODEL = joblib.load('models/rain_today_model.pkl')
    RAIN_TOMORROW_MODEL = joblib.load('models/rain_tomorrow_model.pkl')
    loaded_model = load_model('models/lag_prediction_model.h5', custom_objects={'mse': MeanSquaredError()})
except Exception as e:
    print(f"Error loading models: {e}")
    LOCATION_ENCODER = None
    RAIN_TODAY_MODEL = None
    RAIN_TOMORROW_MODEL = None
    loaded_model = None

@app.route('/api/forecast', methods=['GET'])
def get_forecast():
    """
    Fetches a 5-day weather forecast with 3-hour intervals for the given latitude and longitude.
    """
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    
    if not lat or not lon:
        return jsonify({"error": "Please provide both 'lat' and 'lon' parameters."}), 400
    
    params = {
        'lat': lat,
        'lon': lon,
        'appid': OPENWEATHERMAP_API_KEY,
        'units': 'metric'  # Change to 'imperial' if needed
    }
    
    try:
        response = requests.get(WEATHER_FORECAST_URL, params=params)
        response.raise_for_status()  # Raise HTTPError for bad responses
        data = response.json()
        return jsonify(data)
    except requests.exceptions.HTTPError as http_err:
        return jsonify({"error": f"HTTP error occurred: {http_err}"}), response.status_code
    except Exception as err:
        return jsonify({"error": f"An error occurred: {err}"}), 500

@app.route('/predict', methods=['POST'])
def predict():
    """
    Predicts rain for today and tomorrow based on a place name.
    """
    if not all([LOCATION_ENCODER, RAIN_TODAY_MODEL, RAIN_TOMORROW_MODEL]):
        return jsonify({"error": "Models are not loaded properly."}), 500

    data = request.get_json()
    place = data.get('place')
    
    if not place:
        return jsonify({"error": "Place name is required."}), 400
    
    # Get latitude and longitude from place name
    location = geolocator.geocode(place)
    if not location:
        return jsonify({"error": "Location not found."}), 404
    
    lat = location.latitude
    lon = location.longitude
    
    return predict_rain(lat, lon)

@app.route('/predict_rain', methods=['GET'])
def predict_rain_route():
    """
    Predicts rain for today and tomorrow based on latitude and longitude.
    """
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    
    if not lat or not lon:
        return jsonify({"error": "Please provide both 'lat' and 'lon' parameters."}), 400
    
    return predict_rain(lat, lon)

def predict_rain(lat, lon):
    """
    Helper function to predict rain based on latitude and longitude.
    """
    if not all([LOCATION_ENCODER, RAIN_TODAY_MODEL, RAIN_TOMORROW_MODEL]):
        return jsonify({"error": "Models are not loaded properly."}), 500

    api_key = OPENWEATHERMAP_API_KEY
    api_url = f"{WEATHER_CURRENT_URL}?lat={lat}&lon={lon}&appid={api_key}&units=metric"

    response = requests.get(api_url)

    if response.status_code != 200:
        return jsonify({"error": "Failed to get weather data."}), 400

    weather_data = response.json()
    location_name = weather_data.get("name", "Unknown Location")
    current_temp = weather_data["main"]["temp"]
    humidity = weather_data["main"]["humidity"]
    pressure = weather_data["main"]["pressure"]
    wind_speed = weather_data["wind"]["speed"]
    rainfall = weather_data.get("rain", {}).get("1h", 0)

    # Prepare features for today's prediction
    features_today = pd.DataFrame({
        'Location': [location_name],
        'MinTemp': [current_temp - 2],
        'MaxTemp': [current_temp + 2],
        'Rainfall': [rainfall],
        'Humidity': [humidity],
        'Pressure': [pressure],
        'WindSpeed': [wind_speed]
    })

    # Encode Location
    if location_name in LOCATION_ENCODER.classes_:
        features_today['Location'] = LOCATION_ENCODER.transform([location_name])
    else:
        features_today['Location'] = -1  # Unknown location

    # Predict Rain Today
    prediction_today = RAIN_TODAY_MODEL.predict(features_today)
    
    # Prepare features for tomorrow's prediction
    features_tomorrow = pd.DataFrame({
        'Location': [location_name],
        'MinTemp': [current_temp - 2],
        'MaxTemp': [current_temp + 2],
        'Rainfall': [rainfall],
        'Humidity': [humidity],
        'Pressure': [pressure],
        'WindSpeed': [wind_speed],
        'RainToday': [prediction_today[0]]
    })

    # Encode Location
    if location_name in LOCATION_ENCODER.classes_:
        features_tomorrow['Location'] = LOCATION_ENCODER.transform([location_name])
    else:
        features_tomorrow['Location'] = -1  # Unknown location

    # Predict Rain Tomorrow
    prediction_tomorrow = RAIN_TOMORROW_MODEL.predict(features_tomorrow)

    return jsonify({
        "Location": location_name,
        "RainToday": bool(prediction_today[0]),
        "RainTomorrow": bool(prediction_tomorrow[0])
    })

@app.route('/predict_any', methods=['POST'])
def predict_any():
    """
    Predicts rain based on either a place name or latitude and longitude.
    """
    data = request.get_json()
    place = data.get('place')
    lat = data.get('lat')
    lon = data.get('lon')

    if place:
        return predict()
    elif lat and lon:
        return predict_rain(lat, lon)
    else:
        return jsonify({"error": "Provide either a place name or latitude and longitude."}), 400

@app.route('/forecast_simulation', methods=['GET'])
def forecast_simulation():
    """
    Simulates weather forecast data and checks the rain duration to determine match status.
    """
    start_time = datetime.now()
    hours = 48  # Simulate for 48 hours

    # Simulate forecast data
    simulated_data = simulate_forecast_data(start_time, hours)
    rain_start, rain_end, duration = calculate_rain_duration(simulated_data)

    if rain_start and rain_end and duration:
        status = determine_match_status(duration)
        return jsonify({
            "simulated_forecast": simulated_data,
            "rain_start": rain_start.isoformat(),
            "rain_end": rain_end.isoformat(),
            "duration": str(duration),
            "match_status": status
        })
    else:
        return jsonify({"message": "No significant rain detected."})

def simulate_forecast_data(start_time, hours):
    """Simulate forecast data with varying rain amounts."""
    forecasts = []
    for hour in range(hours):
        current_time = start_time + timedelta(hours=hour)
        rain_amount = round(random.uniform(0, 1.5), 1) if hour % 2 == 1 else 0.0  # Simulate rain only at odd hours
        forecasts.append({"time": current_time.strftime("%Y-%m-%dT%H:%M:%S"), "rain": rain_amount})
    
    return {"forecasts": forecasts}

def calculate_rain_duration(forecast):
    rain_start = None
    rain_end = None

    for entry in forecast["forecasts"]:
        time = datetime.fromisoformat(entry["time"])
        rain_amount = entry["rain"]
        
        # Check if it starts raining
        if rain_amount > 0 and rain_start is None:
            rain_start = time
        # Check if it stops raining
        elif rain_amount == 0 and rain_start is not None:
            rain_end = time
            break  # Stop checking once rain has stopped

    # If rain never stopped, set rain_end to the last time in forecast
    if rain_start and rain_end is None:
        rain_end = time  # Last entry in forecast is considered rain end

    duration = None
    if rain_start and rain_end:
        duration = rain_end - rain_start

    return rain_start, rain_end, duration

def determine_match_status(duration):
    """Determine the match status based on rain duration."""
    if duration and duration.total_seconds() > 3600:  # If rain duration exceeds 1 hour
        return "Match"
    else:
        return "No match"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True)


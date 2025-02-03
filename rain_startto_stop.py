import requests
from datetime import datetime, timedelta
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
import random

# Constants
WEATHER_FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast"
OPENWEATHERMAP_API_KEY = "cdb30228749294aab0742f605b2619c0"

def fetch_forecast(lat, lon):
    """Fetch the weather forecast from OpenWeatherMap API using latitude and longitude."""
    params = {
        'lat': lat,
        'lon': lon,
        'appid': OPENWEATHERMAP_API_KEY,
        'units': 'metric'  # For temperature in Celsius
    }
    
    try:
        response = requests.get(WEATHER_FORECAST_URL, params=params, timeout=10)
        response.raise_for_status()  # Raise an error for bad responses
        return response.json()  # Return the JSON response
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}")
        return None

def parse_forecast_data(data):
    """Parse the forecast data to extract relevant rain information."""
    forecasts = []

    for entry in data['list']:  # 'list' contains the forecast entries
        time = entry['dt_txt']  # Date and time
        rain_amount = entry.get('rain', {}).get('1h', 0.0)  # Rain volume in the last hour
        forecasts.append({"time": time, "rain": rain_amount})
    
    return {"forecasts": forecasts}

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
    if rain_start is not None and rain_end is None:
        rain_end = datetime.fromisoformat(forecast["forecasts"][-1]["time"])

    # Calculate duration
    if rain_start and rain_end:
        duration = rain_end - rain_start
        return rain_start, rain_end, duration
    else:
        return None, None, None

def get_current_location():
    """Get the current location's latitude and longitude for Chennai."""
    geolocator = Nominatim(user_agent="WeatherForecastApp_v1")
    try:
        location = geolocator.geocode("Chennai, India", timeout=10)
        
        if location:
            return location.latitude, location.longitude
        else:
            print("Could not determine the current location.")
            return None, None
    except GeocoderTimedOut:
        print("Geocoding service timed out. Please try again.")
        return None, None
    except GeocoderServiceError as e:
        print(f"Geocoding service error: {e}")
        return None, None

def determine_match_status(duration):
    """Determine the match status based on the rain duration."""
    if duration.total_seconds() < 1800:  # Less than 30 minutes
        return "The match will continue as scheduled (extra time may be added)."
    elif duration.total_seconds() < 11400:  # 30 minutes to 3 hours
        return "The match will be delayed."
    else:  # More than 3 hours
        return "The match may need to be rescheduled or a reserve day may be used."

# Main execution
if __name__ == "__main__":
    lat, lon = get_current_location()

    if lat is not None and lon is not None:
        print(f"Using coordinates: Latitude: {lat}, Longitude: {lon}")
        forecast_data = fetch_forecast(lat, lon)

        if forecast_data:
            parsed_data = parse_forecast_data(forecast_data)
            print(parsed_data)  # Print the formatted forecast data
            
            start_time = datetime.now()  # Start from now
            simulated_data = simulate_forecast_data(start_time, 6)  # Simulate 6 hours of data
            
            start_time, end_time, duration = calculate_rain_duration(simulated_data)

            if start_time and end_time:
                print(f"Simulated rain is expected from {start_time} to {end_time} for a duration of {duration}.")
                match_status = determine_match_status(duration)
                print(match_status)
            else:
                print("No rain is expected in the forecast.")
    else:
        print("Could not fetch the current location.")

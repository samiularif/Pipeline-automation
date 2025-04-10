# Import necessary modules
from flask import Flask, jsonify, Response
from datetime import datetime
import socket
import requests
import os
import json
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Create a Flask app
app = Flask(__name__)

# Configurations
VERSION = os.getenv("APP_VERSION", "dev")
WEATHER_API_KEY = os.getenv("WEATHER_API_KEY")
WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather?q=Dhaka&appid={}&units=metric"

def get_weather_data():
    #Fetch weather data for Dhaka from the OpenWeatherMap API

    try:
        response = requests.get(WEATHER_API_URL.format(WEATHER_API_KEY), timeout=5)
        response.raise_for_status() # Raise an exception if the request fails
        data = response.json()
        return {
            "temperature": str(data["main"]["temp"]),
            "temp_unit": "c"
        }
    except requests.RequestsException as e:
        # Return default data if the API request fails
        return {
            "temperature": "14",
            "temp_unit": "c",
            "error": f"Weather API unavailable: {str(e)}"
        }
    
@app.route('/api/hello', methods=['GET'])
def hello():
    # Return hostname, datetime, version and weather data
    weather = get_weather_data()
    response = {
        "hostname": socket.gethostname(),
        "datetime": datetime.now().strftime("%y%m%d%H%M"),
        "version": VERSION,
        "weather": { 
            "dhaka": weather
        }
    }
    return jsonify(response)
#   If the correct order is required, use the following code
#   return Response(json.dumps(response), mimetype='application/json')

@app.route('/api/health', methods=['GET'])
def health():
    # Return a simple health check response
    weather_api_status = "healthy"
    try:
        # Test reachability of the weather API
        response = requests.get(WEATHER_API_URL.format(WEATHER_API_KEY), timeout=5)
        response.raise_for_status() # Raise an exception if the request fails
    except requests.RequestsException as e:
        weather_api_status = "unreachable"

    health_status = {
        "status": "healthy" if weather_api_status == "healthy" else "not healthy",
        "weather_api" : weather_api_status,
        "timestamp" : datetime.now().strftime("%y%m%d%H%M")
    }
    return jsonify(health_status)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
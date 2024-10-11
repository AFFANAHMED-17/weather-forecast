
# Weather & Rain Prediction App 🌦️

This project is a **Weather and Rain Prediction Application** built using **Flask** for the backend and **Flutter** for the frontend. The app fetches weather data using the OpenWeatherMap API and predicts whether it will rain today or tomorrow using pre-trained machine learning models.

## Features

- Fetch current weather data based on location (latitude and longitude).
- 5-day weather forecast with 3-hour intervals.
- Predicts the likelihood of rain today and tomorrow using machine learning.
- Integration with OpenWeatherMap API for real-time data.
- A simple and interactive Flutter-based UI.

## Technologies Used

- **Backend**: Flask, Scikit-learn (for machine learning), Joblib (for model serialization)
- **Frontend**: Flutter, Dart
- **API**: OpenWeatherMap
- **Geolocation**: Geolocator (in Flutter)

---

## Table of Contents

1. [Installation](#installation)
2. [Backend Setup (Flask)](#backend-setup-flask)
3. [Frontend Setup (Flutter)](#frontend-setup-flutter)
4. [Running the Application](#running-the-application)
5. [API Routes](#api-routes)
6. [Models and Data](#models-and-data)

---

## Installation

### Prerequisites

- **Python** (>= 3.7)
- **Flutter** (>= 3.0.0)
- **Node.js** (for CORS policy configuration)
- **OpenWeatherMap API Key** (Sign up at [OpenWeatherMap](https://home.openweathermap.org/users/sign_up))

Make sure to install **Python**, **Flutter**, and **Node.js** on your system.

### Backend Setup (Flask)

1. Clone the repository and navigate to the backend folder:

   ```bash
   git clone https://github.com/AFFANAHMED-17/weather-rain-prediction.git
   cd weather-rain-prediction/backend
   ```

2. Set up a Python virtual environment:

   ```bash
   python -m venv venv
   source venv/bin/activate   # On Windows: venv\Scripts\activate
   ```

3. Install required Python packages:

   ```bash
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the `backend` directory to store your OpenWeatherMap API key:

   ```bash
   touch .env
   ```

   Add the following to the `.env` file:

   ```
   OPENWEATHERMAP_API_KEY=your_openweathermap_api_key
   ```

5. Start the Flask development server:

   ```bash
   python app.py
   ```

   The Flask server will be running on `http://localhost:3000`.

### Frontend Setup (Flutter)

1. Navigate to the frontend folder:

   ```bash
   cd ../frontend
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Ensure your development device (emulator or physical device) is connected.

4. Run the Flutter app:

   ```bash
   flutter run
   ```

5. To build a release version, use:

   ```bash
   flutter build apk --release
   ```

---

## Running the Application

After completing both backend and frontend setups:

1. **Backend**: Ensure your Flask server is running on `http://localhost:3000`.
   
   ```bash
   cd backend
   python app.py
   ```

2. **Frontend**: Run the Flutter app using the `flutter run` command.

---

## API Routes

### 1. `/api/forecast` (GET)

- **Description**: Fetches a 5-day weather forecast with 3-hour intervals for the given latitude and longitude.
- **Example**:

   ```bash
   curl "http://localhost:3000/api/forecast?lat=35.6895&lon=139.6917"
   ```

- **Response**:

   ```json
   {
     "list": [
       {
         "dt": 1605182400,
         "main": {
           "temp": 285.66,
           ...
         },
         "weather": [
           {
             "description": "clear sky",
             ...
           }
         ]
       },
       ...
     ]
   }
   ```

### 2. `/predict` (POST)

- **Description**: Predicts rain for today and tomorrow based on a place name.
- **Body Parameters**:

   - `place`: The name of the place to get predictions for (e.g., "London").

- **Example**:

   ```bash
   curl -X POST http://localhost:3000/predict -H "Content-Type: application/json" -d '{"place": "London"}'
   ```

- **Response**:

   ```json
   {
     "Location": "London",
     "RainToday": false,
     "RainTomorrow": true
   }
   ```

### 3. `/predict_rain` (GET)

- **Description**: Predicts rain for today and tomorrow based on latitude and longitude.
- **Example**:

   ```bash
   curl "http://localhost:3000/predict_rain?lat=35.6895&lon=139.6917"
   ```

- **Response**:

   ```json
   {
     "Location": "Tokyo",
     "RainToday": false,
     "RainTomorrow": true
   }
   ```

---

## Models and Data

- The machine learning models (`rain_today_model.pkl` and `rain_tomorrow_model.pkl`) are pre-trained using a weather dataset. These models are loaded in the Flask app and used to make predictions.
- The `location_encoder.pkl` is a label encoder that transforms location names into numerical values for model predictions.

## Contribution

Feel free to fork this repository and create a pull request. If you encounter issues, please open an issue on the GitHub page.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Happy Coding!** 😊

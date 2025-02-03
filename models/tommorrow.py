import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.losses import MeanSquaredError  # Import the correct loss function

# Load the saved model from the .h5 file, specifying the correct loss function
loaded_model = load_model('lag_prediction_model.h5', custom_objects={'mse': MeanSquaredError()})

#'MinTemp', 'MaxTemp', 'Rainfall', 'Humidity', 'Pressure', 'WindSpeed'
new_data = np.array([[15.3, 25.6, 0.0, 85.0, 1010.2, 5.1]])  # Example values for lagged features

# Reshape the data to fit the LSTM input structure [samples, time steps, features]
new_data = new_data.reshape((new_data.shape[0], 1, new_data.shape[1]))

# Make prediction using the loaded model
predicted_values = loaded_model.predict(new_data)

# Output predicted values
print(f"Predicted Values: {predicted_values}")

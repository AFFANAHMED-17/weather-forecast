import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class RainPredictionScreen extends StatefulWidget {
  const RainPredictionScreen({Key? key}) : super(key: key);

  @override
  _RainPredictionScreenState createState() => _RainPredictionScreenState();
}

class _RainPredictionScreenState extends State<RainPredictionScreen> {
  String place = "";
  Map<String, dynamic>? predictionData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      predictionData = null;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Location services are disabled.';
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permissions are denied';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 'Location permissions are permanently denied.';
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String lat = position.latitude.toString();
      String lon = position.longitude.toString();
      place = "$lat,$lon";

      await fetchRainPrediction(lat, lon);
    } catch (e) {
      setState(() {
        _error = 'Failed to get location. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchRainPrediction(String lat, String lon) async {
    final url = Uri.parse('http://192.168.1.8:3000/predict_any');
    Map<String, String> body = {'lat': lat, 'lon': lon};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictionData = data;
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data['error'] ?? 'An unexpected error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data. Please ensure the backend is running.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPredictionCard(String title, Map<String, dynamic> data) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: title == 'Today' ? Colors.lightBlue[100] : Colors.lightGreen[100],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ).createShader(Rect.fromLTWH(0, 0, 100, 100)),
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              data['RainToday'] ? Icons.cloud : Icons.wb_sunny,
              color: data['RainToday'] ? Colors.blue : Colors.orange,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              'Location: ${data['Location']}',
              style: TextStyle(fontSize: 18, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 10),
            Text(
              'Rain Today: ${data['RainToday'] ? "☔ Yes" : "🌤️ No"}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: data['RainToday'] ? Colors.redAccent : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rain Tomorrow: ${data['RainTomorrow'] ? "☔ Yes" : "🌤️ No"}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: data['RainTomorrow'] ? Colors.redAccent : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[200]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : fetchUserLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.deepPurple,
                elevation: 10,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Refresh Rain Prediction'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 18),
              )
            else if (predictionData != null)
              Column(
                children: [
                  _buildPredictionCard('Today', {
                    "Location": predictionData!['Location'],
                    "RainToday": predictionData!['RainToday'],
                    "RainTomorrow": predictionData!['RainTomorrow']
                  }),
                  const SizedBox(height: 10),
                  _buildPredictionCard('Tomorrow', {
                    "Location": predictionData!['Location'],
                    "RainToday": predictionData!['RainToday'],
                    "RainTomorrow": predictionData!['RainTomorrow']
                  }),
                ],
              )
            else
              const Text(
                'Press the button to get rain prediction.',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}

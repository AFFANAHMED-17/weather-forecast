import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class UnifiedWeatherScreen extends StatefulWidget {
  const UnifiedWeatherScreen({Key? key}) : super(key: key);

  @override
  _UnifiedWeatherScreenState createState() => _UnifiedWeatherScreenState();
}

class _UnifiedWeatherScreenState extends State<UnifiedWeatherScreen> {
  String apiUrl = 'http://172.20.10.4:5000';

  // Rain Prediction Variables
  Map<String, dynamic>? predictionData;
  bool _isLoadingPrediction = false;
  String? _errorPrediction;

  // Forecast Variables
  Map<String, dynamic>? forecastData;
  bool _isLoadingForecast = false;

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    setState(() {
      _isLoadingPrediction = true;
      _errorPrediction = null;
      predictionData = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String lat = position.latitude.toString();
      String lon = position.longitude.toString();

      await fetchRainPrediction(lat, lon);
    } catch (e) {
      setState(() {
        _errorPrediction = e.toString();
        _isLoadingPrediction = false;
      });
    }
  }

  Future<void> fetchRainPrediction(String lat, String lon) async {
    final url = Uri.parse('$apiUrl/predict_any');
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
          _isLoadingPrediction = false;
        });
      } else {
        throw Exception('Failed to fetch prediction data.');
      }
    } catch (e) {
      setState(() {
        _errorPrediction = e.toString();
        _isLoadingPrediction = false;
      });
    }
  }

  Future<void> fetchSimulatedForecast() async {
    setState(() {
      _isLoadingForecast = true;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl/forecast_simulation'));

      if (response.statusCode == 200) {
        setState(() {
          forecastData = json.decode(response.body);
          _isLoadingForecast = false;
        });
      } else {
        throw Exception('Failed to fetch simulated forecast.');
      }
    } catch (e) {
      setState(() {
        _isLoadingForecast = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch simulated forecast data.')),
      );
    }
  }

  Future<void> fetchLiveForecast(String lat, String lon) async {
    setState(() {
      _isLoadingForecast = true;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl/live_forecast?lat=$lat&lon=$lon'));

      if (response.statusCode == 200) {
        setState(() {
          forecastData = json.decode(response.body);
          _isLoadingForecast = false;
        });
      } else {
        throw Exception('Failed to fetch live forecast.');
      }
    } catch (e) {
      setState(() {
        _isLoadingForecast = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch live forecast data.')),
      );
    }
  }

  Widget _buildPredictionCard(String title, Map<String, dynamic> data) {
    return Expanded(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: title == 'Today' ? Colors.lightBlue[100] : Colors.lightGreen[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Rain: ${data['RainToday'] ?? data['RainTomorrow'] ? "☔ Yes" : "🌤️ No"}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastView() {
    if (forecastData == null) return const Text('No forecast data available.');
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rain Start: ${forecastData!['rain_start'] ?? 'N/A'}'),
            Text('Rain End: ${forecastData!['rain_end'] ?? 'N/A'}'),
            Text('Duration: ${forecastData!['duration'] ?? 'N/A'}'),
            Text('Match Status: ${forecastData!['match_status'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[200]!, Colors.blue[800]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        ' Weather Prediction',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchUserLocation,
                        child: const Text('Refresh Prediction'),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoadingPrediction)
                        const CircularProgressIndicator()
                      else if (_errorPrediction != null)
                        Text(
                          _errorPrediction!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        )
                      else if (predictionData != null)
                        Row(
                          children: [
                            _buildPredictionCard('Today', predictionData!),
                            const SizedBox(width: 10),
                            _buildPredictionCard('Tomorrow', predictionData!),
                          ],
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchSimulatedForecast,
                        child: const Text('Get Live Forecast'),
                      ),
                      const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: () => fetchLiveForecast('12.97', '77.59'),
                      //   child: const Text('Get Live Forecast'),
                      // ),
                      const SizedBox(height: 20),
                      if (_isLoadingForecast)
                        const CircularProgressIndicator()
                      else if (forecastData != null)
                        _buildForecastView(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

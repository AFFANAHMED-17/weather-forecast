import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/forecast.dart';

class WeatherHomePage extends StatefulWidget {
  WeatherHomePage({Key? key}) : super(key: key);

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  List<Forecast> _forecasts = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Automatically get location when screen loads
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _forecasts = [];
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Location services are disabled.';
        _isLoading = false;
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
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
        _error =
            'Location permissions are permanently denied, we cannot request permissions.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      // Fetch weather after getting location
      fetchWeather();
    } catch (e) {
      setState(() {
        _error = 'Failed to get location. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWeather() async {
    if (_currentPosition == null) {
      setState(() {
        _error = "Unable to fetch your location.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _forecasts = [];
    });

    final lat = _currentPosition!.latitude.toString();
    final lon = _currentPosition!.longitude.toString();

    // Replace with your backend URL
    final backendUrl = 'http://172.20.10.4:5000/api/forecast';
    final url = Uri.parse('$backendUrl?lat=$lat&lon=$lon');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = data['list'];
        List<Forecast> forecasts =
            list.map((item) => Forecast.fromJson(item)).toList();
        setState(() {
          _forecasts = forecasts;
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data['error'] ?? 'An unexpected error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        _error =
            'Failed to fetch data. Please ensure the backend is running and accessible.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildForecastList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _forecasts.length,
        itemBuilder: (context, index) {
          final forecast = _forecasts[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Image.network(
                'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                width: 50,
                height: 50,
              ),
              title: Text(
                '${forecast.dateTime.toLocal()}'.split(' ')[0] +
                    ' ${forecast.dateTime.hour}:00',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                forecast.weatherDescription,
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                '${forecast.temperature}°C',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05), // Responsive padding
        child: Column(
          children: [
            // ElevatedButton(
            //   onPressed: _isLoading ? null : _getCurrentLocation,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blueAccent, // Updated parameter
            //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     textStyle: TextStyle(
            //       fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   child: Text('Refresh Forecast'),
            // ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_forecasts.isNotEmpty)
              buildForecastList()
            else
              Text(
                'Press the button to get weather forecast.',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/weather_home_page.dart';
import 'screens/rain_prediction_screen.dart';

void main() {
  runApp(WeatherRainApp());
}

class WeatherRainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather & Rain Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            title: Text('Weather & Rain Prediction'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Weather Forecast', icon: Icon(Icons.cloud)),
                Tab(text: 'Rain Prediction', icon: Icon(Icons.umbrella)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              WeatherHomePage(),
              RainPredictionScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

// //import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class MatchDetailsPage extends StatefulWidget {
//   final String team1;
//   final String team2;
//   final String venue;
//   final String date;

//   const MatchDetailsPage({
//     Key? key,
//     required this.team1,
//     required this.team2,
//     required this.venue,
//     required this.date,
//   }) : super(key: key);

//   @override
//   _MatchDetailsPageState createState() => _MatchDetailsPageState();
// }

// class _MatchDetailsPageState extends State<MatchDetailsPage> {
//   // Weather prediction data
//   Map<String, dynamic>? weatherData;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchWeatherData();
//   }

//   Future<void> fetchWeatherData() async {
//     const apiKey = 'f76969b2358dd421b3826dcc509ebf5d';
//     final city = widget.venue; // Assuming venue is a city name
//     final url = Uri.parse(
//         'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         setState(() {
//           weatherData = json.decode(response.body);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load weather data';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching weather: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Gradient Background
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue[200]!, Colors.blue[800]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Card(
//                 elevation: 10,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       // Match Information
//                       Text(
//                         '${widget.team1} vs ${widget.team2}',
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueAccent,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'Venue: ${widget.venue}',
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Date: ${widget.date}',
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       const SizedBox(height: 30),

//                       // Weather Prediction Section
//                       if (_isLoading)
//                         const CircularProgressIndicator()
//                       else if (_errorMessage != null)
//                         Text(
//                           _errorMessage!,
//                           style: const TextStyle(color: Colors.red, fontSize: 16),
//                         )
//                       else if (weatherData != null)
//                         Column(
//                           children: [
//                             const Text(
//                               'Weather Prediction',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             _buildPredictionRow('Temperature',
//                                 '${weatherData!['main']['temp']} °C'),
//                             _buildPredictionRow('Rain Probability',
//                                 '${weatherData!['clouds']['all']}%'),
//                             _buildPredictionRow('Humidity',
//                                 '${weatherData!['main']['humidity']}%'),
//                           ],
//                         )
//                       else
//                         const Text('No weather data available.'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build prediction rows
//   Widget _buildPredictionRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 18),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }//
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchDetailsPage extends StatefulWidget {
  final String team1;
  final String team2;
  final String venue;
  final String date;

  const MatchDetailsPage({
    Key? key,
    required this.team1,
    required this.team2,
    required this.venue,
    required this.date,
  }) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  // Weather prediction data
  Map<String, dynamic>? weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  // Map of team names to their corresponding flag assets
  final Map<String, String> teamFlags = {
    'India': 'assets/flags/ind.png',
    'Australia': 'assets/flags/aus.png',
    'England': 'assets/flags/eng.png',
    'Pakistan': 'assets/flags/pak.jpeg',
    'South Africa': 'assets/flags/sa.png',
    'New Zealand': 'assets/flags/nz.png',
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    const apiKey = 'f76969b2358dd421b3826dcc509ebf5d';
    final city = widget.venue; // Assuming venue is a city name
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
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
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Match Information with Flags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Flag for Team 1
                          _buildTeamWithFlag(widget.team1),
                          const SizedBox(width: 10),
                          const Text(
                            'vs',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Flag for Team 2
                          _buildTeamWithFlag(widget.team2),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Venue: ${widget.venue}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Date: ${widget.date}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 30),

                      // Weather Prediction Section
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        )
                      else if (weatherData != null)
                        Column(
                          children: [
                            const Text(
                              'Weather Prediction',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildWeatherCard(
                              'Temperature',
                              '${weatherData!['main']['temp']} °C',
                              Icons.thermostat,
                              Colors.orangeAccent,
                            ),
                            _buildWeatherCard(
                              'Rain Probability',
                              '${weatherData!['clouds']['all']}%',
                              Icons.cloud,
                              Colors.lightBlueAccent,
                            ),
                            _buildWeatherCard(
                              'Humidity',
                              '${weatherData!['main']['humidity']}%',
                              Icons.water_drop,
                              Colors.teal,
                            ),
                          ],
                        )
                      else
                        const Text('No weather data available.'),
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

  // Helper method to build weather cards
  Widget _buildWeatherCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Helper method to display a team name with its flag
  Widget _buildTeamWithFlag(String teamName) {
    return Row(
      children: [
        Image.asset(
          teamFlags[teamName]!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 8),
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

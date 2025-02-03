
import 'package:flutter/material.dart';
import 'screens/weather_home_page.dart';
import 'screens/rain_prediction_screen.dart';

import 'screens/match_details_page.dart';


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
      home: LoadingPage(), // Start with the Loading Page
    );
  }
}

// Loading Page
class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // Simulate a delay or loading task
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
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
                colors: [Colors.blue[300]!, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_outlined,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Weather Prediction App',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 30),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
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

// Login Page
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Dummy email and password for login
  String correctEmail_1 = 'viswaagatiya.cs22@bitsathy.ac.in';
  String correctPassword_1 = '11072004';
  String correctEmail_2 = 'vigneshwaran.cs22@bitsathy.ac.in';
  String correctPassword_2 = '01112004';
  String correctEmail_3 = 'affanahmed.cs22@bitsathy.ac.in';
  String correctPassword_3 = '20092004';
  String correctEmail_4 = 'riyas.cs22@bitsathy.ac.in';
  String correctPassword_4 = '12345678';
  

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        if (email == correctEmail_1 && password == correctPassword_1 ||
            email == correctEmail_2 && password == correctPassword_2 ||
            email == correctEmail_3 && password == correctPassword_3 ||
            email == correctEmail_4 && password == correctPassword_4) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainTabControllerPage()));
        } else {
          _showErrorDialog();
        }
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text('Incorrect email or password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
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
                colors: [Colors.blue[300]!, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_outlined,
                          size: 80,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Weather Prediction App',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                      ],
                    ),
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

// Main TabController Page (Unchanged)
class MainTabControllerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Weather & Rain Prediction'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Weather Forecast', icon: Icon(Icons.cloud)),
              Tab(text: 'Rain Prediction', icon: Icon(Icons.umbrella)),
            
              Tab(text: 'Cricket Matches', icon: Icon(Icons.sports_cricket)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WeatherHomePage(),
            UnifiedWeatherScreen(),
            HomePage(), // Display the list of matches in this tab
          ],
        ),
      ),
    );
  }
}


class CricketWeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Weather Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}class HomePage extends StatelessWidget {
  // Dummy data for upcoming matches
  final List<Map<String, String>> matches = [
    {
      'team1': 'India',
      'team2': 'Australia',
      'venue': 'Mumbai',
      'date': '2024-11-10',
    },
    {
      'team1': 'England',
      'team2': 'Pakistan',
      'venue': 'London',
      'date': '2024-11-12',
    },
    {
      'team1': 'South Africa',
      'team2': 'New Zealand',
      'venue': 'Johannesburg',
      'date': '2024-11-15',
    },
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Cricket Weather Predictor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blue[200],
        elevation: 0,
      ),
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
            child: ListView.builder(
              itemCount: matches.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final match = matches[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                teamFlags[match['team1']]!,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${match['team1']} vs ${match['team2']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                teamFlags[match['team2']]!,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Venue: ${match['venue']}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${match['date']}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to MatchDetailsPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchDetailsPage(
                                    team1: match['team1']!,
                                    team2: match['team2']!,
                                    venue: match['venue']!,
                                    date: match['date']!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

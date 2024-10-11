class Forecast {
  final DateTime dateTime;
  final double temperature;
  final String weatherDescription;
  final String icon;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.weatherDescription,
    required this.icon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      weatherDescription: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

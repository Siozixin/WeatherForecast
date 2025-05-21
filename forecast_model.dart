class Forecast {
  final DateTime dateTime;
  final String iconCode;
  final String condition;
  final double temp;
  final int humidity;
  final double windSpeed;

  Forecast({
    required this.dateTime,
    required this.iconCode,
    required this.condition,
    required this.temp,
    required this.humidity,
    required this.windSpeed,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.parse(json['dt_txt']),
      temp: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

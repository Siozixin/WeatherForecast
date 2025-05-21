// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_1/models/weather_model.dart';

// class WeatherService {
//   final String _apiKey = 'cb2b8d91b575d6d952157fdfb57894bb';

//   Future<Weather> fetchWeather(String cityName) async {
//     final url =
//         'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric';
//     final response = await http.get(Uri.parse(url));
    
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return Weather.fromJson(data);
//     } else {
//       throw Exception('Failed to fetch weather data');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  final String _apiKey = 'cb2b8d91b575d6d952157fdfb57894bb'; // Replace with your OpenWeatherMap API key
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> fetchWeather(String cityName) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<Forecast>> fetchForecast(String cityName) async {
    final response = await http.get(Uri.parse('$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];
      return forecastList.map((item) => Forecast.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/weather_service.dart';
import 'package:flutter_application_1/models/weather_model.dart';
import 'package:flutter_application_1/models/forecast_model.dart';
import 'package:flutter_application_1/graphs/forecast_graph_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = true;
  String _error = '';
  List<Forecast> _forecastList = [];

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.fetchWeather('Serdang');
      final forecast = await _weatherService.fetchForecast('Serdang');
      setState(() {
        _weather = weather;
        _forecastList = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getBackgroundColor(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return Colors.lightBlueAccent;
      case 'clouds':
        return Colors.grey.shade400;
      case 'rain':
        return Colors.blueGrey;
      default:
        return Colors.teal.shade200;
    }
  }

  List<Forecast> get todayForecasts {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfTomorrow = startOfToday.add(const Duration(days: 1));

  return _forecastList.where((forecast) {
    final dt = forecast.dateTime;
    // Include forecasts >= startOfToday AND <= startOfTomorrow (including exactly 00:00 tomorrow)
    return !dt.isBefore(startOfToday) && !dt.isAfter(startOfTomorrow);
  }).toList()
  ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(_weather!.description),
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
            // Limit max height, adjust as needed (e.g., 80% of screen height)
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // child: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
                  Text(
                    _weather!.cityName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    'https://openweathermap.org/img/wn/${_weather!.iconCode}@2x.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weather!.condition,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weather!.description[0].toUpperCase() + _weather!.description.substring(1),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)} °C',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text('Humidity: ${_weather!.humidity}%', style: const TextStyle(fontSize: 16)),
                  Text('Wind: ${_weather!.windSpeed} m/s', style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                   // Forecast Header
                  Text(
                    'Today\'s Forecast',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Forecast Overview
                  SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: todayForecasts.length,
                        itemBuilder: (context, index) {
                          final forecast = todayForecasts[index];
                          final time = '${forecast.dateTime.hour.toString().padLeft(2, '0')}:00';
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(time, style: const TextStyle(fontSize: 16)),
                                Image.network(
                                  'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                                  width: 50,
                                  height: 50,
                                ),
                                Text('${forecast.temp.toStringAsFixed(1)}°C'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🟢 Forecast Graph Table Widget (temperature, humidity, wind)
                    ForecastGraphTable(forecastList: todayForecasts),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}

// class _HomeScreenState extends State<HomeScreen> {
//   final WeatherService _weatherService = WeatherService();
//   Weather? _weather;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadWeather();
//   }

//   Future<void> _loadWeather() async {
//     try { //set location
//       Weather weather = await _weatherService.fetchWeather('Puchong'); // Replace with your default city
//       setState(() {
//         _weather = weather;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading weather: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Smart Weather")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _weather == null
//               ? const Center(child: Text("Failed to load weather"))
//               : Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _weather!.cityName,
//                         style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         "${_weather!.temperature.toStringAsFixed(1)}°C",
//                         style: const TextStyle(fontSize: 50),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         _weather!.condition,
//                         style: const TextStyle(fontSize: 24),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }
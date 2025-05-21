import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/models/forecast_model.dart';

enum WeatherMetric { temperature, humidity, wind }

class ForecastGraphTable extends StatefulWidget {
  final List<Forecast> forecastList;

  const ForecastGraphTable({super.key, required this.forecastList});

  @override
  State<ForecastGraphTable> createState() => _ForecastGraphTableState();
}

class _ForecastGraphTableState extends State<ForecastGraphTable> {
  WeatherMetric _selectedMetric = WeatherMetric.temperature;

  List<FlSpot> _buildSpots() {
  return widget.forecastList.asMap().entries.map((entry) {
    final index = entry.key.toDouble();
    final forecast = entry.value;
    double y;

    switch (_selectedMetric) {
      case WeatherMetric.temperature:
        y = forecast.temp;
        break;
      case WeatherMetric.humidity:
        y = forecast.humidity.toDouble();
        break;
      case WeatherMetric.wind:
        y = forecast.windSpeed;
        break;
    }

    return FlSpot(index, y);
  }).toList();
}

List<String> _buildTimeLabels() {
  return widget.forecastList.map((f) {
    final hour = f.dateTime.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }).toList();
}

  String _getMetricUnit() {
    switch (_selectedMetric) {
      case WeatherMetric.temperature:
        return '°C';
      case WeatherMetric.humidity:
        return '%';
      case WeatherMetric.wind:
        return 'm/s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final labels = _buildTimeLabels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔘 Toggle Buttons
        ToggleButtons(
          isSelected: [
            _selectedMetric == WeatherMetric.temperature,
            _selectedMetric == WeatherMetric.humidity,
            _selectedMetric == WeatherMetric.wind,
          ],
          onPressed: (index) {
            setState(() {
              _selectedMetric = WeatherMetric.values[index];
            });
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Temperature'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Humidity'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Wind'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 📈 Line Graph
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 60,
    interval: 1,
    getTitlesWidget: (value, meta) {
      final index = value.toInt();
      final forecasts = widget.forecastList;

      if (index < 0 || index >= forecasts.length) return const SizedBox();

      // Example: Show only every 2nd or 3rd point to avoid crowding
      if (index % 3 != 0) return const SizedBox();

      final forecast = forecasts[index];
      final hour = forecast.dateTime.hour.toString().padLeft(2, '0');

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://openweathermap.org/img/wn/${forecast.iconCode}.png',
            width: 25,
            height: 25,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 20),
          ),
          Text('$hour:00', style: const TextStyle(fontSize: 10)),
          Text(forecast.condition, style: const TextStyle(fontSize: 10)),
        ],
      );
    },
  ),
),
                
                // bottomTitles: AxisTitles(
                //   axisNameWidget: const Text('Time'),
                //   sideTitles: SideTitles(
                //     showTitles: true,
                //     reservedSize: 36,
                //     interval: 1,
                //     getTitlesWidget: (value, _) {
                //       if (value.toInt() < labels.length) {
                //         return Text(
                //           labels[value.toInt()],
                //           style: const TextStyle(fontSize: 10),
                //         );
                //       }
                //       return const Text('');
                //     },
                //   ),
                // ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(_getMetricUnit()),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 5,
                    getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0)),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
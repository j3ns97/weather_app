import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String? apiKey = dotenv.env['API_KEY'];

  Future<Weather> fetchWeather(String cityName) async {
    final response = await http.get(Uri.parse(
        '$baseUrl?q=$cityName&units=metric&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current weather data.');
    }
  }

  Future<void> saveWeatherData(String locality, Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = jsonEncode(weather.toJson());
    await prefs.setString('weather_$locality', weatherJson);
  }

  Future<Weather?> getWeatherData(String locality) async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = prefs.getString('weather_$locality');
    if (weatherJson == null) return null;

    final weatherMap = jsonDecode(weatherJson);
    return Weather.fromJson(weatherMap);
  }
}

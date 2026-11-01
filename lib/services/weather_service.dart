import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/geo_location.dart';

/// Service for communicating with Open-Meteo Weather and Geocoding APIs.
class WeatherService {
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const Duration _timeout = Duration(seconds: 15);

  /// Search cities by name using Open-Meteo Geocoding API.
  Future<List<GeoLocation>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_geocodingBaseUrl?name=${Uri.encodeComponent(query.trim())}&count=10&language=en&format=json',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) return [];

        return results
            .map((r) => GeoLocation.fromJson(r as Map<String, dynamic>))
            .toList();
      } else {
        throw WeatherServiceException(
          'Geocoding request failed with status ${response.statusCode}',
        );
      }
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException(
        'Failed to search cities. Please check your internet connection.',
      );
    }
  }

  /// Fetch comprehensive weather data for given coordinates.
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
  }) async {
    final uri = Uri.parse(
      '$_weatherBaseUrl?'
      'latitude=${latitude.toStringAsFixed(4)}'
      '&longitude=${longitude.toStringAsFixed(4)}'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m,'
      'visibility,uv_index'
      '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,'
      'weather_code,wind_speed_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'sunrise,sunset,uv_index_max,precipitation_probability_max'
      '&timezone=${Uri.encodeComponent(timezone)}'
      '&forecast_days=7',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(data);
      } else {
        throw WeatherServiceException(
          'Weather request failed with status ${response.statusCode}',
        );
      }
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException(
        'Failed to fetch weather data. Please check your internet connection.',
      );
    }
  }
}

/// Custom exception for weather service errors.
class WeatherServiceException implements Exception {
  final String message;
  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}

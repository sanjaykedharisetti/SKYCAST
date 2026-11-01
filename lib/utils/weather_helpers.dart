import 'package:flutter/material.dart';

/// Maps WMO weather codes to descriptions and icons.
class WeatherHelpers {
  /// Get human-readable weather description from WMO weather code.
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
        return 'Light Drizzle';
      case 53:
        return 'Moderate Drizzle';
      case 55:
        return 'Dense Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
        return 'Light Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
        return 'Light Snow';
      case 73:
        return 'Moderate Snow';
      case 75:
        return 'Heavy Snow';
      case 77:
        return 'Snow Grains';
      case 80:
        return 'Light Showers';
      case 81:
        return 'Moderate Showers';
      case 82:
        return 'Violent Showers';
      case 85:
        return 'Light Snow Showers';
      case 86:
        return 'Heavy Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }

  /// Get weather icon based on WMO code and day/night.
  static IconData getWeatherIcon(int code, {bool isDay = true}) {
    if (code == 0 || code == 1) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    if (code == 2) {
      return isDay ? Icons.cloud_queue_rounded : Icons.nights_stay_rounded;
    }
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if (code >= 61 && code <= 67) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.shower_rounded;
    if (code >= 85 && code <= 86) return Icons.ac_unit_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
  }

  /// Get weather icon color.
  static Color getWeatherIconColor(int code, {bool isDay = true}) {
    if (code == 0 || code == 1) {
      return isDay ? const Color(0xFFFFB300) : const Color(0xFFB0BEC5);
    }
    if (code == 2 || code == 3) return const Color(0xFF90A4AE);
    if (code == 45 || code == 48) return const Color(0xFF78909C);
    if (code >= 51 && code <= 67) return const Color(0xFF42A5F5);
    if (code >= 71 && code <= 86) return const Color(0xFFE0E0E0);
    if (code >= 95) return const Color(0xFFFFCA28);
    return const Color(0xFFFFB300);
  }

  /// Determine weather category for background gradients.
  static WeatherCondition getWeatherCondition(int code, {bool isDay = true}) {
    if (!isDay) return WeatherCondition.night;
    if (code == 0 || code == 1) return WeatherCondition.sunny;
    if (code == 2 || code == 3) return WeatherCondition.cloudy;
    if (code == 45 || code == 48) return WeatherCondition.cloudy;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherCondition.rainy;
    }
    if (code >= 71 && code <= 86) return WeatherCondition.snowy;
    if (code >= 95) return WeatherCondition.stormy;
    return WeatherCondition.sunny;
  }

  /// Get UV index risk category.
  static String getUVCategory(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  /// Get UV index color.
  static Color getUVColor(double uvIndex) {
    if (uvIndex <= 2) return const Color(0xFF4CAF50);
    if (uvIndex <= 5) return const Color(0xFFFFC107);
    if (uvIndex <= 7) return const Color(0xFFFF9800);
    if (uvIndex <= 10) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }

  /// Get wind direction string from degrees.
  static String getWindDirection(double degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((degrees / 22.5) + 0.5).toInt() % 16;
    return directions[index];
  }

  /// Format visibility in km.
  static String formatVisibility(double visibilityMeters) {
    final km = visibilityMeters / 1000.0;
    if (km >= 10) return '${km.toStringAsFixed(0)} km';
    return '${km.toStringAsFixed(1)} km';
  }
}

enum WeatherCondition { sunny, cloudy, rainy, snowy, stormy, night }

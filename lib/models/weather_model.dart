/// Strongly-typed model for weather data from Open-Meteo API.
class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final double utcOffsetSeconds;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.utcOffsetSeconds,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final utcOffset = (json['utc_offset_seconds'] ?? 0).toDouble();

    // Parse current weather
    final currentJson = json['current'] ?? json['current_weather'] ?? {};
    final current = CurrentWeather.fromJson(currentJson);

    // Parse hourly data
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final hourlyTimes = (hourlyJson['time'] as List<dynamic>?) ?? [];
    final hourlyTemps = (hourlyJson['temperature_2m'] as List<dynamic>?) ?? [];
    final hourlyCodes = (hourlyJson['weather_code'] as List<dynamic>?) ?? [];
    final hourlyPrecipProb =
        (hourlyJson['precipitation_probability'] as List<dynamic>?) ?? [];
    final hourlyHumidity =
        (hourlyJson['relative_humidity_2m'] as List<dynamic>?) ?? [];
    final hourlyWindSpeed =
        (hourlyJson['wind_speed_10m'] as List<dynamic>?) ?? [];

    final hourlyList = <HourlyForecast>[];
    for (int i = 0; i < hourlyTimes.length && i < hourlyTemps.length; i++) {
      hourlyList.add(
        HourlyForecast(
          time: DateTime.parse(hourlyTimes[i] as String),
          temperature: _toDouble(hourlyTemps[i]),
          weatherCode: _toInt(hourlyCodes.length > i ? hourlyCodes[i] : 0),
          precipitationProbability:
              hourlyPrecipProb.length > i ? _toInt(hourlyPrecipProb[i]) : null,
          humidity:
              hourlyHumidity.length > i ? _toDouble(hourlyHumidity[i]) : null,
          windSpeed:
              hourlyWindSpeed.length > i ? _toDouble(hourlyWindSpeed[i]) : null,
        ),
      );
    }

    // Parse daily data
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final dailyTimes = (dailyJson['time'] as List<dynamic>?) ?? [];
    final dailyMaxTemps =
        (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final dailyMinTemps =
        (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
    final dailyCodes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final dailyPrecipProb =
        (dailyJson['precipitation_probability_max'] as List<dynamic>?) ?? [];
    final dailySunrise = (dailyJson['sunrise'] as List<dynamic>?) ?? [];
    final dailySunset = (dailyJson['sunset'] as List<dynamic>?) ?? [];
    final dailyUVMax = (dailyJson['uv_index_max'] as List<dynamic>?) ?? [];

    final dailyList = <DailyForecast>[];
    for (int i = 0; i < dailyTimes.length; i++) {
      dailyList.add(
        DailyForecast(
          date: DateTime.parse(dailyTimes[i] as String),
          maxTemperature:
              dailyMaxTemps.length > i ? _toDouble(dailyMaxTemps[i]) : 0,
          minTemperature:
              dailyMinTemps.length > i ? _toDouble(dailyMinTemps[i]) : 0,
          weatherCode: dailyCodes.length > i ? _toInt(dailyCodes[i]) : 0,
          precipitationProbability:
              dailyPrecipProb.length > i ? _toInt(dailyPrecipProb[i]) : null,
          sunrise: dailySunrise.length > i
              ? DateTime.tryParse(dailySunrise[i] as String)
              : null,
          sunset: dailySunset.length > i
              ? DateTime.tryParse(dailySunset[i] as String)
              : null,
          uvIndexMax: dailyUVMax.length > i ? _toDouble(dailyUVMax[i]) : null,
        ),
      );
    }

    return WeatherData(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      timezone: (json['timezone'] as String?) ?? 'UTC',
      utcOffsetSeconds: utcOffset,
      current: current,
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class CurrentWeather {
  final double temperature;
  final double windSpeed;
  final double windDirection;
  final int weatherCode;
  final double? apparentTemperature;
  final double? humidity;
  final double? visibility;
  final double? uvIndex;
  final double? precipitation;
  final String? time;
  final int? isDay;

  const CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    this.apparentTemperature,
    this.humidity,
    this.visibility,
    this.uvIndex,
    this.precipitation,
    this.time,
    this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: _toDouble(json['temperature_2m'] ?? json['temperature']),
      windSpeed: _toDouble(json['wind_speed_10m'] ?? json['windspeed']),
      windDirection: _toDouble(
        json['wind_direction_10m'] ?? json['winddirection'],
      ),
      weatherCode: _toInt(json['weather_code'] ?? json['weathercode'] ?? 0),
      apparentTemperature: json['apparent_temperature'] != null
          ? _toDouble(json['apparent_temperature'])
          : null,
      humidity: json['relative_humidity_2m'] != null
          ? _toDouble(json['relative_humidity_2m'])
          : null,
      visibility:
          json['visibility'] != null ? _toDouble(json['visibility']) : null,
      uvIndex: json['uv_index'] != null ? _toDouble(json['uv_index']) : null,
      precipitation: json['precipitation'] != null
          ? _toDouble(json['precipitation'])
          : null,
      time: json['time'] as String?,
      isDay: json['is_day'] != null ? _toInt(json['is_day']) : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int? precipitationProbability;
  final double? humidity;
  final double? windSpeed;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    this.precipitationProbability,
    this.humidity,
    this.windSpeed,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;
  final int? precipitationProbability;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? uvIndexMax;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    this.precipitationProbability,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
  });
}

import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/geo_location.dart';
import '../utils/weather_helpers.dart';
import '../utils/date_time_helpers.dart';

/// Responsive main weather card showing current conditions.
class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weatherData;
  final GeoLocation location;

  const CurrentWeatherCard({
    super.key,
    required this.weatherData,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final isDay = current.isDay != null ? current.isDay == 1 : true;
    final localTime = DateTimeHelpers.getLocalTime(
      weatherData.utcOffsetSeconds,
    );

    // Get today's daily data for max/min temps
    final todayDaily =
        weatherData.daily.isNotEmpty ? weatherData.daily.first : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 360;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: isCompact ? 16 : 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location: Constrained so Flexible truncates if city name is long
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location.shortDisplayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 16 : 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Date and time
              Text(
                DateTimeHelpers.formatFullDate(localTime),
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateTimeHelpers.formatTime12h(localTime),
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: isCompact ? 12 : 13,
                ),
              ),
              SizedBox(height: isCompact ? 16 : 20),

              // Weather icon
              Icon(
                WeatherHelpers.getWeatherIcon(
                  current.weatherCode,
                  isDay: isDay,
                ),
                size: isCompact ? 64 : 76,
                color: WeatherHelpers.getWeatherIconColor(
                  current.weatherCode,
                  isDay: isDay,
                ),
              ),
              const SizedBox(height: 12),

              // Temperature: FittedBox prevents any horizontal clipping
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${current.temperature.round()}°',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 68 : 80,
                    fontWeight: FontWeight.w200,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Weather description
              Text(
                WeatherHelpers.getWeatherDescription(current.weatherCode),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Feels like + H/L
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (current.apparentTemperature != null)
                    Text(
                      'Feels like ${current.apparentTemperature!.round()}°',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: isCompact ? 13 : 14,
                      ),
                    ),
                  if (todayDaily != null)
                    Text(
                      'H: ${todayDaily.maxTemperature.round()}°  L: ${todayDaily.minTemperature.round()}°',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: isCompact ? 13 : 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

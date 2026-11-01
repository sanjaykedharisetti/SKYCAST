import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_helpers.dart';
import '../utils/date_time_helpers.dart';

/// Responsive horizontal scrolling hourly forecast widget.
class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyData;
  final double utcOffsetSeconds;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyData,
    required this.utcOffsetSeconds,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 360;
        final horizontalMargin = isCompact ? 10.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin + 4),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.white.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: isCompact ? 15 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 136,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                itemCount: hourlyData.length,
                itemBuilder: (context, index) {
                  final hour = hourlyData[index];
                  final isNow = index == 0;

                  return Container(
                    width: isCompact ? 68 : 74,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isNow
                          ? Colors.white.withAlpha(40)
                          : Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(18),
                      border: isNow
                          ? Border.all(
                              color: Colors.white.withAlpha(70),
                              width: 1,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          isNow ? 'Now' : DateTimeHelpers.formatHour(hour.time),
                          style: TextStyle(
                            color: Colors.white.withAlpha(isNow ? 255 : 180),
                            fontSize: isCompact ? 11 : 12,
                            fontWeight:
                                isNow ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        Icon(
                          WeatherHelpers.getWeatherIcon(
                            hour.weatherCode,
                            isDay: hour.time.hour >= 6 && hour.time.hour < 18,
                          ),
                          color: WeatherHelpers.getWeatherIconColor(
                            hour.weatherCode,
                            isDay: hour.time.hour >= 6 && hour.time.hour < 18,
                          ),
                          size: isCompact ? 24 : 26,
                        ),
                        Text(
                          '${hour.temperature.round()}°',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 15 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hour.precipitationProbability != null &&
                            hour.precipitationProbability! > 0)
                          Text(
                            '${hour.precipitationProbability}%',
                            style: TextStyle(
                              color: Colors.lightBlueAccent.withAlpha(220),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

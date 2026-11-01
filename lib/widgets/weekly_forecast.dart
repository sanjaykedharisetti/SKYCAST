import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_helpers.dart';
import '../utils/date_time_helpers.dart';

/// Responsive seven-day weather forecast list.
class WeeklyForecast extends StatelessWidget {
  final List<DailyForecast> dailyData;

  const WeeklyForecast({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) return const SizedBox.shrink();

    // Calculate overall min/max temperatures for consistent bar visualization
    double minTempAll = double.infinity;
    double maxTempAll = double.negativeInfinity;
    for (final d in dailyData) {
      if (d.minTemperature < minTempAll) minTempAll = d.minTemperature;
      if (d.maxTemperature > maxTempAll) maxTempAll = d.maxTemperature;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 360;
        final horizontalMargin = isCompact ? 10.0 : 16.0;
        final horizontalPadding = isCompact ? 10.0 : 14.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin + 4),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.white.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dailyData.length}-Day Forecast',
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: List.generate(dailyData.length, (index) {
                  final day = dailyData[index];
                  final isToday = DateTimeHelpers.isToday(day.date);
                  final isLast = index == dailyData.length - 1;

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Colors.white.withAlpha(20),
                                width: 0.5,
                              ),
                            ),
                    ),
                    child: _buildForecastRow(
                      context,
                      day,
                      isToday,
                      screenWidth,
                      minTempAll,
                      maxTempAll,
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForecastRow(
    BuildContext context,
    DailyForecast day,
    bool isToday,
    double availableWidth,
    double minTempAll,
    double maxTempAll,
  ) {
    final isCompact = availableWidth < 360;
    final showCondition = availableWidth >= 380;
    final dayLabelWidth = isCompact ? 48.0 : 56.0;

    // Responsive temperature bar width
    final double tempBarWidth;
    if (availableWidth < 340) {
      tempBarWidth = 36.0;
    } else if (availableWidth < 420) {
      tempBarWidth = 46.0;
    } else if (availableWidth < 600) {
      tempBarWidth = 60.0;
    } else {
      tempBarWidth = 80.0;
    }

    final hasPrecipitation = day.precipitationProbability != null &&
        day.precipitationProbability! > 0;

    return Row(
      children: [
        // 1. Day label & precipitation probability (stacked compactly)
        SizedBox(
          width: dayLabelWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isToday ? 'Today' : DateTimeHelpers.formatDayShort(day.date),
                style: TextStyle(
                  color: Colors.white.withAlpha(isToday ? 255 : 200),
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasPrecipitation)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 10,
                      color: Colors.lightBlueAccent.withAlpha(220),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${day.precipitationProbability}%',
                      style: TextStyle(
                        color: Colors.lightBlueAccent.withAlpha(220),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // 2. Weather condition icon
        Icon(
          WeatherHelpers.getWeatherIcon(day.weatherCode),
          color: WeatherHelpers.getWeatherIconColor(day.weatherCode),
          size: isCompact ? 20 : 22,
        ),

        // 3. Condition description (takes remaining middle space or Spacer)
        if (showCondition) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              WeatherHelpers.getWeatherDescription(day.weatherCode),
              style: TextStyle(
                color: Colors.white.withAlpha(160),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),

        const SizedBox(width: 6),

        // 4. Temperature range: Min temp, dynamic progress bar, Max temp
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Min temp
            SizedBox(
              width: 30,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${day.minTemperature.round()}°',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Temperature range bar
            SizedBox(
              width: tempBarWidth,
              child: _buildTempBar(day, tempBarWidth, minTempAll, maxTempAll),
            ),
            const SizedBox(width: 6),

            // Max temp
            SizedBox(
              width: 30,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${day.maxTemperature.round()}°',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTempBar(
    DailyForecast day,
    double barWidth,
    double minTempAll,
    double maxTempAll,
  ) {
    final range = maxTempAll - minTempAll;
    if (range <= 0) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(60),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    final leftFraction = ((day.minTemperature - minTempAll) / range).clamp(
      0.0,
      1.0,
    );
    final rightFraction = ((maxTempAll - day.maxTemperature) / range).clamp(
      0.0,
      1.0,
    );

    final leftPadding = (leftFraction * barWidth).clamp(0.0, barWidth - 4.0);
    final rightPadding = (rightFraction * barWidth).clamp(0.0, barWidth - 4.0);
    final safeRightPadding = (barWidth - leftPadding - 4.0).clamp(
      0.0,
      rightPadding,
    );

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding, right: safeRightPadding),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_helpers.dart';
import '../utils/date_time_helpers.dart';

/// Responsive grid of weather detail cards.
class WeatherDetailsGrid extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailsGrid({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final todayDaily =
        weatherData.daily.isNotEmpty ? weatherData.daily.first : null;

    final details = <_DetailItem>[];

    // Humidity
    if (current.humidity != null) {
      details.add(
        _DetailItem(
          icon: Icons.water_drop_outlined,
          label: 'Humidity',
          value: '${current.humidity!.round()}%',
          subtitle: _getHumidityDescription(current.humidity!),
          iconColor: const Color(0xFF42A5F5),
        ),
      );
    }

    // Wind
    details.add(
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${current.windSpeed.round()} km/h',
        subtitle: WeatherHelpers.getWindDirection(current.windDirection),
        iconColor: const Color(0xFF78909C),
      ),
    );

    // UV Index
    final uvIndex = current.uvIndex ?? todayDaily?.uvIndexMax;
    if (uvIndex != null) {
      details.add(
        _DetailItem(
          icon: Icons.wb_sunny_outlined,
          label: 'UV Index',
          value: uvIndex.toStringAsFixed(1),
          subtitle: WeatherHelpers.getUVCategory(uvIndex),
          iconColor: WeatherHelpers.getUVColor(uvIndex),
        ),
      );
    }

    // Visibility
    if (current.visibility != null) {
      details.add(
        _DetailItem(
          icon: Icons.visibility_outlined,
          label: 'Visibility',
          value: WeatherHelpers.formatVisibility(current.visibility!),
          subtitle: current.visibility! >= 10000 ? 'Clear' : 'Limited',
          iconColor: const Color(0xFF90A4AE),
        ),
      );
    }

    // Sunrise
    if (todayDaily?.sunrise != null) {
      details.add(
        _DetailItem(
          icon: Icons.wb_twilight_rounded,
          label: 'Sunrise',
          value: DateTimeHelpers.formatTime12h(todayDaily!.sunrise!),
          subtitle: 'Dawn',
          iconColor: const Color(0xFFFFB74D),
        ),
      );
    }

    // Sunset
    if (todayDaily?.sunset != null) {
      details.add(
        _DetailItem(
          icon: Icons.nightlight_round,
          label: 'Sunset',
          value: DateTimeHelpers.formatTime12h(todayDaily!.sunset!),
          subtitle: 'Dusk',
          iconColor: const Color(0xFFFF8A65),
        ),
      );
    }

    // Feels like
    if (current.apparentTemperature != null) {
      details.add(
        _DetailItem(
          icon: Icons.thermostat_rounded,
          label: 'Feels Like',
          value: '${current.apparentTemperature!.round()}°',
          subtitle: _getFeelsLikeDescription(
            current.temperature,
            current.apparentTemperature!,
          ),
          iconColor: const Color(0xFFEF5350),
        ),
      );
    }

    // Precipitation
    if (current.precipitation != null) {
      details.add(
        _DetailItem(
          icon: Icons.umbrella_rounded,
          label: 'Precipitation',
          value: '${current.precipitation!.toStringAsFixed(1)} mm',
          subtitle: current.precipitation! > 0 ? 'Active' : 'None',
          iconColor: const Color(0xFF29B6F6),
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 360;
        final horizontalMargin = isCompact ? 10.0 : 16.0;

        // Adaptive column count and aspect ratio based on available width
        final int crossAxisCount;
        final double childAspectRatio;

        if (screenWidth < 310) {
          crossAxisCount = 1;
          childAspectRatio = 2.4;
        } else if (screenWidth < 600) {
          crossAxisCount = 2;
          if (screenWidth < 350) {
            childAspectRatio = 1.15;
          } else if (screenWidth < 400) {
            childAspectRatio = 1.25;
          } else {
            childAspectRatio = 1.35;
          }
        } else if (screenWidth < 850) {
          crossAxisCount = 3;
          childAspectRatio = 1.35;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 1.45;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin + 4),
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    size: 16,
                    color: Colors.white.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weather Details',
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isCompact ? 6 : 8,
                  mainAxisSpacing: isCompact ? 6 : 8,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: details.length,
                itemBuilder: (context, index) {
                  return _buildDetailCard(details[index], isCompact);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailCard(_DetailItem item, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon + Label
          Row(
            children: [
              Icon(item.icon, size: 15, color: item.iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Value: Scaled with FittedBox so it never overflows
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 19 : 21,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Subtitle
          Text(
            item.subtitle.isNotEmpty ? item.subtitle : ' ',
            style: TextStyle(
              color: Colors.white.withAlpha(130),
              fontSize: isCompact ? 11 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getHumidityDescription(double humidity) {
    if (humidity < 30) return 'Dry';
    if (humidity < 60) return 'Comfortable';
    if (humidity < 80) return 'Humid';
    return 'Very Humid';
  }

  String _getFeelsLikeDescription(double actual, double feelsLike) {
    final diff = feelsLike - actual;
    if (diff.abs() < 2) return 'Similar';
    if (diff > 0) return 'Warmer';
    return 'Cooler';
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color iconColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.iconColor,
  });
}

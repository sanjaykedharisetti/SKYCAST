import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/weather_helpers.dart';
import '../utils/date_time_helpers.dart';
import '../widgets/weather_background.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/weekly_forecast.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/city_search_field.dart';

/// Main weather dashboard screen.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherProvider, ThemeProvider>(
      builder: (context, weatherProvider, themeProvider, _) {
        final weatherData = weatherProvider.weatherData;
        final isDay = weatherData?.current.isDay != null
            ? weatherData!.current.isDay == 1
            : true;
        final weatherCode = weatherData?.current.weatherCode ?? 0;
        final condition = WeatherHelpers.getWeatherCondition(
          weatherCode,
          isDay: isDay,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: WeatherBackground(
            condition: weatherData != null ? condition : WeatherCondition.sunny,
            isDarkMode: themeProvider.isDarkMode,
            child: SafeArea(
              child: _buildContent(context, weatherProvider, themeProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WeatherProvider provider,
    ThemeProvider themeProvider,
  ) {
    if (provider.isLoading && !provider.hasData) {
      return _buildLoadingState(context);
    }

    if (provider.errorMessage != null && !provider.hasData) {
      return _buildErrorState(context, provider);
    }

    if (!provider.hasData) {
      return _buildLoadingState(context);
    }

    return _buildDashboard(context, provider, themeProvider);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading weather data...',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WeatherProvider provider) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Colors.white54,
              ),
              const SizedBox(height: 20),
              Text(
                provider.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => provider.refreshWeather(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(30),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WeatherProvider provider,
    ThemeProvider themeProvider,
  ) {
    final weatherData = provider.weatherData!;
    final location = provider.selectedLocation!;

    // Filter hourly data to next 24 hours from now
    final now = DateTimeHelpers.getLocalTime(weatherData.utcOffsetSeconds);
    final hourlyData = weatherData.hourly.where((h) {
      return h.time.isAfter(now.subtract(const Duration(hours: 1))) &&
          h.time.isBefore(now.add(const Duration(hours: 25)));
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWide = screenWidth > 800;
        final isCompact = screenWidth < 360;
        final maxWidth = isWide ? 900.0 : double.infinity;

        return RefreshIndicator(
          onRefresh: () => provider.refreshWeather(),
          color: Colors.white,
          backgroundColor: Colors.white.withAlpha(30),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App bar
                    _buildAppBar(context, provider, themeProvider, isCompact),

                    // Cached indicator
                    if (provider.isCached)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Colors.orange.shade200,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                provider.errorMessage ?? 'Showing cached data',
                                style: TextStyle(
                                  color: Colors.orange.shade200,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Loading overlay for background refresh
                    if (provider.isLoading && provider.hasData)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withAlpha(20),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withAlpha(100),
                            ),
                          ),
                        ),
                      ),

                    // Current weather
                    CurrentWeatherCard(
                      weatherData: weatherData,
                      location: location,
                    ),

                    // Hourly forecast
                    if (hourlyData.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      HourlyForecastWidget(
                        hourlyData: hourlyData,
                        utcOffsetSeconds: weatherData.utcOffsetSeconds,
                      ),
                    ],

                    SizedBox(height: isCompact ? 16 : 20),

                    // Weekly forecast
                    if (weatherData.daily.isNotEmpty)
                      WeeklyForecast(dailyData: weatherData.daily),

                    SizedBox(height: isCompact ? 16 : 20),

                    // Weather details
                    WeatherDetailsGrid(weatherData: weatherData),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WeatherProvider provider,
    ThemeProvider themeProvider,
    bool isCompact,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          // Logo / Brand
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: isCompact ? 20 : 22,
              ),
              const SizedBox(width: 6),
              Text(
                'SKYCAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 16 : 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isCompact ? 1.0 : 1.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Search button
          IconButton(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(6),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CitySearchDelegate(),
              );
            },
            icon: const Icon(Icons.search_rounded, size: 20),
            color: Colors.white,
            tooltip: 'Search City',
          ),

          // Refresh button
          IconButton(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(6),
            onPressed:
                provider.isLoading ? null : () => provider.refreshWeather(),
            icon: provider.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            color: Colors.white,
            tooltip: 'Refresh',
          ),

          // Theme toggle
          IconButton(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(6),
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 20,
            ),
            color: Colors.white,
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
    );
  }
}

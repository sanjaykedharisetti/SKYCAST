import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/geo_location.dart';
import '../services/weather_service.dart';

/// Central weather state management provider.
class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  // State
  WeatherData? _weatherData;
  GeoLocation? _selectedLocation;
  List<GeoLocation> _searchResults = [];
  List<GeoLocation> _recentSearches = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isCached = false;
  String? _errorMessage;

  // Getters
  WeatherData? get weatherData => _weatherData;
  GeoLocation? get selectedLocation => _selectedLocation;
  List<GeoLocation> get searchResults => _searchResults;
  List<GeoLocation> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isCached => _isCached;
  String? get errorMessage => _errorMessage;
  bool get hasData => _weatherData != null;

  WeatherProvider() {
    _loadRecentSearches();
    _loadDefaultCity();
  }

  /// Load default city (Hyderabad) on first launch.
  Future<void> _loadDefaultCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString('skycast_last_location');

    if (savedLocation != null) {
      try {
        final locationJson = json.decode(savedLocation) as Map<String, dynamic>;
        _selectedLocation = GeoLocation.fromJson(locationJson);
        await fetchWeather();
        return;
      } catch (_) {
        // Fall through to default.
      }
    }

    // Default to Hyderabad, India
    _selectedLocation = const GeoLocation(
      id: 1269843,
      name: 'Hyderabad',
      latitude: 17.3850,
      longitude: 78.4867,
      country: 'India',
      admin1: 'Telangana',
      timezone: 'Asia/Kolkata',
    );
    await fetchWeather();
  }

  /// Search cities with the given query.
  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _service.searchCities(query);
    } catch (e) {
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Select a location and fetch its weather.
  Future<void> selectLocation(GeoLocation location) async {
    _selectedLocation = location;
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();

    // Save to recent searches
    await _addToRecentSearches(location);

    // Save as last location
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'skycast_last_location',
        json.encode(location.toJson()),
      );
    } catch (_) {}

    await fetchWeather();
  }

  /// Fetch weather for the current selected location.
  Future<void> fetchWeather() async {
    if (_selectedLocation == null) return;

    _isLoading = true;
    _errorMessage = null;
    _isCached = false;
    notifyListeners();

    try {
      _weatherData = await _service.fetchWeather(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        timezone: _selectedLocation!.timezone ?? 'auto',
      );
      _isCached = false;
      _errorMessage = null;

      // Cache the weather data
      await _cacheWeatherData();
    } catch (e) {
      // Try loading cached data
      final cached = await _loadCachedWeather();
      if (cached != null) {
        _weatherData = cached;
        _isCached = true;
        _errorMessage = 'Showing cached data. Tap refresh to retry.';
      } else {
        _errorMessage = e.toString();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh weather data.
  Future<void> refreshWeather() async {
    await fetchWeather();
  }

  // --- Recent Searches ---

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = prefs.getStringList('skycast_recent_searches') ?? [];
      _recentSearches = recentJson
          .map((s) {
            try {
              return GeoLocation.fromJson(
                json.decode(s) as Map<String, dynamic>,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<GeoLocation>()
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _addToRecentSearches(GeoLocation location) async {
    _recentSearches.removeWhere((l) => l.id == location.id);
    _recentSearches.insert(0, location);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson =
          _recentSearches.map((l) => json.encode(l.toJson())).toList();
      await prefs.setStringList('skycast_recent_searches', recentJson);
    } catch (_) {}
  }

  /// Clear a single recent search.
  Future<void> removeRecentSearch(GeoLocation location) async {
    _recentSearches.removeWhere((l) => l.id == location.id);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson =
          _recentSearches.map((l) => json.encode(l.toJson())).toList();
      await prefs.setStringList('skycast_recent_searches', recentJson);
    } catch (_) {}
  }

  // --- Caching ---

  Future<void> _cacheWeatherData() async {
    // Simple cache: store the raw JSON would require re-fetching.
    // Instead we just mark the last successful fetch time.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'skycast_cache_time',
        DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  Future<WeatherData?> _loadCachedWeather() async {
    // For simplicity, we return null since we don't persist the full JSON.
    // The existing _weatherData in memory serves as the cache.
    return _weatherData;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

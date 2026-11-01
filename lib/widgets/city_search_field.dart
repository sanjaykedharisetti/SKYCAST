import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/geo_location.dart';

/// City search dialog with autocomplete and recent searches.
class CitySearchDelegate extends StatefulWidget {
  const CitySearchDelegate({super.key});

  @override
  State<CitySearchDelegate> createState() => _CitySearchDelegateState();
}

class _CitySearchDelegateState extends State<CitySearchDelegate> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<WeatherProvider>().searchCities(query);
      }
    });
  }

  void _selectLocation(GeoLocation location) {
    context.read<WeatherProvider>().selectLocation(location);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: (screenHeight * 0.8).clamp(320.0, 600.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            context.read<WeatherProvider>().searchCities('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  _onSearchChanged(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _debounceTimer?.cancel();
                    context.read<WeatherProvider>().searchCities(value);
                  }
                },
              ),
            ),

            // Results
            Flexible(
              child: Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  if (provider.isSearching) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (_controller.text.isNotEmpty &&
                      provider.searchResults.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final location = provider.searchResults[index];
                        return _buildLocationTile(
                          location,
                          theme,
                          isRecent: false,
                        );
                      },
                    );
                  }

                  if (_controller.text.isNotEmpty &&
                      provider.searchResults.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No cities found',
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different spelling',
                            style: TextStyle(
                              color: theme.colorScheme.outline.withAlpha(150),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show recent searches
                  if (provider.recentSearches.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Text(
                            'Recent Searches',
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemCount: provider.recentSearches.length,
                            itemBuilder: (context, index) {
                              final location = provider.recentSearches[index];
                              return _buildLocationTile(
                                location,
                                theme,
                                isRecent: true,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // Empty state
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Search for a city',
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    GeoLocation location,
    ThemeData theme, {
    required bool isRecent,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        isRecent ? Icons.history_rounded : Icons.location_on_outlined,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        location.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        location.displayName,
        style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isRecent
          ? IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: theme.colorScheme.outline,
              ),
              onPressed: () {
                context.read<WeatherProvider>().removeRecentSearch(location);
              },
            )
          : null,
      onTap: () => _selectLocation(location),
    );
  }
}

/// Model for geocoding search results from Open-Meteo Geocoding API.
class GeoLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // state/province
  final String? timezone;

  const GeoLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.timezone,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Formatted display string for the location.
  String get displayName {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Short display: city, country.
  String get shortDisplayName {
    if (country != null && country!.isNotEmpty) {
      return '$name, $country';
    }
    return name;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
        'timezone': timezone,
      };
}

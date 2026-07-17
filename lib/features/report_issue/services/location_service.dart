import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum LocationFailureCode {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  gpsUnavailable,
  addressUnavailable,
  unknown,
}

class LocationServiceFailure implements Exception {
  const LocationServiceFailure(
    this.message, {
    this.code = LocationFailureCode.unknown,
  });

  final String message;
  final LocationFailureCode code;
}

class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.components,
    required this.placeId,
    required this.locationTimestamp,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
  final Map<String, String> components;
  final String placeId;
  final DateTime locationTimestamp;
}

class LocationService {
  const LocationService();

  Future<LocationResult> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceFailure(
        'Unable to detect your location. Please enter your address manually.',
        code: LocationFailureCode.servicesDisabled,
      );
    }

    final ph.PermissionStatus current =
        await ph.Permission.locationWhenInUse.status;
    ph.PermissionStatus status = current;
    if (!status.isGranted) {
      status = await ph.Permission.locationWhenInUse.request();
    }

    if (status.isDenied || status.isRestricted || status.isLimited) {
      throw const LocationServiceFailure(
        'Location permission is required to detect your current address automatically.',
        code: LocationFailureCode.permissionDenied,
      );
    }

    if (status.isPermanentlyDenied) {
      throw const LocationServiceFailure(
        'Location permission is required to detect your current address automatically.',
        code: LocationFailureCode.permissionDeniedForever,
      );
    }

    Position? position;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
        break;
      } catch (_) {
        if (attempt == 2) {
          position = await Geolocator.getLastKnownPosition();
        }
      }
    }

    if (position == null) {
      throw const LocationServiceFailure(
        'Unable to detect your location. Please enter your address manually.',
        code: LocationFailureCode.gpsUnavailable,
      );
    }

    return reverseGeocodeCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<LocationResult> reverseGeocodeCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(latitude, longitude);
    } catch (_) {
      throw const LocationServiceFailure(
        'Unable to detect your location. Please enter your address manually.',
        code: LocationFailureCode.addressUnavailable,
      );
    }

    if (placemarks.isEmpty) {
      throw const LocationServiceFailure(
        'Unable to detect your location. Please enter your address manually.',
        code: LocationFailureCode.addressUnavailable,
      );
    }

    final Placemark first = placemarks.first;
    final Map<String, String> components = <String, String>{
      'houseFlat': _clean(first.subThoroughfare),
      'buildingName': _clean(first.name),
      'street': _clean(first.thoroughfare),
      'landmark': _clean(first.subLocality),
      'area': _clean(first.subLocality),
      'villageTown': _clean(first.locality),
      'mandal': _clean(first.subAdministrativeArea),
      'district': _clean(first.subAdministrativeArea),
      'city': _clean(first.locality),
      'state': _clean(first.administrativeArea),
      'country': _clean(first.country),
      'pinCode': _clean(first.postalCode),
    }..removeWhere((String _, String value) => value.isEmpty);

    final List<String> lines = <String>[
      _clean(first.name),
      _clean(first.subThoroughfare),
      _clean(first.thoroughfare),
      _clean(first.subLocality),
      _clean(first.locality),
      _clean(first.subAdministrativeArea),
      _clean(first.administrativeArea),
      _clean(first.postalCode),
      _clean(first.country),
    ].where((String part) => part.isNotEmpty).toSet().toList(growable: false);

    if (lines.isEmpty) {
      throw const LocationServiceFailure(
        'Unable to detect your location. Please enter your address manually.',
        code: LocationFailureCode.addressUnavailable,
      );
    }

    final String formattedAddress = lines.join(', ');

    return LocationResult(
      latitude: latitude,
      longitude: longitude,
      formattedAddress: formattedAddress,
      components: components,
      placeId: '${latitude.toStringAsFixed(5)}_${longitude.toStringAsFixed(5)}',
      locationTimestamp: DateTime.now().toUtc(),
    );
  }

  String _clean(String? value) {
    return (value ?? '').trim();
  }
}

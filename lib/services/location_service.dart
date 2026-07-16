import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  /// Verificar y solicitar permisos de ubicación
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Obtener ubicación actual
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convertir coordenadas a dirección legible
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*$'), '')
            .replaceAll(RegExp(r',\s*,+'), ', ')
            .trim();
      }
      return 'Dirección no encontrada';
    } catch (e) {
      return 'Error al obtener dirección';
    }
  }

  /// Obtiene el distrito aproximado desde coordenadas (Cusco)
  Future<String?> getDistritoFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final candidates = [
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ];

      const distritosConocidos = {
        'cusco': 'Cusco',
        'wanchaq': 'Wanchaq',
        'santiago': 'Santiago',
        'san sebastián': 'San Sebastián',
        'san sebastian': 'San Sebastián',
        'san jerónimo': 'San Jerónimo',
        'san jeronomo': 'San Jerónimo',
        'saylla': 'Saylla',
        'poroy': 'Poroy',
        'ccorca': 'Ccorca',
        'san salvador': 'San Salvador',
      };

      for (final candidate in candidates) {
        if (candidate == null || candidate.trim().isEmpty) continue;
        final key = candidate.trim().toLowerCase();
        if (distritosConocidos.containsKey(key)) {
          return distritosConocidos[key];
        }
        for (final entry in distritosConocidos.entries) {
          if (key.contains(entry.key)) return entry.value;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Abrir Google Maps con la ubicación
  Future<void> openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await launchUrl(Uri.parse(url));
  }
}
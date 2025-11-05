// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart';

class GpsService {
static Future<Position?> obtenerUbicacion() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    print("GPS desactivado");
    return null;
  }

  LocationPermission permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) {
      print("Permiso denegado");
      return null;
    }
  }

  if (permiso == LocationPermission.deniedForever) {
    print("Permiso denegado para siempre");
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}


  static double distanciaMetros(Position actual, double lat, double lng) {
    return Geolocator.distanceBetween(
      actual.latitude,
      actual.longitude,
      lat,
      lng,
    );
  }
}

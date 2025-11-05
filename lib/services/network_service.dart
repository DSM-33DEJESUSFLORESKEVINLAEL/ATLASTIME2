// ignore_for_file: unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {

  /// Retorna true si el dispositivo está conectado por Wi-Fi
  static Future<bool> isWifi() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Retorna true si hay internet (Wifi o Datos)
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Escucha cambios pero regresando SOLO el primer elemento de la lista
  static Stream<ConnectivityResult> onChange() {
    return Connectivity().onConnectivityChanged.map((list) => list.first);
  }
}

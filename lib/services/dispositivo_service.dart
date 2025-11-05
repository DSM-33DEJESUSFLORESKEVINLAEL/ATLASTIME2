import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DispositivoService {
  static const _channel = MethodChannel('com.example.atlastime/serial');

  // Obtiene el ANDROID_ID desde el canal nativo
  static Future<String> obtenerSerial() async {
    try {
      final serial = await _channel.invokeMethod<String>('getSerial');
      return serial ?? "ANDROID_ID_UNAVAILABLE";
    } catch (e) {
      return "ERROR: $e";
    }
  }

  // Valida si el dispositivo ya fue autorizado
  static Future<bool> validarDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final serial = await obtenerSerial();
    final guardado = prefs.getString('serial_autorizado');

    if (guardado == null) {
      await prefs.setString('serial_autorizado', serial);
      return true;
    }

    return serial == guardado;
  }

  // ✅ NUEVO: Devuelve "Samsung SM-A515F" o "Xiaomi Redmi Note 10", etc.
  static Future<String> obtenerNombreDispositivo() async {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return "${android.manufacturer} ${android.model}";
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return "${ios.name} ${ios.model}";
    } else {
      return "DISPOSITIVO_DESCONOCIDO";
    }
  }
}

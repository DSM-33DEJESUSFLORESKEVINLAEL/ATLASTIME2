import 'package:atlastime/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final splashYaMostrado = prefs.getBool('splash_mostrado') ?? false;

  // ✅ Verificar si hay sesión activa
  final tieneSesion = await AuthService.verificarSesion();

  runApp(MyApp(
    initialRoute: splashYaMostrado
        ? (tieneSesion ? '/home' : '/login')
        : '/', // ← Splash solo 1 vez
  ));
}

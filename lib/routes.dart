import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/historial_page.dart';
import 'package:atlastime/DecidirPage.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const SplashPage(),
  '/login': (_) => const LoginPage(),
  '/home': (_) => const HomePage(),
  '/historial': (_) => const HistorialPage(),
  '/decidir': (_) => const DecidirPage(),
};

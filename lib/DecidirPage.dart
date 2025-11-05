// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DecidirPage extends StatefulWidget {
  const DecidirPage({super.key});

  @override
  State<DecidirPage> createState() => _DecidirPageState();
}

class _DecidirPageState extends State<DecidirPage> {
  @override
  void initState() {
    super.initState();
    decidir();
  }

  Future<void> decidir() async {
    final sesionActiva = await AuthService.verificarSesion();
    if (mounted) {
      Navigator.pushReplacementNamed(context, sesionActiva ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

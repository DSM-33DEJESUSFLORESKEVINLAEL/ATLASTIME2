// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../services/auth_service.dart';
// import '../services/asistencia_service.dart';
// import '../db/sincronizador.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override

  
//   void initState() {
//     super.initState();

//     Future.microtask(() async {
//       final prefs = await SharedPreferences.getInstance();

//       final permisosOK = await _verificarPermisosRapido();
//       if (!permisosOK) await _solicitarPermisos();

//       final sesionActiva = await AuthService.verificarSesion();

//       // ✅ Guardar que ya se mostró el Splash
//       await prefs.setBool('splash_mostrado', true);

//       // ⏩ Redirigir rápido
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, sesionActiva ? '/home' : '/login');
//       }

//       // 🔄 Ejecutar tareas pesadas en segundo plano
//       Future.microtask(() async {
//         await AsistenciaService.verificarFaltasRetroactivas();
//         await Sincronizador.sincronizar();
//       });
//     });
//   }

  

//   Future<bool> _verificarPermisosRapido() async {
//     final permisos = [
//       // Permission.camera,
//       Permission.locationWhenInUse,
//       Permission.storage,
//       Permission.manageExternalStorage,
//     ];

//     for (final permiso in permisos) {
//       if (!await permiso.isGranted) return false;
//     }

//     return true;
//   }

//   Future<void> _solicitarPermisos() async {
//     final permisos = [
//       // Permission.camera,
//       Permission.locationWhenInUse,
//       Permission.storage,
//       Permission.manageExternalStorage,
//     ];

//     for (final permiso in permisos) {
//       final estado = await permiso.request();
//       if (estado.isGranted) {
//         print("✅ Permiso concedido: $permiso");
//       } else {
//         print("❌ Permiso denegado: $permiso");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Image(
//           image: AssetImage('assets/logo_atlas.png'),
//           width: 150,
//           height: 150,
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/asistencia_service.dart';
import '../db/sincronizador.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // 1) Inicial previo (permisos + prefs)
    final prefs = await SharedPreferences.getInstance();

    final permisosOK = await _verificarPermisosRapido();
    if (!permisosOK) {
      await _solicitarPermisos();
    }

    final sesionActiva = await AuthService.verificarSesion();

    // 2) Marca que ya se mostró el Splash
    await prefs.setBool('splash_mostrado', true);

    // 3) Navegación LIMPIANDO el stack
    if (!mounted) return;
    final destino = sesionActiva ? '/home' : '/login';
    Navigator.of(context).pushNamedAndRemoveUntil(destino, (route) => false);

    // 4) Tareas en segundo plano (sin usar context)
    //    No dependen de la pantalla actual
    unawaited(_tareasPesadas());
  }

  Future<void> _tareasPesadas() async {
    try {
      await AsistenciaService.verificarFaltasRetroactivas();
      await Sincronizador.sincronizar();
    } catch (e) {
      print('⚠️ Tareas pesadas con error: $e');
    }
  }

  Future<bool> _verificarPermisosRapido() async {
    final permisos = <Permission>[
      Permission.locationWhenInUse,
      Permission.storage,
      Permission.manageExternalStorage,
    ];
    for (final p in permisos) {
      if (!await p.isGranted) return false;
    }
    return true;
  }

  Future<void> _solicitarPermisos() async {
    final permisos = <Permission>[
      Permission.locationWhenInUse,
      Permission.storage,
      Permission.manageExternalStorage,
    ];
    for (final p in permisos) {
      final estado = await p.request();
      if (estado.isGranted) {
        print("✅ Permiso concedido: $p");
      } else {
        print("❌ Permiso denegado: $p");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 Evita que el botón atrás cierre/navegue mientras estamos en Splash
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image(
            image: AssetImage('assets/logo_atlas.png'),
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}

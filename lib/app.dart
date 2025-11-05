
// import 'package:flutter/material.dart';
// import 'routes.dart';

// class MyApp extends StatelessWidget {
//   final String initialRoute;

//   const MyApp({super.key, required this.initialRoute});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Llantera Atlas Asistencia',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
//         useMaterial3: true,
//       ),
//       initialRoute: initialRoute,
//       routes: appRoutes,
//     );
//   }
// }

// lib/app.dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AtlasTime',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
      ),
      initialRoute: initialRoute,
      routes: appRoutes, // 👈 usa tu mapa definido en routes.dart
    );
  }
}

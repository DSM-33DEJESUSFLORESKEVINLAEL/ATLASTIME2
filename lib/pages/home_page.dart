// // ignore_for_file: use_build_context_synchronously, avoid_print
// import 'dart:async';
// import 'package:atlastime/db/sincronizador.dart';
// import 'package:atlastime/services/apiService.dart';
// import 'package:atlastime/services/network_service.dart';
// import 'package:atlastime/services/usuario_sync_service.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/asistencia_service.dart';
// import '../services/auth_service.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:onboarding_overlay/onboarding_overlay.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   bool entradaMarcada = false;
//   String tipoNombre = '';
//   String areaNombre = '';
//   String horarioTexto = '';
//   String empresaNombre = '';
//   String zonaNombre = '';
//   String zonaLatitud = '';
//   String zonaLongitud = '';
//   String zonaRango = '';
//   Timer? _timerSincronizacion;
//   Timer? _debounceNetwork;
//   bool _syncEnProgreso = false;
//   bool _dialogoAbierto = false;
//   bool _tourEnCurso = false;

//   // ===== Onboarding =====
//   final GlobalKey<OnboardingState> _onboardingKey =
//       GlobalKey<OnboardingState>();
//   final FocusNode _fnBienvenida = FocusNode(); 
//   final FocusNode _fnEntrada = FocusNode();
//   final FocusNode _fnSalida = FocusNode();
//   final FocusNode _fnHistorial = FocusNode();
//   final FocusNode _fnLogout = FocusNode();
//   final FocusNode _fnCredenciales = FocusNode();


//   @override
//   void initState() {
//     super.initState();

//     AsistenciaService.verificarFaltasRetroactivas();
//     _sincronizarSeguro();
//     cargarDatosExtendidos();
//     obtenerUbicacion();
//     _prepararOnboarding();

//     NetworkService.onChange().listen((status) {
//       if (status == ConnectivityResult.wifi) {
//         _debounceNetwork?.cancel();
//         _debounceNetwork = Timer(const Duration(minutes: 6), () async {
//           if (!_syncEnProgreso) {
//             print('📶 Conexión Wi-Fi estable detectada → sincronizando...');
//             await _sincronizarSeguro();
//           }
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timerSincronizacion?.cancel();
//     _fnBienvenida.dispose();
//     _fnEntrada.dispose();
//     _fnSalida.dispose();
//     _fnHistorial.dispose();
//     _fnLogout.dispose();
//     _fnCredenciales.dispose();
//   super.dispose();
//   }

//   // =============== Onboarding helpers ===============
//   Future<void> _prepararOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     final yaMostrado = prefs.getBool('onboarding_home_done') ?? false;

//     if (yaMostrado) {
//       _iniciarSincronizacionPeriodica();
//       return;
//     }

//     // Espera a que la UI esté montada y los targets tengan RenderObject adjunto
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final ok = await _esperarTargetsAdjuntos(timeoutMs: 1500);
//       if (!mounted) return;
//       if (ok && _onboardingKey.currentState != null && mounted) {
//         _tourEnCurso = true;
//         // proteger contra estado destruido
//         await Future.delayed(Duration(milliseconds: 50));
//         if (!mounted) return;
//         _onboardingKey.currentState!.show();
//         _tourEnCurso = false;
//         await prefs.setBool('onboarding_home_done', true);
//       }
//       _iniciarSincronizacionPeriodica();
//     });
//   }

//   // Espera a que los 5 Focus tengan RenderObject adjunto al árbol
//   Future<bool> _esperarTargetsAdjuntos({int timeoutMs = 1500}) async {
//     final int intentos = (timeoutMs / 50).ceil();
//     for (int i = 0; i < intentos; i++) {
//       if (_todosAdjuntos()) return true;
//       await Future<void>.delayed(const Duration(milliseconds: 50));
//     }
//     return _todosAdjuntos();
//   }

//   bool _estaAdjunto(FocusNode n) {
//     final ctx = n.context;
//     if (ctx == null) return false;
//     final ro = ctx.findRenderObject();
//     return ro != null && ro.attached;
//   }

//   bool _todosAdjuntos() =>
//       _estaAdjunto(_fnEntrada) &&
//       _estaAdjunto(_fnSalida) &&
//       _estaAdjunto(_fnHistorial) &&
//       _estaAdjunto(_fnLogout) &&
//       _estaAdjunto(_fnCredenciales);

//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------
//   // MENSAJE DE BIENVENIDA
//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------

//   List<OnboardingStep> _pasosOnboarding() => [
//     // 👇 NUEVO: Bienvenida
//     OnboardingStep(
//       focusNode: _fnBienvenida,
//       titleText: "¡Bienvenido a Atlas Time!",
//       bodyText: "Te mostraremos rápidamente cómo registrar tu asistencia.",
//       shape: const CircleBorder(),
//       overlayBehavior: HitTestBehavior.opaque,
//     ),
//     OnboardingStep(
//       focusNode: _fnEntrada,
//       titleText: "Marcar Entrada",
//       bodyText:
//           "Presiona aquí para registrar tu ENTRADA. Se guarda la hora y tu ubicación.",
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//       overlayBehavior: HitTestBehavior.opaque, // bloquea taps
//     ),
//     OnboardingStep(
//       focusNode: _fnSalida,
//       titleText: "Marcar Salida",
//       bodyText: "Al finalizar tu jornada, registra tu SALIDA aquí.",
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//       overlayBehavior: HitTestBehavior.opaque,
//     ),
//     OnboardingStep(
//       focusNode: _fnHistorial,
//       titleText: "Historial",
//       bodyText: "Consulta entradas, salidas y el tiempo de retraso.",
//       shape: const CircleBorder(),
//       overlayBehavior: HitTestBehavior.opaque,
//     ),
//     OnboardingStep(
//       focusNode: _fnCredenciales,
//       titleText: "Usuario",
//       bodyText:
//           "Tu usuario y contraseña se guardan localmente en el teléfono para ingresar rápidamente. "
//           "Puedes salir del teléfono sin problema; al regresar, tus datos siguen guardados.",
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//       overlayBehavior: HitTestBehavior.opaque,
//     ),
//     OnboardingStep(
//       focusNode: _fnLogout,
//       titleText: "Cerrar sesión",
//       bodyText: "Puede cerrar tu sesión si lo desea.",
//       shape: const CircleBorder(),
//       overlayBehavior: HitTestBehavior.opaque,
//     ),
//   ];
//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------
//   // SINCRONIZACION
//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------
//   void _iniciarSincronizacionPeriodica() {
//     _timerSincronizacion?.cancel();
//     _timerSincronizacion = Timer.periodic(
//       // const Duration(seconds: 30),
//       const Duration(minutes: 6),
//       (_) => _sincronizarSeguro(),
//     );
//   }

//   Future<void> _sincronizarSeguro() async {
//     if (_syncEnProgreso || _tourEnCurso) {
//       print("⏸️ Sincronización ignorada (ya en progreso o tour activo)");
//       return;
//     }

//     final usuario = AuthService.usuarioActivo;
//     if (usuario == null) {
//       print("⚠️ No hay usuario activo, se omite sincronización.");
//       return;
//     }

//     _syncEnProgreso = true;
//     print("🔄 Iniciando sincronización segura...");

//     try {
//       await Sincronizador.sincronizar();
//       await UsuarioSyncService.refrescarDatos();
//       await cargarDatosExtendidos();
//       print("✅ Sincronización completada correctamente");
//     } catch (e) {
//       print("⚠️ Error sincronizando: $e");
//     } finally {
//       _syncEnProgreso = false;
//       print("✅ Sincronización finalizada (estado liberado)");
//     }
//   }

//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------
//   // GEOLOCALIZACION
//   // --------------------------------------------------------------------------------------------
//   // --------------------------------------------------------------------------------------------
//   Future<void> obtenerUbicacion() async {
//     try {
//       final permiso = await Permission.locationWhenInUse.status;
//       if (permiso.isDenied || permiso.isRestricted) {
//         final req = await Permission.locationWhenInUse.request();
//         if (!req.isGranted) {
//           print('🚫 Permiso de ubicación denegado por el usuario.');
//           return;
//         }
//       }

//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('📵 Servicio de ubicación desactivado.');
//         return;
//       }

//       LocationPermission geoPerm = await Geolocator.checkPermission();
//       if (geoPerm == LocationPermission.denied) {
//         geoPerm = await Geolocator.requestPermission();
//         if (geoPerm == LocationPermission.denied) {
//           print('🚫 Permiso de geolocalización denegado.');
//           return;
//         }
//       }
//       if (geoPerm == LocationPermission.deniedForever) {
//         print('⛔ Permiso de geolocalización denegado permanentemente.');
//         return;
//       }

//       final posicion = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       print("📍 Posición: ${posicion.latitude}, ${posicion.longitude}");
//     } catch (e) {
//       print('❌ Error obteniendo ubicación: $e');
//     }
//   }

//   // =======================
//   // 💾 Cargar datos UI
//   // =======================
//   Future<void> cargarDatosExtendidos() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       print("🎯 CARGANDO DATOS EXTENDIDOS DESDE PREFS...");
//       final pEmpresa = prefs.getString('empresa') ?? '';
//       final pArea = prefs.getString('area_nombre') ?? '';
//       final pTipo = prefs.getString('tipo_nombre') ?? '';
//       final pZona = prefs.getString('zona') ?? '';
//       final pHor = prefs.getString('horario_texto') ?? '';
//       final pLat = prefs.getString('zona_lat') ?? '';
//       final pLng = prefs.getString('zona_lng') ?? '';
//       final pRango = prefs.getString('zona_rango') ?? '';

//       print("empresa: $pEmpresa");
//       print("area: $pArea");
//       print("tipo: $pTipo");
//       print("zona: $pZona");
//       print("lat: $pLat | lng: $pLng | rango: $pRango");

//       if (!mounted) return;

//       setState(() {
//         empresaNombre = pEmpresa;
//         areaNombre = pArea;
//         tipoNombre = pTipo;
//         zonaNombre = pZona;
//         horarioTexto = pHor;
//         zonaLatitud = pLat;
//         zonaLongitud = pLng;
//         zonaRango = pRango;
//       });

//       //   print("✅ ESTADO ACTUALIZADO EN UI:");
//       //   print("empresaNombre: $empresaNombre");
//       //   print("areaNombre: $areaNombre");
//       //   print("tipoNombre: $tipoNombre");
//       //   print("zonaNombre: $zonaNombre");
//       //   print("zonaLatitud: $zonaLatitud");
//       //   print("zonaLongitud: $zonaLongitud");
//       //   print("zonaRango: $zonaRango");
//     } catch (e) {
//       //   print('⚠️ Error cargando datos extendidos: $e');
//     }
//   }

//   // =======================
//   // DIALOGOS
//   // =======================
//   void _mostrarDialogoCargando(String mensaje) {
//     if (_dialogoAbierto) return;
//     _dialogoAbierto = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             content: Row(
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(mensaje, style: const TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   void _cerrarDialogoActual() {
//     if (_dialogoAbierto && mounted) {
//       Navigator.of(context).pop();
//       _dialogoAbierto = false;
//     }
//   }

//   // CUANDO DA EL MSJ DE REGISTRAR
//   void _mostrarDialogoTemporal(
//     String mensaje, {
//     Duration duracion = const Duration(seconds: 3),
//   }) {
//     if (_dialogoAbierto) _cerrarDialogoActual();
//     _dialogoAbierto = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             content: Row(
//               children: [
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(mensaje, style: const TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//     );

//     Future.delayed(duracion, _cerrarDialogoActual);
//   }

//   // =======================================================================
//   // =============== Opciones extra (vacaciones/incapacidad) ===============
//   // =======================================================================
//   void mostrarOpcionesExtras() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.beach_access),
//                 title: const Text("Vacaciones"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   registrarTipo("VACACION");
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.healing),
//                 title: const Text("Incapacidad"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   registrarTipo("INCAPACIDAD");
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> registrarTipo(String tipo) async {
//     final nombre = AuthService.usuarioActivo?.nombre ?? '';
//     if (nombre.isEmpty) {
//       _mostrarDialogoTemporal("❌ No hay usuario activo.");
//       return;
//     }

//     final yaRegistro = await ApiService.yaRegistroEntradaHoy(nombre);
//     if (yaRegistro) {
//       _mostrarDialogoTemporal("⚠️ Ya se registró un movimiento hoy.");
//       return;
//     }

//     _mostrarDialogoCargando("Registrando $tipo...");
//     final resultado = await AsistenciaService.registrarTipoAusencia(tipo);
//     _cerrarDialogoActual();
//     if (resultado.isNotEmpty) {
//       _mostrarDialogoTemporal(resultado);
//     }
//   }

//   // =======================================================================
//   // ===================== Entrada / Salida ================================
//   // =======================================================================
//   Future<void> marcarEntrada() async {
//     _mostrarDialogoCargando("🟢 Registrando ENTRADA...");

//     final usuario = AuthService.usuarioActivo;
//     if (usuario == null) {
//       _cerrarDialogoActual();
//       _mostrarDialogoTemporal("❌ No hay usuario activo.");
//       return;
//     }
// //VALIDACION DE QUE YA REGISTRO ENTRADA
//     final yaRegistro = await ApiService.yaRegistroEntradaHoy(usuario.nombre);
//     if (yaRegistro) {
//       _cerrarDialogoActual();
//       _mostrarDialogoTemporal("⚠️ Ya registró su entrada hoy.");
//       return;
//     }

//     final resultado = await AsistenciaService.registrarEntrada();
//     _cerrarDialogoActual();
//     _mostrarDialogoTemporal(resultado);

//     if (resultado.contains("Entrada registrada") && mounted) {
//       setState(() => entradaMarcada = true);
//       await _sincronizarSeguro();
//     }
//   }

//   Future<void> marcarSalida() async {
//     _mostrarDialogoCargando("🟢 Registrando SALIDA...");
//     final resultado = await AsistenciaService.registrarSalida();
//     _cerrarDialogoActual();
//     _mostrarDialogoTemporal(resultado);
//   }

//   // =============== BOTONES DE SALIR / HISTORIAL ===================
//   void salir() {
//     AuthService.logout();
//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   void irAHistorial() {
//     Navigator.pushNamed(context, '/historial');
//   }

//   // =============== UI ===============
//   @override
//   Widget build(BuildContext context) {
//     // ignore: unused_local_variable
//     final nombre = AuthService.usuarioActivo?.nombre ?? "Empleado";

//     return Onboarding(
//       key: _onboardingKey,
//       steps: _pasosOnboarding(),
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           title: const Text("Control de Asistencia"),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           foregroundColor: Colors.white,
//           actions: [
//             Focus(
//               focusNode: _fnLogout,
//               child: IconButton(
//                 icon: const Icon(Icons.logout),
//                 tooltip: "Cerrar sesión",
//                 onPressed: _tourEnCurso ? null : salir,
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: Focus(
//           focusNode: _fnHistorial,
//           child: FloatingActionButton.extended(
//             onPressed: _tourEnCurso ? null : irAHistorial,
//             label: const Text("Historial"),
//             icon: const Icon(Icons.history),
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//           ),
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFDD835), Color(0xFFFDD835)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           width: double.infinity,
//           child: Center(
//             child: Card(
//               elevation: 20,
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 24),
//               child: Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.verified,
//                       size: 70,
//                       color: Color(0xFF2E7D32),
//                     ),
//                     const SizedBox(height: 10),
//                     Focus(
//                       focusNode: _fnCredenciales,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             "¡Hola, ${AuthService.usuarioActivo?.nombre ?? 'Empleado'}!\n",
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),

//                           // // ► Datos dinámicos refrescados
//                           // if (empresaNombre.isNotEmpty) Text("Empresa: $empresaNombre"),
//                           // if (areaNombre.isNotEmpty)    Text("Área: $areaNombre"),
//                           // if (tipoNombre.isNotEmpty)    Text("Tipo: $tipoNombre"),
//                           // if (zonaNombre.isNotEmpty)    Text("Zona: $zonaNombre"),
//                           // if (horarioTexto.isNotEmpty)  Text("Horario: $horarioTexto"),
//                           // ► Datos dinámicos refrescados
//                           // if (empresaNombre.isNotEmpty)
//                           //   Text("Empresa: $empresaNombre"),
//                           // if (areaNombre.isNotEmpty) Text("Área: $areaNombre"),
//                           // if (tipoNombre.isNotEmpty) Text("Tipo: $tipoNombre"),
//                           // if (zonaNombre.isNotEmpty) Text("Zona: $zonaNombre"),
//                           // if (horarioTexto.isNotEmpty)
//                           //   Text("Horario: $horarioTexto"),
//                           // if (zonaLatitud.isNotEmpty)
//                           //   Text("Latitud: $zonaLatitud"),
//                           // if (zonaLongitud.isNotEmpty)
//                           //   Text("Longitud: $zonaLongitud"),
//                           // if (zonaRango.isNotEmpty)
//                           //   Text("Rango permitido: $zonaRango m"),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Botón Entrada
//                     Focus(
//                       focusNode: _fnEntrada,
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             _tourEnCurso
//                                 ? null
//                                 : (entradaMarcada ? null : marcarEntrada),
//                         icon: const Icon(Icons.login),
//                         label: const Text("Marcar Entrada"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF9CCC65),
//                           foregroundColor: Colors.white,
//                           textStyle: const TextStyle(fontSize: 16),
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 8,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     // Botón Salida
//                     Focus(
//                       focusNode: _fnSalida,
//                       child: ElevatedButton.icon(
//                         onPressed: _tourEnCurso ? null : marcarSalida,
//                         icon: const Icon(Icons.logout),
//                         label: const Text("Marcar Salida"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFFF7043),
//                           foregroundColor: Colors.white,
//                           textStyle: const TextStyle(fontSize: 16),
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 8,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlastime/services/asistencia_service.dart';
import 'package:atlastime/services/auth_service.dart';
import 'package:atlastime/services/usuario_sync_service.dart';
import 'package:atlastime/db/sincronizador.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool cargando = false;
  bool entradaMarcada = false;
  bool salidaMarcada = false;
  bool _syncEnProgreso = false;

  String nombre = "";
  String empresa = "";
  String area = "";
  String tipo = "";
  String horario = "";
  String zona = "";

  final GlobalKey<OnboardingState> _onboardingKey = GlobalKey<OnboardingState>();
  final FocusNode _fnBienvenida = FocusNode();
  final FocusNode _fnEntrada = FocusNode();
  final FocusNode _fnSalida = FocusNode();
  final FocusNode _fnHistorial = FocusNode();
  final FocusNode _fnCredenciales = FocusNode();
  final FocusNode _fnLogout = FocusNode();

 @override
  void initState() {
    super.initState();

    // 👇 Registramos el observador del ciclo de vida
    WidgetsBinding.instance.addObserver(this);

    _cargarDatos();
    _prepararOnboarding();
    _sincronizarSeguro();
    _verificarCambioDeDia(); // 👈 Detecta cambio de día

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.wifi)) {
        Future.delayed(const Duration(seconds: 5), _sincronizarSeguro);
      }
    });
  }

@override
  void dispose() {
    // 👇 Quitamos el observador al destruir el widget
    WidgetsBinding.instance.removeObserver(this);

    _fnBienvenida.dispose();
    _fnEntrada.dispose();
    _fnSalida.dispose();
    _fnHistorial.dispose();
    _fnCredenciales.dispose();
    _fnLogout.dispose();

    final onboarding = _onboardingKey.currentState;
    onboarding?.hide();

    super.dispose();
  }



  // =========================================================
  // 🔄 SINCRONIZACIÓN SEGURA
  // =========================================================
  Future<void> _sincronizarSeguro() async {
    if (_syncEnProgreso) {
      print("⏸️ Sincronización ya en progreso, se omite.");
      return;
    }
    _syncEnProgreso = true;
    // print("🔄 Iniciando sincronización segura...");
    try {
      await Sincronizador.sincronizar();
      await UsuarioSyncService.refrescarDatos();
      await cargarDatosExtendidos();
      // print("✅ Sincronización completada correctamente");
    } catch (e) {
      print("⚠️ Error en sincronización: $e");
    } finally {
      _syncEnProgreso = false;
      // print("✅ Sincronización finalizada");
    }
  }

  // =========================================================
  // 💾 CARGAR DATOS DESDE PREFS
  // =========================================================
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('nombre_completo') ?? '';
      empresa = prefs.getString('empresa') ?? '';
      area = prefs.getString('area_nombre') ?? '';
      tipo = prefs.getString('tipo_nombre') ?? '';
      horario = prefs.getString('horario_texto') ?? '';
      zona = prefs.getString('zona') ?? '';
    });
    Future.delayed(const Duration(milliseconds: 700), _mostrarBienvenida);
  }

 Future<void> cargarDatosExtendidos() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    print("🎯 CARGANDO DATOS EXTENDIDOS DESDE PREFS...");

    // ✅ Si el widget ya no está montado, salimos antes de setState
    if (!mounted) {
      print("⚠️ Widget desmontado, se cancela actualización de UI.");
      return;
    }

    setState(() {
      empresa = prefs.getString('empresa') ?? '';
      area = prefs.getString('area_nombre') ?? '';
      tipo = prefs.getString('tipo_nombre') ?? '';
      horario = prefs.getString('horario_texto') ?? '';
      zona = prefs.getString('zona') ?? '';
    });

    print("✅ Datos cargados: $empresa | $area | $tipo | $zona");
  } catch (e) {
    print("❌ Error cargando datos extendidos: $e");
  }
}


  // =========================================================
  // 🌞 MENSAJE DE BIENVENIDA
  // =========================================================
  void _mostrarBienvenida() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFDD835),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        content: Row(
          children: [
            const Icon(Icons.wb_sunny, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nombre.isNotEmpty
                    ? "🌞 ¡Buen día, $nombre!"
                    : "🌞 ¡Bienvenido a AtlasTime!",
                style: const TextStyle(
                    // color: Colors.white,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

 // =========================================================
  // 👀 DETECTAR CAMBIO DE ESTADO DE LA APP
  // =========================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarCambioDeDia(); // 👈 Se ejecuta al volver del fondo
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _verificarCambioDeDia(); // 👈 También al reconstruir la vista
  }
  
// =========================================================
// 🕓 DETECTAR CAMBIO DE DÍA
// =========================================================
Future<void> _verificarCambioDeDia() async {
  final prefs = await SharedPreferences.getInstance();

  final hoy = DateTime.now();
  final fechaHoy = "${hoy.year}-${hoy.month}-${hoy.day}";
  final ultimaFecha = prefs.getString('ultima_fecha') ?? '';

  if (ultimaFecha != fechaHoy) {
    // print("🌅 Nuevo día detectado — refrescando datos y sincronización...");
    await prefs.setString('ultima_fecha', fechaHoy);
    await _sincronizarSeguro();
    await cargarDatosExtendidos();
    setState(() {
      entradaMarcada = false;
      salidaMarcada = false;
    });
      _mostrarMensaje("🌞 Nuevo día detectado. Puedes registrar tu entrada ahora.");

  } else {
    print("📅 Mismo día detectado — sin cambios.");
  }
}

  // =========================================================
  // 🧭 ONBOARDING
  // =========================================================
  List<OnboardingStep> _pasosOnboarding() => [
        OnboardingStep(
          focusNode: _fnBienvenida,
          titleText: "¡Bienvenido a Atlas Time!",
          bodyText:
              "Te mostraremos rápidamente cómo registrar tu asistencia y navegar en la app.",
          shape: const CircleBorder(),
        ),
        OnboardingStep(
          focusNode: _fnEntrada,
          titleText: "Marcar Entrada",
          bodyText:
              "Presiona aquí para registrar tu ENTRADA. Se guardará la hora y tu ubicación.",
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        OnboardingStep(
          focusNode: _fnSalida,
          titleText: "Marcar Salida",
          bodyText: "Cuando termines tu jornada, marca tu SALIDA aquí.",
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        OnboardingStep(
          focusNode: _fnHistorial,
          titleText: "Historial",
          bodyText:
              "Consulta tus registros anteriores de entradas, salidas y retrasos.",
          shape: const CircleBorder(),
        ),
        OnboardingStep(
          focusNode: _fnCredenciales,
          titleText: "Usuario",
          bodyText:
              "Tu usuario y contraseña se guardan localmente para un acceso rápido y seguro.",
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        OnboardingStep(
          focusNode: _fnLogout,
          titleText: "Cerrar sesión",
          bodyText: "Puedes cerrar tu sesión desde aquí cuando lo desees.",
          shape: const CircleBorder(),
        ),
      ];

  Future<void> _prepararOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  final mostrado = prefs.getBool('onboarding_home_done') ?? false;
  if (mostrado) return;

  // 🧩 Esperar hasta que todos los FocusNode estén adjuntos al árbol
  await _esperarTargetsAdjuntos();

  if (!mounted) return;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    final onboarding = _onboardingKey.currentState;
    if (onboarding != null && mounted) {
      onboarding.show();
      await prefs.setBool('onboarding_home_done', true);
    }
  });
}
Future<void> _esperarTargetsAdjuntos() async {
  final nodes = [
    _fnBienvenida,
    _fnEntrada,
    _fnSalida,
    _fnHistorial,
    _fnCredenciales,
    _fnLogout,
  ];

  bool todosAdjuntos() => nodes.every((f) => f.context?.findRenderObject() != null);

  int intentos = 0;
  while (!todosAdjuntos() && intentos < 20) {
    await Future.delayed(const Duration(milliseconds: 200));
    intentos++;
  }
  print("🎯 Targets listos para onboarding (${intentos} intentos)");
}

  // =========================================================
  // 🔁 LÓGICA DE REGISTRO
  // =========================================================
  Future<void> _registrarEntrada() async {
    if (entradaMarcada) return;
    setState(() => cargando = true);
    final msg = await AsistenciaService.registrarEntrada();
    setState(() {
      cargando = false;
      if (msg.contains("Entrada registrada")) entradaMarcada = true;
    });
    _mostrarMensaje(msg);
  }

  Future<void> _registrarSalida() async {
    if (salidaMarcada) return;
    setState(() => cargando = true);
    final msg = await AsistenciaService.registrarSalida();
    setState(() {
      cargando = false;
      if (msg.contains("Salida registrada")) salidaMarcada = true;
    });
    _mostrarMensaje(msg);
  }

  // =========================================================
  // 💬 SNACKBAR GENERAL
  // =========================================================
  void _mostrarMensaje(String msg) {
    Color bg = Colors.amber.shade700;
    IconData icon = Icons.info_outline;

    if (msg.startsWith('✅')) {
      bg = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else if (msg.startsWith('⚠️')) {
      bg = Colors.orange.shade700;
      icon = Icons.warning_amber_rounded;
    } else if (msg.startsWith('❌')) {
      bg = Colors.red.shade700;
      icon = Icons.error_outline;
    } else if (msg.startsWith('📍')) {
      bg = Colors.blue.shade700;
      icon = Icons.location_on_outlined;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🔒 LOGOUT E HISTORIAL
  // =========================================================
  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _irHistorial() {
    Navigator.pushNamed(context, '/historial');
  }

  // =========================================================
  // 🖼️ UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioActivo?.nombre ?? "Empleado";

    return Onboarding(
      key: _onboardingKey,
      steps: _pasosOnboarding(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDD835),
        appBar: AppBar(
          // backgroundColor: Colors.white,
                  backgroundColor: const Color(0xFFFDD835),
          elevation: 3,
          centerTitle: true,
          title: const Text(
            "AtlasTime",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          actions: [
            Focus(
              focusNode: _fnLogout,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.black87),
                tooltip: "Cerrar sesión",
                onPressed: _logout,
              ),
            ),
          ],
        ),
        floatingActionButton: Focus(
          focusNode: _fnHistorial,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.history),
            label: const Text("Historial"),
            onPressed: cargando ? null : _irHistorial,
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Card(
                  color: Colors.white,
                  elevation: 20,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user,
                            color: Color(0xFF2E7D32), size: 80),
                        const SizedBox(height: 16),
                        Focus(
                          focusNode: _fnBienvenida,
                          child: Text(
                            "¡Hola, $usuario!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        const SizedBox(height: 10),
                        // _infoRow("Empresa", empresa),
                        _infoRow("Área", area),
                        // _infoRow("Tipo", tipo),
                        // _infoRow("Zona", zona),
                        _infoRow("Horario", horario),
                        const SizedBox(height: 24),
                        Focus(
                          focusNode: _fnEntrada,
                          child: ElevatedButton.icon(
                            onPressed:
                                (cargando || entradaMarcada) ? null : _registrarEntrada,
                            icon: const Icon(Icons.login),
                            label: const Text("Registrar Entrada"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9CCC65),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 16),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Focus(
                          focusNode: _fnSalida,
                          child: ElevatedButton.icon(
                            onPressed:
                                (cargando || salidaMarcada) ? null : _registrarSalida,
                            icon: const Icon(Icons.logout),
                            label: const Text("Registrar Salida"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7043),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 16),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (cargando)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : "-",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

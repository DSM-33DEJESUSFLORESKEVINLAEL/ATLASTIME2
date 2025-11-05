// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, avoid_print

// import 'package:atlastime/db/database_helper.dart';
import 'package:atlastime/models/usuario.dart';
import 'package:atlastime/services/apiService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioController = TextEditingController();
  final pswController = TextEditingController();
  String mensaje = "";
  bool _verClave = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, verificarGPS);
    // usuarioController.text = '23';
    // pswController.text = '123';
  }

  Future<void> verificarGPS() async {
    bool gpsActivo = await Geolocator.isLocationServiceEnabled();
    LocationPermission permiso = await Geolocator.checkPermission();

    if (!gpsActivo ||
        permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Permiso de ubicación requerido"),
              content: const Text(
                "Activa el GPS y otorga permisos de ubicación para continuar.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (!gpsActivo) await Geolocator.openLocationSettings();
                    LocationPermission nuevoPermiso =
                        await Geolocator.requestPermission();
                    if (nuevoPermiso == LocationPermission.denied ||
                        nuevoPermiso == LocationPermission.deniedForever) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Permiso de ubicación denegado"),
                        ),
                      );
                    }
                  },
                  child: const Text("Permitir"),
                ),
              ],
            ),
      );
    }
  }
  
void login() async {
  final userData = await AuthService.login(
    usuarioController.text.trim(),
    pswController.text.trim(),
  );

  if (userData != null) {
    final idEmpleado = userData['ID_EMPLEADO'].toString();
    final idEmpresa = userData['ID_EMPRESA'].toString();   

    final idTipo = userData['ID_TIPO'].toString();
    final idArea = userData['ID_AREA'].toString();
    final idHorario = userData['ID_HORARIO'].toString();
    final idZona = userData['ID_ZONA'].toString();

    final tipoNombre = await ApiService.getNombreTipo(idTipo);
    final areaNombre = await ApiService.getNombreArea(idArea);
    final horarioTexto = await ApiService.getHorarioTexto(idHorario);
    final zonatexto = await ApiService.getZonaTrabajo(idZona);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_empleado', idEmpleado);     // ✅ Guardar
    await prefs.setString('id_empresa', idEmpresa);       // ✅ Guardar
    await prefs.setString('nombre', userData['NOMBRE_COMPLETO'] ?? '');
    await prefs.setString('empresa', userData['EMPRESA'] ?? '');
    await prefs.setString('zona', zonatexto['ZONA'] ?? '');
    await prefs.setString('tipo', tipoNombre);
    await prefs.setString('tipo_nombre', tipoNombre);
    await prefs.setString('area_nombre', areaNombre);
    await prefs.setString('horario_texto', horarioTexto);

    AuthService.usuarioActivo = Usuario(
      id: idEmpleado,
      nombre: userData['NOMBRE_COMPLETO'] ?? '',
      nomina: userData['NOMINA'] ?? '',
      usuario: userData['USUARIO'] ?? '',
      areaNombre: areaNombre,
      idArea: int.tryParse(idArea) ?? 0,
      tipoNombre: tipoNombre,
      idTipo: int.tryParse(idTipo) ?? 0,
      horaEntrada: userData['HORA_ENTRADA'],
      horaSalida: userData['HORA_SALIDA'],
      idZona: idZona,
      idEmpresa: idEmpresa, // ✅ Asignar si está en tu modelo
    );

    AuthService.empresaActiva = userData['EMPRESA'];

    print('✅ Datos guardados en SharedPreferences:');
    print('ID_EMPLEADO: $idEmpleado');
    print('ID_EMPRESA: $idEmpresa');
    print('NOMBRE: ${userData['NOMBRE_COMPLETO']}');
    print('EMPRESA: ${userData['EMPRESA']}');
    print("🌍 ZONA RECIBIDA DESDE API: $zonatexto");
    print('TIPO: $tipoNombre');
    print('ÁREA: $areaNombre');
    print('HORARIO: $horarioTexto');

    // ignore: unused_local_variable
    final datosZona = await ApiService.getZonaTrabajo(idZona.toString());


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 ¡Bienvenido!"),
        content: Text(
          "Hola ${userData['NOMBRE_COMPLETO']}, eres $tipoNombre del área $areaNombre.\nHorario: $horarioTexto",
        ),
      ),
    );
// ESTE ES PARA EL INICIO DE LA APP 
    await Future.delayed(
      const Duration(seconds: 3)
      //  const Duration(minutes: 6)
      );
    if (mounted) Navigator.of(context).pop();

    

    Navigator.pushReplacementNamed(context, '/home');
  } else {
    setState(() => mensaje = "Usuario o clave incorrectos");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDD835),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    // 'assets/logo_atlas.png', // Asegúrate de colocar el archivo en assets y registrar en pubspec.yaml
                    'assets/icono.png', // Asegúrate de colocar el archivo en assets y registrar en pubspec.yaml
                    height: 150,
                  ),

                  const SizedBox(height: 24),
                  TextField(
                    controller: usuarioController,
                    decoration: InputDecoration(
                      labelText: "Usuario",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      // Limpia espacios al final si los hay
                      if (value.endsWith(' ')) {
                        usuarioController.text = value.trimRight();
                        usuarioController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: usuarioController.text.length),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: pswController,
                    obscureText: !_verClave,
                    decoration: InputDecoration(
                      labelText: "Clave",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verClave ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _verClave = !_verClave),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text(
                        "Ingresar",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFDD835,
                        ), // Amarillo institucional
                        foregroundColor: Colors.black, // Texto negro
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: login,
                    ),
                  ),
                  if (mensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        mensaje,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

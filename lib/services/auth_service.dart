// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:atlastime/services/apiService.dart';
import 'package:atlastime/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Usuario? usuarioActivo;
  static String? empresaActiva;

  static int? movimientoActivoId;
  static Map<String, dynamic>? datosEntrada;

  static Future<Map<String, dynamic>?> login(String usuario, String clave) async {
    final json = await ApiService.login(usuario, clave);
    print("json $json");

    if (json != null && json['NOMINA'] != null) {
      usuarioActivo = Usuario(
        id: json['ID_EMPLEADO']?.toString() ?? '',
        nombre: json['NOMBRE_COMPLETO'] ?? '',
        nomina: json['NOMINA'] ?? '',
        usuario: json['NOMINA'] ?? '', // Usamos NOMINA como usuario
        areaNombre: json['AREA'] ?? '',
        idArea: int.tryParse(json['ID_AREA']?.toString() ?? '') ?? 0,
        idTipo: int.tryParse(json['ID_TIPO']?.toString() ?? '') ?? 0,
        tipoNombre: json['TIPO']?.toString() ?? '',
        horaEntrada: json['HORA_ENTRADA'],
        horaSalida: json['HORA_SALIDA'],
        idZona: json['ID_ZONA']?.toString() ?? '',
        idEmpresa: json['ID_EMPRESA']?.toString() ?? '',
      );

      empresaActiva = json['EMPRESA']?.toString() ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sesion_activa', true);
      await prefs.setString('id_empleado', usuarioActivo!.id);
      await prefs.setString('nombre', usuarioActivo!.nombre);
      await prefs.setString('nomina', usuarioActivo!.nomina);
      await prefs.setString('usuario', usuarioActivo!.usuario);
      await prefs.setString('empresa', empresaActiva ?? '');
      await prefs.setString('area', usuarioActivo!.areaNombre);
      await prefs.setInt('id_area', usuarioActivo!.idArea);
      await prefs.setString('hora_entrada', usuarioActivo!.horaEntrada ?? '');
      await prefs.setString('hora_salida', usuarioActivo!.horaSalida ?? '');
      await prefs.setString('id_zona', usuarioActivo!.idZona ?? '');
      await prefs.setString('tipo', usuarioActivo!.tipoNombre ?? '');
      await prefs.setInt('id_tipo', usuarioActivo!.idTipo);
      await prefs.setString('id_empresa', usuarioActivo!.idEmpresa ?? '');

      print(
        "📦 Usuario guardado localmente: ${usuarioActivo!.tipoNombre} ${usuarioActivo!.id} ${usuarioActivo!.nombre} empresa $empresaActiva, zona ${usuarioActivo!.idZona}",
      );

      await restaurarMovimientoPrevio();
      return json;
    }

    return null;
  }

  static Future<void> logout() async {
    usuarioActivo = null;
    empresaActiva = null;
    movimientoActivoId = null;
    datosEntrada = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final activa = prefs.getBool('sesion_activa') ?? false;

    if (activa) {
      usuarioActivo = Usuario(
        id: prefs.getString('id_empleado') ?? '',
        nombre: prefs.getString('nombre') ?? '',
        nomina: prefs.getString('nomina') ?? '',
        usuario: prefs.getString('usuario') ?? '',
        areaNombre: prefs.getString('area') ?? '',
        idArea: prefs.getInt('id_area') ?? 0,
        tipoNombre: prefs.getString('tipo') ?? '',
        idTipo: prefs.getInt('id_tipo') ?? 0,
        horaEntrada: prefs.getString('hora_entrada'),
        horaSalida: prefs.getString('hora_salida'),
        idZona: prefs.getString('id_zona'),
        idEmpresa: prefs.getString('id_empresa') ?? '',
      );

      empresaActiva = prefs.getString('empresa');
      await restaurarMovimientoPrevio();
    }

    return activa;
  }

  static Future<void> restaurarMovimientoPrevio() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('movimiento_id');
    final datos = prefs.getString('movimiento_datos');

    if (id != null && datos != null) {
      movimientoActivoId = id;
      datosEntrada = jsonDecode(datos);
      print("✅ Movimiento restaurado: ID $id");
    } else {
      print("⚠️ No hay movimiento previo guardado.");
    }
  }

  static Future<void> debugPrintPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    print('--- DEBUG PREFS ---');
    print('sesion_activa: ${prefs.getBool('sesion_activa')}');
    print('id_empleado: ${prefs.getString('id_empleado')}');
    print('nombre: ${prefs.getString('nombre')}');
    print('nomina: ${prefs.getString('nomina')}');
    print('usuario: ${prefs.getString('usuario')}');
    print('empresa: ${prefs.getString('empresa')}');
    print('id_empresa: ${prefs.getString('id_empresa')}');
    print('area: ${prefs.getString('area')}');
    print('id_area: ${prefs.getInt('id_area')}');
    print('tipo: ${prefs.getString('tipo')}');
    print('id_tipo: ${prefs.getInt('id_tipo')}');
    print('hora_entrada: ${prefs.getString('hora_entrada')}');
    print('hora_salida: ${prefs.getString('hora_salida')}');
    print('id_zona: ${prefs.getString('id_zona')}');
    print('movimiento_id: ${prefs.getInt('movimiento_id')}');
    print('movimiento_datos: ${prefs.getString('movimiento_datos')}');
    print('-------------------');
  }
}

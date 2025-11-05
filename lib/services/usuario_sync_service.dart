// ignore_for_file: avoid_print

import 'package:atlastime/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiService.dart';
import 'auth_service.dart';

class UsuarioSyncService {
  static Future<void> refrescarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawId = prefs.get('id_empleado');
      if (rawId == null) {
        print("⚠️ No hay id_empleado guardado en prefs");
        return;
      }

      final idEmpleado = int.tryParse(rawId.toString()) ?? 0;
      if (idEmpleado == 0) {
        print("⚠️ ID inválido ($rawId)");
        return;
      }

      print("🔍 REFRESCAR DATOS — INICIANDO (id_empleado=$idEmpleado)");

      // 🔹 Obtener datos del servidor
      final datos = await ApiService.obtenerDatosUsuario(idEmpleado);
      if (datos == null || datos.isEmpty) {
        print("⛔ No se pudieron obtener datos del servidor");
        return;
      }

      print("✅ Datos del servidor recibidos correctamente: $datos");

      // --- Campos del servidor ---
      final nombreCompleto = (datos['NOMBRE_COMPLETO'] ?? '').toString();
      final empresaId = (datos['ID_EMPRESA'] ?? '').toString();
      final empresaNom = (datos['EMPRESA'] ?? '').toString();
      final idArea = (datos['ID_AREA'] ?? '').toString();
      final idTipo = (datos['ID_TIPO'] ?? '').toString();
      final idHorario = (datos['ID_HORARIO'] ?? '').toString();
      final idZona = (datos['ID_ZONA'] ?? '').toString(); // Puede ser texto (ej. "TOLUCA")

      // --- Resolver textos ---
      final areaNombre = await ApiService.getNombreArea(idArea);
      final tipoNombre = await ApiService.getNombreTipo(idTipo);
      final horarioTexto = await ApiService.getHorarioTexto(idHorario);

      // --- Resolver zona ---
      String zonaNombre = idZona;
      double lat = 0.0;
      double lng = 0.0;
      double rango = 0.0;

      if (idZona.isEmpty) {
        print("⚠️ El servidor no envió zona.");
      } else {
        // print("🌍 Zona detectada desde API → $idZona");

        // 🔹 Intentar obtener coordenadas y rango de la zona
        final zonaServer = await ApiService.getZonaTrabajo(idZona);

        if (zonaServer.isNotEmpty) {
          zonaNombre = (zonaServer['ZONA'] ?? idZona).toString();
          lat = double.tryParse(zonaServer['LAT'].toString()) ?? 0.0;
          lng = double.tryParse(zonaServer['LNG'].toString()) ?? 0.0;
          rango = double.tryParse(zonaServer['RANGO'].toString()) ?? 0.0;

          // print("📍 Coordenadas obtenidas -> LAT:$lat LNG:$lng RANGO:$rango");
        } else {
          // print("⚠️ No se encontraron coordenadas para la zona $idZona");
        }
      }

      // 💾 Guardar en SharedPreferences
      await prefs.setString('nombre', nombreCompleto);
      await prefs.setString('empresa_id', empresaId);
      await prefs.setString('empresa', empresaNom);
      await prefs.setString('area_nombre', areaNombre);
      await prefs.setString('tipo_nombre', tipoNombre);
      await prefs.setString('horario_texto', horarioTexto);
      await prefs.setString('id_zona', idZona);
      await prefs.setString('zona', zonaNombre);
      await prefs.setString('zona_lat', lat.toString());
      await prefs.setString('zona_lng', lng.toString());
      await prefs.setString('zona_rango', rango.toString());

      // --- Actualizar empresa en movimientos locales ---
      final idEmpresaInt = int.tryParse(empresaId) ?? 0;
      if (idEmpresaInt > 0) {
        await DatabaseHelper.actualizarEmpresaEnMovimientos(idEmpresaInt);
      }

      // --- Actualizar usuario activo (AuthService) ---
      if (AuthService.usuarioActivo != null) {
        AuthService.usuarioActivo = AuthService.usuarioActivo!.copyWith(
          nombre: nombreCompleto,
          idEmpresa: empresaId,
          tipoNombre: tipoNombre,
          areaNombre: areaNombre,
          idZona: idZona,
        );
      }

      // // --- LOG Final ---
      // print("💾 GUARDADO OK:");
      // print("empresa: $empresaNom  | empresa_id: $empresaId");
      // print("area:    $areaNombre  | tipo: $tipoNombre");
      // print("zona:    $zonaNombre  | id_zona: $idZona");
      // print("LAT: $lat | LNG: $lng | RANGO: $rango");
      // print("horario: $horarioTexto");

    } catch (e, st) {
      print("❌ Error en refrescarDatos(): $e");
      print(st);
    }
  }
}


// pero a cada rato se modifica 
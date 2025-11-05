// lib/db/sincronizador.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:atlastime/db/database_helper.dart';
import 'package:atlastime/services/apiService.dart';
import 'package:atlastime/services/usuario_sync_service.dart';  // 👈 NUEVO

class Sincronizador {
  static Future<void> sincronizar() async {
    try {
      // 🌐 Verifica si hay conexión a internet
      final tieneInternet = await _hayInternet();
      if (!tieneInternet) {
        print("📴 Sin internet. No se sincroniza.");
        return;
      }

      // 👇 NUEVO: Antes de sincronizar movimientos, refrescamos datos del usuario
      await UsuarioSyncService.refrescarDatos();

      // 🔍 Obtiene movimientos locales no sincronizados (SINCRONIZADO = 'N')
      final pendientes = await DatabaseHelper.movimientosPendientes();
      print("🔄 Pendientes por sincronizar: ${pendientes.length}");
      for (final mov in pendientes) {
        final limpio =
            Map<String, dynamic>.from(mov)
              ..remove('ID_MOVIMIENTO')
              ..remove('SINCRONIZADO')
              ..removeWhere(
                (key, value) =>
                    value == null || (value is String && value.trim().isEmpty),
              );

        // 🛑 Verificar si ya existe en el servidor
        final usuario = mov['USUARIO'] ?? mov['NOMINA'] ?? mov['NOMBRE_COMPL'];
        final fechaEntradaStr = mov['FECHA_ENTRADA'];

        if (usuario == null || fechaEntradaStr == null) {
          print(
            "⚠️ Movimiento inválido, falta USUARIO o FECHA_ENTRADA. ID_LOCAL: ${mov['ID_MOVIMIENTO']}",
          );
          continue;
        }

        final yaExiste = await ApiService.existeMovimiento(
          usuario.toString(),
          DateTime.parse(fechaEntradaStr),
        );

        if (yaExiste) {
          print(
            "⚠️ Ya existe en servidor, se marca como sincronizado: ${mov['ID_MOVIMIENTO']}",
          );
          await DatabaseHelper.marcarSincronizado(mov['ID_MOVIMIENTO']);
          continue;
        }

        print("📤 Enviando movimiento limpio: ${jsonEncode(limpio)}");
        final response = await ApiService.insertMovimiento(limpio);

        if (response is int && response > 0) {
          await DatabaseHelper.marcarSincronizado(mov['ID_MOVIMIENTO']);
          print("✅ Sincronizado ID local: ${mov['ID_MOVIMIENTO']}");
        } else {
          print("❌ Fallo al enviar movimiento: ${mov['ID_MOVIMIENTO']}");
        }
      }
    } catch (e) {
      print("❌ Error en sincronización: $e");
    }
  }

  static Future<bool> _hayInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

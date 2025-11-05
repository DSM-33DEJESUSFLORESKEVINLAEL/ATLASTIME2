// ignore_for_file: avoid_print, unused_local_variable, equal_keys_in_map, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:atlastime/db/database_helper.dart';
import 'package:atlastime/services/apiService.dart';
import 'package:atlastime/services/gps_service.dart';
import 'package:atlastime/services/auth_service.dart';
import 'package:atlastime/services/dispositivo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AsistenciaService {
  static Future<void> cargarCatalogoMovimientos() async {
    final usuario = AuthService.usuarioActivo;
    if (usuario == null) {
      print("⚠️ No hay usuario autenticado.");
      return;
    }

    final nombre = usuario.nombre;
    final respuesta = await ApiService.getObtener(nombre);
    print("📦 Respuesta en asistencia_service: ${respuesta.crudo}");
  }

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  // ---------------------REGISTRAR ENTRADA--------------------------------
  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------

  //   static Future<String> registrarEntrada() async {
  //     try {
  //       final usuario = AuthService.usuarioActivo;
  //       if (usuario == null) return "❌ No hay usuario autenticado.";

  //       final zona = usuario.idZona;
  //       if (zona == null) {
  //         return "⚠️ No tienes asignada una zona de trabajo. Contacta al administrador.";
  //       }

  //       final datosZona = await ApiService.getZonaTrabajo(zona.toString());
  //       final empresaLat = double.tryParse(
  //       datosZona['LAT']?.toString() ??
  //       datosZona['lat']?.toString() ??
  //       '') ?? 0.0;

  // final empresaLng = double.tryParse(
  //       datosZona['LNG']?.toString() ??
  //       datosZona['lng']?.toString() ??
  //       '') ?? 0.0;

  // final rangoPermitidoMetros = double.tryParse(
  //       datosZona['RANGO']?.toString() ??
  //       datosZona['rango']?.toString() ??
  //       '') ?? 150.0;

  //       final yaRegistro = await ApiService.yaRegistroEntradaHoy(usuario.nombre);
  //       final yaRegistro2 = await ApiService.yaRegistroSalidaHoy(usuario.nombre);
  //       if (yaRegistro || yaRegistro2)
  //         return "⚠️ Ya registró su entrada o salida hoy.";

  //       final prefs = await SharedPreferences.getInstance();
  //       final datosGuardados = prefs.getString('movimiento_datos');
  //       if (datosGuardados != null) {
  //         try {
  //           final datos = jsonDecode(datosGuardados);
  //           final fechaEntrada = DateTime.tryParse(datos['FECHA_ENTRADA'] ?? '');
  //           final hoy = DateTime.now();
  //           if (fechaEntrada != null &&
  //               fechaEntrada.year == hoy.year &&
  //               fechaEntrada.month == hoy.month &&
  //               fechaEntrada.day == hoy.day) {
  //             return "⚠️ Ya registró su entrada hoy.";
  //           }
  //         } catch (_) {}
  //       }

  //       final posicion = await GpsService.obtenerUbicacion();
  //       if (posicion == null) return "📍 No se pudo obtener ubicación.";

  //       final distancia = GpsService.distanciaMetros(
  //         posicion,
  //         empresaLat,
  //         empresaLng,
  //       );

  //       print("📏 Distancia calculada: ${distancia.toStringAsFixed(2)} metros");
  //       print(
  //         "📍 Coordenadas actuales: ${posicion.latitude}, ${posicion.longitude}",
  //       );
  //       print("🏢 Coordenadas empresa: $empresaLat, $empresaLng");
  //       print("🎯 Rango permitido: $rangoPermitidoMetros m");

  //       if (distancia > rangoPermitidoMetros) {
  //         return "📍 Estás fuera del rango permitido (${distancia.toStringAsFixed(1)} m).";
  //       }

  //       final serial = await DispositivoService.obtenerNombreDispositivo();
  //       final autorizado = await DispositivoService.validarDispositivo();
  //       if (!autorizado) return "🔒 Dispositivo no autorizado.";

  //       final ahora = DateTime.now();
  //       final hora =
  //           "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

  //       final movimiento = {
  //         "NOMBRE_COMPL": usuario.nombre,
  //         "NOMINA": usuario.nomina,
  //         "NUMERO_SERIE": serial,
  //         "ID_EMPRESA": usuario.idEmpresa,
  //         "ID_EMPLEADO": usuario.id,
  //         "ID_AREA": usuario.idArea,
  //         "ID_TIPO": usuario.idTipo,
  //         "ID_ZONA": usuario.idZona,
  //         "FECHA_ENTRADA": ahora.toIso8601String(),
  //         "HORA_ENTRADA": hora,
  //         "UBICACION_ENTRADA": "${posicion.latitude},${posicion.longitude}",
  //       };

  //       print("📤 Movimiento a enviar:");
  //       print(jsonEncode(movimiento));

  //       final id = await ApiService.insertMovimiento(movimiento);
  //       if (id != null) {
  //         AuthService.movimientoActivoId = id;
  //         AuthService.datosEntrada = movimiento;
  //         await prefs.setInt('movimiento_id', id);
  //         movimiento['ID_MOVIMIENTOS'] = id.toString();
  //         movimiento['SINCRONIZADO'] = 'S';
  //         await prefs.setString('movimiento_datos', jsonEncode(movimiento));
  //         return "✅ Entrada registrada exitosamente.\n🌞 ¡Buen día!";
  //       }

  //       movimiento['SINCRONIZADO'] = 'N';
  //       await DatabaseHelper.guardarMovimiento(movimiento);
  //       return "✅ Entrada guardada localmente.\n📴 Se enviará cuando haya internet.";
  //     } catch (e, stack) {
  //       print("❌ Error inesperado en registrarEntrada: $e");
  //       print(stack);
  //       return "❌ Error inesperado. Verifica conexión o permisos.";
  //     }
  //   }

  static Future<String> registrarEntrada() async {
    try {
      final usuario = AuthService.usuarioActivo;
      if (usuario == null) return "❌ No hay usuario autenticado.";

      final zona = usuario.idZona;
      if (zona == null) {
        return "⚠️ No tienes asignada una zona de trabajo. Contacta al administrador.";
      }

      // ==========================
      // 📍 DATOS DE ZONA
      // ==========================
      final datosZona = await ApiService.getZonaTrabajo(zona.toString());
      final empresaLat =
          double.tryParse(
            datosZona['LAT']?.toString() ?? datosZona['lat']?.toString() ?? '',
          ) ??
          0.0;
      final empresaLng =
          double.tryParse(
            datosZona['LNG']?.toString() ?? datosZona['lng']?.toString() ?? '',
          ) ??
          0.0;
      final rangoPermitidoMetros =
          double.tryParse(
            datosZona['RANGO']?.toString() ??
                datosZona['rango']?.toString() ??
                '',
          ) ??
          150.0;

      // ==========================
      // 📅 VALIDAR SI YA REGISTRÓ HOY
      // ==========================
      final prefs = await SharedPreferences.getInstance();
      final hoy = DateTime.now();
      final fechaHoyStr = "${hoy.year}-${hoy.month}-${hoy.day}";
      final ultimaFechaStr = prefs.getString('ultima_fecha') ?? '';

      // 🔹 Si la fecha guardada es distinta → permitir nueva entrada y actualizar
      if (ultimaFechaStr != fechaHoyStr) {
        print(
          "🆕 Nuevo día detectado desde SharedPrefs ($ultimaFechaStr → $fechaHoyStr)",
        );
        await prefs.setString('ultima_fecha', fechaHoyStr);
      } else {
        // 🔹 Consultar si el backend reporta una entrada sin salida
        final yaRegistroEntrada = await ApiService.yaRegistroEntradaHoy(
          usuario.nombre,
        );
        final yaRegistroSalida = await ApiService.yaRegistroSalidaHoy(
          usuario.nombre,
        );

        // ==========================
        // 🕓 AJUSTE POR ZONA HORARIA
        // ==========================
        final ahoraLocal = DateTime.now(); // Hora local del dispositivo
        final ahoraUtc = ahoraLocal.toUtc(); // Hora en UTC

        // Si el servidor y el dispositivo están en el mismo día UTC → validar normalmente
        if (ahoraUtc.day == ahoraLocal.day) {
          if (yaRegistroEntrada && !yaRegistroSalida) {
            print(
              "⚠️ El servidor reporta que ya se registró entrada/salida hoy (mismo día UTC).",
            );
            return "⚠️ Ya registró su entrada hoy.";
          }
        } else {
          // Si hay desfase de zona (servidor en UTC, local en otro día), permitimos nueva entrada
          print(
            "🕓 Zona horaria desfasada — ignorando validación del servidor y permitiendo nueva entrada.",
          );
        }
      }

      // ==========================
      // 📍 VALIDAR UBICACIÓN
      // ==========================
      final posicion = await GpsService.obtenerUbicacion();
      if (posicion == null) return "📍 No se pudo obtener ubicación.";

      final distancia = GpsService.distanciaMetros(
        posicion,
        empresaLat,
        empresaLng,
      );
      if (distancia > rangoPermitidoMetros) {
        return "📍 Estás fuera del rango permitido (${distancia.toStringAsFixed(1)} m).";
      }

      final serial = await DispositivoService.obtenerNombreDispositivo();
      final autorizado = await DispositivoService.validarDispositivo();
      if (!autorizado) return "🔒 Dispositivo no autorizado.";

      // ==========================
      // 🕒 CREAR MOVIMIENTO
      // ==========================
      final ahora = DateTime.now();
      final hora =
          "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

      final movimiento = {
        "NOMBRE_COMPL": usuario.nombre,
        "NOMINA": usuario.nomina,
        "NUMERO_SERIE": serial,
        "ID_EMPRESA": usuario.idEmpresa,
        "ID_EMPLEADO": usuario.id,
        "ID_AREA": usuario.idArea,
        "ID_TIPO": usuario.idTipo,
        "ID_ZONA": usuario.idZona,
        "FECHA_ENTRADA": ahora.toIso8601String(),
        "HORA_ENTRADA": hora,
        "UBICACION_ENTRADA": "${posicion.latitude},${posicion.longitude}",
      };

      print("📤 Movimiento a enviar: ${jsonEncode(movimiento)}");

      final id = await ApiService.insertMovimiento(movimiento);
      if (id != null) {
        AuthService.movimientoActivoId = id;
        AuthService.datosEntrada = movimiento;
        await prefs.setInt('movimiento_id', id);
        movimiento['ID_MOVIMIENTOS'] = id.toString();
        movimiento['SINCRONIZADO'] = 'S';
        await prefs.setString('movimiento_datos', jsonEncode(movimiento));

        // 💾 Guardar fecha actual para evitar duplicados en el mismo día
        await prefs.setString('ultima_fecha', fechaHoyStr);

        return "✅ Entrada registrada exitosamente.\n🌞 ¡Buen día!";
      }

      movimiento['SINCRONIZADO'] = 'N';
      await DatabaseHelper.guardarMovimiento(movimiento);
      await prefs.setString('ultima_fecha', fechaHoyStr);
      return "✅ Entrada guardada localmente.\n📴 Se enviará cuando haya internet.";
    } catch (e, stack) {
      print("❌ Error inesperado en registrarEntrada: $e");
      print(stack);
      return "❌ Error inesperado. Verifica conexión o permisos.";
    }
  }

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  // ---------------------REGISTRAR SALIDA---------------------------------
  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------

  //   static Future<String> registrarSalida() async {
  //     final usuario = AuthService.usuarioActivo;
  //     if (usuario == null) return "❌ Usuario no autenticado.";

  //     final zona = usuario.idZona;
  //     if (zona == null) {
  //       return "⚠️ No tienes asignada una zona de trabajo. Por favor contacta al administrador.";
  //     }

  //     final datosZona = await ApiService.getZonaTrabajo(zona.toString());
  //      final empresaLat = double.tryParse(
  //       datosZona['LAT']?.toString() ??
  //       datosZona['lat']?.toString() ??
  //       '') ?? 0.0;

  //     final empresaLng = double.tryParse(
  //       datosZona['LNG']?.toString() ??
  //       datosZona['lng']?.toString() ??
  //       '') ?? 0.0;

  //     final rangoPermitidoMetros = double.tryParse(
  //       datosZona['RANGO']?.toString() ??
  //       datosZona['rango']?.toString() ??
  //       '') ?? 0.0;

  //     final posicion = await GpsService.obtenerUbicacion();
  //     if (posicion == null) return "📍 No se pudo obtener ubicación.";

  //     final distancia = GpsService.distanciaMetros(
  //       posicion,
  //       empresaLat,
  //       empresaLng,
  //     );
  //     if (distancia > rangoPermitidoMetros) {
  //       return "📍 Estás fuera del rango permitido (${distancia.toStringAsFixed(1)} m). Acércate al área asignada.";
  //     }

  //     final serial = await DispositivoService.obtenerNombreDispositivo();
  //     final autorizado = await DispositivoService.validarDispositivo();
  //     if (!autorizado) return "🔒 Dispositivo no autorizado.";

  //     final ahora = DateTime.now();
  //     final hora =
  //         "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

  //     int? idMovimiento = AuthService.movimientoActivoId;

  //     if (idMovimiento == null) {
  //       final prefs = await SharedPreferences.getInstance();
  //       final idGuardado = prefs.getInt('movimiento_id');

  //       if (idGuardado != null) {
  //         idMovimiento = idGuardado;
  //         AuthService.movimientoActivoId = idMovimiento;
  //         print("🔁 ID restaurado desde SharedPreferences: $idMovimiento");
  //       } else {
  //         final respuesta = await ApiService.getObtener(usuario.nombre);
  //         if (respuesta.crudo is List) {
  //           final List registros = respuesta.crudo;
  //           final hoy = DateTime.now();
  //           final registroHoy = registros.firstWhere((e) {
  //             final fechaRaw = e['FECHA_ENTRADA']?.toString() ?? '';
  //             try {
  //               final fecha = DateFormat('dd/MM/yyyy').parse(fechaRaw);
  //               return fecha.year == hoy.year &&
  //                   fecha.month == hoy.month &&
  //                   fecha.day == hoy.day;
  //             } catch (_) {
  //               return false;
  //             }
  //           }, orElse: () => null);

  //           if (registroHoy != null) {
  //             idMovimiento = int.tryParse(
  //               registroHoy['ID_MOVIMIENTOS'].toString(),
  //             );
  //             AuthService.movimientoActivoId = idMovimiento;
  //             print("🆔 ID recuperado desde historial API: $idMovimiento");
  //           }
  //         }
  // // =============================================
  // // REGISTRO DE SOLO SALIDA
  // // =============================================

  //         if (idMovimiento == null) {
  //           print(
  //             "⚠️ No se encontró entrada previa. Se registrará salida directamente.",
  //           );

  //           final movimiento = {
  //             "NOMBRE_COMPL": usuario.nombre,
  //             "NOMINA": usuario.nomina,
  //             "NUMERO_SERIE": serial,
  //             "ID_EMPRESA": usuario.idEmpresa,
  //             "ID_EMPLEADO": usuario.id,
  //             "ID_AREA": usuario.idArea,
  //             "ID_TIPO": usuario.idTipo,
  //             "ID_ZONA": usuario.idZona,
  //             "FECHA_SALIDA": ahora.toIso8601String(),
  //             "HORA_SALIDA": hora,
  //             "UBICACION_ENTRADA": "${posicion.latitude},${posicion.longitude}",
  //             "UBICACION_SALIDA": "${posicion.latitude},${posicion.longitude}",
  //           };

  //           final nuevoId = await ApiService.insert2Movimiento(movimiento);
  //           if (nuevoId != null) {
  //             AuthService.movimientoActivoId = nuevoId;
  //             await prefs.setInt('movimiento_id', nuevoId);
  //             return "✅ Salida registrada directamente.\n📤 No se encontró entrada previa.";
  //           } else {
  //             return "❌ No se pudo registrar salida directa.";
  //           }
  //         }
  //       }
  //     }
  // // =============================================
  // // REGISTRO DE SALIDA DIRECTO
  // // =============================================
  //     final movimiento = {
  //       "ID_MOVIMIENTO": idMovimiento,
  //       "ID_EMPRESA": usuario.idEmpresa,
  //       "FECHA_SALIDA": ahora.toIso8601String(),
  //       "HORA_SALIDA": hora,
  //       "UBICACION_SALIDA": "${posicion.latitude},${posicion.longitude}",
  //     };

  //     print("📤 Enviando salida parcial: ${jsonEncode(movimiento)}");
  //     final ok = await ApiService.updateMovimiento(movimiento);
  //     return ok
  //         ? "✅ Salida registrada correctamente.\n🏁 ¡Buen trabajo hoy!"
  //         : "⚠️ Salida registrada correctamente vuelva pronto..";
  //   }

static Future<String> registrarSalida() async {
  try {
    final usuario = AuthService.usuarioActivo;
    if (usuario == null) return "❌ Usuario no autenticado.";

    final zona = usuario.idZona;
    if (zona == null) {
      return "⚠️ No tienes asignada una zona de trabajo. Contacta al administrador.";
    }

    // ==========================
    // 📍 DATOS DE ZONA
    // ==========================
    final datosZona = await ApiService.getZonaTrabajo(zona.toString());
    final empresaLat = double.tryParse(
          datosZona['LAT']?.toString() ?? datosZona['lat']?.toString() ?? '',
        ) ??
        0.0;
    final empresaLng = double.tryParse(
          datosZona['LNG']?.toString() ?? datosZona['lng']?.toString() ?? '',
        ) ??
        0.0;
    final rangoPermitidoMetros = double.tryParse(
          datosZona['RANGO']?.toString() ?? datosZona['rango']?.toString() ?? '',
        ) ??
        150.0;

    // ==========================
    // 📍 VALIDAR UBICACIÓN
    // ==========================
    final posicion = await GpsService.obtenerUbicacion();
    if (posicion == null) return "📍 No se pudo obtener ubicación.";

    final distancia = GpsService.distanciaMetros(
      posicion,
      empresaLat,
      empresaLng,
    );
    if (distancia > rangoPermitidoMetros) {
      return "📍 Estás fuera del rango permitido (${distancia.toStringAsFixed(1)} m).";
    }

    // ==========================
    // 🔒 VALIDAR DISPOSITIVO
    // ==========================
    final serial = await DispositivoService.obtenerNombreDispositivo();
    final autorizado = await DispositivoService.validarDispositivo();
    if (!autorizado) return "🔒 Dispositivo no autorizado.";

    // ==========================
    // 🕓 DATOS DE TIEMPO ACTUAL
    // ==========================
    final ahora = DateTime.now();
    final hora =
        "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";
    final fechaHoyStr = "${ahora.year}-${ahora.month}-${ahora.day}";

    final prefs = await SharedPreferences.getInstance();
    final ultimaFechaStr = prefs.getString('ultima_fecha') ?? '';
    int? idMovimiento = AuthService.movimientoActivoId;

    // ==========================
    // 🔄 VERIFICAR CAMBIO DE DÍA
    // ==========================
    if (ultimaFechaStr != fechaHoyStr) {
      print("🌅 Nuevo día detectado: no se usará ID de movimiento previo.");
      idMovimiento = null; // 👈 Evita registrar salida sobre movimiento viejo
      await prefs.setString('ultima_fecha', fechaHoyStr);
    }

    // ==========================
    // 🔍 OBTENER ID SI EXISTE
    // ==========================
    if (idMovimiento == null) {
      final idGuardado = prefs.getInt('movimiento_id');
      if (idGuardado != null) {
        idMovimiento = idGuardado;
        print("🔁 ID restaurado desde SharedPreferences: $idMovimiento");
      } else {
        // Buscar si hay entrada del mismo día desde el backend
        final respuesta = await ApiService.getObtener(usuario.nombre);
        if (respuesta.crudo is List) {
          final List registros = respuesta.crudo;
          final registroHoy = registros.firstWhere(
            (e) {
              final fechaRaw = e['FECHA_ENTRADA']?.toString() ?? '';
              try {
                final fecha = DateTime.parse(fechaRaw);
                return fecha.year == ahora.year &&
                    fecha.month == ahora.month &&
                    fecha.day == ahora.day;
              } catch (_) {
                return false;
              }
            },
            orElse: () => null,
          );

          if (registroHoy != null) {
            idMovimiento =
                int.tryParse(registroHoy['ID_MOVIMIENTOS'].toString());
            AuthService.movimientoActivoId = idMovimiento;
            print("🆔 ID recuperado desde API para hoy: $idMovimiento");
          }
        }
      }
    }

    // ==========================
    // 🚫 SIN ENTRADA PREVIA
    // ==========================
    if (idMovimiento == null) {
      print("⚠️ No se encontró entrada previa. Se registrará salida directa.");

      final movimiento = {
        "NOMBRE_COMPL": usuario.nombre,
        "NOMINA": usuario.nomina,
        "NUMERO_SERIE": serial,
        "ID_EMPRESA": usuario.idEmpresa,
        "ID_EMPLEADO": usuario.id,
        "ID_AREA": usuario.idArea,
        "ID_TIPO": usuario.idTipo,
        "ID_ZONA": usuario.idZona,
        "FECHA_SALIDA": ahora.toIso8601String(),
        "HORA_SALIDA": hora,
        "UBICACION_ENTRADA": "${posicion.latitude},${posicion.longitude}",
        "UBICACION_SALIDA": "${posicion.latitude},${posicion.longitude}",
      };

      final nuevoId = await ApiService.insert2Movimiento(movimiento);
      if (nuevoId != null) {
        AuthService.movimientoActivoId = nuevoId;
        await prefs.setInt('movimiento_id', nuevoId);
        return "✅ Salida registrada directamente.\n(No había entrada previa registrada)";
      } else {
        return "❌ No se pudo registrar salida directa.";
      }
    }

    // ==========================
    // 📝 REGISTRO NORMAL DE SALIDA
    // ==========================
    final movimiento = {
      "ID_MOVIMIENTO": idMovimiento,
      "ID_EMPRESA": usuario.idEmpresa,
      "FECHA_SALIDA": ahora.toIso8601String(),
      "HORA_SALIDA": hora,
      "UBICACION_SALIDA": "${posicion.latitude},${posicion.longitude}",
    };

    print("📤 Enviando salida parcial: ${jsonEncode(movimiento)}");

    final ok = await ApiService.updateMovimiento(movimiento);

    if (ok) {
      // Limpiar ID para evitar reutilizarlo al siguiente día
      await prefs.remove('movimiento_id');
      AuthService.movimientoActivoId = null;

      // Actualizar fecha
      await prefs.setString('ultima_fecha', fechaHoyStr);

      return "✅ Salida registrada correctamente.\n🏁 ¡Buen trabajo hoy!";
    } else {
      return "⚠️ Error al registrar salida. Intenta nuevamente.";
    }
  } catch (e, stack) {
    print("❌ Error inesperado en registrarSalida: $e");
    print(stack);
    return "❌ Error inesperado. Verifica conexión o permisos.";
  }
}

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  // ---------------------REGISTRAR EL TIPO DE AUSENCIA--------------------
  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  static Future<String> registrarTipoAusencia(String tipo) async {
    final idString = AuthService.usuarioActivo?.id ?? '0';
    final id = int.tryParse(idString) ?? 0;
    return await ApiService.registrarTipoAusencia(tipo, id);
  }

  static Future<void> registrarTipoAusenciaEnFecha(
    String tipo,
    DateTime fecha,
  ) async {
    final usuario = AuthService.usuarioActivo;
    if (usuario == null) return;

    final zona = usuario.idZona?.toString() ?? '';
    final serial = await DispositivoService.obtenerNombreDispositivo();

    final body = {
      'TIPO': tipo,
      'NOMINA': usuario.nomina,
      'NOMBRE_COMPL': usuario.nombre,
      'AREA': usuario.areaNombre,
      'FECHA_ENTRADA': fecha.toIso8601String(),
      'NUMERO_SERIE': serial,
    };

    await ApiService.postMovimientoDirecto(body);
  }

  static Future<void> verificarFaltasRetroactivas() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = DateTime.now();
    final formato = DateFormat('yyyy-MM-dd');

    final ultimaFechaStr =
        prefs.getString('ultimaFechaFalta') ??
        formato.format(hoy.subtract(Duration(days: 1)));
    final ultimaFecha = formato.parse(ultimaFechaStr);
    DateTime fechaActual = ultimaFecha.add(Duration(days: 1));

    while (!fechaActual.isAfter(hoy)) {
      final fechaStr = formato.format(fechaActual);
      final exito = await ApiService.registrarFaltasEnFecha(fechaStr);
      if (exito) {
        print('✅ Faltas registradas en $fechaStr');
        await prefs.setString('ultimaFechaFalta', fechaStr);
      } else {
        print('⚠️ Fallo en $fechaStr');
        break;
      }
      fechaActual = fechaActual.add(Duration(days: 1));
    }
  }
}

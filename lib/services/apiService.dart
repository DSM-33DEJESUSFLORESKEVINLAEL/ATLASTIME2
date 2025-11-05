// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:atlastime/db/database_helper.dart';
// import 'package:atlastime/models/usuario.dart';
import 'package:atlastime/services/auth_service.dart';
import 'package:atlastime/services/dispositivo_service.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class ObtenerRespuesta {
  final dynamic crudo;
  final List<Map<String, dynamic>> lista;

  ObtenerRespuesta({required this.crudo, required this.lista});
}

class ApiService {
  static const String baseUrl =
      // 'http://atlastoluca.dyndns.org:18000/datasnap/rest/TServerMethods1';
         "http://atlastoluca.dyndns.org:20000/datasnap/rest/TServerMethods1";

  //---------------------------------------------------------------------
  // LOGIN
  //---------------------------------------------------------------------

  static Future<Map<String, dynamic>?> login(
    String usuario,
    String clave,
  ) async {
    final url = Uri.parse('$baseUrl/LoginMOVIL/$usuario/$clave');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json is Map && json.containsKey('DATA')) {
          final dataList = json['DATA'];
          if (dataList is List && dataList.isNotEmpty) {
            final userMap = dataList[0];
            return userMap; // 👈 ESTO ES LO QUE DEBE LLEGAR A LOGIN_PAGE
          }
        }
      }
    } catch (e) {
      print('Error en login API: $e');
    }
    return null;
  }

  //---------------------------------------------------------------------
  // OBTENER ID

  //---------------------------------------------------------------------

  // OBTENER NOMBRE DEL TIPO POR ID
  static Future<String> getNombreTipo(String idTipo) async {
    final url = Uri.parse('$baseUrl/getTipoByID/$idTipo');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['DATA'] as List;
        if (data.isNotEmpty) return data[0]['NOMBRE'] ?? 'Desconocido';
      }
    } catch (e) {
      print("❌ Error en getNombreTipo: $e");
    }
    return 'Desconocido';
  }

  // OBTENER NOMBRE DEL ÁREA POR ID
  static Future<String> getNombreArea(String idArea) async {
    final url = Uri.parse('$baseUrl/getAreaByID/$idArea');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['DATA'] as List;
        if (data.isNotEmpty) return data[0]['NOMBRE'] ?? 'Desconocido';
      }
    } catch (e) {
      print("❌ Error en getNombreArea: $e");
    }
    return 'Desconocido';
  }

  // OBTENER HORARIO FORMATEADO POR ID
  static Future<String> getHorarioTexto(String idHorario) async {
    final url = Uri.parse('$baseUrl/getHorarioByID/$idHorario');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['DATA'] as List;
        if (data.isNotEmpty) {
          final h = data[0];
          return '${h['HORA_ENTRADA']} - ${h['HORA_SALIDA']}';
        }
      }
    } catch (e) {
      print("❌ Error en getHorarioTexto: $e");
    }
    return 'Horario desconocido';
  }

  //---------------------------------------------------------------------
  // EN OBSERVACION

  //---------------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getHistorial(String nombre) async {
    final url = Uri.parse('$baseUrl/Gethistorial/$nombre');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['DATA'] as List;
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  // ---------------------------------ZONA----------------------------------------

  // static Future<Map<String, dynamic>> getZonaTrabajo(String idZona) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/GetZonaTrabajoByID/$idZona'),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final zonaMap = {
  //         'ZONA': data['ID_ZONA'],
  //         'lat': data['LATITUD'],
  //         'lng': data['LONGITUD'],
  //         'rango': data['RANGO_METROS'],
  //       };

  //       // Guarda localmente
  //       await DatabaseHelper.guardarZonaTrabajo(zonaMap);

  //       return zonaMap;
  //     } else {
  //       print("⚠️ Error al obtener zona: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error al obtener zona: $e");

  //     // Cargar desde SQLite si existe
  //     final zonaLocal = await DatabaseHelper.obtenerZonaTrabajo(idZona);
  //     if (zonaLocal != null) {
  //       print("📦 Zona recuperada localmente desde SQLite");
  //       return {
  //         'ZONA': zonaLocal['ID_ZONA'],
  //         'lat': zonaLocal['LAT'],
  //         'lng': zonaLocal['LNG'],
  //         'rango': zonaLocal['RANGO'],
  //       };
  //     }
  //   }

  //   // 🔁 Fallback por si no hay ni API ni SQLite
  //   return {};
  // }
static Future<Map<String, dynamic>> getZonaTrabajo(String idZona) async {
  try {
    if (idZona.isEmpty) {
      print("⚠️ ID de zona vacío, no se puede consultar");
      return {};
    }

    // 🔹 Si no es un ID numérico, igual hacemos la consulta (porque tu servidor acepta nombres)
    final response = await http.get(
      Uri.parse('$baseUrl/GetZonaTrabajoByID/$idZona'),
    );

    if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;

      // ✅ Detectar si viene directo o dentro de DATA
      Map<String, dynamic>? data;

      // ignore: unnecessary_type_check
      if (jsonData is Map && jsonData['DATA'] is List && jsonData['DATA'].isNotEmpty) {
        data = jsonData['DATA'][0];
      // ignore: unnecessary_type_check
      } else if (jsonData is Map && jsonData.containsKey('ID_ZONA')) {
        data = jsonData;
      } else {
        print("⚠️ Respuesta del servidor vacía o formato desconocido");
        return {};
      }

      // 🔹 Construir mapa estándar
      final zonaServer = {
        'ID_ZONA': data?['ID_ZONA']?.toString() ?? '',
        'ZONA': data?['ID_ZONA']?.toString() ?? 'SIN NOMBRE',
        'LAT': double.tryParse(data?['LATITUD']?.toString() ?? '0') ?? 0.0,
        'LNG': double.tryParse(data?['LONGITUD']?.toString() ?? '0') ?? 0.0,
        'RANGO': double.tryParse(data?['RANGO_METROS']?.toString() ?? '0') ?? 0.0,
      };

      // 💾 Guardar / actualizar en SQLite
      await DatabaseHelper.guardarZonaTrabajo(zonaServer, desdeServidor: true);

      print("💾 Zona guardada correctamente → ${zonaServer['ZONA']}");
      return zonaServer;
    } else {
      print("⚠️ Fallo al obtener zona (HTTP ${response.statusCode})");
    }
  } catch (e) {
    print("❌ Error al obtener zona: $e");
  }

  // 🔁 Fallback — intentar cargar desde SQLite si no hay respuesta del servidor
  final zonaLocal = await DatabaseHelper.obtenerZonaTrabajo(idZona);
  if (zonaLocal != null) {
    print("📦 Zona recuperada desde SQLite → ${zonaLocal['ZONA']}");
    return {
      'ID_ZONA': zonaLocal['ID_ZONA']?.toString() ?? '',
      'ZONA': zonaLocal['ZONA']?.toString() ?? '',
      'LAT': (zonaLocal['LAT'] ?? 0.0).toDouble(),
      'LNG': (zonaLocal['LNG'] ?? 0.0).toDouble(),
      'RANGO': (zonaLocal['RANGO'] ?? 0.0).toDouble(),
    };
  }

  print("⚠️ No se encontró zona ni en servidor ni en SQLite");
  return {};
}

  static Future<ObtenerRespuesta> getObtener(String nombre) async {
    final url = Uri.parse('$baseUrl/Obtener/$nombre');
    final res = await http.get(url);

    dynamic json;
    List<Map<String, dynamic>> lista = [];

    if (res.statusCode == 200) {
      json = jsonDecode(res.body);
      print("📦 Respuesta cruda: $json");

      if (json is List) {
        lista = List<Map<String, dynamic>>.from(json);
      } else if (json is Map && json['DATA'] != null) {
        lista = List<Map<String, dynamic>>.from(json['DATA']);
      } else {
        // print("! La respuesta no contiene datos esperados.");
      }
    } else {
      print("⚠️ Error HTTP ${res.statusCode}: ${res.body}");
    }

    return ObtenerRespuesta(crudo: json, lista: lista);
  }

  //---------------------------------------------------------------------

  static Future<dynamic> insertMovimiento(
    Map<String, dynamic> movimiento,
  ) async {
    final url = Uri.parse('$baseUrl/InsertMovimiento');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movimiento),
      );

      print("📤 Enviando movimiento: ${jsonEncode(movimiento)}");
      print("📥 StatusCode: ${res.statusCode}");
      print("📥 Body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = res.body.trim();
        dynamic decoded;

        try {
          decoded = jsonDecode(body);
          print("📥 Tipo de response: ${decoded.runtimeType}");
        } catch (_) {
          decoded = body;
          print("📥 Response como texto: $decoded");
        }

        if (decoded is Map && decoded['result'] != null) {
          final result = decoded['result'];
          if (result is List && result.isNotEmpty) {
            return int.tryParse(result[0].toString());
          }
        }

        final intValue = int.tryParse(body);
        if (intValue != null) return intValue;

        if (body == 'true' || decoded == true) return true;
      } else {
        print("❌ Error HTTP: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ Excepción al enviar movimiento: $e");
    }

    return null;
  }

  // ---------------------------------------------------------------------------

  static Future<dynamic> insert2Movimiento(
    Map<String, dynamic> movimiento,
  ) async {
    final url = Uri.parse('$baseUrl/Insert2Movimiento');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movimiento),
      );

      print("📤 Enviando movimiento: ${jsonEncode(movimiento)}");
      print("📥 StatusCode: ${res.statusCode}");
      print("📥 Body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = res.body.trim();
        dynamic decoded;

        try {
          decoded = jsonDecode(body);
          print("📥 Tipo de response: ${decoded.runtimeType}");
        } catch (_) {
          decoded = body;
          print("📥 Response como texto: $decoded");
        }

        if (decoded is Map && decoded['result'] != null) {
          final result = decoded['result'];
          if (result is List && result.isNotEmpty) {
            return int.tryParse(result[0].toString());
          }
        }

        final intValue = int.tryParse(body);
        if (intValue != null) return intValue;

        if (body == 'true' || decoded == true) return true;
      } else {
        print("❌ Error HTTP: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ Excepción al enviar movimiento: $e");
    }

    return null;
  }
  // ------------------------------------------------------------------------------

  // ACTUALIZAR MOVIMIENTO
  static Future<bool> updateMovimiento(Map<String, dynamic> movimiento) async {
    final url = Uri.parse(
      '$baseUrl/InsertMovimiento',
    ); // ⚠️ Usa el endpoint correcto

    try {
      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movimiento),
      );

      print("📤 Enviando actualización: ${jsonEncode(movimiento)}");
      print("📥 StatusCode: ${res.statusCode}");
      print("📥 Body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);

        if (decoded is Map && decoded['result'] != null) {
          return decoded['result'][0] == true;
        }

        if (decoded is bool) {
          return decoded;
        }
      } else {
        print("❌ Error HTTP al actualizar: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ Excepción al actualizar movimiento: $e");
    }

    return false;
  }

  // ELIMINAR MOVIMIENTO POR ID
  static Future<bool> deleteMovimiento(int id) async {
    final url = Uri.parse('$baseUrl/DeleteMovimiento/$id');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['result'][0] == true;
    }
    return false;
  }

  // OBTENER TODOS LOS EMPLEADOS
  static Future<List<Map<String, dynamic>>> getEmpleados() async {
    final url = Uri.parse('$baseUrl/GetEmpleados');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['DATA'] as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // OBTENER EMPLEADO POR ID
  static Future<Map<String, dynamic>?> getEmpleado(int id) async {
    final url = Uri.parse('$baseUrl/GetEmpleado/$id');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['DATA'] as List;
      if (data.isNotEmpty) return data[0];
    }
    return null;
  }

  // INSERTAR EMPLEADO
  static Future<bool> insertEmpleado(Map<String, dynamic> empleado) async {
    final url = Uri.parse('$baseUrl/InsertEmpleado');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(empleado),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['result'][0] == true;
    }
    return false;
  }

  // ACTUALIZAR EMPLEADO
  static Future<bool> updateEmpleado(Map<String, dynamic> empleado) async {
    final url = Uri.parse('$baseUrl/UpdateEmpleado');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(empleado),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['result'][0] == true;
    }
    return false;
  }

  // ELIMINAR EMPLEADO POR ID
  static Future<bool> deleteEmpleado(int id) async {
    final url = Uri.parse('$baseUrl/DeleteEmpleado/$id');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['result'][0] == true;
    }
    return false;
  }

  // VERIFICAR SI YA REGISTRÓ ENTRADA HOY
  static Future<bool> yaRegistroEntradaHoy(String nombre) async {
    final url = Uri.parse('$baseUrl/YaRegistroEntradaHoy/$nombre');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is bool) {
          return decoded; // <-- ✅ Si la API devuelve directamente "true"
        }
        if (decoded is Map && decoded['result'] != null) {
          return decoded['result'][0] == true;
        }
      }
    } catch (e) {
      print("❌ Error en yaRegistroEntradaHoy: $e");
    }
    return false;
  }

  // VERIFICAR SI YA REGISTRÓ ENTRADA HOY
  static Future<bool> yaRegistroSalidaHoy(String nombre) async {
    final url = Uri.parse('$baseUrl/yaRegistroSalidaHoy/$nombre');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is bool) {
          return decoded; // <-- ✅ Si la API devuelve directamente "true"
        }
        if (decoded is Map && decoded['result'] != null) {
          return decoded['result'][0] == true;
        }
      }
    } catch (e) {
      print("❌ Error en yaRegistroSalidaHoy: $e");
    }
    return false;
  }

  //   static Future<String> registrarTipoAusencia(
  //     String tipo,
  //     int usuarioId,
  //   ) async {
  //     final usuario = AuthService.usuarioActivo;
  //     if (usuario == null) return "Usuario no autenticado.";

  //     final zona = usuario.zona ?? '';
  //     final serial = await DispositivoService.obtenerNombreDispositivo();

  //     final url = Uri.parse('$baseUrl/RegistrarTipoAusencia');
  //     final body = jsonEncode({
  //       'TIPO': tipo,
  //       'NOMINA': usuario.nomina,
  //       'NOMBRE_COMPL': usuario.nombre,
  //       'AREA': usuario.areaNombre,
  //       'FECHA_ENTRADA': DateTime.now().toIso8601String(),
  //       'NUMERO_SERIE': serial,
  //       // 'UBICACION_PRINCIPAL': zona,
  //     });

  //  print("📤 JSON enviado a RegistrarTipoAusencia:");
  //   print(jsonEncode(body)); // 🔍 Aquí ves el JSON en consola
  //     try {
  //       final res = await http.post(
  //         url,
  //         headers: {'Content-Type': 'application/json'},
  //         body: body,
  //       );

  //       if (res.statusCode == 200) {
  //         return "Registro de $tipo exitoso.";
  //         //  return"";
  //       } else {
  //         return "Error al registrar $tipo: ${res.body}";
  //       }
  //     } catch (e) {
  //       return "Error de conexión: $e";
  //     }
  //   }
  // static Future<String> registrarTipoAusencia(
  //   String tipo,
  //   int usuarioId,
  // ) async {
  //   final usuario = AuthService.usuarioActivo;
  //   if (usuario == null) return "Usuario no autenticado.";

  //   final zona = usuario.zona ?? '';
  //   final serial = await DispositivoService.obtenerNombreDispositivo();

  //   // 🔁 Obtener los ID de tipo y área
  //   final idTipo = usuario.idTipo.toString(); // ejemplo: "4"
  //   final nombreTipo = tipo; // ejemplo: "VACACION"
  //   final idArea = usuario.idArea.toString();

  //   final url = Uri.parse('$baseUrl/RegistrarTipoAusencia');
  //   final body = jsonEncode({
  //     'ID_TIPO': idTipo,       // ✅ Se envía como número o string de número
  //     'TIPO': nombreTipo,      // ✅ Se envía como texto
  //     'NOMINA': usuario.nomina,
  //     'NOMBRE_COMPL': usuario.nombre,
  //     'AREA': idArea,
  //     'FECHA_ENTRADA': DateTime.now().toIso8601String(),
  //     'NUMERO_SERIE': serial,
  //   });

  //   print("📤 JSON enviado a RegistrarTipoAusencia:");
  //   print(body);

  //   try {
  //     final res = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: body,
  //     );

  //     if (res.statusCode == 200) {
  //       return "Registro de $tipo exitoso.";
  //     } else {
  //       return "Error al registrar $tipo: ${res.body}";
  //     }
  //   } catch (e) {
  //     return "Error de conexión: $e";
  //   }
  // }
  static Future<String> registrarTipoAusencia(
    String tipo,
    int usuarioId,
  ) async {
    final usuario = AuthService.usuarioActivo;
    if (usuario == null) return "Usuario no autenticado.";

    final serial = await DispositivoService.obtenerNombreDispositivo();

    final idTipo = usuario.idTipo.toString();
    final nombreTipo = tipo;
    final idArea = usuario.idArea.toString();
    final idEmpresa = usuario.idEmpresa ?? ''; // ✅ de tu modelo
    final idEmpleado = usuario.id; // ✅ ya es un string

    final url = Uri.parse('$baseUrl/RegistrarTipoAusencia');
    final body = jsonEncode({
      'ID_TIPO': idTipo,
      'TIPO': nombreTipo,
      'ID_EMPRESA': idEmpresa,
      'ID_EMPLEADO': idEmpleado,
      'NOMINA': usuario.nomina,
      'NOMBRE_COMPL': usuario.nombre,
      'AREA': idArea,
      'FECHA_ENTRADA': DateTime.now().toIso8601String(),
      'NUMERO_SERIE': serial,
    });

    print("📤 JSON enviado a RegistrarTipoAusencia:");
    print(body);

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        return "Registro de $tipo exitoso.";
      } else {
        return "Error al registrar $tipo: ${res.body}";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  static Future<void> postMovimientoDirecto(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/RegistrarTipoAusencia');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      print("❌ Error en postMovimientoDirecto: $e");
    }
  }

  static Future<bool> yaRegistroEntradaEnFecha(
    String nombre,
    DateTime fecha,
  ) async {
    final fechaStr = fecha.toIso8601String().split('T').first; // solo la fecha
    final url = Uri.parse(
      '$baseUrl/YaRegistroEntradaEnFecha/$nombre/$fechaStr',
    );
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is bool) return decoded;
        if (decoded is Map && decoded['result'] != null) {
          return decoded['result'][0] == true;
        }
      }
    } catch (e) {
      print("❌ Error en yaRegistroEntradaEnFecha: $e");
    }
    return false;
  }

  static Future<bool> registrarFaltasEnFecha(String fechaStr) async {
    final url = Uri.parse('$baseUrl/RegistrarFaltasEnFecha/$fechaStr');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body.toLowerCase() == 'true';
      }
    } catch (e) {
      print('❌ Error al registrar faltas para $fechaStr: $e');
    }
    return false;
  }

  // VERIFICAR SI YA EXISTE MOVIMIENTO EN UNA FECHA ESPECÍFICA
  static Future<bool> existeMovimiento(String usuario, DateTime fecha) async {
    final fechaStr = fecha.toIso8601String().split('T').first; // Ej: 2025-07-01
    final url = Uri.parse('$baseUrl/ExisteMoviento/$usuario/$fechaStr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = response.body.trim();
        return body == 'true'; // ✅ Devuelve true si el backend regresó 'true'
      } else {
        print("⚠️ Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error al verificar existencia de movimiento: $e");
    }

    return false;
  }

  // OBTENER TODOS LOS EMPLEADOS
  static Future<List<Map<String, dynamic>>> getFechas() async {
    final url = Uri.parse('$baseUrl/getFechas');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['DATA'] as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> obtenerDatosUsuario(
    int idEmpleado,
  ) async {
    final url = Uri.parse("$baseUrl/getEmpleadoByID/$idEmpleado");

    try {
      final resp = await http.get(url);
      print("📡 STATUS: ${resp.statusCode}");
      print("📦 BODY: ${resp.body}");

      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final json = jsonDecode(resp.body);
        print("🔍 JSON DECODIFICADO: $json");

        Map<String, dynamic>? mapa;

        if (json is Map && json["DATA"] is List && json["DATA"].isNotEmpty) {
          mapa = Map<String, dynamic>.from(json["DATA"][0]);
        } else if (json is List &&
            json.isNotEmpty &&
            json[0]["DATA"] is List &&
            json[0]["DATA"].isNotEmpty) {
          mapa = Map<String, dynamic>.from(json[0]["DATA"][0]);
        }

        if (mapa != null) {
          // ====== 🔥 AQUI: RESOLVER EMPRESA POR ID ======
          final idEmp = mapa["ID_EMPRESA"]?.toString() ?? '';
          final nombreEmpresa = await getNombreEmpresa(idEmp);
          mapa["EMPRESA"] = nombreEmpresa;
          print("🏢 Empresa resuelta desde API: $nombreEmpresa");

          return mapa;
        }
      }
    } catch (e) {
      print("❌ Error obtenerDatosUsuario: $e");
    }

    print("⛔ RETURN NULL en obtenerDatosUsuario()");
    return null;
  }

  // OBTENER NOMBRE DE EMPRESA POR ID
  static Future<String> getNombreEmpresa(String idEmp) async {
    final url = Uri.parse('$baseUrl/getEmpresaByID/$idEmp');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['DATA'] as List;
        if (data.isNotEmpty) return data[0]['NOMBRE'] ?? 'Empresa desconocida';
      }
    } catch (e) {
      print("❌ Error getNombreEmpresa: $e");
    }
    return 'Empresa desconocida';
  }
}

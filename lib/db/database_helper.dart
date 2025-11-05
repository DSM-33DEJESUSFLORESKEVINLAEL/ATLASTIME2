// // ignore_for_file: avoid_print

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseHelper {
//   static Database? _db;

//   static Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await iniciarDB();
//     return _db!;
//   }

//   static Future<Database> iniciarDB() async {
//     final path = join(await getDatabasesPath(), 'asistencia.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//     CREATE TABLE movimientos (
//       ID_MOVIMIENTO INTEGER PRIMARY KEY AUTOINCREMENT,
//       NOMBRE_COMPL TEXT,
//       TIPO TEXT,
//       NOMINA TEXT,
//       NUMERO_SERIE TEXT,
//       AREA TEXT,
//       ID_EMPRESA INTEGER,
//       ID_AREA INTEGER,
//       ID_TIPO INTEGER,
//       ID_ZONA INTEGER,
//       ID_EMPLEADO INTEGER,
//       FECHA_ENTRADA TEXT,
//       HORA_ENTRADA TEXT,
//       FECHA_SALIDA TEXT,
//       HORA_SALIDA TEXT,
//       UBICACION_ENTRADA TEXT,
//       UBICACION_SALIDA TEXT,
//       RETRASO_MINUTOS INTEGER,
//       FOTO_FRONTAL TEXT,
//       FOTO_TRASERA TEXT,
//       SINCRONIZADO TEXT
//     )
//   ''');

//         await db.execute('''
//        CREATE TABLE zonas_trabajo (
//        ID_ZONA TEXT PRIMARY KEY,
//        LAT REAL,
//        LNG REAL,
//        RANGO REAL
//       )
//   ''');

//         print('📦 DB creada con tablas movimientos & zonas_trabajo');
//       },
//     );
//   }

//   // --------------------------------------------------------------------
//   static Future<int> guardarMovimiento(Map<String, dynamic> datos) async {
//     final base = await db;
//     final id = await base.insert('movimientos', datos);
//     print('✅ Movimiento guardado con ID $id: $datos');
//     return id;
//   }

//   static Future<List<Map<String, dynamic>>> movimientosPendientes() async {
//     final base = await db;
//     return await base.query(
//       'movimientos',
//       where: 'SINCRONIZADO = ?',
//       whereArgs: ['N'],
//     );
//   }

//   static Future<void> marcarSincronizado(int id) async {
//     final base = await db;
//     await base.update(
//       'movimientos',
//       {'SINCRONIZADO': 'S'},
//       where: 'ID_MOVIMIENTO = ?',
//       whereArgs: [id],
//     );
//   }

//   static Future<void> actualizarMovimientoSalida(
//     Map<String, dynamic> datos,
//   ) async {
//     final base = await db;
//     final id = datos['ID_MOVIMIENTO'];
//     if (id == null) return;

//     await base.update(
//       'movimientos',
//       {
//         'FECHA_SALIDA': datos['FECHA_SALIDA'],
//         'HORA_SALIDA': datos['HORA_SALIDA'],
//         'UBICACION_SALIDA': datos['UBICACION_SALIDA'],
//         'SINCRONIZADO': 'N',
//       },
//       where: 'ID_MOVIMIENTO = ?',
//       whereArgs: [id],
//     );

//     print("💾 Salida actualizada localmente en SQLite para ID: $id");
//   }

//   static Future<void> actualizarEmpresaEnMovimientos(int nuevaEmpresaId) async {
//     final base = await db;
//     await base.update(
//       'movimientos',
//       {'ID_EMPRESA': nuevaEmpresaId, 'SINCRONIZADO': 'N'},
//     );
//     print("🏢 Empresa actualizada en movimientos locales a: $nuevaEmpresaId");
//   }

//   // --------------------------------------------------------------------
//   /// GUARDA ZONA — SOLO SI VIENE DEL SERVIDOR
//   static Future<void> guardarZonaTrabajo(
//     Map<String, dynamic> zona,
//     { bool desdeServidor = false }
//   ) async {

//     print("🔍 guardarZonaTrabajo() llamado con -> ${zona['ZONA']}  | desdeServidor=$desdeServidor");

//     if (!desdeServidor) {
//       print("⛔ Ignorado: intento de guardar zona NO-SERVER -> ${zona['ZONA']}");
//       return;
//     }

//     final base = await db;
//     await base.insert(
//       'zonas_trabajo',
//       {
//         'ID_ZONA': zona['ZONA'],
//         'LAT': zona['lat'],
//         'LNG': zona['lng'],
//         'RANGO': zona['rango'],
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     print("💾 Zona actualizada/reemplazada en SQLite -> ${zona['ZONA']}");
//   }

//   static Future<Map<String, dynamic>?> obtenerZonaTrabajo(String idZona) async {
//     final base = await db;
//     final res = await base.query(
//       'zonas_trabajo',
//       where: 'ID_ZONA = ?',
//       whereArgs: [idZona],
//       limit: 1,
//     );
//     return res.isNotEmpty ? res.first : null;
//   }
// }



// ignore_for_file: avoid_print

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  // ==============================
  // 🔹 Inicialización de la base
  // ==============================
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await iniciarDB();
    return _db!;
  }

  static Future<Database> iniciarDB() async {
    final path = join(await getDatabasesPath(), 'asistencia.db');
    return openDatabase(
      path,
      version: 2, // ⬆️ versión aumentada para crear nueva estructura
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movimientos (
            ID_MOVIMIENTO INTEGER PRIMARY KEY AUTOINCREMENT,
            NOMBRE_COMPL TEXT,
            TIPO TEXT,
            NOMINA TEXT,
            NUMERO_SERIE TEXT,
            AREA TEXT,
            ID_EMPRESA INTEGER,
            ID_AREA INTEGER,
            ID_TIPO INTEGER,
            ID_ZONA INTEGER,
            ID_EMPLEADO INTEGER,
            FECHA_ENTRADA TEXT,
            HORA_ENTRADA TEXT,
            FECHA_SALIDA TEXT,
            HORA_SALIDA TEXT,
            UBICACION_ENTRADA TEXT,
            UBICACION_SALIDA TEXT,
            RETRASO_MINUTOS INTEGER,
            FOTO_FRONTAL TEXT,
            FOTO_TRASERA TEXT,
            SINCRONIZADO TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE zonas_trabajo (
            ID_ZONA TEXT PRIMARY KEY,
            ZONA TEXT,
            LAT REAL,
            LNG REAL,
            RANGO REAL
          )
        ''');

        print('📦 DB creada con tablas movimientos & zonas_trabajo');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE zonas_trabajo ADD COLUMN ZONA TEXT;');
          print('🆙 Base de datos actualizada a versión 2 (ZONA agregada)');
        }
      },
    );
  }

  // ==============================
  // 🔹 Movimientos
  // ==============================
  static Future<int> guardarMovimiento(Map<String, dynamic> datos) async {
    final base = await db;
    final id = await base.insert('movimientos', datos);
    print('✅ Movimiento guardado con ID $id: $datos');
    return id;
  }

  static Future<List<Map<String, dynamic>>> movimientosPendientes() async {
    final base = await db;
    return await base.query(
      'movimientos',
      where: 'SINCRONIZADO = ?',
      whereArgs: ['N'],
    );
  }

  static Future<void> marcarSincronizado(int id) async {
    final base = await db;
    await base.update(
      'movimientos',
      {'SINCRONIZADO': 'S'},
      where: 'ID_MOVIMIENTO = ?',
      whereArgs: [id],
    );
  }

  static Future<void> actualizarMovimientoSalida(
    Map<String, dynamic> datos,
  ) async {
    final base = await db;
    final id = datos['ID_MOVIMIENTO'];
    if (id == null) return;

    await base.update(
      'movimientos',
      {
        'FECHA_SALIDA': datos['FECHA_SALIDA'],
        'HORA_SALIDA': datos['HORA_SALIDA'],
        'UBICACION_SALIDA': datos['UBICACION_SALIDA'],
        'SINCRONIZADO': 'N',
      },
      where: 'ID_MOVIMIENTO = ?',
      whereArgs: [id],
    );

    print("💾 Salida actualizada localmente en SQLite para ID: $id");
  }

  static Future<void> actualizarEmpresaEnMovimientos(int nuevaEmpresaId) async {
    final base = await db;
    await base.update(
      'movimientos',
      {'ID_EMPRESA': nuevaEmpresaId, 'SINCRONIZADO': 'N'},
    );
    // print("🏢 Empresa actualizada en movimientos locales a: $nuevaEmpresaId");
  }

  // ==============================
  // 🔹 Zonas de trabajo
  // ==============================

  /// Guarda una zona (solo si viene del servidor)
  // ==============================
// 🔹 Zonas de trabajo
// ==============================

/// Guarda una zona (solo si viene del servidor)
static Future<void> guardarZonaTrabajo(
  Map<String, dynamic> zona, {
  bool desdeServidor = false,
}) async {
  print("🔍 guardarZonaTrabajo() llamado con -> ${zona['ZONA']}  | desdeServidor=$desdeServidor");

  if (!desdeServidor) {
    print("⛔ Ignorado: intento de guardar zona NO-SERVER -> ${zona['ZONA']}");
    return;
  }

  final base = await db;
  await base.insert(
    'zonas_trabajo',
    {
      'ID_ZONA': zona['ID_ZONA'] ?? zona['ZONA'] ?? '',
      'ZONA': zona['ZONA'] ?? '',
      'LAT': zona['LAT'] ?? zona['lat'] ?? 0.0,
      'LNG': zona['LNG'] ?? zona['lng'] ?? 0.0,
      'RANGO': zona['RANGO'] ?? zona['rango'] ?? 0.0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  // print("💾 Zona actualizada/reemplazada en SQLite -> ${zona['ZONA']}");
}

/// Obtiene los datos completos de la zona desde SQLite
static Future<Map<String, dynamic>?> obtenerZonaTrabajo(String idZona) async {
  if (idZona.isEmpty) return null;

  final base = await db;
  final res = await base.query(
    'zonas_trabajo',
    where: 'ID_ZONA = ?',
    whereArgs: [idZona],
    limit: 1,
  );

  if (res.isNotEmpty) {
    final zona = Map<String, dynamic>.from(res.first);
    print("🌍 Zona obtenida desde SQLite: ${zona['ZONA']}");
    return zona;
  }

  print("⚠️ Zona no encontrada (id_zona=$idZona)");
  return null;
}

}

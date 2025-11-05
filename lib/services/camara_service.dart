// // ignore_for_file: avoid_print

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// class CamaraService {
//   static CameraController? _controller;
//   static List<CameraDescription>? _cameras;
//   static bool _tomandoFoto = false;

//   static Future<void> _inicializarCamaras() async {
//     try {
//       _cameras ??= await availableCameras();
//     } catch (e) {
//       print('❌ Error al obtener cámaras: $e');
//       _cameras = [];
//     }
//   }

//   static Future<String?> tomarFoto({bool trasera = false}) async {
//     if (_tomandoFoto) {
//       print("⚠️ Ya se está tomando una foto");
//       return null;
//     }

//     _tomandoFoto = true;
//     await _inicializarCamaras();

//     if (_cameras == null || _cameras!.isEmpty) {
//       print('❌ No se encontraron cámaras disponibles');
//       _tomandoFoto = false;
//       return null;
//     }

//     String? resultado;

//     try {
//       final cam = trasera
//           ? _cameras!.firstWhere(
//               (c) => c.lensDirection == CameraLensDirection.back,
//               orElse: () => _cameras!.first,
//             )
//           : _cameras!.firstWhere(
//               (c) => c.lensDirection == CameraLensDirection.front,
//               orElse: () => _cameras!.first,
//             );

//       _controller = CameraController(
//         cam,
//         ResolutionPreset.low,
//         enableAudio: false,
//       );

//       await _controller!.initialize();
//       await _controller!.setFlashMode(FlashMode.off);

//       final image = await _controller!.takePicture();

//       if (!await File(image.path).exists()) {
//         print('❌ El archivo no existe: ${image.path}');
//         return null;
//       }

//       final dir = await getTemporaryDirectory();
//       final filePath = join(dir.path, 'CAP${DateTime.now().millisecondsSinceEpoch}.jpg');
//       final copiedFile = await File(image.path).copy(filePath);
//       resultado = copiedFile.path;
//       print('📸 Foto guardada en: $resultado');
//     } catch (e) {
//       print('❌ Error al tomar foto: $e');
//       resultado = null;
//     }
//    await Future.delayed(const Duration(milliseconds: 400)); // entre captura y dispose

//     // ✅ Cierra la cámara solo después de que el flujo termine
//     await cerrarCamara();
//     _tomandoFoto = false;
//     return resultado;
//   }

//   static Future<String?> tomarFotoFrontal() => tomarFoto(trasera: false);

//   static Future<String?> tomarFotoTrasera() => tomarFoto(trasera: true);

//   static Future<void> cerrarCamara() async {
//     if (_controller != null) {
//       try {
//         await _controller!.dispose();
//         print('📸 Cámara cerrada correctamente');
//       } catch (e) {
//         print('❌ Error al cerrar la cámara: $e');
//       } finally {
//         _controller = null;
//       }
//     }
//   }
// }
// -------------------------------------------------------------------------------
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CamaraService {
  static CameraController? _controller;
  static List<CameraDescription>? _camaras;
  static bool _tomandoFoto = false;

  static Future<void> _inicializarCamaras() async {
    try {
      _camaras ??= await availableCameras();
    } catch (_) {
      _camaras = [];
    }
  }

  static Future<String?> tomarFoto({bool trasera = false}) async {
    if (_tomandoFoto) return null;
    _tomandoFoto = true;

    await _inicializarCamaras();
    if (_camaras == null || _camaras!.isEmpty) {
      _tomandoFoto = false;
      return null;
    }

    String? resultado;

    try {
      final cam = (trasera
          ? _camaras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _camaras!.first,
            )
          : _camaras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _camaras!.first,
            ));

      _controller = CameraController(
        cam,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      // Bloquear enfoque para evitar espera prolongada
      await _controller!.setFocusMode(FocusMode.locked);

      final image = await _controller!.takePicture();

      final dir = await getTemporaryDirectory();
      final filePath = join(dir.path, 'CAP${DateTime.now().millisecondsSinceEpoch}.jpg');
      resultado = (await File(image.path).copy(filePath)).path;
    } catch (_) {
      resultado = null;
    }

    await cerrarCamara();
    _tomandoFoto = false;
    return resultado;
  }

  static Future<String?> tomarFotoFrontal() => tomarFoto(trasera: false);
  static Future<String?> tomarFotoTrasera() => tomarFoto(trasera: true);

  static Future<void> cerrarCamara() async {
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
  }
}

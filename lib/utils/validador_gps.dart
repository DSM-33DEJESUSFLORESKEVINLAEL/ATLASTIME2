import 'package:geolocator/geolocator.dart';
import 'constantes.dart';

class ValidadorGPS {
  static bool estaDentroDelRango(Position posicion) {
    final distancia = Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      Constantes.empresaLatitud,
      Constantes.empresaLongitud,
    );
    return distancia <= Constantes.radioPermitidoMetros;
  }
}

import 'package:flutter/material.dart';

class TarjetaMovimiento extends StatelessWidget {
  final String fecha;
  final String hora;
  final bool completado;

  const TarjetaMovimiento({
    super.key,
    required this.fecha,
    required this.hora,
    this.completado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Icon(
          completado ? Icons.check_circle : Icons.access_time,
          color: completado ? Colors.green : Colors.orange,
        ),
        title: Text("Fecha: $fecha"),
        subtitle: Text("Hora: $hora"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

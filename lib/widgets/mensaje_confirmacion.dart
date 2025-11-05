import 'package:flutter/material.dart';

class MensajeConfirmacion extends StatelessWidget {
  final String mensaje;
  final bool esError;

  const MensajeConfirmacion({
    super.key,
    required this.mensaje,
    this.esError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: esError ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            esError ? Icons.error_outline : Icons.check_circle_outline,
            color: esError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: esError ? Colors.red : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

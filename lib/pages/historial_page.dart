// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:atlastime/services/apiService.dart';
import 'package:atlastime/services/auth_service.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<Map<String, dynamic>> asistencias = [];
  bool cargando = true;
  int sumaRetrasos = 0;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  List<Map<String, dynamic>> asistenciasOriginales = [];
  List<Map<String, dynamic>> periodos = [];
  Map<String, dynamic>? periodoSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final usuario = AuthService.usuarioActivo;
    if (usuario == null) {
      print("⚠️ No hay usuario autenticado.");
      setState(() => cargando = false);
      return;
    }

    final historial = await ApiService.getHistorial(usuario.nombre);
    final listaPeriodos = await ApiService.getFechas();

    final periodosFiltrados =
        listaPeriodos
            .where((p) => p['ID_TIPO'].toString() == usuario.idTipo.toString())
            .toList();

    print("📥 Historial recibido: $historial");

    final nombreCompleto = usuario.nombre;
    final historialConNombre =
        historial
            .map<Map<String, dynamic>>(
              (a) => {...a, 'NOMBRE_COMPL': nombreCompleto},
            )
            .toList();

    final periodoActual = obtenerPeriodoActual(periodosFiltrados);

    setState(() {
      periodos = periodosFiltrados;
      periodoSeleccionado = periodoActual;

      if (periodoSeleccionado != null) {
        fechaInicio = DateTime.tryParse(periodoSeleccionado!['FINICIAL']);
        fechaFin = DateTime.tryParse(periodoSeleccionado!['FINAL']);
      }

      asistenciasOriginales =
          historialConNombre.where((a) {
              final fEntradaStr = a['FECHA_ENTRADA']?.toString() ?? '';
              final fSalidaStr = a['FECHA_SALIDA']?.toString() ?? '';

              final fEntrada = DateTime.tryParse(fEntradaStr);
              final fSalida = DateTime.tryParse(fSalidaStr);

              final entradaValida =
                  fEntrada != null &&
                  fEntrada.year > 1900 &&
                  !fEntradaStr.contains('1899-12-30');
              final salidaValida =
                  fSalida != null &&
                  fSalida.year > 1900 &&
                  !fSalidaStr.contains('1899-12-30');

              return entradaValida || (!entradaValida && salidaValida);
            }).toList()
            ..sort((a, b) {
              final aFechaStr = a['FECHA_ENTRADA']?.toString() ?? '';
              final bFechaStr = b['FECHA_ENTRADA']?.toString() ?? '';
              final aFecha =
                  DateTime.tryParse(
                    aFechaStr.contains('1899-12-30')
                        ? a['FECHA_SALIDA']
                        : a['FECHA_ENTRADA'],
                  ) ??
                  DateTime(2000);
              final bFecha =
                  DateTime.tryParse(
                    bFechaStr.contains('1899-12-30')
                        ? b['FECHA_SALIDA']
                        : b['FECHA_ENTRADA'],
                  ) ??
                  DateTime(2000);
              return bFecha.compareTo(aFecha);
            });

      filtrarPorRango();
      cargando = false;
    });
  }

  void filtrarPorRango() {
    if (fechaInicio == null || fechaFin == null) return;

    final inicio = soloFecha(fechaInicio!);
    final fin = soloFecha(fechaFin!);

    setState(() {
      asistencias =
          asistenciasOriginales.where((a) {
            final fEntradaStr = a['FECHA_ENTRADA']?.toString() ?? '';
            final fSalidaStr = a['FECHA_SALIDA']?.toString() ?? '';

            final fEntrada = DateTime.tryParse(fEntradaStr);
            final fSalida = DateTime.tryParse(fSalidaStr);

            DateTime? fechaValida;

            if (fEntrada != null &&
                !fEntradaStr.contains('1899-12-30') &&
                fEntrada.year > 1900) {
              fechaValida = soloFecha(fEntrada);
            } else if (fSalida != null &&
                !fSalidaStr.contains('1899-12-30') &&
                fSalida.year > 1900) {
              fechaValida = soloFecha(fSalida);
            }

            return fechaValida != null &&
                !fechaValida.isBefore(inicio) &&
                !fechaValida.isAfter(fin);
          }).toList();

      _calcularRetrasos();
    });
  }

  DateTime soloFecha(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void _calcularRetrasos() {
    sumaRetrasos = asistencias.fold<int>(0, (acum, a) {
      final minutos = int.tryParse('${a['RETRASO'] ?? 0}') ?? 0;
      return minutos > 0 ? acum + minutos : acum;
    });
  }

  Map<String, dynamic>? obtenerPeriodoActual(
    List<Map<String, dynamic>> periodos,
  ) {
    final hoy = DateTime.now();
    for (var p in periodos) {
      final inicio = DateTime.tryParse(p['FINICIAL'].toString());
      final fin = DateTime.tryParse(p['FINAL'].toString());
      if (inicio != null && fin != null) {
        if (!hoy.isBefore(inicio) && !hoy.isAfter(fin)) {
          return p;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Historial de Asistencia"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDD835), Color(0xFFFDD835)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            cargando
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : Column(
                  children: [
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: periodoSeleccionado,
                        items:
                            periodos.map((p) {
                              final inicio = _formatearFecha2(p['FINICIAL']);
                              final fin = _formatearFecha2(p['FINAL']);
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: p,
                                child: Text(
                                  'Periodo ${p['NUMEROPERIODO']}: $inicio - $fin',
                                ),
                              );
                            }).toList(),
                        onChanged: (nuevoPeriodo) {
                          if (nuevoPeriodo != null) {
                            setState(() {
                              periodoSeleccionado = nuevoPeriodo;
                              fechaInicio = DateTime.tryParse(
                                nuevoPeriodo['FINICIAL'],
                              );
                              fechaFin = DateTime.tryParse(
                                nuevoPeriodo['FINAL'],
                              );
                            });
                            filtrarPorRango();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: '📅 Seleccione un periodo',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (fechaInicio != null && fechaFin != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(blurRadius: 4, color: Colors.black12),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total de retrasos:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "$sumaRetrasos min",
                              style: TextStyle(
                                color:
                                    sumaRetrasos > 0
                                        ? Colors.red
                                        : Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            asistencias.isEmpty
                                ? const Center(
                                  child: Text(
                                    "🗓️ No hay registros en ese rango",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: asistencias.length,
                                  itemBuilder:
                                      (_, i) =>
                                          _buildCardAsistencia(asistencias[i]),
                                ),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }

  Widget _buildCardAsistencia(Map<String, dynamic> a) {
    final int minutos = int.tryParse('${a['RETRASO'] ?? 0}') ?? 0;
    final Color retardoColor = minutos > 0 ? Colors.red : Colors.green;
    final String tipo = (a['TIPO'] ?? '').toString().toUpperCase();

    final bool esVacacion = tipo == 'VACACION';
    final bool esIncapacidad = tipo == 'INCAPACIDAD';

    final String fechaEntradaStr = a['FECHA_ENTRADA']?.toString() ?? '';
    final String fechaSalidaStr = a['FECHA_SALIDA']?.toString() ?? '';

    final fechaMostrar =
        (fechaEntradaStr.contains('1899-12-30') || fechaEntradaStr.isEmpty)
            ? fechaSalidaStr
            : fechaEntradaStr;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(fechaMostrar),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (esVacacion || esIncapacidad)
              Text(
                esVacacion ? '🌴 Vacación' : '🤒 Incapacidad',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              )
            else ...[
              Row(
                children: [
                  const Icon(Icons.login, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "Entrada: ${a['HORA_ENTRADA'] ?? '-'}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.logout, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "Salida: ${a['HORA_SALIDA'] ?? '-'}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if ((a['HORA_ENTRADA'] == null ||
                  a['HORA_ENTRADA'].toString().trim().isEmpty)) ...[
                
              ],
             
              if ((a['RETRASO']?.toString() ?? '').toUpperCase() == 'SS') ...[
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "🕒 Registro de salida únicamente",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      minutos > 0 ? Icons.warning : Icons.check_circle,
                      color: retardoColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${minutos < 0 ? 'Adelanto' : 'Retraso'}: ",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${minutos.abs()} min",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: retardoColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  "Registrado",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(dynamic fechaEntrada) {
    if (fechaEntrada == null) return '-';
    final fecha = DateTime.tryParse(fechaEntrada.toString());
    if (fecha == null) return '-';

    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final nombreDia = dias[fecha.weekday - 1];
    final nombreMes = meses[fecha.month - 1];

    return "$nombreDia ${fecha.day} de $nombreMes del ${fecha.year}";
  }

  String _formatearFecha2(dynamic fechaEntrada) {
    if (fechaEntrada == null) return '-';
    final fecha = DateTime.tryParse(fechaEntrada.toString());
    if (fecha == null) return '-';
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }
}

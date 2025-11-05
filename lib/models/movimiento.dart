class Movimiento {
  final int idMovimiento;
  final int idEmpleado;
  final String nombre;
  final String nomina;
  final String numeroSerie;
  final int? idArea;
  final int? idTipo;
  final int? idZona; // ✅ NUEVO
  final DateTime? fechaEntrada;
  final String? horaEntrada;
  final DateTime? fechaSalida;
  final String? horaSalida;
  final String? ubicacionEntrada;
  final String? ubicacionSalida;
  final String? fotoFrontal;
  final String? fotoTrasera;
  final int? retrasoMinutos;
  final String? sincronizado;

  Movimiento({
    required this.idMovimiento,
    required this.idEmpleado,
    required this.nombre,
    required this.nomina,
    required this.numeroSerie,
    this.idArea,
    this.idTipo,
    this.idZona, // ✅
    this.fechaEntrada,
    this.horaEntrada,
    this.fechaSalida,
    this.horaSalida,
    this.ubicacionEntrada,
    this.ubicacionSalida,
    this.fotoFrontal,
    this.fotoTrasera,
    this.retrasoMinutos,
    this.sincronizado,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) => Movimiento(
        idMovimiento: json['ID_MOVIMIENTO'],
        idEmpleado: json['ID_EMPLEADO'],
        nombre: json['NOMBRE'],
        nomina: json['NOMINA'],
        numeroSerie: json['NUMERO_SERIE'],
        idArea: json['ID_AREA'],
        idTipo: json['ID_TIPO'],
        idZona: json['ID_ZONA'], // ✅
        fechaEntrada: json['FECHA_ENTRADA'] != null ? DateTime.parse(json['FECHA_ENTRADA']) : null,
        horaEntrada: json['HORA_ENTRADA'],
        fechaSalida: json['FECHA_SALIDA'] != null ? DateTime.parse(json['FECHA_SALIDA']) : null,
        horaSalida: json['HORA_SALIDA'],
        ubicacionEntrada: json['UBICACION_ENTRADA'],
        ubicacionSalida: json['UBICACION_SALIDA'],
        fotoFrontal: json['FOTO_FRONTAL'],
        fotoTrasera: json['FOTO_TRASERA'],
        retrasoMinutos: json['RETRASO_MINUTOS'],
        sincronizado: json['SINCRONIZADO'],
      );

  Map<String, dynamic> toJson() => {
        'ID_MOVIMIENTO': idMovimiento,
        'ID_EMPLEADO': idEmpleado,
        'NOMBRE': nombre,
        'NOMINA': nomina,
        'NUMERO_SERIE': numeroSerie,
        'ID_AREA': idArea,
        'ID_TIPO': idTipo,
        'ID_ZONA': idZona, // ✅
        'FECHA_ENTRADA': fechaEntrada?.toIso8601String(),
        'HORA_ENTRADA': horaEntrada,
        'FECHA_SALIDA': fechaSalida?.toIso8601String(),
        'HORA_SALIDA': horaSalida,
        'UBICACION_ENTRADA': ubicacionEntrada,
        'UBICACION_SALIDA': ubicacionSalida,
        'FOTO_FRONTAL': fotoFrontal,
        'FOTO_TRASERA': fotoTrasera,
        'RETRASO_MINUTOS': retrasoMinutos,
        'SINCRONIZADO': sincronizado,
      };

  factory Movimiento.fromMap(Map<String, dynamic> map) => Movimiento(
        idMovimiento: int.tryParse(map['ID_MOVIMIENTO'].toString()) ?? 0,
        idEmpleado: int.tryParse(map['ID_EMPLEADO'].toString()) ?? 0,
        nombre: map['NOMBRE_COMPL'] ?? '',
        nomina: map['NOMINA'] ?? '',
        numeroSerie: map['NUMERO_SERIE'] ?? '',
        idArea: map['ID_AREA'] != null ? int.tryParse(map['ID_AREA'].toString()) : null,
        idTipo: map['ID_TIPO'] != null ? int.tryParse(map['ID_TIPO'].toString()) : null,
        idZona: map['ID_ZONA'] != null ? int.tryParse(map['ID_ZONA'].toString()) : null, // ✅
        fechaEntrada: map['FECHA_ENTRADA'] != null ? DateTime.tryParse(map['FECHA_ENTRADA']) : null,
        horaEntrada: map['HORA_ENTRADA'],
        fechaSalida: map['FECHA_SALIDA'] != null ? DateTime.tryParse(map['FECHA_SALIDA']) : null,
        horaSalida: map['HORA_SALIDA'],
        ubicacionEntrada: map['UBICACION_ENTRADA'],
        ubicacionSalida: map['UBICACION_SALIDA'],
        fotoFrontal: map['FOTO_FRONTAL'],
        fotoTrasera: map['FOTO_TRASERA'],
        retrasoMinutos: map['RETRASO_MINUTOS'] != null ? int.tryParse(map['RETRASO_MINUTOS'].toString()) : null,
        sincronizado: map['SINCRONIZADO'],
      );

  Map<String, dynamic> toMap() => {
        'ID_MOVIMIENTO': idMovimiento,
        'ID_EMPLEADO': idEmpleado,
        'NOMBRE_COMPL': nombre,
        'NOMINA': nomina,
        'NUMERO_SERIE': numeroSerie,
        'ID_AREA': idArea,
        'ID_TIPO': idTipo,
        'ID_ZONA': idZona, // ✅
        'FECHA_ENTRADA': fechaEntrada?.toIso8601String(),
        'HORA_ENTRADA': horaEntrada,
        'FECHA_SALIDA': fechaSalida?.toIso8601String(),
        'HORA_SALIDA': horaSalida,
        'UBICACION_ENTRADA': ubicacionEntrada,
        'UBICACION_SALIDA': ubicacionSalida,
        'FOTO_FRONTAL': fotoFrontal,
        'FOTO_TRASERA': fotoTrasera,
        'RETRASO_MINUTOS': retrasoMinutos,
        'SINCRONIZADO': sincronizado,
      };
}

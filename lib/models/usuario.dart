class Usuario {
  final String id;
  final String nombre;
  final String nomina;
  final String usuario;
  final String areaNombre;
  final int idArea;
  final int idTipo;
  final String? idZona;
  final String? idEmpresa;
  final String? tipoNombre;
  final String? horaEntrada;
  final String? horaSalida;

  Usuario({
    required this.id,
    required this.nombre,
    required this.nomina,
    required this.usuario,
    required this.areaNombre,
    required this.idArea,
    required this.idTipo,
    this.idZona,
    this.idEmpresa,
    this.tipoNombre,
    this.horaEntrada,
    this.horaSalida,
  });

  // Getter opcional por claridad
  String? get zona => idZona;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['ID_EMPLEADO']?.toString() ?? '',
      nombre: json['NOMBRE_COMPLETO'] ?? '',
      nomina: json['NOMINA'] ?? '',
      usuario: json['NOMINA'] ?? '', // NOMINA se usa como login
      areaNombre: json['AREA'] ?? '',
      idArea: int.tryParse(json['ID_AREA']?.toString() ?? '') ?? 0,
      idTipo: int.tryParse(json['ID_TIPO']?.toString() ?? '') ?? 0,
      idZona: json['ID_ZONA']?.toString(),
      idEmpresa: json['ID_EMPRESA']?.toString(),
      tipoNombre: json['TIPO']?.toString(),
      horaEntrada: json['HORA_ENTRADA'],
      horaSalida: json['HORA_SALIDA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_EMPLEADO': id,
      'NOMBRE_COMPLETO': nombre,
      'NOMINA': nomina,
      'USUARIO': usuario,
      'AREA': areaNombre,
      'ID_AREA': idArea,
      'ID_TIPO': idTipo,
      'ID_ZONA': idZona,
      'ID_EMPRESA': idEmpresa,
      'TIPO': tipoNombre,
      'HORA_ENTRADA': horaEntrada,
      'HORA_SALIDA': horaSalida,
    };
  }


    Usuario copyWith({
    String? id,
    String? nombre,
    String? nomina,
    String? usuario,
    String? areaNombre,
    int? idArea,
    int? idTipo,
    String? idZona,
    String? idEmpresa,
    String? tipoNombre,
    String? horaEntrada,
    String? horaSalida,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nomina: nomina ?? this.nomina,
      usuario: usuario ?? this.usuario,
      areaNombre: areaNombre ?? this.areaNombre,
      idArea: idArea ?? this.idArea,
      idTipo: idTipo ?? this.idTipo,
      idZona: idZona ?? this.idZona,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      tipoNombre: tipoNombre ?? this.tipoNombre,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
    );
  }

}

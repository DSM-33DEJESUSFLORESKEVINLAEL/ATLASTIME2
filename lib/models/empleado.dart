class Empleado {
  final String idEmpleado;
  final String nombre;
  final String empresa;
  final String area;

  Empleado({
    required this.idEmpleado,
    required this.nombre,
    required this.empresa,
    required this.area,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) => Empleado(
        idEmpleado: json['ID_EMPLEADO'].toString(), // 🔄 convertimos a String
        nombre: json['NOMBRE'],
        empresa: json['EMPRESA'],
        area: json['AREA'],
      );

  Map<String, dynamic> toJson() => {
        'ID_EMPLEADO': idEmpleado,
        'NOMBRE': nombre,
        'EMPRESA': empresa,
        'AREA': area,
      };
}

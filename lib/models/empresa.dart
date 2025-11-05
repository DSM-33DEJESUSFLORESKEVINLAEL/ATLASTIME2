class Empresa {
  final String empresa;
  final String nombre;

  Empresa({
    required this.empresa,
    required this.nombre,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
        empresa: json['EMPRESA'],
        nombre: json['NOMBRE'],
      );

  Map<String, dynamic> toJson() => {
        'EMPRESA': empresa,
        'NOMBRE': nombre,
      };
}

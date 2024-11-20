class AmigoVirtual {
  final int idAmigo;
  final String nombre;
  final int? idApariencia;
  final int? idVoz;

  AmigoVirtual({
    required this.idAmigo,
    required this.nombre,
    this.idApariencia,
    this.idVoz,
  });

  factory AmigoVirtual.fromJson(Map<String, dynamic> json) {
    return AmigoVirtual(
      idAmigo: json['idAmigo'],
      nombre: json['nombre'],
      idApariencia: json['idApariencia'],
      idVoz: json['idVoz'],
    );
  }
}

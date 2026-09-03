class AccessRecord {
  final String usuario;
  final DateTime fechaHora;
  final bool exitoso;

  AccessRecord({
    required this.usuario,
    required this.fechaHora,
    required this.exitoso,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'fechaHora': fechaHora.toIso8601String(),
      'exitoso': exitoso,
    };
  }

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
    return AccessRecord(
      usuario: json['usuario'] as String,
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      exitoso: json['exitoso'] as bool,
    );
  }
}
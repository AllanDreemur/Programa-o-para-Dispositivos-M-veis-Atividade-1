class Localizacao {
  const Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  final int? id;
  final double latitude;
  final double longitude;
  final double precisao; // metros
  final DateTime instante; // sempre em UTC

  Map<String, Object?> toMap() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'precisao': precisao,
        'instante': instante.toUtc().toIso8601String(),
      };

  factory Localizacao.fromMap(Map<String, Object?> mapa) => Localizacao(
        id: mapa['id'] as int?,
        latitude: (mapa['latitude'] as num).toDouble(),
        longitude: (mapa['longitude'] as num).toDouble(),
        precisao: (mapa['precisao'] as num).toDouble(),
        instante: DateTime.parse(mapa['instante'] as String).toUtc(),
      );
}
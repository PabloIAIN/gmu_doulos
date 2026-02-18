class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final String ubicacion;
  final String tipo;
  final double? latitud;
  final double? longitud;

  Evento({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    required this.tipo,
    this.latitud,
    this.longitud,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'ubicacion': ubicacion,
      'tipo': tipo,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // Crear desde Map de SQLite
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      hora: map['hora'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      tipo: map['tipo'],
      latitud: map['latitud'],
      longitud: map['longitud'],
    );
  }

  // Copiar con modificaciones
  Evento copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    String? hora,
    String? ubicacion,
    String? tipo,
    double? latitud,
    double? longitud,
  }) {
    return Evento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      ubicacion: ubicacion ?? this.ubicacion,
      tipo: tipo ?? this.tipo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }

  // Días restantes hasta el evento
  int get diasRestantes {
    return fecha.difference(DateTime.now()).inDays;
  }

  // Si el evento ya pasó
  bool get yaPaso {
    return fecha.isBefore(DateTime.now());
  }
}

// Tipos de eventos
class TiposEvento {
  static const List<String> tipos = [
    'reunion',
    'campamento',
    'clase',
    'ceremonia',
    'actividad',
    'servicio',
  ];

  static String getNombre(String tipo) {
    switch (tipo) {
      case 'reunion':
        return 'Reunión';
      case 'campamento':
        return 'Campamento';
      case 'clase':
        return 'Clase';
      case 'ceremonia':
        return 'Ceremonia';
      case 'actividad':
        return 'Actividad';
      case 'servicio':
        return 'Servicio';
      default:
        return 'Evento';
    }
  }
}
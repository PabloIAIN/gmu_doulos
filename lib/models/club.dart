class Club {
  final String id;
  final String nombre;
  final String iglesia;
  final String ciudad;
  final String pais;
  final String? asociacion;
  final String? unionCampo;
  final String codigoAcceso;
  final List<String> ministerios;
  final String plan;
  final int maxMiembros;
  final DateTime? planExpira;
  final bool activo;

  Club({
    required this.id,
    required this.nombre,
    required this.iglesia,
    required this.ciudad,
    this.pais = 'México',
    this.asociacion,
    this.unionCampo,
    required this.codigoAcceso,
    this.ministerios = const ['gm'],
    this.plan = 'gratis',
    this.maxMiembros = 20,
    this.planExpira,
    this.activo = true,
  });

  bool get tieneGM => ministerios.contains('gm');
  bool get tieneConq => ministerios.contains('conq');
  bool get tieneAv => ministerios.contains('av');
  bool get tieneAmbosJuv => tieneGM && tieneConq;
  bool get esPro => plan == 'pro';

  factory Club.fromMap(Map<String, dynamic> map) {
    final ministeriosRaw = map['ministerios'] as String? ?? 'gm';
    return Club(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      iglesia: map['iglesia'] as String,
      ciudad: map['ciudad'] as String,
      pais: map['pais'] as String? ?? 'México',
      asociacion: map['asociacion'] as String?,
      unionCampo: map['union_campo'] as String?,
      codigoAcceso: map['codigo_acceso'] as String? ?? '',
      ministerios: ministeriosRaw.split(',').map((e) => e.trim()).toList(),
      plan: map['plan'] as String? ?? 'gratis',
      maxMiembros: map['max_miembros'] is int ? map['max_miembros'] as int : int.tryParse(map['max_miembros']?.toString() ?? '20') ?? 20,
      planExpira: map['plan_expira'] != null ? DateTime.tryParse(map['plan_expira'].toString()) : null,
      activo: map['activo'] == 1 || map['activo'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'iglesia': iglesia,
    'ciudad': ciudad,
    'pais': pais,
    'asociacion': asociacion,
    'union_campo': unionCampo,
    'codigo_acceso': codigoAcceso,
    'ministerios': ministerios.join(','),
    'plan': plan,
    'max_miembros': maxMiembros,
    'plan_expira': planExpira?.toIso8601String(),
    'activo': activo ? 1 : 0,
  };

  Club copyWith({
    String? nombre,
    String? iglesia,
    String? ciudad,
    List<String>? ministerios,
    String? plan,
    int? maxMiembros,
  }) => Club(
    id: id,
    nombre: nombre ?? this.nombre,
    iglesia: iglesia ?? this.iglesia,
    ciudad: ciudad ?? this.ciudad,
    pais: pais,
    asociacion: asociacion,
    unionCampo: unionCampo,
    codigoAcceso: codigoAcceso,
    ministerios: ministerios ?? this.ministerios,
    plan: plan ?? this.plan,
    maxMiembros: maxMiembros ?? this.maxMiembros,
    planExpira: planExpira,
    activo: activo,
  );
}

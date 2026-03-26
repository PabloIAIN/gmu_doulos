/// Centralized configuration constants for the GMU Doulos app.
abstract class AppConfig {
  static const String appName = 'GMU Doulos';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '2';
  static const String division = 'División Interamericana';
  static const String tagline = '"Siervos de Cristo"';

  // Defaults for backwards compatibility
  static const String clubName = 'Club de Guías Mayores';
  static const String location = 'Montemorelos, Nuevo León';
  static const String church = 'Iglesia Adventista Central';
  static const String appNameWithVersion = '$appName v$appVersion';

  // Technical identifiers
  static const String databaseName = 'gmu_doulos.db';
  static const int dbVersion = 10;
  static const String notificationChannelId = 'gmu_doulos_channel';
  static const String notificationChannelDescription = 'Notificaciones de GMU Doulos';

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gmu-doulos.vercel.app/api',
  );

  // Ministerios de la DIA
  static const Map<String, String> ministeriosNombres = {
    'gm': 'Guías Mayores',
    'conq': 'Conquistadores',
    'av': 'Aventureros',
  };

  // Clases por ministerio
  static const List<String> clasesGM = [
    'Guía Mayor Aspirante',
    'Guía Mayor',
    'Guía Mayor Avanzado',
    'Guía Mayor Instructor',
  ];

  static const Map<String, List<String>> clasesConquistadores = {
    'regulares': ['Amigo', 'Compañero', 'Explorador', 'Orientador', 'Viajero', 'Guía'],
    'avanzadas': [
      'Amigo de la Naturaleza', 'Compañero de Excursionismo',
      'Explorador de Campo y Bosque', 'Orientador de Nuevas Fronteras',
      'Viajero en el Bosque', 'Guía de Exploración',
    ],
  };

  static const List<String> clasesAventureros = [
    'Corderitos', 'Aves Madrugadoras', 'Abejas Industriosas',
    'Rayos de Sol', 'Constructor', 'Manos Ayudadoras',
  ];

  // Roles por ministerio
  static const List<String> rolesGM = [
    'Director GM', 'Director Asociado GM', 'Secretario GM',
    'Tesorero GM', 'Consejero GM', 'Aspirante GM',
  ];

  static const List<String> rolesConq = [
    'Director Conq', 'Director Asociado Conq', 'Secretario Conq',
    'Consejero Conq', 'Conquistador',
  ];

  static const List<String> rolesAv = [
    'Director Aventureros', 'Director Asociado Aventureros',
    'Consejero Aventureros', 'Aventurero',
  ];

  static const List<String> rolesGenerales = ['Coordinador General'];
}

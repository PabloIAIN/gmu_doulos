/// Centralized configuration constants for the GMU Doulos app.
///
/// Use these instead of hardcoding strings throughout the codebase.
abstract class AppConfig {
  static const String appName = 'GMU Doulos';
  static const String clubName = 'Club de Guías Mayores';
  static const String location = 'Montemorelos, Nuevo León';
  static const String church = 'Iglesia Adventista Central';
  static const String tagline = '"Siervos de Cristo"';
  static const String version = 'v1.1.0';
  static const String appNameWithVersion = '$appName $version';

  // Technical identifiers
  static const String databaseName = 'gmu_doulos.db';
  static const String notificationChannelId = 'gmu_doulos_channel';
  static const String notificationChannelDescription =
      'Notificaciones del $clubName';
}

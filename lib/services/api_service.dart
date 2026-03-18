import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para comunicación con el backend REST API.
/// Maneja todas las operaciones CRUD contra el servidor Vercel + PostgreSQL.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Configuración ──
  // TODO: Cambiar a tu URL real de Vercel
  static const String _baseUrl = 'https://gmu-doulos.vercel.app/api';
  static const String _apiKey = 'gmu-doulos-2025-secret';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-API-Key': _apiKey,
      };

  // ══════════════════════════════════════════
  //  MIEMBROS
  // ══════════════════════════════════════════

  /// Obtener todos los miembros
  Future<List<Map<String, dynamic>>> getMiembros({String? rol, int? activo}) async {
    final params = <String, String>{};
    if (rol != null) params['rol'] = rol;
    if (activo != null) params['activo'] = activo.toString();

    final uri = Uri.parse('$_baseUrl/miembros').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  /// Obtener un miembro por ID
  Future<Map<String, dynamic>> getMiembro(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/miembros?id=$id'),
      headers: _headers,
    );
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return Map<String, dynamic>.from(body['data']);
  }

  /// Crear o actualizar miembro
  Future<void> saveMiembro(Map<String, dynamic> miembro) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/miembros'),
      headers: _headers,
      body: jsonEncode(miembro),
    );
    _checkResponse(response);
  }

  /// Actualizar miembro
  Future<void> updateMiembro(String id, Map<String, dynamic> campos) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/miembros?id=$id'),
      headers: _headers,
      body: jsonEncode(campos),
    );
    _checkResponse(response);
  }

  /// Eliminar miembro
  Future<void> deleteMiembro(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/miembros?id=$id'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  // ══════════════════════════════════════════
  //  EVENTOS
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getEventos({String? tipo}) async {
    final params = <String, String>{};
    if (tipo != null) params['tipo'] = tipo;

    final uri = Uri.parse('$_baseUrl/eventos').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  Future<void> saveEvento(Map<String, dynamic> evento) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/eventos'),
      headers: _headers,
      body: jsonEncode(evento),
    );
    _checkResponse(response);
  }

  Future<void> updateEvento(String id, Map<String, dynamic> campos) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/eventos?id=$id'),
      headers: _headers,
      body: jsonEncode(campos),
    );
    _checkResponse(response);
  }

  Future<void> deleteEvento(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/eventos?id=$id'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  // ══════════════════════════════════════════
  //  ASISTENCIA
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getAsistencia({
    String? unidadId,
    String? miembroId,
    String? fecha,
  }) async {
    final params = <String, String>{};
    if (unidadId != null) params['unidad_id'] = unidadId;
    if (miembroId != null) params['miembro_id'] = miembroId;
    if (fecha != null) params['fecha'] = fecha;

    final uri = Uri.parse('$_baseUrl/asistencia').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  Future<void> saveAsistencia(Map<String, dynamic> registro) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/asistencia'),
      headers: _headers,
      body: jsonEncode(registro),
    );
    _checkResponse(response);
  }

  Future<void> saveAsistenciaMasiva(List<Map<String, dynamic>> registros) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/asistencia'),
      headers: _headers,
      body: jsonEncode({'registros': registros}),
    );
    _checkResponse(response);
  }

  // ══════════════════════════════════════════
  //  UNIDADES
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getUnidades() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/unidades'),
      headers: _headers,
    );
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(body['data']);
  }

  Future<Map<String, dynamic>> getUnidad(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/unidades?id=$id'),
      headers: _headers,
    );
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return Map<String, dynamic>.from(body['data']);
  }

  Future<void> saveUnidad(Map<String, dynamic> unidad) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/unidades'),
      headers: _headers,
      body: jsonEncode(unidad),
    );
    _checkResponse(response);
  }

  Future<void> deleteUnidad(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/unidades?id=$id'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  // ══════════════════════════════════════════
  //  AUTENTICACIÓN
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>?> login(String usuario, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': usuario, 'password': password}),
    );

    if (response.statusCode == 401) return null;
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return Map<String, dynamic>.from(body['data']);
  }

  // ══════════════════════════════════════════
  //  SINCRONIZACIÓN
  // ══════════════════════════════════════════

  /// Subir datos locales al backend
  Future<Map<String, dynamic>> syncSubir({
    List<Map<String, dynamic>>? miembros,
    List<Map<String, dynamic>>? eventos,
    List<Map<String, dynamic>>? unidades,
    List<Map<String, dynamic>>? unidadMiembros,
    List<Map<String, dynamic>>? asistencia,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sync'),
      headers: _headers,
      body: jsonEncode({
        if (miembros != null) 'miembros': miembros,
        if (eventos != null) 'eventos': eventos,
        if (unidades != null) 'unidades': unidades,
        if (unidadMiembros != null) 'unidad_miembros': unidadMiembros,
        if (asistencia != null) 'asistencia': asistencia,
      }),
    );
    _checkResponse(response);

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  /// Descargar todos los datos del backend
  Future<Map<String, dynamic>> syncDescargar() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sync'),
      headers: _headers,
    );
    _checkResponse(response);

    final body = jsonDecode(response.body);
    return Map<String, dynamic>.from(body['data']);
  }

  // ══════════════════════════════════════════
  //  SETUP
  // ══════════════════════════════════════════

  /// Inicializar las tablas en la base de datos remota
  Future<bool> setupDatabase() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/setup'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse('$_baseUrl/health'));
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // ══════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error'] ?? 'Error desconocido',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

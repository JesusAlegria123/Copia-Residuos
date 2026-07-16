import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../config/api_config.dart';
import '../models/reporte_model.dart';

class ReporteService {
  static const distritosDefault = [
    'Cusco',
    'Wanchaq',
    'Santiago',
    'San Sebastián',
    'San Jerónimo',
    'Saylla',
    'Poroy',
    'Ccorca',
    'San Salvador',
    'Otro',
  ];

  Future<List<String>> obtenerDistritos() async {
    try {
      final response = await http
          .get(ApiConfig.uri('/api/reportes/distritos'))
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        return List<String>.from(data['distritos'] as List);
      }
    } catch (_) {
      // Fallback si el backend no responde
    }
    return distritosDefault;
  }

  Future<List<ReporteModel>> listarReportes() async {
    final response = await http
        .get(ApiConfig.uri('/api/reportes'))
        .timeout(const Duration(seconds: 15));

    final body = _decodeBody(response);

    if (response.statusCode == 200 && body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final list = data['reportes'] as List<dynamic>? ?? [];
      return list
          .map((e) => ReporteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw _parseError(body, response.statusCode);
  }

  Future<ReporteModel> crearReporte({
    required String descripcion,
    required String distrito,
    required double latitud,
    required double longitud,
    required File foto,
    String? titulo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/api/reportes'),
    );

    if (titulo != null && titulo.trim().isNotEmpty) {
      request.fields['titulo'] = titulo.trim();
    }
    request.fields['descripcion'] = descripcion.trim();
    request.fields['distrito'] = distrito.trim();
    request.fields['latitud'] = latitud.toString();
    request.fields['longitud'] = longitud.toString();

    final mimeType = lookupMimeType(foto.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: MediaType(parts[0], parts.length > 1 ? parts[1] : 'jpeg'),
      ),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    final body = _decodeBody(response);

    if (response.statusCode == 201 && body['success'] == true) {
      return ReporteModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw _parseError(body, response.statusCode);
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ReporteException(
        'Respuesta inválida del servidor (${response.statusCode}).',
        code: 'INVALID_RESPONSE',
      );
    }
  }

  ReporteException _parseError(Map<String, dynamic> body, int statusCode) {
    if (body['error'] is Map<String, dynamic>) {
      final err = body['error'] as Map<String, dynamic>;
      return ReporteException(
        err['message'] as String? ?? 'No se pudo completar la operación.',
        code: err['code'] as String?,
      );
    }

    if (statusCode == 0 || statusCode >= 500) {
      return const ReporteException(
        'Error en el servidor. Verifica que el backend esté activo.',
        code: 'SERVER_ERROR',
      );
    }

    return ReporteException(
      'No se pudo conectar con el servidor. Revisa tu conexión.',
      code: 'NETWORK_ERROR',
    );
  }
}

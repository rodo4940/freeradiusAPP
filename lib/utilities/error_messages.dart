import 'package:freeradius_app/services/api_services.dart';

String describeApiError(Object error) {
  if (error is ApiException) {
    if (error.statusCode == -1) {
      return 'No se pudo conectar con el servidor. Verifica que el backend esté en ejecución y accesible.';
    }
    final body = error.body?.trim();
    if (body != null && body.isNotEmpty) {
      return 'Error ${error.statusCode}: $body';
    }
    return 'Error ${error.statusCode} al comunicarse con el servidor.';
  }

  final message = error.toString().trim();
  if (message.contains('Connection refused')) {
    return 'No se pudo conectar con el servidor. Verifica que el backend esté en ejecución y accesible.';
  }
  if (message.isEmpty) {
    return 'Ocurrió un error desconocido.';
  }
  return message;
}

import 'dart:convert';

import '../models/access_record.dart';

class JsonService {
  String convertirAJson(List<AccessRecord> registros) {
    final lista = registros.map((registro) => registro.toJson()).toList();

    return jsonEncode(lista);
  }

  List<AccessRecord> convertirDesdeJson(String contenido) {
    final datos = jsonDecode(contenido);

    if (datos is! List) {
      throw const FormatException(
        'El JSON debe contener una lista de registros.',
      );
    }

    return datos.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Un registro no tiene un formato válido.',
        );
      }

      return AccessRecord.fromJson(item);
    }).toList();
  }
}
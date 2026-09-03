import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _usuarioKey = 'usuario_recordado';

  Future<void> guardarUsuario(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usuarioKey, usuario);
  }

  Future<String?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usuarioKey);
  }

  Future<void> eliminarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usuarioKey);
  }
}
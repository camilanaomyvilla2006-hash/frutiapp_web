import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'models/access_record.dart';

import 'services/preferences_service.dart';

import 'services/json_service.dart';
import 'package:web/web.dart' as web;

import 'package:file_selector/file_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrutiApp Web',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 87, 25, 203),
        ),
      ),
      home: LoginPage(),
    );
  }
}

Future<List<dynamic>> cargarProductos() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('No se pudo cargar la información');
}

// stless crea un StatelessWidget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final List<AccessRecord> _bitacora = [];

  final TextEditingController _usuarioController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final PreferencesService _preferencesService = PreferencesService();

  bool _recordarme = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioRecordado();
  }

  Future<void> _cargarUsuarioRecordado() async {
    final usuario = await _preferencesService.obtenerUsuario();

    if (usuario != null && usuario.isNotEmpty) {
      setState(() {
        _usuarioController.text = usuario;
        _recordarme = true;
      });
    }
  }

  Future<void> _ingresar() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final usuario = _usuarioController.text.trim();
  final password = _passwordController.text;

  final exitoso = password == 'fruti123';

  final registro = AccessRecord(
    usuario: usuario,
    fechaHora: DateTime.now(),
    exitoso: exitoso,
  );

  _bitacora.add(registro);

  if (!exitoso) {
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credenciales incorrectas.'),
      ),
    );

    return;
  }

  if (_recordarme) {
    await _preferencesService.guardarUsuario(usuario);
  } else {
    await _preferencesService.eliminarUsuario();
  }

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(
        bitacora: _bitacora,
      ),
    ),
  );
}

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'FrutiApp',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    TextFormField(
                      controller: _usuarioController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el correo';
                        }

                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Correo no válido';
                        }

                        return null;
                      },
                    ),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }

                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: _recordarme,
                          onChanged: (value) {
                            setState(() {
                              _recordarme = value ?? false;
                            });
                          },
                        ),
                        const Text('Recordarme'),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: _ingresar,
                      child: const Text('Ingresar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<AccessRecord> bitacora;

  const HomePage({super.key, required this.bitacora});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 
  final JsonService _jsonService = JsonService();

 void _exportarJson() {
   final contenido = _jsonService.convertirAJson(widget.bitacora);

  final bytes = utf8.encode(contenido);
  final base64 = base64Encode(bytes);

  web.HTMLAnchorElement()
    ..href = 'data:application/json;base64,$base64'
    ..setAttribute('download', 'bitacora_accesos.json')
    ..click();
}
  Future<void> _importarJson() async {
    const tipo = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );

    final XFile? archivo = await openFile(acceptedTypeGroups: [tipo]);

    if (archivo == null) {
      return;
    }

    try {
      final contenido = await archivo.readAsString();

     final registros = _jsonService.convertirDesdeJson(contenido);

      setState(() {
        widget.bitacora.clear();
        widget.bitacora.addAll(registros);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON importado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo JSON no es válido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('FrutiApp'),
  actions: [
    IconButton(
      onPressed: _importarJson,
      icon: const Icon(Icons.upload_file),
      tooltip: 'Importar JSON',
    ),
    IconButton(
      onPressed: _exportarJson,
      icon: const Icon(Icons.download),
      tooltip: 'Exportar JSON',
    ),
  ],
),
      body: widget.bitacora.isEmpty
          ? const Center(child: Text('No hay registros de acceso.'))
          : ListView.builder(
              itemCount: widget.bitacora.length,
              itemBuilder: (context, index) {
                final registro = widget.bitacora[index];

                return ListTile(
                  leading: Icon(
                    registro.exitoso ? Icons.check_circle : Icons.cancel,
                  ),
                  title: Text(registro.usuario),
                  subtitle: Text(registro.fechaHora.toLocal().toString()),
                  trailing: Text(registro.exitoso ? 'Exitoso' : 'Fallido'),
                );
              },
            ),
    );
  }
}

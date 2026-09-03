import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

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

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            // es un widget que nos permite presentar contenido dentro de una especie de tarjeta visual.
            child: Padding(
              padding: EdgeInsets.all(20),
              // Padding agrega espacio alrededor de un widget y utiliza EdgeInsets.all(20)
              child: Form(
                key: _formKey,

                child: Column(
                  children: [
                    /// children permite colocar varios widgets dentro del Column.
                    Text(
                      'FrutiApp',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextFormField(
                      // Es el campo donde el usuario puede escribir información.
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        // labelText hace que aparezca el campo para escribir
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el correo';
                        }

                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Correo no valido';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      // obscureText hace que cuando el usuario escriba la contraseña no se visualice ********
                      decoration: InputDecoration(labelText: 'Contraseña'),

                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        Text('Recordarme'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }
                      },
                      child: Text('Ingresar'),
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
  appBar: AppBar(
    title: Text('FrutiApp'),
  ),
  body: FutureBuilder<List<dynamic>>(
    future: cargarProductos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if (snapshot.hasError) {
        return Center(
          child: Text('Error al cargar los datos'),
        );
      }

      final productos = snapshot.data ?? [];

      return ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];

          return ListTile(
            title: Text(producto['title']),
            subtitle: Text(
              'Precio: ₡${producto['id'] * 100}',
            ),
          );
        },
      );
    },
  ),
);
  }
}

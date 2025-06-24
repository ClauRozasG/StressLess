import 'package:flutter/material.dart';
import 'verificationCode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaPrueba.dart';
import 'pantallaInicioColaborador.dart';
import 'package:app_stressless/main.dart';

class LoginColaboradorPage extends StatefulWidget {
  const LoginColaboradorPage({super.key});

  @override
  State<LoginColaboradorPage> createState() => _LoginColaboradorPageState();
}

class _LoginColaboradorPageState extends State<LoginColaboradorPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.mic, size: 60, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  "Bienvenido\ncolaborador",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Un día a la vez\nAquí te ayudamos a entender\ncómo estás",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: '••••••••',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // lógica para recuperar contraseña
                    },
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                // Iniciar sesión button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3E2E),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Todos los campos son obligatorios")),
                      );
                      return;
                    }

                    final response = await http.post(
                      Uri.parse('http://192.168.1.40:8000/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'correo': email,
                        'contrasenia': password,
                        'rol': 'COLABORADOR',
                      }),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final token = data['token'];
                      final idColaborador = data['id'];
                      final nombre = data['nombre']; // <-- NUEVO: nombre desde backend

                      print("✅ Token recibido: $token");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sesión iniciada con éxito")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => pantallaInicioColaborador(
                            idColaborador: idColaborador,
                            nombreColaborador: nombre,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Credenciales inválidas: ${response.statusCode}")),
                      );
                      print("❌ Error login: ${response.body}");
                    }
                  },


                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 20),

                // Registro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const verificationCode()),
                    );
                  },
                  child: const Text(
                    '¿Eres nuevo colaborador? Ingresa aquí',
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                const SizedBox(height: 10),

                // Volver
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3E2E),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const StressLessApp()),
                          (route) => false,
                    );
                  },

                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:app_stressless/screens/registroLider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaInicioLider.dart';
import 'package:app_stressless/main.dart';


class initialLoginLider extends StatefulWidget {
  const initialLoginLider({super.key});

  @override
  State<initialLoginLider> createState() => _initialLoginLiderState();
}

class _initialLoginLiderState extends State<initialLoginLider> {
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
                  "Bienvenido\nlíder",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Detecta, previene y acompaña \ncon empatía",
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
                    final email = _emailController.text;
                    final password = _passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Completa todos los campos")),
                      );
                      return;
                    }

                    final url = Uri.parse("http://192.168.1.40:8000/login");

                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "correo": email,
                        "contrasenia": password,
                        "rol": "LIDER"
                      }),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final idLider = data['id'];

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaInicioLider(idLider: idLider),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Credenciales incorrectas")),
                      );
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
                      MaterialPageRoute(builder: (context) => const registroLider()),
                    );
                  },
                  child: const Text(
                    '¿Eres nuevo líder? Ingresa aquí',
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

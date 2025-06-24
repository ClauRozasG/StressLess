import 'package:flutter/material.dart';
import 'envioInvitaciones.dart'; // O tu pantalla siguiente
import 'package:http/http.dart' as http;
import 'dart:convert';

class registroLider extends StatefulWidget {
  const registroLider({super.key});

  @override
  State<registroLider> createState() => _registroLiderState();
}

class _registroLiderState extends State<registroLider> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _mensaje = '';

  void _registrar() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _mensaje = 'Todos los campos son obligatorios');
      return;
    }

    if (password != confirm) {
      setState(() => _mensaje = 'Las contraseñas no coinciden');
      return;
    }

    final url = Uri.parse('http://192.168.1.40:8000/leaders');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nombre": nombre,
        "correo": email,
        "contrasenia": password,
        "estado": true
      }),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final idLider = data['id'];
      final correo = _emailController.text.trim();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => envioInvitaciones(
            idLider: idLider,
            correoLider: correo,
          ),
        ),
      );
    } else {
      setState(() => _mensaje = 'Error al registrar líder');
      print("⚠️ ${response.statusCode}: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido líder',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _buildLabel('Nombre completo', Icons.person),
                _buildEditableField(_nombreController, 'Tu nombre'),

                const SizedBox(height: 15),
                _buildLabel('E-mail', Icons.email),
                _buildEditableField(_emailController, 'example@example.com.pe'),

                const SizedBox(height: 15),
                _buildLabel('Crea una contraseña', Icons.lock),
                _buildPasswordField(_passwordController),

                const SizedBox(height: 15),
                _buildLabel('Reconfirma la contraseña', Icons.lock),
                _buildPasswordField(_confirmPasswordController),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Volver'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Crear cuenta'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    _mensaje,
                    style: TextStyle(
                      color: _mensaje == 'Registro exitoso' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEditableField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
    );
  }
}

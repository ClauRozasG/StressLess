import 'package:flutter/material.dart';
import 'verificationCode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaInicioColaborador.dart';
import 'package:app_stressless/main.dart';import 'package:app_stressless/constants.dart';
import 'package:app_stressless/screens/cambioContraseniaPantallaInicio.dart';

class LoginColaboradorPage extends StatefulWidget {
  const LoginColaboradorPage({super.key});

  @override
  State<LoginColaboradorPage> createState() => _LoginColaboradorPageState();
}

class _LoginColaboradorPageState extends State<LoginColaboradorPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  Color get _primary => const Color(0xFF8D6E63); // café suave
  Color get _bg => const Color(0xFFF5F5DC);       // beige fondo

  InputDecoration _decor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.brown.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _primary, width: 1.6),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'contrasenia': password,
          'rol': 'COLABORADOR',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final idColaborador = data['id'];
        final nombre = data['nombre'];

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de red: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔝 Header centrado, sin card
                const Icon(Icons.mic, size: 72, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  "Bienvenido\ncolaborador",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Un día a la vez\nAquí te ayudamos a entender\ncómo estás",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 26),

                // ✉️ Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  decoration: _decor(
                    hint: 'example@email.com',
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 12),

                // 🔒 Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: _decor(
                    hint: 'Tu contraseña',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.brown.shade400,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordRequestPage(rol: "COLABORADOR"),
                        ),
                      );
                    },

                    child: const Text('Olvidé mi contraseña', style: TextStyle(fontSize: 12)),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔘 Login (full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),

                const SizedBox(height: 10),

                // ➕ Registro
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

                const SizedBox(height: 8),

                // ⬅️ Volver (outline)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.brown.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const StressLessApp()),
                            (route) => false,
                      );
                    },
                    child: Text(
                      'Volver',
                      style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

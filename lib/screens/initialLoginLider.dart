import 'package:app_stressless/api_client.dart';
import 'package:app_stressless/jwt_decoder.dart';
import 'package:app_stressless/screens/registroLider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaInicioLider.dart';
import 'package:app_stressless/main.dart';
import 'package:app_stressless/constants.dart';
import 'package:app_stressless/screens/cambioContraseniaPantallaInicio.dart';



class initialLoginLider extends StatefulWidget {
  const initialLoginLider({super.key});

  @override
  State<initialLoginLider> createState() => _initialLoginLiderState();
}

class _initialLoginLiderState extends State<initialLoginLider> {
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
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": email,
          "contrasenia": password,
          "rol": "LIDER"
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        //ApiClient.authToken = json['token'];
        final data = jsonDecode(response.body);
        final idLider = data['id'];
        final token = data["access_token"] ?? data["token"];

        if (token != null) {
          ApiConfig.authToken = token;
          ApiClient.authToken = token;

          // 🔐 Debug: decodificar JWT y ver payload
          final payload = decodeJwtPayload(token);
          print("🔐 JWT payload: $payload");

          // Si quieres también un SnackBar visible:
          if (payload != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Rol: ${payload["rol"]}, ID: ${payload["id"]}")),
            );
          }

          // ⚠️ Si el rol no es LIDER, avisa en consola
          if (payload?["rol"]?.toString()?.toUpperCase() != "LIDER") {
            print("⚠️ El rol en el token no es LIDER, es: ${payload?["rol"]}");
          }
        }

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
                // 🔝 Header centrado
                const Icon(Icons.mic, size: 72, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  "Bienvenido\nlíder",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Detecta, previene y acompaña\ncon empatía",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 26),

                // ✉️ Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                          builder: (_) => const ForgotPasswordRequestPage(rol: "LIDER"),
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

                const SizedBox(height: 12),

                // ➕ Registro
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

                const SizedBox(height: 8),

                // ⬅️ Volver
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

import 'package:flutter/material.dart';
import 'package:app_stressless/screens/initialLoginLider.dart';
import 'screens/loginColab.dart';

void main() {
  runApp(const StressLessApp());
}

class StressLessApp extends StatelessWidget {
  const StressLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StressLess',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige
        useMaterial3: false,
      ),
      home: const LoginInicio(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginInicio extends StatelessWidget {
  const LoginInicio({super.key});

  Color get _primary => const Color(0xFF8D6E63); // café suave
  Color get _textDark => const Color(0xFF4E342E); // café texto
  Color get _muted => const Color(0xFF6D4C41); // subtítulo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔝 Header centrado
                const Icon(Icons.mic, size: 72, color: Colors.teal),
                const SizedBox(height: 16),
                Text(
                  '¡Bienvenido!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo quieres ingresar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _muted,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 28),

                // 👤 Botón Líder
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.verified_user),
                    label: const Text(
                      'Iniciar sesión como líder',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const initialLoginLider()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 👩‍💼 Botón Colaborador (mismo estilo que el de líder)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people_alt_outlined),
                    label: const Text(
                      'Iniciar sesión como colaborador',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginColaboradorPage()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 🌿 Nota

              ],
            ),
          ),
        ),
      ),
    );
  }
}

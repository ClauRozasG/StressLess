import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_stressless/constants.dart';

class PantallaCambiarContrasena extends StatefulWidget {
  final int idColaborador;

  const PantallaCambiarContrasena({super.key, required this.idColaborador});

  @override
  State<PantallaCambiarContrasena> createState() => _PantallaCambiarContrasenaState();
}

class _PantallaCambiarContrasenaState extends State<PantallaCambiarContrasena> {
  // Paleta
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E); // café texto

  final TextEditingController _nuevaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _loading = false;

  @override
  void dispose() {
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

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

  // ================== Password strength ==================
  int _scorePassword(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[a-z]').hasMatch(p)) score++;
    if (RegExp(r'\d').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\'",.<>\/\?\\|`~]'").hasMatch(p)) score++;
    return score; // 0..5
    }

  String _labelForScore(int s) {
    if (s <= 1) return 'Muy débil';
    if (s == 2) return 'Débil';
    if (s == 3) return 'Media';
    if (s == 4) return 'Fuerte';
    return 'Muy fuerte';
  }

  Color _colorForScore(int s) {
    if (s <= 1) return Colors.red;
    if (s == 2) return Colors.deepOrange;
    if (s == 3) return Colors.amber.shade800;
    if (s == 4) return Colors.green;
    return Colors.green.shade700;
  }

  double _valueForScore(int s) => (s.clamp(0, 5)) / 5.0;

  Future<void> _cambiarContrasena() async {
    final nueva = _nuevaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    if (nueva.isEmpty || confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa ambos campos")),
      );
      return;
    }

    if (nueva != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    // Reglas mínimas recomendadas
    if (_scorePassword(nueva) < 3 || nueva.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña es muy débil. Usa mínimo 8 caracteres combinando mayúsculas, números y símbolos.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/colaborador/${widget.idColaborador}/cambiar-contrasena");
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nueva_contrasena": nueva}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contraseña actualizada exitosamente")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cambiar contraseña: ${response.statusCode}")),
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
    final score = _scorePassword(_nuevaController.text);
    final color = _colorForScore(score);
    final label = _labelForScore(score);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Atrás',
        ),
        title: Text(
          'Cambiar contraseña',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Header con avatar genérico
                CircleAvatar(
                radius: 28,
                backgroundColor: _primary.withOpacity(.15),
                child: Icon(Icons.lock_reset, color: _primary, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'Actualiza tu contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 18),

              // Campo nueva contraseña
              TextField(
                controller: _nuevaController,
                obscureText: _obscureNueva,
                onChanged: (_) => setState(() {}),
                decoration: _decor(
                  hint: 'Nueva contraseña',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureNueva ? Icons.visibility_off : Icons.visibility,
                      color: Colors.brown.shade400,
                    ),
                    onPressed: () => setState(() => _obscureNueva = !_obscureNueva),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Medidor de fuerza
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _valueForScore(score),
                  backgroundColor: Colors.brown.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Seguridad: $label',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Checklist de requisitos
              _RuleItem(ok: _nuevaController.text.length >= 8, text: 'Mínimo 8 caracteres'),
              _RuleItem(ok: RegExp(r'[A-Z]').hasMatch(_nuevaController.text), text: 'Incluye una MAYÚSCULA'),
              _RuleItem(ok: RegExp(r'\d').hasMatch(_nuevaController.text), text: 'Incluye un número'),
              _RuleItem(ok: RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\'",.<>\/\?\\|`~]'").hasMatch(_nuevaController.text), text: 'Incluye un símbolo'),

                  const SizedBox(height: 16),

                // Confirmar contraseña
                TextField(
                  controller: _confirmarController,
                  obscureText: _obscureConfirmar,
                  decoration: _decor(
                    hint: 'Confirmar contraseña',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                        color: Colors.brown.shade400,
                      ),
                      onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Botones
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _cambiarContrasena,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.brown.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Atrás',
                      style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final bool ok;
  final String text;

  const _RuleItem({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16, color: ok ? Colors.green : Colors.brown.shade400),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12.5)),
      ],
    );
  }
}

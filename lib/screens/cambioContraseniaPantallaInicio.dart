import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

// ======= Paleta / Estilos base =======
const _bg = Color(0xFFF5F5DC);       // beige
const _primary = Color(0xFF8D6E63);  // café
const _textDark = Color(0xFF4E342E); // café oscuro

OutlineInputBorder _outlined([Color? color]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(color: color ?? Colors.brown.shade200, width: 1),
);

InputDecoration _decor({
  String? hint,
  IconData? prefix,
  Widget? suffix,
  bool filledWhite = true,
}) {
  return InputDecoration(
    prefixIcon: prefix != null ? Icon(prefix, color: _primary) : null,
    suffixIcon: suffix,
    hintText: hint,
    filled: true,
    fillColor: filledWhite ? Colors.white : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: _outlined(),
    focusedBorder: _outlined(_primary),
  );
}

ButtonStyle _primaryBtn() => ElevatedButton.styleFrom(
  backgroundColor: _primary,
  padding: const EdgeInsets.symmetric(vertical: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  elevation: 3,
);

ButtonStyle _outlineBtn() => OutlinedButton.styleFrom(
  side: BorderSide(color: Colors.brown.shade300),
  padding: const EdgeInsets.symmetric(vertical: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
);

// =============================================================
// 1) SOLICITAR CÓDIGO
// =============================================================
class ForgotPasswordRequestPage extends StatefulWidget {
  final String rol; // "LIDER" | "COLABORADOR"
  const ForgotPasswordRequestPage({super.key, required this.rol});

  @override
  State<ForgotPasswordRequestPage> createState() => _ForgotPasswordRequestPageState();
}

class _ForgotPasswordRequestPageState extends State<ForgotPasswordRequestPage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _requestReset() async {
    final email = _emailCtrl.text.trim();
    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un correo válido.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/password/forgot"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": email, "rol": widget.rol}),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Si el correo existe, te enviamos un código.")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotPasswordCodePage(email: email, rol: widget.rol),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo enviar el código: ${resp.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de red: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text("Recuperar contraseña", style: TextStyle(color: _textDark, fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 70, color: _primary),
                const SizedBox(height: 12),
                const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  "Ingresa tu correo y te enviaremos un código de verificación.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.brown.shade600),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  decoration: _decor(hint: "example@email.com", prefix: Icons.email_outlined),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _requestReset,
                    style: _primaryBtn(),
                    child: _loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Enviar código", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: _outlineBtn(),
                    child: Text("Volver", style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// 2) INGRESAR CÓDIGO (6 dígitos, auto-avance)
// =============================================================
class ForgotPasswordCodePage extends StatefulWidget {
  final String email;
  final String rol;
  const ForgotPasswordCodePage({super.key, required this.email, required this.rol});

  @override
  State<ForgotPasswordCodePage> createState() => _ForgotPasswordCodePageState();
}

class _ForgotPasswordCodePageState extends State<ForgotPasswordCodePage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  bool _checking = false;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nodes.isNotEmpty) _nodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final n in _nodes) n.dispose();
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.length == 1) {
      if (i < _nodes.length - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        _nodes[i].unfocus();
      }
      setState(() {});
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  Future<void> _verifyAndNext() async {
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el código de 6 dígitos.")),
      );
      return;
    }
    setState(() => _checking = true);
    try {
      final resp = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/password/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": widget.email, "rol": widget.rol, "codigo": _code}),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotPasswordResetPage(email: widget.email, rol: widget.rol, code: _code),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Código inválido o expirado.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de red: $e")),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/password/forgot"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": widget.email, "rol": widget.rol}),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código reenviado.")),
      );
      for (final c in _controllers) c.clear();
      _nodes.first.requestFocus();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo reenviar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _code.length == 6;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text("Verificar código", style: TextStyle(color: _textDark, fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const Icon(Icons.mark_email_read, size: 70, color: _primary),
                const SizedBox(height: 12),
                Text("Hemos enviado un código a:", style: TextStyle(color: Colors.brown.shade700)),
                const SizedBox(height: 4),
                Text(widget.email, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 16),

                // OTP 6 dígitos
                LayoutBuilder(
                  builder: (context, constraints) {
                    const int boxes = 6;
                    const double gap = 12; // era tu margen horizontal (6 a cada lado)
                    // ancho disponible para las cajas: total - espacios
                    final double w = (constraints.maxWidth - gap * (boxes - 1)) / boxes;

                    // limites para que no queden ni muy chicas ni gigantes
                    final double boxWidth = w.clamp(44.0, 52.0); // tú usabas 52

                    Widget slot(int i) => SizedBox(
                      width: boxWidth,
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: _decor(hint: '•', filledWhite: true).copyWith(counterText: ''),
                        onChanged: (v) => _onChanged(i, v),
                      ),
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(boxes, (i) {
                        return Padding(
                          padding: EdgeInsets.only(right: i == boxes - 1 ? 0 : gap),
                          child: slot(i),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: _checking ? null : _resend,
                  child: const Text("Reenviar código", style: TextStyle(decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!isComplete || _checking) ? null : _verifyAndNext,
                    style: _primaryBtn(),
                    child: _checking
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Verificar", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _checking ? null : () => Navigator.pop(context),
                    style: _outlineBtn(),
                    child: Text("Atrás", style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// 3) NUEVA CONTRASEÑA
// =============================================================
class ForgotPasswordResetPage extends StatefulWidget {
  final String email;
  final String rol;
  final String code;
  const ForgotPasswordResetPage({super.key, required this.email, required this.rol, required this.code});

  @override
  State<ForgotPasswordResetPage> createState() => _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _obsc1 = true;
  bool _obsc2 = true;
  bool _saving = false;

  Future<void> _save() async {
    final p1 = _pass1.text;
    final p2 = _pass2.text;

    if (p1.isEmpty || p2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Completa ambos campos.")));
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Las contraseñas no coinciden.")));
      return;
    }
    if (p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mínimo 6 caracteres.")));
      return;
    }

    setState(() => _saving = true);
    try {
      final resp = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/password/reset"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": widget.email,
          "rol": widget.rol,
          "codigo": widget.code,
          "nueva_contrasena": p1,
        }),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contraseña actualizada.")));
        Navigator.popUntil(context, (route) => route.isFirst); // vuelve al inicio/login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${resp.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de red: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text("Nueva contraseña", style: TextStyle(color: _textDark, fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.password, size: 70, color: _primary),
                const SizedBox(height: 12),
                const Text(
                  "Crea tu nueva contraseña",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _pass1,
                  obscureText: _obsc1,
                  decoration: _decor(hint: '••••••••', prefix: Icons.lock_outline, suffix: IconButton(
                    icon: Icon(_obsc1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obsc1 = !_obsc1),
                  )),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass2,
                  obscureText: _obsc2,
                  decoration: _decor(hint: 'Repite la contraseña', prefix: Icons.lock_outline, suffix: IconButton(
                    icon: Icon(_obsc2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obsc2 = !_obsc2),
                  )),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: _primaryBtn(),
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Guardar", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: _outlineBtn(),
                    child: Text("Atrás", style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

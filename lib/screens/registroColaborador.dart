import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_stressless/constants.dart';
import 'pantallaInicioColaborador.dart';

class registroColaborador extends StatefulWidget {
  final String nombre;
  final String email;
  final String codigo;       // OTP
  final String correoLider;  // correo del líder

  const registroColaborador({
    super.key,
    required this.nombre,
    required this.email,
    required this.codigo,
    required this.correoLider,
  });

  @override
  State<registroColaborador> createState() => _registroColaboradorState();
}

class _registroColaboradorState extends State<registroColaborador> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = widget.nombre;
    _emailCtrl.text = widget.email;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _registrarYEntrar() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final body = {
        "nombre": _nombreCtrl.text.trim(),
        "correo": _emailCtrl.text.trim().toLowerCase(),
        "contrasenia": _passCtrl.text,
        "codigo": widget.codigo,
      };

      final uri = Uri.parse("${ApiConfig.baseUrl}/register-colaborador");;
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("🟡 REGISTRO status: ${resp.statusCode}");
      debugPrint("🟡 REGISTRO body: ${resp.body}");

      if (!mounted) return;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);

        // ---- Normaliza ID ----
        int? _asInt(dynamic v) {
          if (v == null) return null;
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        }

        int? idColaborador =
            _asInt(data["id_colaborador"]) ??
                _asInt(data["colaborador"]?["id"]) ??
                _asInt(data["id"]) ??
                _asInt(data["data"]?["id"]) ??
                _asInt(data["user"]?["id"]) ??
                _asInt(data["usuario"]?["id"]);

        final String nombreColaborador =
        (data["nombre"] ??
            data["colaborador"]?["nombre"] ??
            data["user"]?["nombre"] ??
            data["usuario"]?["nombre"] ??
            _nombreCtrl.text)
            .toString();

        if (idColaborador == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: no se recibió ID. Respuesta: ${resp.body}"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() => _loading = false);
          return;
        }

        // Navegación limpia
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => pantallaInicioColaborador(
              idColaborador: idColaborador!,
              nombreColaborador: nombreColaborador,
            ),
          ),
              (route) => false,
        );
      } else {
        String msg = "No se pudo registrar (${resp.statusCode})";
        try {
          final err = jsonDecode(resp.body);
          if (err is Map && err["detail"] != null) msg = err["detail"].toString();
          if (err is Map && err["message"] != null) msg = err["message"].toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e, st) {
      debugPrint("🔴 REGISTRO EXCEPTION: $e\n$st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de red: $e"), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primary = const Color(0xFF8D6E63);
    final Color _bg = const Color(0xFFF5F5DC);
    final Color _textDark = const Color(0xFF4E342E);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        title: Text("Bienvenido colaborador",
            style: TextStyle(color: _textDark, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Completa tu registro para empezar",
                style: TextStyle(color: Colors.brown.shade700)),

            const SizedBox(height: 20),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre completo",
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: TextEditingController(text: widget.correoLider),
              enabled: false,
              decoration: InputDecoration(
                labelText: "Correo del líder",
                prefixIcon: const Icon(Icons.supervisor_account_outlined),
                filled: true,
                fillColor: Colors.grey.shade200,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              enabled: false,
              decoration: InputDecoration(
                labelText: "E-mail",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade200,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Crea una contraseña",
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pass2Ctrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Reconfirma la contraseña",
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _registrarYEntrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Text("Aceptar",
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

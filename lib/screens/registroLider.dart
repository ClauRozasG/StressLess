import 'package:flutter/material.dart';
import 'envioInvitaciones.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';import 'package:app_stressless/constants.dart';

class registroLider extends StatefulWidget {
  const registroLider({super.key});

  @override
  State<registroLider> createState() => _registroLiderState();
}

class _registroLiderState extends State<registroLider> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _mensaje = '';
  bool _loading = false;
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  Color get _primary => const Color(0xFF8D6E63); // café suave
  Color get _bg => const Color(0xFFF5F5DC); // beige que ya usas

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }

  String? _validateNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
    if (v.trim().length < 3) return 'Muy corto';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    final emailRe = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
    if (!emailRe.hasMatch(v.trim())) return 'Correo no válido';
    return null;
  }

  String? _validatePwd(String? v) {
    if (v == null || v.isEmpty) return 'Crea una contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Reconfirma la contraseña';
    if (v != _passwordController.text) return 'No coincide con la contraseña';
    return null;
  }

  Future<void> _registrar() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() {
      _loading = true;
      _mensaje = '';
    });

    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final url = Uri.parse('${ApiConfig.baseUrl}/leaders');
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

    if (!mounted) return;

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
      debugPrint("⚠️ ${response.statusCode}: ${response.body}");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 8,
              shadowColor: Colors.brown.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header lindo
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.verified_user, color: _primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bienvenido líder',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.brown.shade800,
                                  )),
                              Text('Crea tu cuenta para invitar a tu equipo',
                                  style: TextStyle(
                                    color: Colors.brown.shade500,
                                    fontSize: 13.5,
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 22),

                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // Nombre
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Nombre completo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown.shade700,
                                )),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nombreController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: _inputDecoration(
                              hint: 'Tu nombre',
                              icon: Icons.person_outline,
                            ),
                            validator: _validateNombre,
                          ),

                          const SizedBox(height: 14),

                          // Email
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('E-mail',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown.shade700,
                                )),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: _inputDecoration(
                              hint: 'example@example.com',
                              icon: Icons.email_outlined,
                            ),
                            validator: _validateEmail,
                          ),

                          const SizedBox(height: 14),

                          // Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Crea una contraseña',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown.shade700,
                                )),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePwd,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: _inputDecoration(
                              hint: 'Mínimo 6 caracteres',
                              icon: Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePwd ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.brown.shade400,
                                ),
                                onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                              ),
                            ),
                            validator: _validatePwd,
                          ),

                          const SizedBox(height: 14),

                          // Confirm Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Reconfirma la contraseña',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown.shade700,
                                )),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: _inputDecoration(
                              hint: 'Vuelve a escribir tu contraseña',
                              icon: Icons.lock_reset_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.brown.shade400,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: _validateConfirm,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_mensaje.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _mensaje,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _mensaje == 'Registro exitoso' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.brown.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Volver', style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _registrar,
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
                                : const Text('Crear cuenta', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
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

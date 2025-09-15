import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'registroColaborador.dart';
import 'package:app_stressless/constants.dart';

class verificationCode extends StatefulWidget {
  const verificationCode({super.key});

  @override
  State<verificationCode> createState() => _verificationCodeState();
}

class _verificationCodeState extends State<verificationCode> {
  final List<TextEditingController> _controllers =
  List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(5, (_) => FocusNode()); // para mover foco

  final _emailCtrl = TextEditingController();
  final _resendFormKey = GlobalKey<FormState>();

  String _message = '';
  bool _isCodeCorrect = false;
  bool _loading = false;
  bool _resendLoading = false;

  Color get _primary => const Color(0xFF8D6E63); // café
  Color get _bg => const Color(0xFFF5F5DC); // beige

  bool get _isCodeComplete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final enteredCode = _controllers.map((c) => c.text).join();
    setState(() => _loading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/validar-codigo/$enteredCode");
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nombre = data['nombre'];
        final email = data['correo'];
        final correoLider = data['correo_lider'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => registroColaborador(
              nombre: nombre,
              email: email,
              codigo: enteredCode,
              correoLider: correoLider,
            ),
          ),
        );
      } else {
        setState(() {
          _message = 'Código inválido o ya usado';
          _isCodeCorrect = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de red: $e';
        _isCodeCorrect = false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openResendBottomSheet() {
    _emailCtrl.text = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: bottomInset + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.email_outlined, color: _primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reenviar código',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa tu correo de colaborador. Te enviaremos un nuevo código si corresponde.',
                  style: TextStyle(
                    color: Colors.brown.shade600,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Form(
                key: _resendFormKey,
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.brown.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _primary, width: 1.6),
                    ),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Ingresa tu correo';
                    final emailRegex = RegExp(
                        r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$");
                    if (!emailRegex.hasMatch(v)) return 'Correo inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resendLoading
                      ? null
                      : () async {
                    if (!(_resendFormKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    await _sendResendRequest(_emailCtrl.text.trim());
                    if (!mounted) return;
                    Navigator.pop(ctx); // cierra el sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _resendLoading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Reenviar código',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendResendRequest(String email) async {
    setState(() => _resendLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/resend-code");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );

      // El backend siempre responde mensaje neutro (200-OK o 201-OK sería lo ideal)
      if (!mounted) return;

      // Feedback UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Si el correo está registrado, se ha reenviado el código.'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpia inputs de código y regresa foco
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();

      // Borra mensajes de error visibles
      setState(() {
        _message = '';
        _isCodeCorrect = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo reenviar el código. Intenta nuevamente. ($e)'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }
  // ---------- fin reenviar ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 8,
              shadowColor: Colors.brown.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.key, color: _primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Verificación',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.brown.shade800)),
                              Text('Ingresa el código enviado a tu correo',
                                  style: TextStyle(
                                      color: Colors.brown.shade500,
                                      fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Campos de código
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        return SizedBox(
                          width: 52,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.brown.shade200, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: _primary, width: 1.6),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 4) {
                                _focusNodes[i + 1].requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    // Reenviar: abre el bottom sheet
                    GestureDetector(
                      onTap: _openResendBottomSheet,
                      child: Text(
                        'Reenviar código',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_message.isNotEmpty)
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isCodeCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 26),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.brown.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text("Volver",
                                style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCodeComplete && !_loading ? _verifyCode : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                    )
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

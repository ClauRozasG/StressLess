import 'package:flutter/material.dart';
import 'registroColaborador.dart';

class verificationCode extends StatefulWidget {
  const verificationCode({super.key});

  @override
  State<verificationCode> createState() => _verificationCodeState();
}

class _verificationCodeState extends State<verificationCode> {
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  String _message = '';
  bool _isCodeCorrect = false;

  // Simula el código correcto
  final String _correctCode = '12345';

  void _verifyCode() {
    final enteredCode = _controllers.map((c) => c.text).join();

    if (enteredCode.length < 5) return;

    if (enteredCode == _correctCode) {
      // ✅ Código correcto: ir a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => registroColaborador(
            nombre: 'Claudia Rozas Gamero',  // puedes cambiar esto por variable real
            email: 'claudia@upc.com.pe',     // lo mismo
          ),
        ),
      );
    } else {
      setState(() {
        _message = 'Código incorrecto';
        _isCodeCorrect = false;
      });
    }
  }

  void _resendCode() {
    setState(() {
      _message = 'Código reenviado';
      _isCodeCorrect = false;
      _controllers.forEach((c) => c.clear());
    });
  }

  bool get _isCodeComplete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // beige
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 60, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                '¡Hola!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Ingresa el código enviado a tu correo'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _controllers[i],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _resendCode,
                child: const Text(
                  'Reenviar código',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _message,
                style: TextStyle(
                  color: _isCodeCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Volver'),
                  ),
                  ElevatedButton(
                    onPressed: _isCodeComplete ? _verifyCode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[300],
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

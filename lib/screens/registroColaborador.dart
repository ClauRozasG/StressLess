import 'package:flutter/material.dart';
import 'pantallaInicioColaborador.dart';
import 'modeloPredict.dart';

class registroColaborador extends StatefulWidget {
  final String nombre;
  final String email;

  const registroColaborador({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<registroColaborador> createState() => _registroColaboradorState();
}

class _registroColaboradorState extends State<registroColaborador> {
  final TextEditingController _liderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _mensaje = '';

  void _registrar() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _mensaje = 'Las contraseñas no coinciden');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PruebaEstresPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido colaborador',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _buildLabel('Nombre Completo', Icons.person),
                _buildReadOnlyField(widget.nombre),

                const SizedBox(height: 15),
                _buildLabel('Nombre Líder', Icons.emoji_people),
                _buildEditableField(_liderController, 'XXXXXX XXXXX XXXXX'),

                const SizedBox(height: 15),
                _buildLabel('E-mail', Icons.email),
                _buildReadOnlyField(widget.email),

                const SizedBox(height: 15),
                _buildLabel('Crea una contraseña', Icons.lock),
                _buildPasswordField(_passwordController),

                const SizedBox(height: 15),
                _buildLabel('Reconfirma la contraseña', Icons.lock),
                _buildPasswordField(_confirmPasswordController),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Aceptar'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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

  Widget _buildReadOnlyField(String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: const InputDecoration(
        fillColor: Colors.grey,
        filled: true,
        border: OutlineInputBorder(),
      ),
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

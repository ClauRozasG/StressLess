import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaCambiarContrasena extends StatelessWidget {
  final int idColaborador;

  const PantallaCambiarContrasena({super.key, required this.idColaborador});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nuevaController = TextEditingController();
    final TextEditingController confirmarController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            const Text('Claudia Rozas Gamero', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _campoPassword('Crea una contraseña', nuevaController),
            const SizedBox(height: 12),
            _campoPassword('Reconfirma la contraseña', confirmarController),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: _estiloBoton(),
                  child: const Text('Atrás'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nueva = nuevaController.text.trim();
                    final confirmar = confirmarController.text.trim();

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

                    final url = Uri.parse("http://192.168.1.40:8000/colaborador/${idColaborador}/cambiar-contrasena");
                    final response = await http.put(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"nueva_contrasena": nueva}),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Contraseña actualizada exitosamente")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error al cambiar contraseña")),
                      );
                    }
                  },

                  style: _estiloBoton(),
                  child: const Text('Aceptar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _campoPassword(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  ButtonStyle _estiloBoton() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.brown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

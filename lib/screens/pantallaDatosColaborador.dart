import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaDatosColaborador extends StatefulWidget {
  final int idColaborador;

  const PantallaDatosColaborador({super.key, required this.idColaborador});

  @override
  State<PantallaDatosColaborador> createState() => _PantallaDatosColaboradorState();
}

class _PantallaDatosColaboradorState extends State<PantallaDatosColaborador> {
  String nombreLider = '';
  String correo = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final url = Uri.parse("http://192.168.1.40:8000/colaborador/${widget.idColaborador}/datos");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nombreLider = data['nombre_lider'];
          correo = data['correo'];
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error cargando datos: $e");
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            Text(correo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _campoLectura('👨‍🏫 Nombre Líder', nombreLider),
            const SizedBox(height: 12),
            _campoLectura('📧 E-mail', correo),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Atrás'),
            )
          ],
        ),
      ),
    );
  }

  Widget _campoLectura(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: valor),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.grey,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}


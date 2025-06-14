import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class envioInvitaciones extends StatefulWidget {
  final int idLider;
  final String correoLider;

  const envioInvitaciones({
    super.key,
    required this.idLider,
    required this.correoLider,
  });

  @override
  State<envioInvitaciones> createState() => _envioInvitacionesState();
}

class _envioInvitacionesState extends State<envioInvitaciones> {
  List<dynamic> _colaboradores = [];
  List<dynamic> _filtrados = [];
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarColaboradores();
  }

  Future<void> _cargarColaboradores() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/precolaboradores/${widget.correoLider}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _colaboradores = data;
        _filtrados = data;
      });
    } else {
      setState(() {
        _colaboradores = [];
        _filtrados = [];
      });
    }
  }


  void _filtrar(String query) {
    final resultado = _colaboradores.where((c) {
      final nombre = (c['nombre'] ?? '').toLowerCase();
      final email = (c['correo'] ?? '').toLowerCase();
      return nombre.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filtrados = resultado;
    });
  }

  void _enviarInvitaciones() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.102:8000/send-invitations/${widget.idLider}'),
      headers: {'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJsaWRlcjFAZXhhbXBsZS5jb20iLCJyb2wiOiJMSURFUiIsImV4cCI6MTc0OTAxMzc3M30.qxn8I8eQSpTXIAbn3tZGzmEX8Oj1ecJbmtfh695Q4NA'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invitaciones enviadas")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Lista de colaboradores',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lista de colaboradores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filtrar,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filtrados.isEmpty
                  ? const Center(child: Text("No hay colaboradores"))
                  : ListView.builder(
                itemCount: _filtrados.length,
                itemBuilder: (context, index) {
                  final colaborador = _filtrados[index];
                  return ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(colaborador['nombre']),
                    subtitle: Text(colaborador['correo']),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _enviarInvitaciones,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Enviar invitaciones', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

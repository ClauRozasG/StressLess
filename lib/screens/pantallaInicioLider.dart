import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaInicioLider extends StatefulWidget {
  final int idLider;

  const PantallaInicioLider({super.key, required this.idLider});

  @override
  State<PantallaInicioLider> createState() => _PantallaInicioLiderState();
}

class _PantallaInicioLiderState extends State<PantallaInicioLider> {
  List<dynamic> colaboradores = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarColaboradores();
  }

  Future<void> _cargarColaboradores() async {
    final url = Uri.parse('http://10.0.2.2:8000/leaders/${widget.idLider}/collaborators');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          colaboradores = jsonDecode(response.body);
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error cargando colaboradores: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cargar colaboradores")),
      );
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
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F5DC),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Center(child: Icon(Icons.menu, size: 40)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bienvenido líder',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tus colaboradores',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            const SizedBox(height: 20),
            Expanded(
              child: colaboradores.isEmpty
                  ? const Text("No hay colaboradores registrados.")
                  : ListView.builder(
                itemCount: colaboradores.length,
                itemBuilder: (context, index) {
                  final colaborador = colaboradores[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(colaborador['nombre']),
                      subtitle: Text(colaborador['correo']),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Ir a historial o detalle del colaborador
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

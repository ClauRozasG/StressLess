import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaHistorialColaboradores.dart';
import 'initialLoginLider.dart';

class PantallaInicioLider extends StatefulWidget {
  final int idLider;

  const PantallaInicioLider({super.key, required this.idLider});

  @override
  State<PantallaInicioLider> createState() => _PantallaInicioLiderState();
}

class _PantallaInicioLiderState extends State<PantallaInicioLider> {
  List<dynamic> colaboradores = [];
  bool cargando = true;
  Set<int> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarColaboradores();
  }

  Future<void> _cargarColaboradores() async {
    final url = Uri.parse('http://192.168.1.40:8000/leaders/${widget.idLider}/resumen-colaboradores');

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

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
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
            onPressed: () => Scaffold.of(context).openDrawer(),
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
            const DrawerHeader(child: Center(child: Icon(Icons.menu, size: 40))),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const initialLoginLider()),
                      (Route<dynamic> route) => false,
                );
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
                  final id = colaborador['colaborador_id'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: _seleccionados.contains(id),
                        onChanged: (bool? value) {
                          setState(() {
                            value == true
                                ? _seleccionados.add(id)
                                : _seleccionados.remove(id);
                          });
                        },
                      ),
                      title: Text(colaborador['nombre']),
                      subtitle: Text(colaborador['correo']),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (colaborador['estado'] == 'No registrado') {
                          _mostrarDialogo("Colaborador no registrado", "Este colaborador aún no ha creado su cuenta.");
                        } else if (colaborador['tiene_historial'] == false) {
                          _mostrarDialogo("Sin historial", "Este colaborador aún no tiene pruebas realizadas.");
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaHistorialColaborador(
                                colaboradorId: id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _seleccionados.isNotEmpty
                  ? () async {
                final url = Uri.parse("http://192.168.1.40:8000/enviar-invitaciones/");
                final response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "id_lider": widget.idLider,
                    "colaboradores_ids": _seleccionados.toList(),
                  }),

                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invitaciones enviadas correctamente")),
                  );
                  setState(() => _seleccionados.clear());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al enviar: ${response.body}")),
                  );
                }
              }
                  : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Enviar invitaciones"),
            ),
          ],
        ),
      ),
    );
  }
}

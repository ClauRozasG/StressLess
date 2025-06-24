import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantallaPrueba.dart';
import 'initialLoginLider.dart';
import 'loginColab.dart';
import 'pantallaHistorialColaboradores.dart';
import 'pantallaConfiguracionColaborador.dart';

class pantallaInicioColaborador extends StatelessWidget {
  final int idColaborador;
  final String nombreColaborador;

  const pantallaInicioColaborador({
    super.key,
    required this.idColaborador,
    required this.nombreColaborador,
  });

  Future<http.Response> _fetchPruebaPendiente() {
    return http.get(
      Uri.parse("http://192.168.1.40:8000/colaborador/$idColaborador/prueba-pendiente"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset('assets/images/menu.png', width: 30, height: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          FutureBuilder<http.Response>(
            future: _fetchPruebaPendiente(),
            builder: (context, snapshot) {
              bool hayPendiente = false;
              if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                final data = jsonDecode(snapshot.data!.body);
                hayPendiente = data["pendiente"] == true;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: Image.asset('assets/images/notification.png', width: 28, height: 28),
                    onPressed: () async {
                      if (hayPendiente) {
                        final data = jsonDecode(snapshot.data!.body);
                        final idNotificacion = data["id_notificacion"];
                        await http.put(
                          Uri.parse("http://192.168.1.40:8000/notificacion/$idNotificacion/leido"),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaInicioPrueba(
                              idColaborador: idColaborador,
                              nombre: nombreColaborador,
                              idPrueba: data["id_prueba"],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No tienes pruebas pendientes.")),
                        );
                      }
                    },
                  ),
                  if (hayPendiente)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F5DC),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF5F5DC)),
              child: SizedBox(),
            ),
            _buildDrawerItem(context, Icons.settings, 'Configuración', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaConfiguracionColaborador(
                    nombre: nombreColaborador,
                    idColaborador: idColaborador,
                  ),
                ),
              );
            }),
            _buildDrawerItem(context, Icons.history, 'Ver historial', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaHistorialColaborador(
                    colaboradorId: idColaborador,
                  ),
                ),
              );
            }),
            _buildDrawerItem(context, Icons.logout, 'Cerrar sesión', () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginColaboradorPage()),
                    (route) => false,
              );
            }),
          ],
        ),
      ),
      body: FutureBuilder<http.Response>(
        future: _fetchPruebaPendiente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.statusCode == 200) {
            final data = jsonDecode(snapshot.data!.body);
            if (data["pendiente"] == true) {
              final fechaEnvio = data["fecha_envio"];
              return Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaInicioPrueba(
                          idColaborador: idColaborador,
                          nombre: nombreColaborador,
                          idPrueba: data["id_prueba"],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFFF4B183),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🧠 Prueba pendiente',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '📅 Enviado: $fechaEnvio',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Toca esta tarjeta para comenzar la prueba',
                            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          return const Center(
            child: Text(
              'Aún no hay pruebas disponibles.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.black),
      ],
    );
  }
}

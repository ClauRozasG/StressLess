import 'package:flutter/material.dart';
import 'pantallaLecturaPrueba.dart';
import 'loginColab.dart';

class PantallaInicioPrueba extends StatelessWidget {
  final int idColaborador;
  final String nombre;
  final int idPrueba;

  const PantallaInicioPrueba({
    super.key,
    required this.idColaborador,
    required this.nombre,
    required this.idPrueba,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Fondo beige
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Acción de notificación (futuro)
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
              child: Center(
                child: Icon(Icons.menu, size: 40, color: Colors.black),
              ),
            ),
            _buildDrawerItem(context, Icons.settings, 'Configuración', () {
              // Navegar a configuración
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.history, 'Ver historial', () {
              // Navegar a historial
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.logout, 'Cerrar sesión', () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginColaboradorPage()),
                    (Route<dynamic> route) => false,
              );
            }),
          ],
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/stressless.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 40),
              const Text(
                'Tienes una prueba disponible.\n¿Te gustaría realizarla?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaLecturaPrueba(
                        idColaborador: idColaborador,
                        nombre: nombre,
                      ),
                    ),
                  );

                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text('Empezar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.black),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class pantallaInicioColaborador extends StatelessWidget {
  const pantallaInicioColaborador({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/images/menu.png',
              width: 30,
              height: 30,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // abrir el menú lateral
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Image.asset(
                'assets/images/notification.png',
                width: 28,
                height: 28,
              ),
              onPressed: () {
                // Acción para notificaciones
              },
            ),
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
            _buildDrawerItem(context, Icons.settings, 'Configuración', () {}),
            _buildDrawerItem(context, Icons.history, 'Ver historial', () {}),
            _buildDrawerItem(context, Icons.logout, 'Cerrar sesión', () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Image.asset(
              'assets/images/stressless.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Aún no hay pruebas disponibles.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
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

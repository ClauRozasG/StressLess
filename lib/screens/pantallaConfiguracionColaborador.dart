import 'package:flutter/material.dart';
import 'pantallaDatosColaborador.dart';
import 'pantallaCambiarContrasena.dart';

class PantallaConfiguracionColaborador extends StatelessWidget {
  final String nombre;
  final int idColaborador;

  const PantallaConfiguracionColaborador({
    super.key,
    required this.nombre,
    required this.idColaborador,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F5DC),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(child: SizedBox()),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // centra verticalmente
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _boton(context, 'Datos', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaDatosColaborador(idColaborador: idColaborador),
                ),
              );
            }),
            _boton(context, 'Cambiar contraseña', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaCambiarContrasena(idColaborador: idColaborador),
                ),
              );
            }),
            const SizedBox(height: 20),
            _boton(context, 'Atrás', () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _boton(BuildContext context, String texto, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(texto),
      ),
    );
  }
}

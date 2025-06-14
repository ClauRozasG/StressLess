import 'package:app_stressless/screens/pantallaPrueba.dart';
import 'package:flutter/material.dart';

class PantallaResultadoPrueba extends StatelessWidget {
  final bool esEstresado;
  final String fecha;
  final String archivoAudio;
  final int idColaborador;


  const PantallaResultadoPrueba({
    super.key,
    required this.esEstresado,
    required this.fecha,
    required this.archivoAudio,
    required this.idColaborador,
  });

  @override
  Widget build(BuildContext context) {
    final mensaje = esEstresado
        ? 'Parece que estás experimentando signos de estrés. Recuerda tomar una pausa o hacer ejercicios de respiración.'
        : 'Te encuentras en un estado estable. ¡Sigue así! No olvides darte tiempo para ti.';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/stressless.png',
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 30),
            Text(
              mensaje,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Último análisis: $fecha',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Archivo: $archivoAudio',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            if (esEstresado)
              ElevatedButton(
                onPressed: () {
                  // Navegar a recomendaciones
                },
                style: _estiloBoton(),
                child: const Text('Ver recomendaciones'),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar a historial
              },
              style: _estiloBoton(),
              child: const Text('Ver historial'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantallaInicioPrueba(idColaborador: idColaborador)),
                );
              },
              style: _estiloBoton(),
              child: const Text('Atrás'),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _estiloBoton() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.brown[400],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(color: Colors.white),
    );
  }
}

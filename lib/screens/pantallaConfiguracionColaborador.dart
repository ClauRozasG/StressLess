import 'package:flutter/material.dart';
import 'pantallaDatosColaborador.dart';
import 'pantallaCambiarContrasena.dart';
import 'package:app_stressless/constants.dart';

class PantallaConfiguracionColaborador extends StatelessWidget {
  final String nombre;
  final int idColaborador;

  const PantallaConfiguracionColaborador({
    super.key,
    required this.nombre,
    required this.idColaborador,
  });

  Color get _bg => const Color(0xFFF5F5DC);       // beige
  Color get _primary => const Color(0xFF8D6E63);  // café suave
  Color get _textDark => const Color(0xFF4E342E); // café oscuro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        title: Text(
          "Configuración",
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
      ),
      drawer: Drawer(
        backgroundColor: _bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(child: SizedBox()), // futuro menú
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Avatar + nombre
                CircleAvatar(
                  radius: 45,
                  backgroundColor: _primary.withOpacity(.2),
                  child: Icon(Icons.person, color: _primary, size: 50),
                ),
                const SizedBox(height: 14),
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Opciones
                _opcion(
                  context,
                  icon: Icons.info_outline,
                  label: "Datos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaDatosColaborador(idColaborador: idColaborador),
                      ),
                    );
                  },
                ),
                _opcion(
                  context,
                  icon: Icons.lock_outline,
                  label: "Cambiar contraseña",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaCambiarContrasena(idColaborador: idColaborador),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Atrás
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Atrás"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.brown.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _opcion(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: _primary),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

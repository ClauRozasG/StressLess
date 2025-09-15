import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 👈 necesario para el PUT
import 'pantallaLecturaPrueba.dart';
import 'loginColab.dart';import 'package:app_stressless/constants.dart';

class PantallaInicioPrueba extends StatelessWidget {
  final int idColaborador;
  final String nombre;
  final int idPrueba;
  final int? idNotificacion; // 👈 nuevo

  const PantallaInicioPrueba({
    super.key,
    required this.idColaborador,
    required this.nombre,
    required this.idPrueba,
    this.idNotificacion, // 👈 opcional
  });

  Color get _bg => const Color(0xFFF5F5DC);       // beige
  Color get _primary => const Color(0xFF8D6E63);  // café suave
  Color get _textDark => const Color(0xFF4E342E); // café texto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
            tooltip: 'Notificaciones',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: _primary.withOpacity(.1)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _primary.withOpacity(.2),
                    child: Icon(Icons.person, color: _primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _drawerItem(
              context,
              icon: Icons.settings_outlined,
              text: 'Configuración',
              onTap: () => Navigator.pop(context), // TODO: Navegar a config
            ),
            _drawerItem(
              context,
              icon: Icons.history,
              text: 'Ver historial',
              onTap: () => Navigator.pop(context), // TODO: Navegar a historial
            ),
            _drawerItem(
              context,
              icon: Icons.logout,
              text: 'Cerrar sesión',
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginColaboradorPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  const Icon(Icons.mic, size: 72, color: Colors.teal),
                  const SizedBox(height: 12),
                  Text(
                    'Tienes una prueba disponible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '¿Te gustaría realizarla ahora?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Bloque info: estimación + ambiente + privacidad
                  Material(
                    elevation: 1,
                    color: Colors.white,
                    shadowColor: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.timer_outlined,
                            title: 'Duración estimada',
                            subtitle: '1–2 minutos',
                            color: _primary,
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.noise_aware_outlined,
                            title: 'Ambiente recomendado',
                            subtitle: 'Lugar tranquilo y sin interrupciones',
                            color: _primary,
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacidad',
                            subtitle: 'Tu audio se usa sólo para esta evaluación',
                            color: _primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Pasos antes de empezar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Antes de comenzar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _StepTile(number: 1, text: 'Colócate en un ambiente silencioso.'),
                  const _StepTile(number: 2, text: 'Lee con voz natural, sin apuros.'),
                  const _StepTile(number: 3, text: 'Si te equivocas, puedes repetir.'),

                  const SizedBox(height: 24),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 1) Marca como leído/aceptado/”iniciado” en el backend
                        if (idNotificacion != null) {
                          try {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PantallaLecturaPrueba(
                                  idColaborador: idColaborador,
                                  nombre: nombre,
                                  idPrueba: idPrueba,
                                ),
                              ),
                            );
                          } catch (e) {
                            // opcional: mostrar un aviso, pero no bloquees al usuario
                          }
                        }

                        // 2) Ahora sí navega a la lectura (sin vuelta atrás a esta pantalla)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaLecturaPrueba(
                              idColaborador: idColaborador,
                              nombre: nombre,
                              idPrueba: idPrueba,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[400],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text(
                        'Empezar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ), // 👈 cierro el SizedBox del botón

                  const SizedBox(height: 10),

                  // Secundario
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.brown.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hacerla más tarde',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==== helpers ====

  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    final textDark = _textDark;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textDark),
          title: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
          onTap: onTap,
        ),
        Divider(height: 1, color: Colors.brown.shade200),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  )),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.brown.shade600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String text;

  const _StepTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF8D6E63).withOpacity(.15),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Color(0xFF8D6E63),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

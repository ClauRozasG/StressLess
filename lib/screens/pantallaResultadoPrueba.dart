import 'package:flutter/material.dart';
import 'loginColab.dart';
import 'pantallaInicioColaborador.dart';import 'package:app_stressless/constants.dart';

class PantallaResultadoPrueba extends StatelessWidget {
  final bool esEstresado;
  final String fecha;
  final String archivoAudio;
  final int idColaborador;
  final String nombre;

  const PantallaResultadoPrueba({
    super.key,
    required this.esEstresado,
    required this.fecha,
    required this.archivoAudio,
    required this.idColaborador,
    required this.nombre,
  });

  Color get _bg => const Color(0xFFF5F5DC);       // beige
  Color get _primary => const Color(0xFF8D6E63);  // café suave
  Color get _textDark => const Color(0xFF4E342E); // café texto

  @override
  Widget build(BuildContext context) {
    final Color estadoColor = esEstresado ? Colors.red : Colors.green;
    final Color chipBg = esEstresado ? Colors.red.shade50 : Colors.green.shade50;
    final String estadoTxt = esEstresado ? 'Estrés detectado' : 'Estado estable';
    final IconData estadoIcon = esEstresado ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

    final String mensaje = esEstresado
        ? 'Parece que presentas signos de estrés. Tómate una pausa, respira profundo y realiza actividades que te relajen.'
        : 'Te encuentras en un estado estable. ¡Sigue así! Mantén tus hábitos saludables y escucha a tu cuerpo.';

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
        title: Text(
          'Resultado de la prueba',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginColaboradorPage()),
                      (Route<dynamic> route) => false,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta principal de resultado
                  Material(
                    elevation: 1,
                    color: Colors.white,
                    shadowColor: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: chipBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(estadoIcon, color: estadoColor, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: chipBg,
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(color: estadoColor.withOpacity(.25)),
                                          ),
                                          child: Text(
                                            estadoTxt,
                                            style: TextStyle(
                                              color: estadoColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      mensaje,
                                      style: const TextStyle(fontSize: 15.5, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.brown.shade100, height: 1),
                          const SizedBox(height: 12),

                          // Detalles del análisis
                          Row(
                            children: [
                              const Icon(Icons.event, size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Último análisis: $fecha',
                                  style: TextStyle(color: Colors.brown.shade700, fontSize: 13.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.audio_file_outlined, size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Archivo: $archivoAudio',
                                  style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontSize: 13.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sugerencias según resultado
                  Text(
                    esEstresado ? '¿Qué puedes hacer ahora?' : 'Sigue cuidándote',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TipItem(
                    icon: Icons.self_improvement,
                    text: esEstresado
                        ? 'Respira 4-4-4: 4s inhalar, 4s sostener, 4s exhalar (x4).'
                        : 'Mantén pequeñas pausas activas durante el día.',
                    color: _primary,
                  ),
                  _TipItem(
                    icon: Icons.nightlight_round,
                    text: esEstresado
                        ? 'Toma 5 minutos lejos de pantallas y ruidos.'
                        : 'Cuida tu sueño y horarios regulares.',
                    color: _primary,
                  ),
                  _TipItem(
                    icon: Icons.task_alt,
                    text: esEstresado
                        ? 'Prioriza 1 tarea simple y termínala antes de seguir.'
                        : 'Planifica tu siguiente objetivo de forma realista.',
                    color: _primary,
                  ),

                  const SizedBox(height: 22),

                  // Botones
                  if (esEstresado)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navegar a recomendaciones detalladas
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.library_books_outlined),
                        label: const Text('Ver recomendaciones', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),

                  if (esEstresado) const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navegar a historial del colaborador si lo tienes a mano
                        // Por ahora, si no hay ruta aquí, puedes abrir la pantalla de historial desde el drawer principal.
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.brown.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.history),
                      label: Text(
                        'Ver historial',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => pantallaInicioColaborador(
                              idColaborador: idColaborador,
                              nombreColaborador: nombre,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.brown.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Volver al inicio',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w700,
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
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _TipItem({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

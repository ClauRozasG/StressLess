import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pantallaPrueba.dart';
import 'loginColab.dart';
import 'pantallaHistorialColaboradores.dart';
import 'pantallaConfiguracionColaborador.dart';import 'package:app_stressless/constants.dart';

class pantallaInicioColaborador extends StatefulWidget {
  final int idColaborador;
  final String nombreColaborador;

  const pantallaInicioColaborador({
    super.key,
    required this.idColaborador,
    required this.nombreColaborador,
  });

  @override
  State<pantallaInicioColaborador> createState() => _pantallaInicioColaboradorState();
}

class _pantallaInicioColaboradorState extends State<pantallaInicioColaborador> {
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E);
  int _totalPendientes = 0;// café texto

  Map<String, dynamic>? _pendiente; // {pendiente: bool, id_prueba, fecha_envio, id_notificacion}
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendiente();
    _loadPendientesCount();
  }

  Future<void> _loadPendientesCount() async {
    try {
      final resp = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/colaborador/${widget.idColaborador}/pruebas-pendientes"),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _totalPendientes = data["total"] ?? 0; // crea un int _totalPendientes en tu State
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPendiente() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/colaborador/${widget.idColaborador}/prueba-pendiente"),
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _pendiente = data;
          _loading = false;
        });
      } else {
        setState(() {
          _pendiente = {"pendiente": false};
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendiente = {"pendiente": false};
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar notificaciones: $e")),
      );
    }
  }


  String _fmt(String iso) {
    try {
      final d = DateTime.parse(iso);
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yyyy = d.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _abrirPruebaPendiente() async {
    final data = _pendiente ?? {};
    if (data["pendiente"] == true) {
      final int? idNotificacion = (data["id_notificacion"] as num?)?.toInt();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaInicioPrueba(
            idColaborador: widget.idColaborador,
            nombre: widget.nombreColaborador,
            idPrueba: data["id_prueba"],
            idNotificacion: idNotificacion, // 👈 pásalo
          ),
        ),
      ).then((_) => _loadPendiente()); // al volver, refresca del backend
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes pruebas pendientes.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool hayPendiente = (_pendiente?["pendiente"] == true);

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
            tooltip: 'Menú',
          ),
        ),
        title: Text(
          "Hola, ${widget.nombreColaborador.split(' ').first} 👋",
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none),
                if (hayPendiente)
                  Positioned(
                    right: -1,
                    top: -1,
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
            ),
            tooltip: 'Notificaciones',
            onPressed: _abrirPruebaPendiente,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _loadPendiente,
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
                      widget.nombreColaborador,
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
            _buildDrawerItem(
              context,
              Icons.settings,
              'Configuración',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaConfiguracionColaborador(
                      nombre: widget.nombreColaborador,
                      idColaborador: widget.idColaborador,
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.history,
              'Ver historial',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaHistorialColaborador(
                      colaboradorId: widget.idColaborador,
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.logout,
              'Cerrar sesión',
                  () {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPendiente,
        color: _primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            // Encabezado de bienvenida
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.mic, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu espacio de bienestar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          )),
                      Text('Toma tus pruebas y revisa tu avance',
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 13.5,
                          )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tarjeta principal (pendiente o estado vacío)
            if (hayPendiente)
              _CardPendiente(
                primary: _primary,
                textDark: _textDark,
                fechaEnvio: _fmt(_pendiente?["fecha"] ?? ''),
                onTap: _abrirPruebaPendiente,
              )
            else
              _CardVacio(primary: _primary),

            const SizedBox(height: 16),

            // Accesos rápidos
            Text('Accesos rápidos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown.shade700,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Historial',
                    color: _primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaHistorialColaborador(
                            colaboradorId: widget.idColaborador,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    color: _primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaConfiguracionColaborador(
                            nombre: widget.nombreColaborador,
                            idColaborador: widget.idColaborador,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String text,
      VoidCallback onTap,
      ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: _textDark),
          title: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w700, color: _textDark),
          ),
          onTap: onTap,
        ),
        Divider(height: 1, color: Colors.brown.shade200),
      ],
    );
  }
}

class _CardPendiente extends StatelessWidget {
  final Color primary;
  final Color textDark;
  final String fechaEnvio;
  final VoidCallback onTap;

  const _CardPendiente({
    required this.primary,
    required this.textDark,
    required this.fechaEnvio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.brown.shade100,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.pending_actions, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prueba pendiente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        )),
                    const SizedBox(height: 4),
                    Text('Enviado: $fechaEnvio',
                        style: TextStyle(
                          color: Colors.brown.shade600,
                          fontSize: 13.5,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      'Toca para comenzar la prueba ahora',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.brown.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.brown.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardVacio extends StatelessWidget {
  final Color primary;

  const _CardVacio({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: primary.withOpacity(.08),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.mood, color: primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aún no hay pruebas disponibles.\nTe avisaremos cuando tengas una nueva.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.brown.shade100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF4E342E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.brown.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

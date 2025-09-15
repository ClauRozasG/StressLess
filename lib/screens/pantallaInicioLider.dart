import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_stressless/screens/pantallaNotisLider..dart';
import '../services/liderNotis.dart';
import 'pantallaHistorialColaboradores.dart';
import 'initialLoginLider.dart';
import 'package:app_stressless/constants.dart';
import 'package:app_stressless/api_client.dart';

class PantallaInicioLider extends StatefulWidget {
  final int idLider;

  const PantallaInicioLider({super.key, required this.idLider});


  @override
  State<PantallaInicioLider> createState() => _PantallaInicioLiderState();
}

class _PantallaInicioLiderState extends State<PantallaInicioLider> {
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E); // café texto

  List<dynamic> colaboradores = [];
  bool cargando = true;
  final Set<int> _seleccionados = <int>{}; // solo ids válidos (no null)
  int _unread = 0;
  Future<void> _loadLeaderNotis() async {
    try {
      final list = await LiderNotifApi.listar(widget.idLider);
      setState(() => _unread = list.where((n) => n['leido'] == false).length);
    } catch (_) {}
  }
  @override
  void initState() {
    super.initState();
    _cargarColaboradores();
    _loadLeaderNotis();
  }

  // FIX: parseo seguro para IDs (acepta int, double, String o null)
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  Future<void> _cargarColaboradores() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/leaders/${widget.idLider}/resumen-colaboradores');
    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          colaboradores = jsonDecode(response.body);
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Error cargando colaboradores: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cargar colaboradores")),
      );
      setState(() => cargando = false);
    }
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
        ],
      ),
    );
  }

  String _iniciales(String nombre) {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first.characters.first : '';
    final b = parts.length > 1 ? parts.last.characters.first : '';
    return (a + b).toUpperCase();
  }

  // —— Nuevo: abrir pop-up de calendario (7 días + horas) ——
  void _openCalendarBottomSheet() {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos un colaborador")),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CalendarQueueSheet(
        primary: _primary,
        textDark: _textDark,
        colaboradoresIds: _seleccionados.toList(),
        onQueued: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pruebas programadas"),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Si quieres limpiar la selección después:
          // setState(() => _seleccionados.clear());
        },
      ),
    );
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: _cargarColaboradores,
            tooltip: 'Actualizar',
          ),
          // ❌ quitamos el "actions: [ ... ]" anidado
          IconButton(
            tooltip: 'Alertas de estrés',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaNotifsLider(idLider: widget.idLider),
                ),
              );
              if (updated == true) _loadLeaderNotis();
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (_unread > 0)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
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
                    child: Icon(Icons.verified_user, color: _primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text('Menú',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      )),
                ],
              ),
            ),
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
          : RefreshIndicator(
        onRefresh: _cargarColaboradores,
        color: _primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.groups_2, color: _primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bienvenido líder',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  )),
                              Text('Gestiona y acompaña a tu equipo',
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
                    Text('Tus colaboradores',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            if (colaboradores.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 56, color: Colors.brown.shade300),
                      const SizedBox(height: 8),
                      Text('No hay colaboradores registrados.',
                          style: TextStyle(color: Colors.brown.shade600)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: SliverList.separated(
                  itemCount: colaboradores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = colaboradores[index];

                    // FIX: obtener id de forma robusta sin crashear
                    final int? id = _toInt(c['colaborador_id']) ??
                        _toInt(c['id_colaborador']) ??
                        _toInt(c['idColaborador']) ??
                        _toInt(c['id']) ??
                        _toInt(c['colabId']);

                    final nombre = (c['nombre'] ?? '').toString();
                    final correo = (c['correo'] ?? '').toString();
                    final estado = (c['estado'] ?? '').toString();
                    final tieneHistorial = c['tiene_historial'] == true;

                    final selected = id != null && _seleccionados.contains(id);
                    final puedeSeleccionar = id != null;

                    return Material(
                      elevation: 2,
                      shadowColor: Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (id == null || estado == 'No registrado') {
                            _mostrarDialogo(
                              "Colaborador no registrado",
                              "Este colaborador aún no ha creado su cuenta.",
                            );
                          } else if (!tieneHistorial) {
                            _mostrarDialogo(
                              "Sin historial",
                              "Este colaborador aún no tiene pruebas realizadas.",
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PantallaHistorialColaborador(colaboradorId: id),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selected,
                                onChanged: puedeSeleccionar
                                    ? (v) {
                                  setState(() {
                                    if (v == true && id != null) {
                                      _seleccionados.add(id);
                                    } else if (id != null) {
                                      _seleccionados.remove(id);
                                    }
                                  });
                                }
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                activeColor: _primary,
                              ),
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _primary.withOpacity(.15),
                                child: Text(
                                  _iniciales(nombre),
                                  style: TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre.isNotEmpty ? nombre : (id != null ? "Colaborador #$id" : "Colaborador"),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      correo,
                                      style: TextStyle(
                                        color: Colors.brown.shade600,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: -6,
                                      children: [
                                        _Badge(
                                          label: estado == 'No registrado' ? 'Pendiente' : 'Registrado',
                                          color: estado == 'No registrado' ? Colors.orange : Colors.green,
                                        ),
                                        _Badge(
                                          label: tieneHistorial ? 'Con historial' : 'Sin historial',
                                          color: tieneHistorial ? Colors.blue : Colors.grey,
                                        ),
                                      ],
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
                  },
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),

      // Botón inferior fijo → abre el pop-up de calendario
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _seleccionados.isNotEmpty ? _openCalendarBottomSheet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
            ),
            child: const Text("Enviar pruebas de estrés", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// —— Badge sencillo ——
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =================== POP-UP: Calendario simple (7 días) + horas ===================

class _CalendarQueueSheet extends StatefulWidget {
  final Color primary;
  final Color textDark;
  final List<int> colaboradoresIds;
  final VoidCallback onQueued;

  const _CalendarQueueSheet({
    required this.primary,
    required this.textDark,
    required this.colaboradoresIds,
    required this.onQueued,
  });

  @override
  State<_CalendarQueueSheet> createState() => _CalendarQueueSheetState();
}

class _CalendarQueueSheetState extends State<_CalendarQueueSheet> {
  final String _tz = "America/Lima"; // fijo por ahora
  final Set<DateTime> _selectedDates = {}; // solo fecha (Y-M-D)
  final List<TimeOfDay> _times = [];       // puedes añadir varias horas
  bool _loading = false;

  List<DateTime> get _next7 {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      return d;
    });
  }

  String _weekdayShort(DateTime d) {
    const labels = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    return labels[d.weekday == 7 ? 6 : d.weekday - 1];
  }

  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}";

  String _fmtTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";

  Future<void> _pickTime() async {
    final sel = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (sel != null && !_times.any((t) => t.hour == sel.hour && t.minute == sel.minute)) {
      setState(() => _times.add(sel));
    }
  }

  Future<void> _submit() async {
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Selecciona al menos un día"), backgroundColor: Colors.red.shade700),
      );
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Añade al menos una hora"), backgroundColor: Colors.red.shade700),
      );
      return;
    }

    // Construimos slots (fecha + hora): cartésiano (días × horas)
    final List<Map<String, String>> slots = [];
    for (final d in _selectedDates) {
      final yyyy = d.year.toString().padLeft(4, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      final fecha = "$yyyy-$mm-$dd";
      for (final t in _times) {
        slots.add({"fecha": fecha, "hora": _fmtTime(t)});
      }
    }

    setState(() => _loading = true);
    try {
      final res = await ApiClient.post(
        "/calendar/queue",
        {
          "timezone": _tz,
          "colaboradores_ids": widget.colaboradoresIds,
          "slots": slots,
        },
      );

      if (!mounted) return;
      if (res.statusCode == 200) {
        widget.onQueued();
      } else {
        print("⛔ /calendar/queue status: ${res.statusCode}");
        print("⛔ /calendar/queue body: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error ${res.statusCode}: ${res.body}"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print("💥 /calendar/queue exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excepción: $e"), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, inset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(color: Colors.brown.shade200, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.event, color: widget.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Programar (hasta 7 días)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: widget.textDark),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),

            const SizedBox(height: 10),
            Text("Días (próx. 7)", style: TextStyle(color: widget.textDark, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _next7.map((d) {
                final selected = _selectedDates.any((x) => x.year==d.year && x.month==d.month && x.day==d.day);
                return ChoiceChip(
                  selected: selected,
                  label: Text("${_weekdayShort(d)} ${_fmtDate(d)}"),
                  selectedColor: widget.primary.withOpacity(.2),
                  labelStyle: TextStyle(
                    color: selected ? widget.textDark : Colors.brown.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) {
                    setState(() {
                      final key = DateTime(d.year, d.month, d.day);
                      if (selected) {
                        _selectedDates.removeWhere((x) => x.year==key.year && x.month==key.month && x.day==key.day);
                      } else {
                        _selectedDates.add(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),
            Text("Horas", style: TextStyle(color: widget.textDark, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (_times.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.primary.withOpacity(.2)),
                ),
                child: Text("Aún no has agregado horas", style: TextStyle(color: Colors.brown.shade700)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: -6,
                children: _times.map((t) => Chip(
                  label: Text(_fmtTime(t), style: const TextStyle(fontWeight: FontWeight.w800)),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => setState(() => _times.remove(t)),
                  backgroundColor: widget.primary.withOpacity(.12),
                )).toList(),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: const Text("Añadir hora"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.brown.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Programar", style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

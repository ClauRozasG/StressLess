import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_stressless/api_client.dart'; // <- usa ApiClient para NO escribir Bearer
import 'package:app_stressless/constants.dart'; // si usas baseUrl aquí para otras cosas

class envioInvitaciones extends StatefulWidget {
  final int idLider;
  final String correoLider;

  const envioInvitaciones({
    super.key,
    required this.idLider,
    required this.correoLider,
  });

  @override
  State<envioInvitaciones> createState() => _envioInvitacionesState();
}

class _envioInvitacionesState extends State<envioInvitaciones> {
  // Paleta café & beige que vienes usando
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café
  final Color _textDark = const Color(0xFF4E342E); // café oscuro

  final TextEditingController _busquedaController = TextEditingController();

  List<dynamic> _colaboradores = [];
  List<dynamic> _filtrados = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _cargarColaboradores();
    _busquedaController.addListener(() => _filtrar(_busquedaController.text));
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarColaboradores() async {
    setState(() => _loading = true);
    try {
      // 💡 Usa ApiClient: si hay token, añade Authorization automáticamente
      final res = await ApiClient.get("/precolaboradores/${widget.correoLider}");
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _colaboradores = (data is List) ? data : [];
          _filtrados = _colaboradores;
          _loading = false;
        });
      } else {
        setState(() {
          _colaboradores = [];
          _filtrados = [];
          _loading = false;
        });
        _snack("No se pudo cargar (${res.statusCode})", error: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _colaboradores = [];
        _filtrados = [];
        _loading = false;
      });
      _snack("Error de red: $e", error: true);
    }
  }

  void _filtrar(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtrados = _colaboradores);
      return;
    }
    final resultado = _colaboradores.where((c) {
      final nombre = (c['nombre'] ?? '').toString().toLowerCase();
      final email  = (c['correo'] ?? '').toString().toLowerCase();
      return nombre.contains(q) || email.contains(q);
    }).toList();
    setState(() => _filtrados = resultado);
  }

  Future<void> _enviarInvitaciones() async {
    setState(() => _sending = true);
    try {
      // 💡 MISMO ENDPOINT que ya usas, sin escribir Bearer a mano
      final res = await ApiClient.post("/send-invitations/${widget.idLider}", {});
      if (!mounted) return;

      if (res.statusCode == 200) {
        _snack("Invitaciones enviadas");
      } else {
        _snack("Error: ${res.statusCode}", error: true);
      }
    } catch (e) {
      _snack("Error de red: $e", error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade600,
      ),
    );
  }

  String _iniciales(String nombre) {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first.characters.first : '';
    final b = parts.length > 1 ? parts.last.characters.first : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final count = _filtrados.length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        title: Text('Lista de colaboradores', style: TextStyle(color: _textDark, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar",
            onPressed: _cargarColaboradores,
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _cargarColaboradores,
        color: _primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          children: [
            // Header con buscador + contador
            Material(
              elevation: 1,
              color: Colors.white,
              shadowColor: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.groups_2, color: _primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Colaboradores pre-registrados",
                            style: TextStyle(
                              color: _textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(.08),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: _primary.withOpacity(.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.list_alt, size: 16, color: _primary),
                              const SizedBox(width: 6),
                              Text("$count",
                                  style: TextStyle(
                                    color: _textDark,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _busquedaController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o email',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.brown.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _primary, width: 1.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Lista / estado vacío
            if (_filtrados.isEmpty)
              Container(
                height: 280,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primary.withOpacity(.15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 56, color: Colors.brown.shade300),
                    const SizedBox(height: 8),
                    Text('No hay colaboradores', style: TextStyle(color: Colors.brown.shade600)),
                  ],
                ),
              )
            else
              ..._filtrados.map((c) {
                final nombre = (c['nombre'] ?? '').toString();
                final correo = (c['correo'] ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    elevation: 2,
                    shadowColor: Colors.brown.shade100,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      leading: CircleAvatar(
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
                      title: Text(
                        nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      subtitle: Text(
                        correo,
                        style: TextStyle(color: Colors.brown.shade600),
                      ),
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 88),
          ],
        ),
      ),

      // CTA fija: Enviar invitaciones
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sending ? null : _enviarInvitaciones,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 3,
            ),
            child: _sending
                ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text("Enviar invitaciones", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

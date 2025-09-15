import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';import 'package:app_stressless/constants.dart';

class PantallaDatosColaborador extends StatefulWidget {
  final int idColaborador;

  const PantallaDatosColaborador({super.key, required this.idColaborador});

  @override
  State<PantallaDatosColaborador> createState() => _PantallaDatosColaboradorState();
}

class _PantallaDatosColaboradorState extends State<PantallaDatosColaborador> {
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E); // café texto

  String nombreLider = '';
  String correo = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);
    final url = Uri.parse("${ApiConfig.baseUrl}/colaborador/${widget.idColaborador}/datos");
    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nombreLider = (data['nombre_lider'] ?? '').toString();
          correo = (data['correo'] ?? '').toString();
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudieron cargar los datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        title: Text(
          "Datos del colaborador",
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _cargarDatos,
        color: _primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            // Tarjeta de perfil
            Material(
              elevation: 1,
              color: Colors.white,
              shadowColor: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _primary.withOpacity(.18),
                      child: Icon(Icons.person, color: _primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            correo.isEmpty ? '—' : correo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cuenta vinculada',
                            style: TextStyle(
                              color: Colors.brown.shade600,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sección de datos
            Text(
              'Datos de cuenta',
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            _CampoLectura(
              icon: Icons.emoji_people_outlined,
              label: 'Nombre del líder',
              value: nombreLider.isEmpty ? '—' : nombreLider,
              primary: _primary,
            ),
            const SizedBox(height: 10),
            _CampoLectura(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: correo.isEmpty ? '—' : correo,
              primary: _primary,
            ),

            const SizedBox(height: 22),

            // Botón atrás
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.brown.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Atrás',
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
    );
  }
}

class _CampoLectura extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;

  const _CampoLectura({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.brown.shade200, width: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            )),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: primary, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

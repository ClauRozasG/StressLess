import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';import 'package:app_stressless/constants.dart';

class PantallaHistorialColaborador extends StatefulWidget {
  final int colaboradorId;

  const PantallaHistorialColaborador({super.key, required this.colaboradorId});

  @override
  State<PantallaHistorialColaborador> createState() => _PantallaHistorialColaboradorState();
}

class _PantallaHistorialColaboradorState extends State<PantallaHistorialColaborador> {
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E); // café texto

  List<dynamic> historial = [];
  bool cargando = true;
  bool _verTodo = false;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/historial/${widget.colaboradorId}');
    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final datos = jsonDecode(response.body);

        // Ordenar desc por fecha
        datos.sort((a, b) => DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));

        setState(() {
          historial = datos;
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Error al cargar historial: $e");
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo cargar el historial")),
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

  @override
  Widget build(BuildContext context) {
    final datosMostrados = _verTodo
        ? historial
        : historial.length > 5
        ? historial.sublist(0, 5)
        : historial;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        title: Text(
          "Historial de resultados",
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarHistorial,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.brown.shade300),
            const SizedBox(height: 8),
            Text('Este colaborador aún no tiene historial.',
                style: TextStyle(color: Colors.brown.shade600)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _cargarHistorial,
        color: _primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            // Encabezado lindo
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.assignment_turned_in, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resultados de pruebas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          )),
                      Text('Fechas y estado de cada evaluación',
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 13.5,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contenedor de la tabla con borde redondeado
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.brown.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    // ancho mínimo para que columnas respiren en pantallas angostas
                    constraints: const BoxConstraints(minWidth: 560),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(56), // #
                        1: FlexColumnWidth(2),  // Fecha
                        2: FlexColumnWidth(3),  // Resultado
                        3: FixedColumnWidth(56), // icono
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.brown.shade100, width: 1),
                      ),
                      children: [
                        // Header
                        TableRow(
                          decoration: BoxDecoration(color: const Color(0xFFD7CCC8)),
                          children: const [
                            _CellHeader('#'),
                            _CellHeader('Fecha'),
                            _CellHeader('Resultado'),
                            _CellHeader(''),
                          ],
                        ),
                        // Filas
                        ...List.generate(datosMostrados.length, (index) {
                          final prueba = datosMostrados[index];
                          final resultado = (prueba['resultado'] ?? '').toString();
                          final fecha = (prueba['fecha'] ?? '').toString();
                          final esEstresado = resultado == "Estresado";

                          final Color rowBg = esEstresado
                              ? Colors.red.shade50
                              : Colors.green.shade50;
                          final Color resColor = esEstresado
                              ? Colors.red
                              : Colors.green.shade800;

                          return TableRow(
                            decoration: BoxDecoration(color: rowBg),
                            children: [
                              _CellBody(Text('${index + 1}')),
                              _CellBody(Text(_fmt(fecha))),
                              _CellBody(Text(
                                resultado,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: resColor,
                                ),
                              )),
                              _CellBody(Icon(
                                esEstresado ? Icons.close : Icons.check,
                                color: esEstresado ? Colors.red : Colors.green,
                              )),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (historial.length > 5)
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _verTodo = !_verTodo),
                  icon: Icon(_verTodo ? Icons.arrow_upward : Icons.arrow_downward),
                  label: Text(_verTodo ? "Ver menos" : "Ver todo"),
                  style: TextButton.styleFrom(
                    foregroundColor: _primary,
                  ),
                ),
              ),

            const SizedBox(height: 10),

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

class _CellHeader extends StatelessWidget {
  final String text;
  const _CellHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CellBody extends StatelessWidget {
  final Widget child;
  const _CellBody(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 14, height: 1.2, color: Colors.black87),
        child: child,
      ),
    );
  }
}

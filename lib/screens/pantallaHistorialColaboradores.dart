import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaHistorialColaborador extends StatefulWidget {
  final int colaboradorId;

  const PantallaHistorialColaborador({super.key, required this.colaboradorId});

  @override
  State<PantallaHistorialColaborador> createState() => _PantallaHistorialColaboradorState();
}

class _PantallaHistorialColaboradorState extends State<PantallaHistorialColaborador> {
  List<dynamic> historial = [];
  bool cargando = true;
  bool _verTodo = false;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final url = Uri.parse('http://192.168.1.40:8000/historial/${widget.colaboradorId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final datos = jsonDecode(response.body);

        datos.sort((a, b) =>
            DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));

        setState(() {
          historial = datos;
          cargando = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error al cargar historial: $e");
      setState(() => cargando = false);
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
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text("Historial de resultados"),
        backgroundColor: Colors.brown[400],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
          ? const Center(child: Text("Este colaborador aún no tiene historial."))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FixedColumnWidth(40),
              },
              border: TableBorder.all(color: Colors.brown),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFD7CCC8)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("#", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Resultado", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("\u2713", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...List.generate(datosMostrados.length, (index) {
                  final prueba = datosMostrados[index];
                  final resultado = prueba['resultado'];
                  final fecha = prueba['fecha'];
                  final esEstresado = resultado == "Estresado";

                  return TableRow(
                    decoration: BoxDecoration(
                      color: esEstresado ? Colors.red[50] : Colors.green[50],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("${index + 1}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(fecha),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          resultado,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: esEstresado ? Colors.red : Colors.green[800],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          esEstresado ? Icons.close : Icons.check,
                          color: esEstresado ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          if (historial.length > 5)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _verTodo = !_verTodo;
                });
              },
              icon: Icon(_verTodo ? Icons.arrow_upward : Icons.arrow_downward),
              label: Text(_verTodo ? "Ver menos" : "Ver todo"),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Atrás"),
            ),
          ),
        ],
      ),
    );
  }
}
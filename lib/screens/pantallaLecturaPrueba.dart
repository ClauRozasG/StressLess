import 'package:app_stressless/screens/pantallaResultadoPrueba.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaLecturaPrueba extends StatefulWidget {
  final int idColaborador;

  const PantallaLecturaPrueba({super.key, required this.idColaborador});

  @override
  State<PantallaLecturaPrueba> createState() => _PantallaLecturaPruebaState();
}


class _PantallaLecturaPruebaState extends State<PantallaLecturaPrueba> {
  bool _grabando = false;
  final AudioRecorder _record = AudioRecorder();

  Future<void> _toggleGrabacion() async {
    if (!_grabando) {
      final hasPermission = await _record.hasPermission();
      if (!hasPermission) return;

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/grabacion.wav';

      await _record.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );

      setState(() => _grabando = true);
    } else {
      final path = await _record.stop();
      setState(() => _grabando = false);

      debugPrint('🎙️ Archivo guardado en: $path');

      final uri = Uri.parse('http://192.168.1.102:8000/predecir/');
      final request = http.MultipartRequest('POST', uri);
      request.fields['id_colaborador'] = widget.idColaborador.toString();
      request.files.add(await http.MultipartFile.fromPath('audio', path!));



      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final bodyJson = jsonDecode(responseBody);

        final resultado = bodyJson['resultado'];
        final fecha = bodyJson['fecha'];
        final archivo = bodyJson['archivo'];

        debugPrint('✅ Resultado: $resultado');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultadoPrueba(
              esEstresado: resultado == "Estresado",
              fecha: fecha,
              archivoAudio: archivo,
                idColaborador: widget.idColaborador,
            ),
          ),
        );
      } else {
        debugPrint('❌ Error al enviar audio: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el audio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Text(
              'Lee el siguiente texto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Ha sido un día con varias actividades. '
                      'Me siento satisfecho con lo que logré, '
                      'aunque hubo momentos de tensión. '
                      'Agradezco poder descansar ahora.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_grabando)
              const Text(
                'Grabando...',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleGrabacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: Icon(
                Icons.mic,
                color: _grabando ? Colors.red[100] : Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

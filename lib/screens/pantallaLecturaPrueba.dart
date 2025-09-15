import 'package:app_stressless/screens/pantallaResultadoPrueba.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';import 'package:app_stressless/constants.dart';

class PantallaLecturaPrueba extends StatefulWidget {
  final int idColaborador;
  final String nombre;
  final int idPrueba;

  const PantallaLecturaPrueba({
    super.key,
    required this.idColaborador,
    required this.nombre,
    required this.idPrueba,
  });

  @override
  State<PantallaLecturaPrueba> createState() => _PantallaLecturaPruebaState();
}

class _PantallaLecturaPruebaState extends State<PantallaLecturaPrueba> {
  // 🎨 Paleta
  final Color _bg = const Color(0xFFF5F5DC);       // beige
  final Color _primary = const Color(0xFF8D6E63);  // café suave
  final Color _textDark = const Color(0xFF4E342E); // café texto

  bool _grabando = false;
  final AudioRecorder _record = AudioRecorder();

  // 🔤 Banco de textos
  final List<String> _textos = [
    "Hoy es un día soleado y el cielo está despejado. Salí de casa temprano para llegar puntual al trabajo.",
    "El café de la mañana me ayuda a concentrarme en mis tareas y organizar mejor mi tiempo.",
    "En la oficina todos conversaban sobre el nuevo proyecto y los cambios en el equipo.",
    "El transporte público estuvo lleno, pero finalmente llegué sin retrasos a la reunión.",
    "Cada día trato de equilibrar mis responsabilidades con momentos de descanso y relajación.",
    "El trabajo en equipo requiere comunicación clara y confianza entre los compañeros.",
    "Planificar mis actividades me permite reducir el estrés y cumplir con los plazos establecidos.",
    "Una buena gestión del tiempo influye en la productividad y en el bienestar emocional.",
    "El liderazgo positivo fomenta la motivación y la creatividad de los colaboradores.",
    "Reconocer los logros de los demás genera un ambiente laboral más saludable.",
    "En el informe se registraron treinta y cinco actividades completadas en solo dos semanas.",
    "El proyecto comenzó el tres de marzo y finalizó el veinte de junio con excelentes resultados.",
    "Cada trabajador dedica al menos cuarenta horas semanales a sus responsabilidades.",
    "El número de participantes aumentó de quince a veintidós en menos de un mes.",
    "La encuesta reveló que siete de cada diez empleados sienten la necesidad de mayor apoyo.",
    "Respirar profundamente me ayuda a recuperar la calma en momentos de tensión.",
    "Recordar mis objetivos me motiva a superar los desafíos de la jornada.",
    "Cada esfuerzo cuenta y contribuye al crecimiento personal y profesional.",
    "Mantener un balance entre trabajo y descanso es clave para la salud.",
    "Cuidar de mí mismo me permite rendir mejor en el ámbito laboral."
  ];
  late String _textoSeleccionado;

  // 🎚️ Amplitud / visualización
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> _niveles = <double>[]; // valores normalizados 0..1
  double _dbActual = -160; // dB aproximados
  double _dbMax = -160;
  static const int _maxMuestras = 120; // ~12s a 100ms

  // ⏱️ Tiempo
  DateTime? _inicio;
  String get _elapsed {
    if (_inicio == null || !_grabando) return "00:00";
    final d = DateTime.now().difference(_inicio!);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _textoSeleccionado = _textos[Random().nextInt(_textos.length)];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ampSub?.cancel();
    _record.dispose();
    super.dispose();
  }

  Future<void> _toggleGrabacion() async {
    if (!_grabando) {
      final hasPermission = await _record.hasPermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de micrófono denegado')),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/grabacion.wav';

      await _record.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );

      // ⏱️ Ticker de UI
      _inicio = DateTime.now();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {}); // solo para actualizar el cronómetro
      });

      // 🎚️ stream de amplitud cada 100ms
      _ampSub?.cancel();
      _ampSub = _record
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amp) {
        // La API reporta dB (aprox -160..0). Normalizamos a 0..1
        final db = amp.current; // puede ser negativo
        final norm = _mapDbToUnit(db);
        if (_niveles.length >= _maxMuestras) {
          _niveles.removeAt(0);
        }
        _niveles.add(norm);
        _dbActual = db;
        _dbMax = max(_dbMax, db);
        if (mounted) setState(() {});
      });

      setState(() => _grabando = true);
    } else {
      final path = await _record.stop();
      _ticker?.cancel();
      _ampSub?.cancel();
      setState(() => _grabando = false);

      if (path == null) return;
      debugPrint('🎙️ Archivo guardado en: $path');

      // Enviar al backend
      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}/predecir/');
        final request = http.MultipartRequest('POST', uri);
        request.fields['id_colaborador'] = widget.idColaborador.toString();
        request.files.add(await http.MultipartFile.fromPath('audio', path));
        request.fields['id_prueba'] = widget.idPrueba.toString();

        final response = await request.send();
        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final bodyJson = jsonDecode(responseBody);

          final resultado = bodyJson['resultado'];
          final fecha = bodyJson['fecha'];
          final archivo = bodyJson['archivo'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaResultadoPrueba(
                esEstresado: resultado == "Estresado",
                fecha: fecha,
                archivoAudio: archivo,
                idColaborador: widget.idColaborador,
                nombre: widget.nombre,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar el audio: ${response.statusCode}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red: $e')),
        );
      }
    }
  }

  double _mapDbToUnit(double db) {
    // db suele ir de ~ -160 (silencio) a 0 (muy fuerte)
    // Normalizamos: -60 dB => 0.0 | 0 dB => 1.0 (clamp)
    final clamped = db.clamp(-60.0, 0.0);
    return (clamped + 60.0) / 60.0;
  }

  Color _levelColor(double norm) {
    if (norm < 0.25) return Colors.green;
    if (norm < 0.6) return Colors.orange;
    return Colors.red;
  }

  void _cambiarTexto() {
    final otros = _textos.where((t) => t != _textoSeleccionado).toList();
    setState(() {
      _textoSeleccionado = otros[Random().nextInt(otros.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final nivel = _niveles.isNotEmpty ? _niveles.last : 0.0;
    final nivelColor = _levelColor(nivel);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _textDark),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.menu_book, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lee el siguiente texto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          )),
                      Text('Mantén una voz natural y constante',
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 13.5,
                          )),
                    ],
                  ),
                ),
                Text(
                  _elapsed,
                  style: TextStyle(
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Texto a leer
            Material(
              elevation: 1,
              shadowColor: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _textoSeleccionado,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _grabando ? null : _cambiarTexto,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Cambiar texto'),
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Indicadores en tiempo real
            Material(
              elevation: 1,
              shadowColor: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  children: [
                    // Waveform
                    SizedBox(
                      height: 90,
                      child: CustomPaint(
                        painter: _WavePainter(_niveles, nivelColor),
                        child: Container(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Barra de nivel
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 12,
                              color: Colors.brown.shade100,
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: nivel.clamp(0, 1),
                                child: Container(color: nivelColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${_dbActual.toStringAsFixed(0)} dB",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Meta info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MiniStat(
                          icon: Icons.graphic_eq,
                          label: "Pico",
                          value: "${_dbMax.toStringAsFixed(0)} dB",
                          color: _primary,
                        ),
                        _MiniStat(
                          icon: Icons.speaker_phone_outlined,
                          label: "Nivel",
                          value: nivel < 0.25
                              ? "Bajo"
                              : (nivel < 0.6 ? "Medio" : "Alto"),
                          color: nivelColor,
                        ),
                        _MiniStat(
                          icon: Icons.noise_aware_outlined,
                          label: "Ruido",
                          value: _dbActual < -45 ? "Bajo" : "Ambiente",
                          color: _dbActual < -45 ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Botón de grabación
            Center(
              child: ElevatedButton(
                onPressed: _toggleGrabacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(22),
                  elevation: 3,
                ),
                child: Icon(
                  _grabando ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _grabando ? 'Grabando...' : 'Tocar para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.brown.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======== Widgets de apoyo ========

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.brown.shade600,
                )),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> niveles; // 0..1
  final Color color;

  _WavePainter(this.niveles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (niveles.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final dx = size.width / (niveles.length - 1);
    final midY = size.height / 2;

    for (int i = 0; i < niveles.length; i++) {
      final x = dx * i;
      // De 0..1 a amplitud en pixeles (máx 90% de la altura)
      final amp = (size.height * 0.9) * (niveles[i] - 0.5);
      final y = midY - amp; // invertimos para que arriba sea positivo
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Suave brillo inferior
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(.18), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, midY)
      ..lineTo(0, midY)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.niveles != niveles || oldDelegate.color != color;
  }
}

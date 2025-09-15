import 'package:flutter/material.dart';
import 'package:app_stressless/services/liderNotis.dart';

class PantallaNotifsLider extends StatefulWidget {
  final int idLider;
  const PantallaNotifsLider({super.key, required this.idLider});

  @override
  State<PantallaNotifsLider> createState() => _PantallaNotifsLiderState();
}

class _PantallaNotifsLiderState extends State<PantallaNotifsLider> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LiderNotifApi.listar(widget.idLider);
      setState(() => _items = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de estrés')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: _items.isEmpty
            ? const ListTile(title: Text('Sin alertas'))
            : ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = _items[i];
            final leido = n['leido'] == true;
            final creado = (n['creado_en'] ?? '').toString().replaceAll('T',' ');
            return ListTile(
              leading: Icon(
                leido ? Icons.check_circle : Icons.priority_high,
                color: leido ? Colors.grey : Colors.red,
              ),
              title: Text(n['mensaje'] ?? ''),
              subtitle: Text('${n['colaborador'] ?? 'Colaborador'} • ${creado.isNotEmpty ? creado.substring(0, 16) : ''}'),
              trailing: !leido
                  ? TextButton(
                onPressed: () async {
                  await LiderNotifApi.marcarLeida(n['id'] as int);
                  await _load();
                  Navigator.pop(context, true); // para refrescar badge
                },
                child: const Text('Marcar leída'),
              )
                  : null,
            );
          },
        ),
      ),
    );
  }
}

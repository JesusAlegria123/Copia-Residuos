import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════
// ESTADÍSTICAS DE ALERTAS
// Ubicación: lib/screens/estadisticas_alertas_screen.dart
// ══════════════════════════════════════════════════════════════════
class EstadisticasAlertasScreen extends StatefulWidget {
  const EstadisticasAlertasScreen({super.key});
  @override
  State<EstadisticasAlertasScreen> createState() =>
      _EstadisticasAlertasScreenState();
}

class _EstadisticasAlertasScreenState
    extends State<EstadisticasAlertasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  final _alertas = [
    _Alerta('Mercado Central',   'Punto saturado',   const Color(0xFFEF4444), 'Crítica',  'Hace 2h'),
    _Alerta('Av. La Cultura',    'Contenedor lleno', const Color(0xFFF59E0B), 'Media',    'Hace 4h'),
    _Alerta('San Jerónimo',      'Ruta retrasada',   const Color(0xFFF59E0B), 'Media',    'Hace 5h'),
    _Alerta('Wanchaq',           'Residuos en vía',  const Color(0xFFEF4444), 'Crítica',  'Hace 6h'),
    _Alerta('Saylla',            'Camión averiado',  const Color(0xFF0EA5E9), 'Baja',     'Hace 8h'),
    _Alerta('Cusco Centro',      'Reporte ciudadano',const Color(0xFF10B981), 'Resuelta', 'Hace 10h'),
    _Alerta('Santiago',          'Reporte ciudadano',const Color(0xFF10B981), 'Resuelta', 'Hace 12h'),
  ];

  final _porDia = [5, 3, 7, 4, 8, 6, 7];
  final _dias   = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final criticas  = _alertas.where((a) => a.nivel == 'Crítica').length;
    final medias    = _alertas.where((a) => a.nivel == 'Media').length;
    final bajas     = _alertas.where((a) => a.nivel == 'Baja').length;
    final resueltas = _alertas.where((a) => a.nivel == 'Resuelta').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Estadísticas · Alertas',
            style: GoogleFonts.poppins(fontSize: 16,
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs nivel
              Row(children: [
                _kpi('$criticas',  'Críticas',  const Color(0xFFEF4444), Icons.warning_rounded),
                const SizedBox(width: 10),
                _kpi('$medias',    'Medias',    const Color(0xFFF59E0B), Icons.info_rounded),
                const SizedBox(width: 10),
                _kpi('$resueltas', 'Resueltas', const Color(0xFF10B981), Icons.check_circle_rounded),
              ]),
              const SizedBox(height: 24),
              _titulo('Distribución por nivel'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(children: [
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _PintorRadar(
                      criticas: criticas,
                      medias: medias,
                      bajas: bajas,
                      resueltas: resueltas,
                      progreso: _anim.value,
                    ),
                    child: Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${_alertas.length}',
                            style: GoogleFonts.poppins(color: Colors.white,
                                fontSize: 26, fontWeight: FontWeight.w800)),
                        Text('alertas', style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11)),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _leyenda('Críticas',  criticas,  const Color(0xFFEF4444)),
                      _leyenda('Medias',    medias,    const Color(0xFFF59E0B)),
                      _leyenda('Bajas',     bajas,     const Color(0xFF0EA5E9)),
                      _leyenda('Resueltas', resueltas, const Color(0xFF10B981)),
                    ]),
              ])),
              const SizedBox(height: 20),
              _titulo('Alertas por día (esta semana)'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(children: [
                SizedBox(
                  height: 130,
                  child: CustomPaint(
                    painter: _PintorBurbuja(
                        valores: _porDia, progreso: _anim.value),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _dias.map((d) => Text(d,
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11))).toList()),
              ])),
              const SizedBox(height: 20),
              _titulo('Alertas activas'),
              const SizedBox(height: 14),
              ..._alertas.map((a) => _tarjetaAlerta(a)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titulo(String t) => Text(t, style: GoogleFonts.poppins(
      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700));

  Widget _tarjeta({required Widget child}) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child);

  Widget _kpi(String v, String l, Color c, IconData i) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i, color: c, size: 20),
            const SizedBox(height: 6),
            Text(v, style: GoogleFonts.poppins(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.w800)),
            Text(l, style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.45), fontSize: 10)),
          ]),
    ),
  );

  Widget _leyenda(String l, int v, Color c) => Column(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(height: 4),
    Text('$v', style: GoogleFonts.poppins(color: Colors.white,
        fontSize: 13, fontWeight: FontWeight.w700)),
    Text(l, style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.4), fontSize: 9)),
  ]);

  Widget _tarjetaAlerta(_Alerta a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: a.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: a.color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: a.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.warning_amber_rounded, color: a.color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.lugar, style: GoogleFonts.poppins(color: Colors.white,
                fontSize: 13, fontWeight: FontWeight.w600)),
            Text(a.descripcion, style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.45), fontSize: 11)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(a.nivel, style: GoogleFonts.poppins(
                color: a.color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Text(a.tiempo, style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.3), fontSize: 10)),
        ]),
      ]),
    );
  }
}

class _Alerta {
  final String lugar, descripcion, nivel, tiempo;
  final Color color;
  const _Alerta(this.lugar, this.descripcion, this.color, this.nivel, this.tiempo);
}

class _PintorRadar extends CustomPainter {
  final int criticas, medias, bajas, resueltas;
  final double progreso;
  _PintorRadar({required this.criticas, required this.medias,
    required this.bajas, required this.resueltas, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final total = (criticas + medias + bajas + resueltas).toDouble();
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2 - 14;
    var inicio = -math.pi / 2;

    final secs = [
      (criticas.toDouble(),  const Color(0xFFEF4444)),
      (medias.toDouble(),    const Color(0xFFF59E0B)),
      (bajas.toDouble(),     const Color(0xFF0EA5E9)),
      (resueltas.toDouble(), const Color(0xFF10B981)),
    ];

    for (final s in secs) {
      final barrido = (s.$1 / total) * 2 * math.pi * progreso;
      canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radio),
          inicio, barrido, false,
          Paint()
            ..color = s.$2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 28);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_PintorRadar o) => o.progreso != progreso;
}

class _PintorBurbuja extends CustomPainter {
  final List<int> valores;
  final double progreso;
  _PintorBurbuja({required this.valores, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final max = valores.reduce(math.max).toDouble();
    final paso = size.width / valores.length;

    for (var i = 0; i < valores.length; i++) {
      final x = i * paso + paso / 2;
      final radio = (valores[i] / max) * (size.height / 2) * progreso;
      final y = size.height / 2;

      final color = valores[i] >= 7
          ? const Color(0xFFEF4444)
          : valores[i] >= 5
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981);

      canvas.drawCircle(Offset(x, y), radio,
          Paint()..color = color.withOpacity(0.2));
      canvas.drawCircle(Offset(x, y), radio,
          Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);

      final tp = TextPainter(
        text: TextSpan(
            text: '${valores[i]}',
            style: TextStyle(color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_PintorBurbuja o) => o.progreso != progreso;
}
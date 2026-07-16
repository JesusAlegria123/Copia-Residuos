import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════
// ESTADÍSTICAS DE RUTAS ACTIVAS
// Ubicación: lib/screens/estadisticas_rutas_screen.dart
// ══════════════════════════════════════════════════════════════════
class EstadisticasRutasScreen extends StatefulWidget {
  const EstadisticasRutasScreen({super.key});

  @override
  State<EstadisticasRutasScreen> createState() =>
      _EstadisticasRutasScreenState();
}

class _EstadisticasRutasScreenState extends State<EstadisticasRutasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  final _rutas = [
    _DatoRuta('Ruta A · San Blas',     38, const Color(0xFF0EA5E9), 'Completada'),
    _DatoRuta('Ruta B · Wanchaq',      62, const Color(0xFF10B981), 'En curso'),
    _DatoRuta('Ruta C · Santiago',     55, const Color(0xFFF59E0B), 'En curso'),
    _DatoRuta('Ruta D · Cusco Centro', 90, const Color(0xFF9333EA), 'Completada'),
    _DatoRuta('Ruta E · San Jerónimo', 20, const Color(0xFFEF4444), 'Pendiente'),
    _DatoRuta('Ruta F · Saylla',       45, const Color(0xFF4ADE80), 'En curso'),
  ];

  final _semana = [12, 18, 15, 22, 19, 26, 24];
  final _dias   = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Estadísticas · Rutas',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs
              Row(children: [
                _kpi('48',  'Rutas totales', const Color(0xFF0EA5E9), Icons.route_rounded),
                const SizedBox(width: 10),
                _kpi('32',  'En curso',      const Color(0xFF10B981), Icons.play_circle_outline_rounded),
                const SizedBox(width: 10),
                _kpi('12',  'Pendientes',    const Color(0xFFF59E0B), Icons.pause_circle_outline_rounded),
              ]),
              const SizedBox(height: 24),
              _titulo('Progreso por Ruta'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(
                children: _rutas.map((r) => _filaRuta(r)).toList(),
              )),
              const SizedBox(height: 20),
              _titulo('Rutas completadas esta semana'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      painter: _PintorLinea(
                          valores: _semana,
                          color: const Color(0xFF0EA5E9),
                          progreso: _anim.value),
                      size: Size.infinite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _dias.map((d) => Text(d,
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11))).toList(),
                  ),
                ],
              )),
              const SizedBox(height: 20),
              _titulo('Estado general'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      painter: _PintorDonut(
                        completadas: 18,
                        enCurso: 22,
                        pendientes: 8,
                        progreso: _anim.value,
                      ),
                      child: Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('48', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 26,
                              fontWeight: FontWeight.w800)),
                          Text('rutas', style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11)),
                        ],
                      )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _leyendaDonut('Completadas', 18, const Color(0xFF10B981)),
                      _leyendaDonut('En curso',    22, const Color(0xFF0EA5E9)),
                      _leyendaDonut('Pendientes',   8, const Color(0xFFF59E0B)),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titulo(String t) => Text(t,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15,
          fontWeight: FontWeight.w700));

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: c, size: 20),
        const SizedBox(height: 6),
        Text(v, style: GoogleFonts.poppins(color: Colors.white,
            fontSize: 18, fontWeight: FontWeight.w800)),
        Text(l, style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.45), fontSize: 10)),
      ]),
    ),
  );

  Widget _filaRuta(_DatoRuta r) {
    final colorEstado = r.estado == 'Completada'
        ? const Color(0xFF10B981)
        : r.estado == 'En curso'
        ? const Color(0xFF0EA5E9)
        : const Color(0xFFF59E0B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(r.nombre,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(r.estado, style: GoogleFonts.poppins(
                color: colorEstado, fontSize: 10,
                fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text('${r.progreso}%', style: GoogleFonts.poppins(
              color: r.color, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (r.progreso / 100) * _anim.value,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(r.color),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }

  Widget _leyendaDonut(String l, int v, Color c) => Column(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(height: 4),
    Text('$v', style: GoogleFonts.poppins(color: Colors.white,
        fontSize: 14, fontWeight: FontWeight.w700)),
    Text(l, style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.4), fontSize: 10)),
  ]);
}

class _DatoRuta {
  final String nombre, estado;
  final int progreso;
  final Color color;
  const _DatoRuta(this.nombre, this.progreso, this.color, this.estado);
}

// ── Painter línea ────────────────────────────────────────────────
class _PintorLinea extends CustomPainter {
  final List<int> valores;
  final Color color;
  final double progreso;
  _PintorLinea({required this.valores, required this.color,
    required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final max = valores.reduce(math.max).toDouble();
    final paso = size.width / (valores.length - 1);

    // Área rellena
    final pathArea = Path();
    for (var i = 0; i < valores.length; i++) {
      final x = i * paso;
      final y = size.height - (valores[i] / max) * size.height * progreso;
      i == 0 ? pathArea.moveTo(x, y) : pathArea.lineTo(x, y);
    }
    pathArea.lineTo(size.width, size.height);
    pathArea.lineTo(0, size.height);
    pathArea.close();
    canvas.drawPath(
        pathArea,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Línea
    final pathLinea = Path();
    for (var i = 0; i < valores.length; i++) {
      final x = i * paso;
      final y = size.height - (valores[i] / max) * size.height * progreso;
      i == 0 ? pathLinea.moveTo(x, y) : pathLinea.lineTo(x, y);
    }
    canvas.drawPath(
        pathLinea,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Puntos
    for (var i = 0; i < valores.length; i++) {
      final x = i * paso;
      final y = size.height - (valores[i] / max) * size.height * progreso;
      canvas.drawCircle(Offset(x, y), 4,
          Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 3,
          Paint()..color = const Color(0xFF0D0D1A));
    }
  }

  @override
  bool shouldRepaint(_PintorLinea o) => o.progreso != progreso;
}

// ── Painter donut ────────────────────────────────────────────────
class _PintorDonut extends CustomPainter {
  final int completadas, enCurso, pendientes;
  final double progreso;
  _PintorDonut({required this.completadas, required this.enCurso,
    required this.pendientes, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final total = (completadas + enCurso + pendientes).toDouble();
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2 - 14;
    var inicio = -math.pi / 2;

    final secciones = [
      (completadas.toDouble(), const Color(0xFF10B981)),
      (enCurso.toDouble(),    const Color(0xFF0EA5E9)),
      (pendientes.toDouble(), const Color(0xFFF59E0B)),
    ];

    for (final s in secciones) {
      final barrido = (s.$1 / total) * 2 * math.pi * progreso;
      canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radio),
          inicio, barrido, false,
          Paint()
            ..color = s.$2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 30
            ..strokeCap = StrokeCap.butt);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_PintorDonut o) => o.progreso != progreso;
}
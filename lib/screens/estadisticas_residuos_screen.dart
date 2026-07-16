import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════
// ESTADÍSTICAS DE RESIDUOS
// Ubicación: lib/screens/estadisticas_residuos_screen.dart
// ══════════════════════════════════════════════════════════════════
class EstadisticasResiduosScreen extends StatefulWidget {
  const EstadisticasResiduosScreen({super.key});
  @override
  State<EstadisticasResiduosScreen> createState() =>
      _EstadisticasResiduosScreenState();
}

class _EstadisticasResiduosScreenState
    extends State<EstadisticasResiduosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  final _porTipo = [
    _Dato('Orgánicos',    520, const Color(0xFF10B981)),
    _Dato('Plásticos',    280, const Color(0xFF0EA5E9)),
    _Dato('Papel/Cartón', 180, const Color(0xFFF59E0B)),
    _Dato('Metales',       90, const Color(0xFF9333EA)),
    _Dato('Vidrio',        70, const Color(0xFF4ADE80)),
    _Dato('Otros',         60, const Color(0xFFEF4444)),
  ];

  final _meses = [
    _Dato('Ene', 980,  const Color(0xFF10B981)),
    _Dato('Feb', 1100, const Color(0xFF10B981)),
    _Dato('Mar', 1050, const Color(0xFF10B981)),
    _Dato('Abr', 1250, const Color(0xFF10B981)),
    _Dato('May', 1180, const Color(0xFF10B981)),
    _Dato('Jun', 1320, const Color(0xFF10B981)),
    _Dato('Jul', 1200, const Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  int get _total => _porTipo.fold(0, (s, d) => s + d.valor);

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
        title: Text('Estadísticas · Residuos',
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
              Row(children: [
                _kpi('1.2T', 'Este mes', const Color(0xFF10B981),
                    Icons.delete_outline_rounded),
                const SizedBox(width: 10),
                _kpi('240kg', 'Hoy',   const Color(0xFF0EA5E9),
                    Icons.today_rounded),
                const SizedBox(width: 10),
                _kpi('-5%', 'vs anterior', const Color(0xFF4ADE80),
                    Icons.trending_down_rounded),
              ]),
              const SizedBox(height: 24),
              _titulo('Composición de Residuos'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(children: [
                SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: _PintorTorta3D(
                        datos: _porTipo, progreso: _anim.value),
                    child: Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$_total',
                            style: GoogleFonts.poppins(color: Colors.white,
                                fontSize: 26, fontWeight: FontWeight.w800)),
                        Text('kg/mes', style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11)),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 16),
                ..._porTipo.map((d) {
                  final pct = (d.valor / _total * 100).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(width: 12, height: 12,
                          decoration: BoxDecoration(
                              color: d.color,
                              borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(d.etiqueta,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13))),
                      Text('${d.valor} kg',
                          style: GoogleFonts.poppins(color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (d.valor / _total) * _anim.value,
                            backgroundColor:
                            Colors.white.withOpacity(0.08),
                            valueColor:
                            AlwaysStoppedAnimation<Color>(d.color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$pct%', style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10)),
                    ]),
                  );
                }),
              ])),
              const SizedBox(height: 20),
              _titulo('Toneladas recolectadas por mes'),
              const SizedBox(height: 14),
              _tarjeta(child: Column(children: [
                SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: _PintorBarrasGradiente(
                        datos: _meses, progreso: _anim.value),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _meses.map((d) => Text(d.etiqueta,
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10))).toList(),
                ),
              ])),
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
                fontSize: 16, fontWeight: FontWeight.w800)),
            Text(l, style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.45), fontSize: 10)),
          ]),
    ),
  );
}

class _Dato {
  final String etiqueta;
  final int valor;
  final Color color;
  const _Dato(this.etiqueta, this.valor, this.color);
}

class _PintorTorta3D extends CustomPainter {
  final List<_Dato> datos;
  final double progreso;
  _PintorTorta3D({required this.datos, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final total = datos.fold(0, (s, d) => s + d.valor).toDouble();
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2 - 12;
    var inicio = -math.pi / 2;

    for (final d in datos) {
      final barrido = (d.valor / total) * 2 * math.pi * progreso;
      // Sombra (desplazada)
      canvas.drawArc(
          Rect.fromCircle(
              center: centro + const Offset(2, 3), radius: radio),
          inicio, barrido, false,
          Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 32);
      // Arco principal
      canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radio),
          inicio, barrido, false,
          Paint()
            ..color = d.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 30
            ..strokeCap = StrokeCap.butt);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_PintorTorta3D o) => o.progreso != progreso;
}

class _PintorBarrasGradiente extends CustomPainter {
  final List<_Dato> datos;
  final double progreso;
  _PintorBarrasGradiente({required this.datos, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final max = datos.map((d) => d.valor).reduce(math.max).toDouble();
    final ancho = size.width / datos.length;
    final grosor = ancho * 0.55;

    for (var i = 0; i < datos.length; i++) {
      final alto = (datos[i].valor / max) * size.height * progreso;
      final x = i * ancho + ancho / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - grosor / 2, size.height - alto, grosor, alto),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF10B981).withOpacity(0.3),
          ],
        ).createShader(Rect.fromLTWH(0, size.height - alto, grosor, alto)));
    }
  }

  @override
  bool shouldRepaint(_PintorBarrasGradiente o) => o.progreso != progreso;
}
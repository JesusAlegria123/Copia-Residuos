import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════
// ESTADÍSTICAS DE USUARIOS
// Ubicación: lib/screens/estadisticas_usuarios_screen.dart
// ══════════════════════════════════════════════════════════════════
class EstadisticasUsuariosScreen extends StatefulWidget {
  const EstadisticasUsuariosScreen({super.key});

  @override
  State<EstadisticasUsuariosScreen> createState() =>
      _EstadisticasUsuariosScreenState();
}

class _EstadisticasUsuariosScreenState
    extends State<EstadisticasUsuariosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  // Datos mock
  final _porRol = [
    _DatoCirculo('Admin',         45,  const Color(0xFF9333EA)),
    _DatoCirculo('Municipalidad', 120, const Color(0xFF0EA5E9)),
    _DatoCirculo('Usuario',       980, const Color(0xFF10B981)),
    _DatoCirculo('Ciudadano',    1100, const Color(0xFF4ADE80)),
    _DatoCirculo('Invitado',      155, const Color(0xFFF59E0B)),
  ];

  final _porMes = [
    _DatoBarra('Ene', 180),
    _DatoBarra('Feb', 210),
    _DatoBarra('Mar', 340),
    _DatoBarra('Abr', 290),
    _DatoBarra('May', 410),
    _DatoBarra('Jun', 380),
    _DatoBarra('Jul', 490),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _total => _porRol.fold(0, (s, d) => s + d.valor);

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
        title: Text('Estadísticas · Usuarios',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
              // KPIs rápidos
              Row(children: [
                _miniKpi('$_total', 'Total', const Color(0xFF9333EA),
                    Icons.people_rounded),
                const SizedBox(width: 10),
                _miniKpi('${_porRol[2].valor + _porRol[3].valor}',
                    'Activos', const Color(0xFF10B981),
                    Icons.check_circle_rounded),
                const SizedBox(width: 10),
                _miniKpi('+12%', 'Este mes', const Color(0xFF0EA5E9),
                    Icons.trending_up_rounded),
              ]),
              const SizedBox(height: 24),
              _titulo('Distribución por Rol'),
              const SizedBox(height: 16),
              // Gráfico circular
              _tarjeta(
                child: Column(children: [
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _PintorTorta(
                          datos: _porRol,
                          progreso: _anim.value),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_total',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800)),
                            Text('usuarios',
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Leyenda
                  ..._porRol.map((d) => _filaLeyenda(d)),
                ]),
              ),
              const SizedBox(height: 20),
              _titulo('Crecimiento Mensual'),
              const SizedBox(height: 16),
              _tarjeta(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: CustomPaint(
                        painter: _PintorBarras(
                            datos: _porMes,
                            color: const Color(0xFF9333EA),
                            progreso: _anim.value),
                        size: Size.infinite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _porMes
                          .map((d) => Text(d.etiqueta,
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titulo(String t) => Text(t,
      style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700));

  Widget _tarjeta({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: child,
  );

  Widget _miniKpi(String valor, String label, Color color, IconData icono) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(height: 6),
              Text(valor,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _filaLeyenda(_DatoCirculo d) {
    final pct = (d.valor / _total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: d.color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(d.etiqueta,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 13))),
        Text('${d.valor}',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Text('$pct%',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ]),
    );
  }
}

// ── Modelos de datos ─────────────────────────────────────────────
class _DatoCirculo {
  final String etiqueta;
  final int valor;
  final Color color;
  const _DatoCirculo(this.etiqueta, this.valor, this.color);
}

class _DatoBarra {
  final String etiqueta;
  final int valor;
  const _DatoBarra(this.etiqueta, this.valor);
}

// ── Painter torta ────────────────────────────────────────────────
class _PintorTorta extends CustomPainter {
  final List<_DatoCirculo> datos;
  final double progreso;
  _PintorTorta({required this.datos, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final total = datos.fold(0, (s, d) => s + d.valor).toDouble();
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2 - 10;
    var anguloInicio = -math.pi / 2;

    for (final d in datos) {
      final barrido = (d.valor / total) * 2 * math.pi * progreso;
      final paint = Paint()
        ..color = d.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radio),
          anguloInicio,
          barrido,
          false,
          paint);
      anguloInicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_PintorTorta o) => o.progreso != progreso;
}

// ── Painter barras ───────────────────────────────────────────────
class _PintorBarras extends CustomPainter {
  final List<_DatoBarra> datos;
  final Color color;
  final double progreso;
  _PintorBarras(
      {required this.datos, required this.color, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final maximo = datos.map((d) => d.valor).reduce(math.max).toDouble();
    final ancho = size.width / datos.length;
    final grosor = ancho * 0.5;

    for (var i = 0; i < datos.length; i++) {
      final alto = (datos[i].valor / maximo) * size.height * progreso;
      final x = i * ancho + ancho / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - grosor / 2, size.height - alto, grosor, alto),
        const Radius.circular(6),
      );
      canvas.drawRRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.4)],
            ).createShader(
                Rect.fromLTWH(0, size.height - alto, grosor, alto)));

      // Valor encima
      if (progreso > 0.8) {
        final tp = TextPainter(
          text: TextSpan(
              text: '${datos[i].valor}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(x - tp.width / 2, size.height - alto - 14));
      }
    }
  }

  @override
  bool shouldRepaint(_PintorBarras o) => o.progreso != progreso;
}
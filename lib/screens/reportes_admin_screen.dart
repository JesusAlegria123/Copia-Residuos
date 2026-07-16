import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════════
// REPORTES DE ACUMULACIÓN — VISTA ADMINISTRADOR
// Ubicación: lib/screens/reportes_admin_screen.dart
//
// Criterios cubiertos:
// ✅ Lista de reportes registrados
// ✅ Descripción, distrito, ubicación, fotografía y fecha
// ✅ Visualización de fotografía
// ✅ Latitud y longitud identificables
// ✅ Mensaje de error o ausencia de reportes
// ✅ Filtros por estado y distrito
// ✅ Cambio de estado por admin (Pendiente → En Proceso → Resuelto)
// ══════════════════════════════════════════════════════════════════
class ReportesAdminScreen extends StatefulWidget {
  const ReportesAdminScreen({super.key});

  @override
  State<ReportesAdminScreen> createState() => _ReportesAdminScreenState();
}

class _ReportesAdminScreenState extends State<ReportesAdminScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _cargando = true;
  String? _error;
  String _filtroEstado   = 'Todos';
  String _filtroDistrito = 'Todos';

  // Datos mock — en producción vendrían del backend
  final List<Map<String, dynamic>> _reportes = [
    {
      'id': 1,
      'titulo': 'Acumulación en mercado',
      'descripcion': 'Gran cantidad de residuos sólidos desbordando los contenedores en la entrada principal del mercado. El olor es insoportable y atrae roedores.',
      'distrito': 'Cusco Centro',
      'direccion': 'Mercado Central, Jr. Tupac Amaru',
      'fecha': '2026-07-03',
      'hora': '08:24',
      'estado': 'Pendiente',
      'ciudadano': 'María Q.',
      'foto': null,
      'latitud': -13.5183,
      'longitud': -71.9784,
    },
    {
      'id': 2,
      'titulo': 'Contenedor desbordado',
      'descripcion': 'El punto de reciclaje lleva 3 días sin ser vaciado. Los residuos están esparcidos en la vereda impidiendo el paso peatonal.',
      'distrito': 'Wanchaq',
      'direccion': 'Av. La Cultura 1200',
      'fecha': '2026-07-02',
      'hora': '14:10',
      'estado': 'En Proceso',
      'ciudadano': 'Carlos R.',
      'foto': null,
      'latitud': -13.5255,
      'longitud': -71.9720,
    },
    {
      'id': 3,
      'titulo': 'Residuos en vía pública',
      'descripcion': 'Bolsas de basura doméstica tiradas sobre la vereda. Posiblemente un vecino las dejó fuera del horario de recolección.',
      'distrito': 'Santiago',
      'direccion': 'Calle Tupac Amaru 340',
      'fecha': '2026-07-01',
      'hora': '07:55',
      'estado': 'Resuelto',
      'ciudadano': 'Ana L.',
      'foto': null,
      'latitud': -13.5200,
      'longitud': -71.9950,
    },
    {
      'id': 4,
      'titulo': 'Punto crítico San Jerónimo',
      'descripcion': 'Esquina usada como botadero informal. Acumulación de muebles viejos, colchones y escombros mezclados con residuos domésticos.',
      'distrito': 'San Jerónimo',
      'direccion': 'Av. Evitamiento km 5',
      'fecha': '2026-07-03',
      'hora': '11:30',
      'estado': 'Pendiente',
      'ciudadano': 'Pedro M.',
      'foto': null,
      'latitud': -13.5412,
      'longitud': -71.9102,
    },
    {
      'id': 5,
      'titulo': 'Basura en canal de agua',
      'descripcion': 'Residuos plásticos y orgánicos arrojados directamente al canal de irrigación. Riesgo de contaminación del agua.',
      'distrito': 'Saylla',
      'direccion': 'Canal de Huatanay, sector 3',
      'fecha': '2026-07-02',
      'hora': '16:45',
      'estado': 'En Proceso',
      'ciudadano': 'Rosa T.',
      'foto': null,
      'latitud': -13.5619,
      'longitud': -71.8734,
    },
  ];

  final _estados   = ['Todos', 'Pendiente', 'En Proceso', 'Resuelto'];
  final _distritos = ['Todos', 'Cusco Centro', 'Wanchaq', 'Santiago',
    'San Jerónimo', 'Saylla'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _simularCarga();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _simularCarga() async {
    setState(() { _cargando = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _cargando = false);
    _fadeCtrl.forward(from: 0);
  }

  List<Map<String, dynamic>> get _reportesFiltrados {
    return _reportes.where((r) {
      if (_filtroEstado   != 'Todos' && r['estado']   != _filtroEstado)   return false;
      if (_filtroDistrito != 'Todos' && r['distrito'] != _filtroDistrito) return false;
      return true;
    }).toList();
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':  return const Color(0xFFF59E0B);
      case 'En Proceso': return const Color(0xFF0EA5E9);
      case 'Resuelto':   return const Color(0xFF10B981);
      default:           return Colors.white;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Pendiente':  return Icons.hourglass_empty_rounded;
      case 'En Proceso': return Icons.sync_rounded;
      case 'Resuelto':   return Icons.check_circle_rounded;
      default:           return Icons.circle_outlined;
    }
  }

  void _cambiarEstado(Map<String, dynamic> reporte) {
    final estados = ['Pendiente', 'En Proceso', 'Resuelto'];
    final idx = estados.indexOf(reporte['estado'] as String);
    if (idx == estados.length - 1) {
      _snack('✅ El reporte ya está resuelto', const Color(0xFF10B981));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cambiar estado',
            style: GoogleFonts.poppins(color: Colors.white,
                fontWeight: FontWeight.w700)),
        content: Text(
            '¿Cambiar de "${reporte['estado']}" a "${estados[idx + 1]}"?',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.6), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => reporte['estado'] = estados[idx + 1]);
              Navigator.pop(context);
              _snack('✅ Estado actualizado a "${estados[idx + 1]}"',
                  _colorEstado(estados[idx + 1]));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorEstado(estados[idx + 1]),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirmar',
                style: GoogleFonts.poppins(color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _verDetalle(Map<String, dynamic> r) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => _DetalleReporteScreen(reporte: r,
            onCambiarEstado: () => _cambiarEstado(r))));
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes Ciudadanos',
                style: GoogleFonts.poppins(fontSize: 15,
                    fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Vista Administrador',
                style: GoogleFonts.poppins(fontSize: 10,
                    color: Colors.white.withOpacity(0.4))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: Colors.white.withOpacity(0.6),
            onPressed: _simularCarga,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(
          color: Color(0xFF9333EA), strokeWidth: 2.5))
          : _error != null
          ? _buildError()
          : FadeTransition(opacity: _fadeAnim, child: _buildCuerpo()),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.cloud_off_rounded,
          color: Colors.white.withOpacity(0.3), size: 56),
      const SizedBox(height: 16),
      Text('No se pudo cargar los reportes',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6),
              fontSize: 15)),
      const SizedBox(height: 8),
      Text('Verifica tu conexión e intenta de nuevo',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.35),
              fontSize: 12)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _simularCarga,
        icon: const Icon(Icons.refresh_rounded),
        label: Text('Reintentar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9333EA),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ]),
  );

  Widget _buildCuerpo() {
    return Column(
      children: [
        // ── Estadísticas rápidas ──────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white.withOpacity(0.02),
          child: Row(children: [
            _statChip('${_reportes.length}',   'Total',     const Color(0xFF9333EA), Icons.assignment_rounded),
            const SizedBox(width: 8),
            _statChip(
                '${_reportes.where((r) => r['estado'] == 'Pendiente').length}',
                'Pendientes', const Color(0xFFF59E0B), Icons.hourglass_empty_rounded),
            const SizedBox(width: 8),
            _statChip(
                '${_reportes.where((r) => r['estado'] == 'En Proceso').length}',
                'En Proceso', const Color(0xFF0EA5E9), Icons.sync_rounded),
            const SizedBox(width: 8),
            _statChip(
                '${_reportes.where((r) => r['estado'] == 'Resuelto').length}',
                'Resueltos', const Color(0xFF10B981), Icons.check_circle_rounded),
          ]),
        ),
        // ── Filtros ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(child: _dropdown(
                valor: _filtroEstado,
                opciones: _estados,
                icono: Icons.filter_list_rounded,
                onChange: (v) => setState(() => _filtroEstado = v!))),
            const SizedBox(width: 10),
            Expanded(child: _dropdown(
                valor: _filtroDistrito,
                opciones: _distritos,
                icono: Icons.location_on_outlined,
                onChange: (v) => setState(() => _filtroDistrito = v!))),
          ]),
        ),
        // ── Lista ─────────────────────────────────────────────
        Expanded(
          child: _reportesFiltrados.isEmpty
              ? _buildVacio()
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: _reportesFiltrados.length,
            itemBuilder: (_, i) =>
                _tarjetaReporte(_reportesFiltrados[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVacio() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_rounded,
          color: Colors.white.withOpacity(0.2), size: 60),
      const SizedBox(height: 16),
      Text('Sin reportes',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5),
              fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('No hay reportes con los filtros seleccionados.',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3),
              fontSize: 12)),
    ]),
  );

  Widget _statChip(String v, String l, Color c, IconData i) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(i, color: c, size: 16),
        const SizedBox(height: 3),
        Text(v, style: GoogleFonts.poppins(color: Colors.white,
            fontSize: 15, fontWeight: FontWeight.w800)),
        Text(l, style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.4), fontSize: 9),
            overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  Widget _dropdown({
    required String valor,
    required List<String> opciones,
    required IconData icono,
    required ValueChanged<String?> onChange,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: valor,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A2E),
            icon: const Icon(Icons.expand_more_rounded,
                color: Colors.white38, size: 18),
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.white.withOpacity(0.85)),
            items: opciones.map((o) =>
                DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: onChange,
          ),
        ),
      );

  Widget _tarjetaReporte(Map<String, dynamic> r) {
    final color  = _colorEstado(r['estado'] as String);
    final foto   = r['foto'] as String?;

    return GestureDetector(
      onTap: () => _verDetalle(r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto (si existe) ──────────────────────────────
            if (foto != null && foto.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17)),
                child: Image.file(File(foto),
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderFoto(color)),
              )
            else
              _placeholderFoto(color),
            // ── Contenido ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + estado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(r['titulo'] as String,
                            style: GoogleFonts.poppins(color: Colors.white,
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconoEstado(r['estado'] as String),
                                  color: color, size: 11),
                              const SizedBox(width: 4),
                              Text(r['estado'] as String,
                                  style: GoogleFonts.poppins(color: color,
                                      fontSize: 10, fontWeight: FontWeight.w700)),
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Descripción
                  Text(r['descripcion'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12, height: 1.4)),
                  const SizedBox(height: 10),
                  // Metadatos
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    _meta(Icons.location_on_outlined,
                        '${r['distrito']}', const Color(0xFF0EA5E9)),
                    _meta(Icons.calendar_today_rounded,
                        '${r['fecha']} · ${r['hora']}',
                        Colors.white.withOpacity(0.4)),
                    _meta(Icons.person_outline_rounded,
                        r['ciudadano'] as String,
                        Colors.white.withOpacity(0.4)),
                  ]),
                  const SizedBox(height: 8),
                  // Coordenadas
                  Row(children: [
                    Icon(Icons.my_location_rounded,
                        color: Colors.white.withOpacity(0.25), size: 12),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${(r['latitud'] as double).toStringAsFixed(5)}, '
                            '${(r['longitud'] as double).toStringAsFixed(5)}',
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Botón cambiar estado
                    if (r['estado'] != 'Resuelto')
                      GestureDetector(
                        onTap: () => _cambiarEstado(r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: color.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.update_rounded,
                                    color: color, size: 13),
                                const SizedBox(width: 4),
                                Text('Actualizar',
                                    style: GoogleFonts.poppins(color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ]),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderFoto(Color color) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
    ),
    child: Center(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined,
            color: color.withOpacity(0.4), size: 28),
        const SizedBox(width: 8),
        Text('Sin fotografía',
            style: GoogleFonts.poppins(
                color: color.withOpacity(0.4), fontSize: 12)),
      ],
    )),
  );

  Widget _meta(IconData icono, String texto, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icono, color: color, size: 13),
      const SizedBox(width: 4),
      Text(texto, style: GoogleFonts.poppins(color: color, fontSize: 11)),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════
// DETALLE DEL REPORTE
// ══════════════════════════════════════════════════════════════════
class _DetalleReporteScreen extends StatelessWidget {
  final Map<String, dynamic> reporte;
  final VoidCallback onCambiarEstado;

  const _DetalleReporteScreen({
    required this.reporte,
    required this.onCambiarEstado,
  });

  Color _colorEstado(String e) {
    switch (e) {
      case 'Pendiente':  return const Color(0xFFF59E0B);
      case 'En Proceso': return const Color(0xFF0EA5E9);
      default:           return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color  = _colorEstado(reporte['estado'] as String);
    final foto   = reporte['foto'] as String?;
    final estado = reporte['estado'] as String;

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
        title: Text('Detalle del Reporte',
            style: GoogleFonts.poppins(fontSize: 15,
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto grande
            if (foto != null && foto.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(foto),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        color: color.withOpacity(0.4), size: 44),
                    const SizedBox(height: 8),
                    Text('No se adjuntó fotografía',
                        style: GoogleFonts.poppins(
                            color: color.withOpacity(0.5), fontSize: 13)),
                  ],
                )),
              ),
            const SizedBox(height: 20),
            // Título + estado
            Row(children: [
              Expanded(
                child: Text(reporte['titulo'] as String,
                    style: GoogleFonts.poppins(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(estado, style: GoogleFonts.poppins(
                    color: color, fontSize: 12,
                    fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 16),
            // Secciones
            _seccion('Descripción', Icons.description_outlined,
                reporte['descripcion'] as String),
            const SizedBox(height: 14),
            _tarjetaInfo([
              _InfoFila(Icons.location_city_rounded, 'Distrito',
                  reporte['distrito'] as String, const Color(0xFF0EA5E9)),
              _InfoFila(Icons.signpost_outlined, 'Dirección',
                  reporte['direccion'] as String,
                  Colors.white.withOpacity(0.5)),
              _InfoFila(Icons.calendar_today_rounded, 'Fecha y hora',
                  '${reporte['fecha']}  ·  ${reporte['hora']}',
                  Colors.white.withOpacity(0.5)),
              _InfoFila(Icons.person_outline_rounded, 'Ciudadano',
                  reporte['ciudadano'] as String,
                  Colors.white.withOpacity(0.5)),
            ]),
            const SizedBox(height: 14),
            // Coordenadas
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.my_location_rounded,
                        color: Color(0xFF0EA5E9), size: 16),
                    const SizedBox(width: 8),
                    Text('Ubicación Geográfica',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF0EA5E9),
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _coordenada('Latitud',
                        (reporte['latitud'] as double).toStringAsFixed(6))),
                    const SizedBox(width: 12),
                    Expanded(child: _coordenada('Longitud',
                        (reporte['longitud'] as double).toStringAsFixed(6))),
                  ]),
                  const SizedBox(height: 8),
                  Text('Presiona "Ver en mapa" para visualizar la ubicación.',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botones de acción
            if (estado != 'Resuelto')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCambiarEstado();
                  },
                  icon: const Icon(Icons.update_rounded, size: 18),
                  label: Text(
                      estado == 'Pendiente'
                          ? 'Marcar como En Proceso'
                          : 'Marcar como Resuelto',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            if (estado == 'Resuelto')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Text('Reporte resuelto',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, IconData icono, String contenido) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icono, color: const Color(0xFF9333EA), size: 16),
          const SizedBox(width: 8),
          Text(titulo, style: GoogleFonts.poppins(
              color: const Color(0xFF9333EA), fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
        const SizedBox(height: 6),
        Text(contenido, style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13, height: 1.6)),
      ]);

  Widget _tarjetaInfo(List<_InfoFila> filas) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: filas.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(f.icono, color: f.color, size: 16),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.label, style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
            const SizedBox(height: 2),
            Text(f.valor, style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600)),
          ]),
        ]),
      )).toList()));

  Widget _coordenada(String label, String valor) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.4), fontSize: 10)),
      const SizedBox(height: 4),
      Text(valor, style: GoogleFonts.poppins(
          color: const Color(0xFF0EA5E9), fontSize: 13,
          fontWeight: FontWeight.w700)),
    ]),
  );
}

class _InfoFila {
  final IconData icono;
  final String label, valor;
  final Color color;
  const _InfoFila(this.icono, this.label, this.valor, this.color);
}
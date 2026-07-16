import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'unidad_recoleccion.dart';
import 'seguimiento_unidad_screen.dart';

class MonitoreoScreen extends StatefulWidget {
  const MonitoreoScreen({super.key});

  @override
  State<MonitoreoScreen> createState() => _MonitoreoScreenState();
}

class _MonitoreoScreenState extends State<MonitoreoScreen> {
  @override
  void initState() {
    super.initState();
    // Abre el selector apenas se entra a la pantalla (la "ventana" pedida).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mostrarSelectorUnidades();
    });
  }

  void _mostrarSelectorUnidades() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Selecciona una unidad',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Verás su ubicación y recorrido en tiempo real',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              ...unidadesRecoleccion.map(
                    (u) => _unidadTile(u, dentroDeSheet: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _irASeguimiento(UnidadRecoleccion unidad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeguimientoUnidadScreen(unidad: unidad),
      ),
    );
  }

  Widget _unidadTile(UnidadRecoleccion unidad, {bool dentroDeSheet = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (dentroDeSheet) Navigator.pop(context); // cierra el sheet
          _irASeguimiento(unidad);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unidad.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: unidad.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: unidad.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    color: unidad.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unidad.nombre,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text(unidad.ruta,
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('En ruta',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF4ADE80),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Monitoreo de Unidades',
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF9333EA)),
            tooltip: 'Seleccionar unidad',
            onPressed: _mostrarSelectorUnidades,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Elige una unidad para ver su recorrido en tiempo real',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          ...unidadesRecoleccion.map((u) => _unidadTile(u)),
        ],
      ),
    );
  }
}
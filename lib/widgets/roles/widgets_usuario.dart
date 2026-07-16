import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════════
// WIDGETS EXCLUSIVOS DEL USUARIO REGISTRADO
// Ubicación: lib/widgets/roles/widgets_usuario.dart
// ══════════════════════════════════════════════════════════════════
class WidgetsUsuario {

  // ── Panel principal de usuario ──────────────────────────────
  static Widget panelUsuario({required VoidCallback alPresionar}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0C4A6E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Panel de Usuario',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _botonUsuario(
                icono: Icons.map_outlined,
                etiqueta: 'Mapa',
                alPresionar: alPresionar,
                color: const Color(0xFF60A5FA),
              ),
              const SizedBox(width: 8),
              _botonUsuario(
                icono: Icons.report_problem_outlined,
                etiqueta: 'Reportar',
                alPresionar: alPresionar,
                color: const Color(0xFFFBBF24),
              ),
              const SizedBox(width: 8),
              _botonUsuario(
                icono: Icons.history_rounded,
                etiqueta: 'Historial',
                alPresionar: alPresionar,
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _botonUsuario({
    required IconData icono,
    required String etiqueta,
    required VoidCallback alPresionar,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: alPresionar,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(height: 2),
              Text(etiqueta,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Botón de reporte de problema ────────────────────────────
  static Widget botonReportar({required VoidCallback alPresionar}) {
    return ElevatedButton.icon(
      onPressed: alPresionar,
      icon: const Icon(Icons.report_outlined, size: 18),
      label: Text('Reportar problema',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── Tarjeta de actividad reciente ───────────────────────────
  static Widget tarjetaActividadReciente({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(descripcion,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.25), size: 18),
        ],
      ),
    );
  }

  // ── Tarjeta de estado de reporte ────────────────────────────
  static Widget tarjetaEstadoReporte({
    required String titulo,
    required String estado,
    required Color colorEstado,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: colorEstado, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(titulo,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorEstado.withOpacity(0.4)),
            ),
            child: Text(estado,
                style: GoogleFonts.poppins(
                    color: colorEstado,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
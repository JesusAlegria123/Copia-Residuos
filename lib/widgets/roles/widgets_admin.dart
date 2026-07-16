import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════════
// WIDGETS EXCLUSIVOS DEL ADMINISTRADOR
// Ubicación: lib/widgets/roles/widgets_admin.dart
// ══════════════════════════════════════════════════════════════════
class WidgetsAdmin {

  // ── Panel principal de administración ──────────────────────
  static Widget panelAdmin({required VoidCallback alPresionar}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
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
              const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white),
              const SizedBox(width: 8),
              Text('Panel de Administración',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _botonAdmin(
                icono: Icons.people_rounded,
                etiqueta: 'Usuarios',
                alPresionar: alPresionar,
                color: const Color(0xFF4ADE80),
              ),
              const SizedBox(width: 8),
              _botonAdmin(
                icono: Icons.bar_chart_rounded,
                etiqueta: 'Reportes',
                alPresionar: alPresionar,
                color: const Color(0xFF60A5FA),
              ),
              const SizedBox(width: 8),
              _botonAdmin(
                icono: Icons.settings_rounded,
                etiqueta: 'Configuración',
                alPresionar: alPresionar,
                color: const Color(0xFFF472B6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _botonAdmin({
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

  // ── Botón de gestión de usuarios ────────────────────────────
  static Widget botonGestionUsuarios({required VoidCallback alPresionar}) {
    return ElevatedButton.icon(
      onPressed: alPresionar,
      icon: const Icon(Icons.people_rounded, size: 18),
      label: Text('Gestionar Usuarios',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── Botón de eliminación ────────────────────────────────────
  static Widget botonEliminar({required VoidCallback alPresionar}) {
    return ElevatedButton.icon(
      onPressed: alPresionar,
      icon: const Icon(Icons.delete_outline_rounded, size: 18),
      label: Text('Eliminar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── Tarjeta de estadísticas ─────────────────────────────────
  static Widget tarjetaEstadistica({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text(titulo,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de acción rápida ────────────────────────────────
  static Widget tarjetaAccionRapida({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
    required VoidCallback alPresionar,
  }) {
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 22),
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
                          fontWeight: FontWeight.w700)),
                  Text(subtitulo,
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
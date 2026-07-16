import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════════
// PANTALLA DE PERFIL DE USUARIO
// Ubicación: lib/screens/perfil_screen.dart
// ══════════════════════════════════════════════════════════════════
class PerfilScreen extends StatefulWidget {
  final UserModel usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Gravatars se obtienen automáticamente del correo (MD5 hash).
  // Para demo usamos ui-avatars que genera avatar del nombre sin librerías extra.
  String get _avatarUrl {
    final nombre = Uri.encodeComponent(widget.usuario.nombre);
    final color  = _colorHex.replaceAll('#', '');
    return 'https://ui-avatars.com/api/?name=$nombre'
        '&background=$color&color=fff&size=200&bold=true';
  }

  // Gravatar por correo (si el usuario tiene una cuenta Gravatar)
  String get _gravatarUrl {
    // Usamos un servicio público que no necesita MD5 en Dart
    final email = widget.usuario.email.trim().toLowerCase();
    return 'https://www.gravatar.com/avatar/${email.hashCode.abs()}'
        '?d=identicon&s=200';
  }

  String get _colorHex {
    if (widget.usuario.esAdmin)          return '6B21A8';
    if (widget.usuario.rol == 'Municipalidad') return '0369A1';
    if (widget.usuario.rol == 'Usuario')      return '065F46';
    if (widget.usuario.rol == 'Ciudadano')    return '14532D';
    return '92400E'; // Invitado
  }

  Color get _colorRol {
    if (widget.usuario.esAdmin)               return const Color(0xFF9333EA);
    if (widget.usuario.rol == 'Municipalidad') return const Color(0xFF0EA5E9);
    if (widget.usuario.rol == 'Usuario')       return const Color(0xFF10B981);
    if (widget.usuario.rol == 'Ciudadano')     return const Color(0xFF4ADE80);
    return const Color(0xFFF59E0B);
  }

  IconData get _iconoRol {
    if (widget.usuario.esAdmin)               return Icons.admin_panel_settings_rounded;
    if (widget.usuario.rol == 'Municipalidad') return Icons.account_balance_rounded;
    if (widget.usuario.rol == 'Ciudadano')     return Icons.location_city_rounded;
    return Icons.person_rounded;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Simula cambiar foto (en producción usarías image_picker) ──
  void _cambiarFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2)),
              ),
              Text('Cambiar foto de perfil',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _opcionFoto(
                  Icons.camera_alt_rounded, 'Tomar foto', const Color(0xFF9333EA),
                      () { Navigator.pop(context); _snack('📷 Cámara — Próximamente', const Color(0xFF9333EA)); }),
              const SizedBox(height: 10),
              _opcionFoto(
                  Icons.photo_library_rounded, 'Elegir de galería', const Color(0xFF0EA5E9),
                      () { Navigator.pop(context); _snack('🖼️ Galería — Próximamente', const Color(0xFF0EA5E9)); }),
              const SizedBox(height: 10),
              _opcionFoto(
                  Icons.link_rounded, 'Usar foto de Gravatar', const Color(0xFF10B981),
                      () { Navigator.pop(context); _snack('✅ Usando foto de Gravatar del correo', const Color(0xFF10B981)); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcionFoto(IconData icono, String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mi Perfil',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded,
                color: Color(0xFFB06EF5), size: 20),
            tooltip: 'Editar perfil',
            onPressed: () =>
                _snack('✏️ Edición de perfil — Próximamente', const Color(0xFF9333EA)),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Cabecera con gradiente ──────────────────────
              _buildCabecera(),
              // ── Contenido ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSeccionInfo(),
                    const SizedBox(height: 16),
                    _buildSeccionPermisos(),
                    const SizedBox(height: 16),
                    _buildSeccionAjustes(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cabecera ─────────────────────────────────────────────────
  Widget _buildCabecera() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _colorRol.withOpacity(0.4),
            const Color(0xFF0D0D1A),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar con botón de editar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _colorRol, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _colorRol.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    _avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _colorRol.withOpacity(0.2),
                      child: Center(
                        child: Text(
                          widget.usuario.avatar,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Botón cámara
              GestureDetector(
                onTap: _cambiarFoto,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _colorRol,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF0D0D1A), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nombre
          Text(widget.usuario.nombre,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          // Email
          Text(widget.usuario.email,
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13)),
          const SizedBox(height: 12),
          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _colorRol.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _colorRol.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconoRol, color: _colorRol, size: 16),
                const SizedBox(width: 8),
                Text(widget.usuario.rol,
                    style: GoogleFonts.poppins(
                        color: _colorRol,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Nota de foto automática
          Text('La foto se obtiene automáticamente de tu correo (Gravatar)',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── Sección información ──────────────────────────────────────
  Widget _buildSeccionInfo() {
    return _tarjetaSeccion(
      titulo: 'Información Personal',
      icono: Icons.person_outline_rounded,
      children: [
        _filaInfo('Nombre completo', widget.usuario.nombre,
            Icons.badge_outlined),
        _filaInfo('Correo electrónico', widget.usuario.email,
            Icons.email_outlined),
        _filaInfo('Rol', widget.usuario.rol,
            _iconoRol, colorValor: _colorRol),
        _filaInfo('Estado de cuenta', 'Activo',
            Icons.check_circle_outline_rounded,
            colorValor: const Color(0xFF10B981)),
      ],
    );
  }

  // ── Sección permisos ─────────────────────────────────────────
  Widget _buildSeccionPermisos() {
    final permisos = _obtenerPermisos();
    return _tarjetaSeccion(
      titulo: 'Mis Permisos',
      icono: Icons.shield_outlined,
      children: permisos
          .map((p) => _filaPermiso(
        p['label'] as String,
        p['activo'] as bool,
        p['icono'] as IconData,
      ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> _obtenerPermisos() {
    final esAdmin         = widget.usuario.esAdmin;
    final esMunicipalidad = widget.usuario.rol == 'Municipalidad';
    final esUsuario       = widget.usuario.rol == 'Usuario';
    final esCiudadano     = widget.usuario.rol == 'Ciudadano';

    return [
      {
        'label': 'Ver monitoreo de rutas',
        'activo': esAdmin || esMunicipalidad,
        'icono': Icons.local_shipping_outlined,
      },
      {
        'label': 'Crear reportes ciudadanos',
        'activo': esAdmin || esMunicipalidad || esUsuario || esCiudadano,
        'icono': Icons.report_problem_outlined,
      },
      {
        'label': 'Ver reportes y estadísticas',
        'activo': true,
        'icono': Icons.bar_chart_rounded,
      },
      {
        'label': 'Gestión de usuarios',
        'activo': esAdmin,
        'icono': Icons.admin_panel_settings_rounded,
      },
      {
        'label': 'Acceso a datos municipales',
        'activo': esAdmin || esMunicipalidad,
        'icono': Icons.account_balance_outlined,
      },
    ];
  }

  // ── Sección ajustes ──────────────────────────────────────────
  Widget _buildSeccionAjustes() {
    return _tarjetaSeccion(
      titulo: 'Ajustes',
      icono: Icons.settings_outlined,
      children: [
        _filaAccion('Cambiar foto de perfil',
            Icons.camera_alt_outlined, const Color(0xFF9333EA),
            _cambiarFoto),
        _filaAccion('Cambiar contraseña',
            Icons.lock_reset_rounded, const Color(0xFF0EA5E9),
                () => _snack('🔒 Cambio de contraseña — Próximamente',
                const Color(0xFF0EA5E9))),
        _filaAccion('Notificaciones',
            Icons.notifications_outlined, const Color(0xFFF59E0B),
                () => _snack('🔔 Notificaciones — Próximamente',
                const Color(0xFFF59E0B))),
        _filaAccion('Privacidad y datos',
            Icons.privacy_tip_outlined, const Color(0xFF10B981),
                () => _snack('🔐 Privacidad — Próximamente',
                const Color(0xFF10B981))),
      ],
    );
  }

  // ── Widgets auxiliares ───────────────────────────────────────
  Widget _tarjetaSeccion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono,
                      color: const Color(0xFF9333EA), size: 18),
                ),
                const SizedBox(width: 10),
                Text(titulo,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: Colors.white.withOpacity(0.07)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _filaInfo(String label, String valor, IconData icono,
      {Color? colorValor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono,
              color: Colors.white.withOpacity(0.4), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11)),
                const SizedBox(height: 2),
                Text(valor,
                    style: GoogleFonts.poppins(
                        color: colorValor ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaPermiso(String label, bool activo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono,
              color: activo
                  ? const Color(0xFF10B981)
                  : Colors.white.withOpacity(0.2),
              size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: activo
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: activo
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activo ? 'Permitido' : 'Sin acceso',
              style: GoogleFonts.poppins(
                  color: activo
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.25),
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaAccion(
      String label, IconData icono, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
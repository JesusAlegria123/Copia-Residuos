import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'monitoreo_screen.dart';
import 'reportes_screen.dart';
import 'reportes_admin_screen.dart';
import 'perfil_screen.dart';
import 'estadisticas_usuarios_screen.dart';
import 'estadisticas_rutas_screen.dart';
import 'estadisticas_residuos_screen.dart';
import 'estadisticas_alertas_screen.dart';

const double kWebBreakpoint = 800;

class HomeScreen extends StatefulWidget {
  final UserModel usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  int _navIndex = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── Helpers de rol ───────────────────────────────────────────
  bool get _esAdmin         => widget.usuario.rol == 'Administrador';
  bool get _esMunicipalidad => widget.usuario.rol == 'Municipalidad';
  bool get _esUsuario       => widget.usuario.rol == 'Usuario';
  bool get _esCiudadano     => widget.usuario.rol == 'Ciudadano';

  bool get _puedeVerMonitoreo    => _esAdmin || _esMunicipalidad;
  bool get _puedeCrearReporte    => _esAdmin || _esMunicipalidad || _esUsuario || _esCiudadano;
  bool get _puedeGestionUsuarios => _esAdmin;
  bool get _puedeVerEstadisticas => _esAdmin || _esMunicipalidad;

  Color get _colorRol {
    if (_esAdmin)         return const Color(0xFF9333EA);
    if (_esMunicipalidad) return const Color(0xFF0EA5E9);
    if (_esUsuario)       return const Color(0xFF10B981);
    if (_esCiudadano)     return const Color(0xFF4ADE80);
    return const Color(0xFFF59E0B);
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

  // ── Utilidades ───────────────────────────────────────────────
  void _navegarA(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

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

  void _sinPermiso() =>
      _snack('🔒 No tienes permiso para esta sección',
          const Color(0xFFEF4444));

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Acciones de navegación ───────────────────────────────────
  void _irMonitoreo() => _puedeVerMonitoreo
      ? _navegarA(const MonitoreoScreen())
      : _sinPermiso();

  void _irReportes() => _esAdmin || _esMunicipalidad
      ? _navegarA(const ReportesAdminScreen())
      : _navegarA(const ReportesScreen());

  void _irPerfil() => _navegarA(PerfilScreen(usuario: widget.usuario));

  void _irNuevoReporte() => _puedeCrearReporte
      ? _snack('📝 Nuevo Reporte — Próximamente', Colors.orange)
      : _sinPermiso();

  void _irMapa() => _snack('🗺️ Mapa — Próximamente', Colors.blue);

  void _irSeguimiento() => _puedeVerMonitoreo
      ? _snack('🚛 Seguimiento — Próximamente', Colors.red)
      : _sinPermiso();

  void _irGestionUsuarios() => _puedeGestionUsuarios
      ? _navegarA(GestionUsuariosScreen(adminActual: widget.usuario))
      : _sinPermiso();

  // ── Estadísticas — cada KPI abre su pantalla propia ─────────
  void _irEstadisticasUsuarios() => _puedeVerEstadisticas
      ? _navegarA(const EstadisticasUsuariosScreen())
      : _sinPermiso();

  void _irEstadisticasRutas() => _puedeVerEstadisticas
      ? _navegarA(const EstadisticasRutasScreen())
      : _sinPermiso();

  void _irEstadisticasResiduos() => _puedeVerEstadisticas
      ? _navegarA(const EstadisticasResiduosScreen())
      : _sinPermiso();

  void _irEstadisticasAlertas() => _puedeVerEstadisticas
      ? _navegarA(const EstadisticasAlertasScreen())
      : _sinPermiso();

  // ── Bottom nav (0-3) ─────────────────────────────────────────
  void _navegarDesdeBottomNav(int index) {
    switch (index) {
      case 1: _irMonitoreo(); break;
      case 2: _irReportes();  break;
      case 3: _irPerfil();    break;
      default: setState(() => _navIndex = 0);
    }
  }

  // ── Sidebar web ──────────────────────────────────────────────
  void _navegarDesdeSidebar(String ruta) {
    switch (ruta) {
      case 'dashboard':     setState(() => _navIndex = 0);  break;
      case 'monitoreo':     _irMonitoreo();                 break;
      case 'reportes':      _irReportes();                  break;
      case 'nuevo_reporte': _irNuevoReporte();              break;
      case 'perfil':        _irPerfil();                    break;
      case 'gestion':       _irGestionUsuarios();           break;
      case 'alertas':
        _snack('🔔 Alertas — Próximamente', Colors.orange); break;
      case 'ajustes':
        _snack('⚙️ Ajustes — Próximamente', Colors.grey);   break;
    }
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Cerrar sesión?',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        content: Text('¿Estás seguro de que deseas cerrar sesión?',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B21A8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Salir',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final esWeb = MediaQuery.of(context).size.width >= kWebBreakpoint;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: _buildAppBar(esWeb),
      body: Stack(
        children: [
          const AnimatedBackground(),
          FadeTransition(
            opacity: _fadeAnim,
            child: esWeb ? _buildBodyWeb() : _buildBodyMovil(),
          ),
        ],
      ),
      bottomNavigationBar: esWeb ? null : _buildNavBar(),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool esWeb) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.05),
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.recycling_rounded,
                color: Color(0xFFB06EF5), size: 20),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('UNSAAC',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2)),
                Text(widget.usuario.nombre,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.45)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (esWeb) ...[
          _navChipWeb('Inicio',    'dashboard'),
          if (_puedeVerMonitoreo) _navChipWeb('Monitoreo', 'monitoreo'),
          _navChipWeb('Reportes',  'reportes'),
          if (_puedeCrearReporte) _navChipWeb('Nuevo',     'nuevo_reporte'),
          const SizedBox(width: 4),
        ],
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _colorRol.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _colorRol.withOpacity(0.4)),
          ),
          child: Text(widget.usuario.rol,
              style: GoogleFonts.poppins(
                  color: _colorRol,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: _irPerfil,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: _colorRol.withOpacity(0.3),
            child: Text(widget.usuario.avatar,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          color: Colors.white.withOpacity(0.55),
          tooltip: 'Cerrar sesión',
          onPressed: _confirmarLogout,
        ),
      ],
    );
  }

  Widget _navChipWeb(String label, String ruta) => TextButton(
    onPressed: () => _navegarDesdeSidebar(ruta),
    child: Text(label,
        style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500)),
  );

  // ════════════════════════════════════════════════════════════
  // BODY WEB
  // ════════════════════════════════════════════════════════════
  Widget _buildBodyWeb() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebar(),
        Expanded(child: _buildContenidoWeb()),
      ],
    );
  }

  Widget _buildSidebar() {
    final itemsComunes = <Map<String, dynamic>>[
      {'icono': Icons.dashboard_rounded,      'label': 'Dashboard',     'ruta': 'dashboard'},
      {'icono': Icons.bar_chart_rounded,      'label': 'Reportes',      'ruta': 'reportes'},
      {'icono': Icons.report_problem_outlined,'label': 'Nuevo Reporte', 'ruta': 'nuevo_reporte'},
      {'icono': Icons.person_outline_rounded, 'label': 'Mi Perfil',     'ruta': 'perfil'},
    ];

    final itemsElevados = <Map<String, dynamic>>[
      {'icono': Icons.local_shipping_rounded, 'label': 'Monitoreo',   'ruta': 'monitoreo'},
      {'icono': Icons.notifications_rounded,  'label': 'Alertas',     'ruta': 'alertas'},
      {'icono': Icons.settings_rounded,       'label': 'Ajustes',     'ruta': 'ajustes'},
    ];

    final items = _puedeVerMonitoreo
        ? [...itemsComunes, ...itemsElevados]
        : itemsComunes;

    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.07))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: _irPerfil,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _colorRol.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _colorRol.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _colorRol.withOpacity(0.3),
                      child: Text(widget.usuario.avatar,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.usuario.nombre,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                          Text(widget.usuario.rol,
                              style: GoogleFonts.poppins(
                                  color: _colorRol,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...items.map((item) => _sidebarItem(item)),
                  if (_puedeGestionUsuarios)
                    _sidebarItem({
                      'icono': Icons.admin_panel_settings_rounded,
                      'label': 'Gestión Usuarios',
                      'ruta': 'gestion',
                    }, destacado: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text('v1.0.0 · UNSAAC 2025',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.2))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(Map<String, dynamic> item,
      {bool destacado = false}) {
    final ruta   = item['ruta'] as String;
    final activo = _navIndex == 0 && ruta == 'dashboard';
    final color  = destacado ? const Color(0xFFB06EF5) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navegarDesdeSidebar(ruta),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFF6B21A8).withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: activo
                ? Border.all(color: const Color(0xFF9333EA).withOpacity(0.35))
                : null,
          ),
          child: Row(children: [
            Icon(item['icono'] as IconData,
                color: color ??
                    (activo
                        ? const Color(0xFFB06EF5)
                        : Colors.white.withOpacity(0.45)),
                size: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item['label'] as String,
                  style: GoogleFonts.poppins(
                      color: color ??
                          (activo
                              ? const Color(0xFFE9D5FF)
                              : Colors.white.withOpacity(0.5)),
                      fontSize: 13,
                      fontWeight: activo || destacado
                          ? FontWeight.w600
                          : FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Contenido web ────────────────────────────────────────────
  Widget _buildContenidoWeb() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          if (!_esAdmin) ...[
            const SizedBox(height: 14),
            _buildBannerRol(),
          ],
          const SizedBox(height: 22),
          _buildKpisWeb(),
          const SizedBox(height: 22),
          Text('Módulos del sistema',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _modulosVisibles.map(_buildModuloCard).toList(),
          ),
          const SizedBox(height: 22),
          _buildPanelActividad(),
        ],
      ),
    );
  }

  Widget _buildKpisWeb() {
    final kpis = _kpisParaRol();
    return Row(
      children: kpis.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.key < kpis.length - 1 ? 12 : 0),
          child: e.value,
        ),
      )).toList(),
    );
  }

  // ════════════════════════════════════════════════════════════
  // BODY MÓVIL
  // ════════════════════════════════════════════════════════════
  Widget _buildBodyMovil() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          if (!_esAdmin) ...[
            const SizedBox(height: 12),
            _buildBannerRol(),
          ],
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: _kpisParaRol(),
          ),
          const SizedBox(height: 20),
          Text('Módulos',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: _modulosVisibles.map(_buildModuloCard).toList(),
          ),
          if (_puedeGestionUsuarios) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _irGestionUsuarios,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B21A8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF9333EA).withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      color: Color(0xFFB06EF5), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Gestión de Usuarios',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.3)),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildPanelActividad(),
        ],
      ),
    );
  }

  // ── Banner ───────────────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C1D95).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dashboard',
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              Text('¡Hola, ${widget.usuario.nombre}! 👋',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              const SizedBox(height: 2),
              Text(widget.usuario.email,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Icon(Icons.recycling_rounded,
              color: Colors.white, size: 28),
        ),
      ]),
    );
  }

  // ── Banner rol ───────────────────────────────────────────────
  Widget _buildBannerRol() {
    final String titulo;
    final String subtitulo;
    final IconData icono;

    if (_esMunicipalidad) {
      titulo    = 'Acceso Municipalidad';
      subtitulo = 'Monitoreo, reportes y estadísticas.';
      icono     = Icons.account_balance_rounded;
    } else if (_esUsuario || _esCiudadano) {
      titulo    = 'Acceso Ciudadano';
      subtitulo = 'Puedes ver y crear reportes.';
      icono     = Icons.person_rounded;
    } else {
      titulo    = 'Modo Invitado';
      subtitulo = 'Solo información pública.';
      icono     = Icons.visibility_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _colorRol.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorRol.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(icono, color: _colorRol, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo,
                  style: GoogleFonts.poppins(
                      color: _colorRol,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              Text(subtitulo,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.45), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ],
          ),
        ),
        Icon(Icons.lock_outline_rounded,
            color: _colorRol.withOpacity(0.5), size: 15),
      ]),
    );
  }

  // ── KPIs según rol — cada uno abre su estadística ────────────
  List<Widget> _kpisParaRol() {
    if (_esAdmin || _esMunicipalidad) {
      return [
        _kpiCard('2,400', 'Usuarios', Icons.people_rounded,
            const Color(0xFF9333EA), '+12%',
            onTap: _irEstadisticasUsuarios),       // ← abre estadísticas
        _kpiCard('48', 'Rutas activas', Icons.route_rounded,
            const Color(0xFF0EA5E9), '+3',
            onTap: _irEstadisticasRutas),           // ← abre estadísticas
        _kpiCard('1.2T', 'Residuos/mes', Icons.delete_outline_rounded,
            const Color(0xFF10B981), '-5%',
            onTap: _irEstadisticasResiduos),        // ← abre estadísticas
        _kpiCard('7', 'Alertas', Icons.warning_amber_rounded,
            const Color(0xFFF59E0B), 'hoy',
            onTap: _irEstadisticasAlertas),         // ← abre estadísticas
      ];
    }
    return [
      _kpiCard('3', 'Mis Reportes', Icons.assignment_outlined,
          const Color(0xFF10B981), '+1',
          onTap: _irReportes),
      _kpiCard('7', 'Alertas', Icons.warning_amber_rounded,
          const Color(0xFFF59E0B), 'hoy',
          onTap: () => _snack('⚠️ 7 alertas en tu zona',
              const Color(0xFFF59E0B))),
      _kpiCard('240kg', 'Reciclaje hoy', Icons.eco_rounded,
          const Color(0xFF4ADE80), '+8%',
          onTap: () => _snack('♻️ 240 kg reciclados hoy',
              const Color(0xFF4ADE80))),
    ];
  }

  Widget _kpiCard(String valor, String label, IconData icono,
      Color color, String tendencia, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icono, color: color, size: 16),
                ),
                // Indicador "tap" para estadísticas
                if (_puedeVerEstadisticas)
                  Icon(Icons.bar_chart_rounded,
                      color: color.withOpacity(0.5), size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valor,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
                Row(children: [
                  Expanded(
                    child: Text(label,
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tendencia,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF4ADE80),
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Módulos ──────────────────────────────────────────────────
  static const _definicionModulos = [
    {'nombre': 'report_problem', 'titulo': 'Nuevo Reporte',
      'sub': 'Ciudadano',    'hex': 0xFFF59E0B, 'ruta': 'nuevo_reporte', 'nivel': 'todos'},
    {'nombre': 'bar_chart',      'titulo': 'Reportes',
      'sub': 'Estadísticas', 'hex': 0xFF10B981, 'ruta': 'reportes',      'nivel': 'todos'},
    {'nombre': 'eco',            'titulo': 'Reciclaje',
      'sub': 'Sostenible',   'hex': 0xFF4ADE80, 'ruta': 'reciclaje',     'nivel': 'todos'},
    {'nombre': 'local_shipping', 'titulo': 'Monitoreo',
      'sub': 'Tiempo real',  'hex': 0xFF6B21A8, 'ruta': 'monitoreo',     'nivel': 'admin'},
    {'nombre': 'map',            'titulo': 'Mapa',
      'sub': 'Ubicación',    'hex': 0xFF0EA5E9, 'ruta': 'mapa',          'nivel': 'admin'},
    {'nombre': 'route',          'titulo': 'Seguimiento',
      'sub': 'Unidades',     'hex': 0xFFEF4444, 'ruta': 'seguimiento',   'nivel': 'admin'},
    {'nombre': 'account_balance','titulo': 'Municipio',
      'sub': 'Oficial',      'hex': 0xFF8B5CF6, 'ruta': 'municipio',     'nivel': 'admin'},
    {'nombre': 'analytics',      'titulo': 'Estadísticas',
      'sub': 'Avanzadas',    'hex': 0xFF9333EA, 'ruta': 'estadisticas',  'nivel': 'admin'},
  ];

  List<Map<String, dynamic>> get _modulosVisibles =>
      _definicionModulos.where((m) {
        if (m['nivel'] == 'todos') return true;
        return _puedeVerMonitoreo;
      }).map((m) => {
        'icono': _icono(m['nombre'] as String),
        'titulo': m['titulo'],
        'sub': m['sub'],
        'color': Color(m['hex'] as int),
        'ruta': m['ruta'],
      }).toList();

  IconData _icono(String n) {
    switch (n) {
      case 'local_shipping':  return Icons.local_shipping_outlined;
      case 'map':             return Icons.map_outlined;
      case 'report_problem':  return Icons.report_problem_outlined;
      case 'bar_chart':       return Icons.bar_chart_rounded;
      case 'route':           return Icons.route_outlined;
      case 'account_balance': return Icons.account_balance_outlined;
      case 'analytics':       return Icons.analytics_rounded;
      case 'eco':             return Icons.eco_rounded;
      default:                return Icons.widgets_outlined;
    }
  }

  Widget _buildModuloCard(Map<String, dynamic> m) {
    final acciones = <String, VoidCallback>{
      'monitoreo'    : _irMonitoreo,
      'mapa'         : _irMapa,
      'nuevo_reporte': _irNuevoReporte,
      'reportes'     : _irReportes,
      'seguimiento'  : _irSeguimiento,
      'estadisticas' : _irEstadisticasUsuarios,
      'reciclaje'    : _irEstadisticasResiduos,
      'municipio'    : () => _snack('🏛️ Datos del Municipio',
          const Color(0xFF8B5CF6)),
    };
    final onTap = acciones[m['ruta'] as String] ??
            () => _snack('📱 ${m['titulo']}', m['color'] as Color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: (m['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(m['icono'] as IconData,
                  color: m['color'] as Color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m['titulo'] as String,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
                Text(m['sub'] as String,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45), fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Panel actividad ──────────────────────────────────────────
  Widget _buildPanelActividad() {
    final todas = <Map<String, dynamic>>[
      {
        'icono': Icons.check_circle_outline,
        'titulo': 'Ruta completada — Zona A',
        'sub': 'Hace 2 h',
        'color': const Color(0xFF10B981),
        'soloAdmin': true,
        'accion': () => _snack('✅ Ruta Zona A completada',
            const Color(0xFF10B981)),
      },
      {
        'icono': Icons.warning_amber_outlined,
        'titulo': 'Punto saturado — Mercado Central',
        'sub': 'Hace 4 h',
        'color': const Color(0xFFF59E0B),
        'soloAdmin': false,
        'accion': _irReportes,
      },
      {
        'icono': Icons.person_add_outlined,
        'titulo': 'Nuevo reporte ciudadano',
        'sub': 'Hace 5 h',
        'color': const Color(0xFF0EA5E9),
        'soloAdmin': false,
        'accion': _irNuevoReporte,
      },
      {
        'icono': Icons.local_shipping_outlined,
        'titulo': 'Camión asignado — Ruta 7',
        'sub': 'Hace 6 h',
        'color': const Color(0xFF9333EA),
        'soloAdmin': true,
        'accion': _irMonitoreo,
      },
      {
        'icono': Icons.eco_outlined,
        'titulo': 'Reciclaje registrado — 240 kg',
        'sub': 'Hace 8 h',
        'color': const Color(0xFF4ADE80),
        'soloAdmin': false,
        'accion': _irEstadisticasResiduos,
      },
    ];

    final visibles = todas
        .where((a) => !(a['soloAdmin'] as bool) || _puedeVerMonitoreo)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Actividad reciente',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 12),
          ...visibles.map((a) => GestureDetector(
            onTap: a['accion'] as VoidCallback,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a['icono'] as IconData,
                      color: a['color'] as Color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(a['titulo'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text(a['sub'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.2), size: 16),
              ]),
            ),
          )),
        ],
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1F),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _navegarDesdeBottomNav,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF9333EA),
        unselectedItemColor: Colors.white.withOpacity(0.3),
        selectedLabelStyle:
        GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined,
                  color: _puedeVerMonitoreo
                      ? null
                      : Colors.white.withOpacity(0.18)),
              activeIcon: const Icon(Icons.local_shipping_rounded),
              label: 'Monitoreo'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reportes'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// FONDO ANIMADO
// ══════════════════════════════════════════════════════════════════
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this,
        duration: const Duration(seconds: 9))..repeat(reverse: true);
    _c2 = AnimationController(vsync: this,
        duration: const Duration(seconds: 13))..repeat(reverse: true);
    _c3 = AnimationController(vsync: this,
        duration: const Duration(seconds: 7))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _BgPainter(t1: _c1.value, t2: _c2.value, t3: _c3.value),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t1, t2, t3;
  _BgPainter({required this.t1, required this.t2, required this.t3});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF0D0D1A));
    _orb(canvas,
        Offset(size.width * (.15 + t1 * .35), size.height * (.08 + t1 * .18)),
        size.width * .60, const Color(0xFF6B21A8), .38);
    _orb(canvas,
        Offset(size.width * (.75 - t2 * .25), size.height * (.55 + t2 * .22)),
        size.width * .65, const Color(0xFF312E81), .45);
    _orb(canvas,
        Offset(size.width * (.82 + t3 * .12), size.height * (.22 - t3 * .12)),
        size.width * .38, const Color(0xFF064E3B), .30);
    _orb(canvas,
        Offset(size.width * (.05 - t1 * .05), size.height * (.75 + t3 * .15)),
        size.width * .40, const Color(0xFF7C1E6A), .22);
  }

  void _orb(Canvas c, Offset center, double r, Color color, double op) {
    c.drawCircle(center, r, Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(op), color.withOpacity(op * .5),
          color.withOpacity(0)],
        stops: const [0, .5, 1],
      ).createShader(Rect.fromCircle(center: center, radius: r)));
  }

  @override
  bool shouldRepaint(_BgPainter o) =>
      o.t1 != t1 || o.t2 != t2 || o.t3 != t3;
}
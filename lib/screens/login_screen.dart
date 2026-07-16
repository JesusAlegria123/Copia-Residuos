import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

const double kWebBreakpoint = 800;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  final _authService        = AuthService();

  bool _cargando   = false;
  bool _recordarme = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimaciones();
    _cargarDatos();
  }

  void _initAnimaciones() {
    _fadeCtrl  = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _slideCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _slideCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) { _fadeCtrl.forward(); _slideCtrl.forward(); }
    });
  }

  Future<void> _cargarDatos() async {
    final email      = await _authService.cargarEmailGuardado();
    final recuerdame = await _authService.obtenerRecordarme();
    if (mounted) {
      setState(() {
        _recordarme = recuerdame;
        if (email != null) _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── LOGIN ────────────────────────────────────────────────────
  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final usuario = await _authService.login(
        email     : _emailController.text,
        password  : _passwordController.text,
        recordarme: _recordarme,
      );
      if (!mounted) return;
      if (usuario != null) {
        _snack('✅  Inicio de sesión exitoso', const Color(0xFF16A34A));
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(usuario: usuario),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        _snack('❌  Usuario o contraseña incorrectos', const Color(0xFFDC2626));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ══════════════════════════════════════════════════════════════
  // MENÚ HAMBURGUESA — BottomSheet con info
  // ══════════════════════════════════════════════════════════════
  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MenuInfoSheet(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // REGISTRO — abre pantalla de registro
  // ══════════════════════════════════════════════════════════════
  void _abrirRegistro() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            RegistroScreen(authService: _authService),
        transitionsBuilder: (_, a, __, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    ).then((usuario) {
      // Si regresa con un usuario registrado, navega al home
      if (usuario != null && usuario is UserModel && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(usuario: usuario),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  // ════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final esWeb = width >= kWebBreakpoint;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          const AnimatedBackground(),
          esWeb ? _buildLayoutWeb() : _buildLayoutMovil(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // LAYOUT WEB
  // ════════════════════════════════════════════════════════════
  Widget _buildLayoutWeb() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeaderWeb(),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 55, child: _buildPanelInfo()),
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 40),
                    color: Colors.white.withOpacity(0.07),
                  ),
                  Expanded(flex: 45, child: _buildPanelLoginWeb()),
                ],
              ),
            ),
            _buildFooterWeb(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWeb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF9333EA).withOpacity(0.35)),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF289124),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.recycling_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFE9D5FF), Color(0xFF9333EA)],
            ).createShader(b),
            child: Text('Cusco Limpio',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 4)),
          ),
          const Spacer(),
          _navLink('Inicio'),
          _navLink('Acerca de'),
          _navLink('Servicios'),
          _navLink('Contacto'),
          const SizedBox(width: 8),
          // Botón Registrarse en web
          OutlinedButton.icon(
            onPressed: _abrirRegistro,
            icon: const Icon(Icons.person_add_rounded,
                size: 16, color: Color(0xFFB06EF5)),
            label: Text('Registrarse',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFB06EF5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {},
        child: Text(texto,
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildPanelInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9333EA).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF9333EA).withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Plataforma activa · Cusco 2026',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFFB06EF5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Gestión inteligente\nde residuos sólidos',
                style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2)),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFF4ADE80)],
              ).createShader(b),
              child: Text('Cusco, Perú',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const SizedBox(height: 24),
            Text(
              'Plataforma digital para la gestión de residuos sólidos. '
                  'Monitoreo en tiempo real, participación ciudadana y datos '
                  'para la municipalidad.',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.7),
            ),
            const SizedBox(height: 36),
            ..._features.map((f) => _buildFeatureRow(f)),
            const SizedBox(height: 36),
            Row(
              children: [
                _buildStatWeb('2,400+', 'Usuarios activos'),
                const SizedBox(width: 32),
                _buildStatWeb('98%', 'Cobertura distrital'),
                const SizedBox(width: 32),
                _buildStatWeb('24/7', 'Monitoreo continuo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _features = [
    {
      'icono': Icons.map_outlined,
      'titulo': 'Monitoreo en tiempo real',
      'desc': 'Seguimiento GPS de rutas de recolección',
      'color': const Color(0xFF9333EA),
    },
    {
      'icono': Icons.people_outline_rounded,
      'titulo': 'Participación ciudadana',
      'desc': 'Reporta puntos críticos desde tu celular',
      'color': const Color(0xFF0EA5E9),
    },
    {
      'icono': Icons.bar_chart_rounded,
      'titulo': 'Datos para la municipalidad',
      'desc': 'Reportes y estadísticas en tiempo real',
      'color': const Color(0xFF10B981),
    },
  ];

  Widget _buildFeatureRow(Map<String, dynamic> f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (f['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: (f['color'] as Color).withOpacity(0.3)),
            ),
            child: Icon(f['icono'] as IconData,
                color: f['color'] as Color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f['titulo'] as String,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(f['desc'] as String,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatWeb(String valor, String etiqueta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFE9D5FF), Color(0xFF9333EA)],
          ).createShader(b),
          child: Text(valor,
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
        Text(etiqueta,
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildPanelLoginWeb() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: SlideTransition(
          position: _slideAnim,
          child: _buildFormularioLogin(esWeb: true),
        ),
      ),
    );
  }

  Widget _buildFooterWeb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('© 2026 UNSAAC · Gestión de Residuos Sólidos · Cusco, Perú',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.3), fontSize: 12)),
          Row(
            children: [
              _socialIcon(Icons.camera_alt_outlined,
                  const Color(0xFFE1306C), 'Instagram'),
              const SizedBox(width: 12),
              _socialIcon(
                  Icons.facebook_rounded, const Color(0xFF1877F2), 'Facebook'),
              const SizedBox(width: 12),
              _socialIcon(Icons.alternate_email_rounded,
                  const Color(0xFF1DA1F2), 'Twitter/X'),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // LAYOUT MÓVIL
  // ════════════════════════════════════════════════════════════
  Widget _buildLayoutMovil() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeaderMovil(),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFormularioLogin(esWeb: false),
                ),
                const SizedBox(height: 28),
                _buildSeccionInferiorMovil(),
                const SizedBox(height: 28),
                _buildFooterMovil(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMovil() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom:
          BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + nombre
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFE9D5FF), Color(0xFF9333EA)],
            ).createShader(b),
            child: Text('Cusco Limpio',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2)),
          ),
          Row(
            children: [
              // Botón Registrarse
              OutlinedButton(
                onPressed: _abrirRegistro,
                style: OutlinedButton.styleFrom(
                  side:
                  const BorderSide(color: Color(0xFF9333EA), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                ),
                child: Text('Registrarse',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFB06EF5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              // Tres líneas — menú funcional
              GestureDetector(
                onTap: _abrirMenu,
                child: Icon(Icons.menu_rounded,
                    color: Colors.white.withOpacity(0.8), size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // FORMULARIO DE LOGIN
  // ════════════════════════════════════════════════════════════
  Widget _buildFormularioLogin({required bool esWeb}) {
    return Container(
      padding: EdgeInsets.all(esWeb ? 36 : 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.11), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withOpacity(0.28),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF289124),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.recycling_rounded,
                      color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('Inicio de sesión',
                  style: GoogleFonts.poppins(
                      fontSize: esWeb ? 28 : 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3)),
            ),
            Center(
              child: Text('Bienvenido de vuelta',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.45))),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              controller: _emailController,
              hintText: 'Usuario',
              prefixIcon: Icons.person_outline_rounded,
              tipoTeclado: TextInputType.emailAddress,
              accionTeclado: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Por favor ingresa tu usuario'
                  : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Contraseña',
              prefixIcon: Icons.lock_outline_rounded,
              esPassword: true,
              accionTeclado: TextInputAction.done,
              onEditingComplete: _iniciarSesion,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Por favor ingresa tu contraseña'
                  : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _recordarme,
                        onChanged: (v) =>
                            setState(() => _recordarme = v ?? false),
                        activeColor: const Color(0xFF9333EA),
                        checkColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Recordarme',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.55))),
                  ],
                ),
                const Spacer(),
                Flexible(
                  child: GestureDetector(
                    onTap: () => _snack('📧 Se enviará un correo de recuperación',
                        const Color(0xFF2563EB)),
                    child: Text('¿Olvidaste tu contraseña?',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFB06EF5),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              texto: 'INICIAR',
              onPressed: _iniciarSesion,
              cargando: _cargando,
              icono: Icons.login_rounded,
            ),
            const SizedBox(height: 12),
            // ── Botón Registrarse dentro del formulario ────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _abrirRegistro,
                icon: const Icon(Icons.person_add_rounded,
                    size: 18, color: Color(0xFFB06EF5)),
                label: Text('¿No tienes cuenta? Regístrate',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFB06EF5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: Divider(
                        color: Colors.white.withOpacity(0.1), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('o accede como',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.3))),
                ),
                Expanded(
                    child: Divider(
                        color: Colors.white.withOpacity(0.1), thickness: 1)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _rolChip(
                    label: 'Admin',
                    email: 'admin@unsaac.edu.pe',
                    pass: 'Admin123',
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _rolChip(
                    label: 'Usuario',
                    email: 'usuario@test.com',
                    pass: '123456',
                    color: const Color(0xFF0369A1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _rolChip(
                    label: 'Invitado',
                    email: 'invitado@demo.com',
                    pass: 'demo123',
                    color: const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B21A8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF9333EA).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15,
                      color: const Color(0xFFB06EF5).withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Si aún no eres parte de nosotros, te invitamos a unirte.',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFFD8B4FE),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rolChip({
    required String label,
    required String email,
    required String pass,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _emailController.text    = email;
        _passwordController.text = pass;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: color.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildSeccionInferiorMovil() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C1D95).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(Icons.eco_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text('Cusco merece un futuro\nlimpio y sostenible',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3)),
          const SizedBox(height: 10),
          Text(
            'Plataforma digital para la gestión de residuos sólidos. '
                'Monitoreo en tiempo real, participación ciudadana y datos '
                'para la municipalidad.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                height: 1.6),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statMovil('2.4K', 'Usuarios'),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.2)),
              _statMovil('98%', 'Cobertura'),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.2)),
              _statMovil('24/7', 'Monitoreo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMovil(String valor, String label) {
    return Column(
      children: [
        Text(valor,
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildFooterMovil() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(
                  child: Divider(
                      color: Colors.white.withOpacity(0.12), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Síguenos',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1)),
              ),
              Expanded(
                  child: Divider(
                      color: Colors.white.withOpacity(0.12), thickness: 1)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(Icons.camera_alt_outlined,
                const Color(0xFFE1306C), 'Instagram'),
            const SizedBox(width: 16),
            _socialIcon(
                Icons.facebook_rounded, const Color(0xFF1877F2), 'Facebook'),
            const SizedBox(width: 16),
            _socialIcon(Icons.alternate_email_rounded,
                const Color(0xFF1DA1F2), 'Twitter/X'),
          ],
        ),
        const SizedBox(height: 14),
        Text('© 2025 UNSAAC · Gestión de Residuos Sólidos',
            style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.white.withOpacity(0.28))),
      ],
    );
  }

  Widget _socialIcon(IconData icono, Color color, String nombre) {
    return GestureDetector(
      onTap: () => _snack('Abriendo $nombre...', color),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icono, color: color, size: 20),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// BOTTOM SHEET — MENÚ DE INFORMACIÓN
// ══════════════════════════════════════════════════════════════════
class _MenuInfoSheet extends StatefulWidget {
  @override
  State<_MenuInfoSheet> createState() => _MenuInfoSheetState();
}

class _MenuInfoSheetState extends State<_MenuInfoSheet> {
  int? _expandido; // índice del ítem expandido

  final List<Map<String, dynamic>> _secciones = [
    {
      'icono': Icons.info_outline_rounded,
      'titulo': 'Sobre Nosotros',
      'color': const Color(0xFF9333EA),
      'contenido':
      'Somos un equipo de la Universidad Nacional de San Antonio Abad del Cusco (UNSAAC) '
          'comprometidos con el desarrollo tecnológico de nuestra región. '
          'Esta plataforma nació como proyecto de investigación en 2026 con el objetivo de '
          'modernizar la gestión de residuos sólidos en la ciudad del Cusco, integrando '
          'tecnología, participación ciudadana y datos en tiempo real para apoyar a la '
          'Municipalidad Provincial del Cusco.',
    },
    {
      'icono': Icons.help_outline_rounded,
      'titulo': 'Ayuda',
      'color': const Color(0xFF0EA5E9),
      'contenido':
      '¿Cómo usar la plataforma?\n\n'
          '• Inicia sesión con tus credenciales o regístrate como nuevo usuario.\n'
          '• En el Dashboard podrás ver el resumen general del sistema.\n'
          '• Usa el módulo de Mapa para ver las rutas de recolección en tiempo real.\n'
          '• Reporta puntos críticos de acumulación de basura desde el módulo Ciudadanos.\n'
          '• Consulta estadísticas y reportes en el módulo de Reportes.\n\n'
          'Para soporte técnico escríbenos a: soporte@cuscolimpio.pe',
    },
    {
      'icono': Icons.account_balance_outlined,
      'titulo': 'Historia de la Municipalidad',
      'color': const Color(0xFF10B981),
      'contenido':
      'La Municipalidad Provincial del Cusco fue fundada durante el período colonial, '
          'siendo una de las instituciones públicas más antiguas del Perú. '
          'A lo largo de los siglos ha sido la entidad encargada de administrar la "Ciudad Imperial", '
          'Patrimonio Cultural de la Humanidad desde 1983 según la UNESCO.\n\n'
          'En materia de gestión ambiental, la municipalidad ha impulsado desde 2010 '
          'programas de segregación en la fuente, reciclaje y educación ambiental. '
          'Con Cusco Limpio, damos un paso más hacia una ciudad inteligente y sostenible.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12122A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrastre
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Título del menú
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: Color(0xFFB06EF5), size: 20),
                ),
                const SizedBox(width: 12),
                Text('Información',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          // Ítems expandibles
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _secciones.length,
            itemBuilder: (_, i) {
              final s = _secciones[i];
              final abierto = _expandido == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: abierto
                      ? (s['color'] as Color).withOpacity(0.1)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: abierto
                        ? (s['color'] as Color).withOpacity(0.4)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Column(
                  children: [
                    // Cabecera del ítem
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          setState(() => _expandido = abierto ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: (s['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(s['icono'] as IconData,
                                  color: s['color'] as Color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(s['titulo'] as String,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Icon(
                              abierto
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Contenido expandido
                    if (abierto)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(s['contenido'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.7)),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// PANTALLA DE REGISTRO
// ══════════════════════════════════════════════════════════════════
class RegistroScreen extends StatefulWidget {
  final AuthService authService;
  const RegistroScreen({super.key, required this.authService});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _nombreCtrl       = TextEditingController();
  final _primerApellidoCtrl = TextEditingController();
  final _segundoApellidoCtrl = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passCtrl         = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();

  String _rolSeleccionado = 'Ciudadano';
  bool   _cargando        = false;
  bool   _aceptaTerminos  = false;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  final List<String> _roles = ['Ciudadano', 'Invitado'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _primerApellidoCtrl.dispose();
    _segundoApellidoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ❌ ELIMINA ESTA FUNCIÓN - Ya no se necesita
  // String getNombreCompleto() {
  //   final nombre = _nombreCtrl.text.trim();
  //   final primerApellido = _primerApellidoCtrl.text.trim();
  //   final segundoApellido = _segundoApellidoCtrl.text.trim();
  //   return '$nombre $primerApellido $segundoApellido'.trim();
  // }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      _snack('⚠️ Debes aceptar los términos y condiciones',
          const Color(0xFFF59E0B));
      return;
    }
    setState(() => _cargando = true);
    try {
      // Verificar si el email ya existe
      if (widget.authService.emailExiste(_emailCtrl.text)) {
        _snack('❌ Este correo ya está registrado', const Color(0xFFDC2626));
        return;
      }

      // 🔥 ENVIAR LOS 3 CAMPOS POR SEPARADO 🔥
      final usuario = await widget.authService.registrar(
        nombre          : _nombreCtrl.text.trim(),
        primerApellido  : _primerApellidoCtrl.text.trim(),
        segundoApellido : _segundoApellidoCtrl.text.trim(),
        email           : _emailCtrl.text,
        password        : _passCtrl.text,
        rol             : _rolSeleccionado,
      );

      if (!mounted) return;
      if (usuario != null) {
        _snack('✅ ¡Registro exitoso! Bienvenido/a', const Color(0xFF16A34A));
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pop(context, usuario);
      } else {
        _snack('❌ Error al registrar. Intenta de nuevo.',
            const Color(0xFFDC2626));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── AppBar del registro ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withOpacity(0.08), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 4),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Color(0xFFE9D5FF), Color(0xFF9333EA)],
                          ).createShader(b),
                          child: Text('Crear cuenta',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  // ── Formulario ──────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabecera
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B21A8),
                                      Color(0xFF9333EA)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7C3AED)
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.person_add_rounded,
                                    color: Colors.white,
                                    size: 36),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text('Únete a Cusco Limpio',
                                  style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                            Center(
                              child: Text(
                                'Crea tu cuenta y forma parte del cambio',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── NOMBRE ──────────────────────────
                            _labelCampo('Nombre'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _nombreCtrl,
                              hintText: 'Ej: María',
                              prefixIcon: Icons.person_outlined,
                              tipoTeclado: TextInputType.name,
                              accionTeclado: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa tu nombre';
                                if (v.trim().length < 2)
                                  return 'Mínimo 2 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── PRIMER APELLIDO ─────────────────
                            _labelCampo('Primer Apellido'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _primerApellidoCtrl,
                              hintText: 'Ej: Quispe',
                              prefixIcon: Icons.family_restroom_outlined,
                              tipoTeclado: TextInputType.name,
                              accionTeclado: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa tu primer apellido';
                                if (v.trim().length < 2)
                                  return 'Mínimo 2 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── SEGUNDO APELLIDO ────────────────
                            _labelCampo('Segundo Apellido'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _segundoApellidoCtrl,
                              hintText: 'Ej: Huanca',
                              prefixIcon: Icons.family_restroom_outlined,
                              tipoTeclado: TextInputType.name,
                              accionTeclado: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa tu segundo apellido';
                                if (v.trim().length < 2)
                                  return 'Mínimo 2 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Correo electrónico ──────────────
                            _labelCampo('Correo electrónico'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _emailCtrl,
                              hintText: 'correo@ejemplo.com',
                              prefixIcon: Icons.email_outlined,
                              tipoTeclado: TextInputType.emailAddress,
                              accionTeclado: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa tu correo';
                                final regex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!regex.hasMatch(v.trim()))
                                  return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Contraseña ──────────────────────
                            _labelCampo('Contraseña'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _passCtrl,
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: Icons.lock_outline_rounded,
                              esPassword: true,
                              accionTeclado: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Ingresa una contraseña';
                                if (v.trim().length < 6)
                                  return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Confirmar contraseña ────────────
                            _labelCampo('Confirmar contraseña'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _confirmPassCtrl,
                              hintText: 'Repita su contraseña',
                              prefixIcon: Icons.lock_reset_rounded,
                              esPassword: true,
                              accionTeclado: TextInputAction.done,
                              onEditingComplete: _registrar,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Confirma tu contraseña';
                                if (v.trim() != _passCtrl.text.trim())
                                  return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // ── Selector de rol ─────────────────
                            _labelCampo('Tipo de cuenta'),
                            const SizedBox(height: 10),
                            Row(
                              children: _roles.map((rol) {
                                final seleccionado = _rolSeleccionado == rol;
                                final colores = {
                                  'Ciudadano': const Color(0xFF9333EA),
                                  'Usuario'  : const Color(0xFF0EA5E9),
                                  'Invitado' : const Color(0xFF10B981),
                                };
                                final color = colores[rol]!;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                            () => _rolSeleccionado = rol),
                                    child: AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 200),
                                      margin: EdgeInsets.only(
                                          right: rol != _roles.last ? 8 : 0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? color.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.04),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                          color: seleccionado
                                              ? color.withOpacity(0.7)
                                              : Colors.white.withOpacity(0.1),
                                          width: seleccionado ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            rol == 'Ciudadano'
                                                ? Icons.location_city_rounded
                                                : rol == 'Usuario'
                                                ? Icons.person_rounded
                                                : Icons.visibility_rounded,
                                            color: seleccionado
                                                ? color
                                                : Colors.white.withOpacity(0.3),
                                            size: 22,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(rol,
                                              style: GoogleFonts.poppins(
                                                  color: seleccionado
                                                      ? color
                                                      : Colors.white
                                                      .withOpacity(0.4),
                                                  fontSize: 12,
                                                  fontWeight: seleccionado
                                                      ? FontWeight.w700
                                                      : FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // ── Términos y condiciones ──────────
                            GestureDetector(
                              onTap: () => setState(
                                      () => _aceptaTerminos = !_aceptaTerminos),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _aceptaTerminos,
                                      onChanged: (v) => setState(
                                              () => _aceptaTerminos = v ?? false),
                                      activeColor: const Color(0xFF9333EA),
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                          color:
                                          Colors.white.withOpacity(0.35),
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                            Colors.white.withOpacity(0.6)),
                                        children: [
                                          const TextSpan(
                                              text: 'Acepto los '),
                                          TextSpan(
                                            text: 'Términos y Condiciones',
                                            style: GoogleFonts.poppins(
                                                color:
                                                const Color(0xFFB06EF5),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                          const TextSpan(
                                              text:
                                              ' y la Política de Privacidad de Cusco Limpio.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Botón REGISTRARSE ───────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _cargando ? null : _registrar,
                                icon: _cargando
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                                    : const Icon(Icons.person_add_rounded,
                                    size: 20),
                                label: Text(
                                    _cargando ? 'Registrando...' : 'REGISTRARSE',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: 1)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                  const Color(0xFF7C3AED).withOpacity(0.5),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Ya tengo cuenta ─────────────────
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(fontSize: 13),
                                    children: [
                                      TextSpan(
                                          text: '¿Ya tienes cuenta? ',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.5))),
                                      TextSpan(
                                          text: 'Inicia sesión',
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFFB06EF5),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelCampo(String texto) {
    return Text(texto,
        style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.75),
            fontSize: 13,
            fontWeight: FontWeight.w600));
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
    _c1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))
      ..repeat(reverse: true);
    _c2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 13))
      ..repeat(reverse: true);
    _c3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (context, _) => CustomPaint(
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
        Paint()..color = const Color(0xFF090913));
    _orb(
        canvas,
        Offset(size.width * (.15 + t1 * .35), size.height * (.08 + t1 * .18)),
        size.width * .60, const Color(0xFF870000), .38);
    _orb(
        canvas,
        Offset(size.width * (.75 - t2 * .25), size.height * (.55 + t2 * .22)),
        size.width * .65, const Color(0xFF312E81), .45);
    _orb(
        canvas,
        Offset(size.width * (.82 + t3 * .12), size.height * (.22 - t3 * .12)),
        size.width * .38, const Color(0xFF064E3B), .30);
    _orb(
        canvas,
        Offset(size.width * (.05 - t1 * .05), size.height * (.75 + t3 * .15)),
        size.width * .40, const Color(0xFF7C1E6A), .22);
  }

  void _orb(Canvas c, Offset center, double r, Color color, double op) {
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(op),
            color.withOpacity(op * .5),
            color.withOpacity(0),
          ],
          stops: const [0, .5, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_BgPainter o) =>
      o.t1 != t1 || o.t2 != t2 || o.t3 != t3;
}
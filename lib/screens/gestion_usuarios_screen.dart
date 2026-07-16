import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_management_service.dart';
import '../models/user_models.dart';

const double _kWebBreakpoint = 800;

class GestionUsuariosScreen extends StatefulWidget {
  final dynamic adminActual;
  const GestionUsuariosScreen({super.key, required this.adminActual});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen>
    with SingleTickerProviderStateMixin {
  final _service = UserManagementService();

  List<UsuarioModel> _todos = [];
  List<UsuarioModel> _filtrados = [];
  bool _cargando = true;
  String? _error;

  String _rolSeleccionado = 'Todos';
  DateTimeRange? _rangoFechas;
  final _buscadorCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _rolesDisponibles = [
    'Todos',
    'ADMIN',
    'USUARIO',
    'INVITADO',
    'MUNICIPALIDAD',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _buscadorCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _service.obtenerUsuarios();
      setState(() {
        _todos = lista;
        _aplicarFiltros();
        _cargando = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar la lista de usuarios.';
        _cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    final busqueda = _buscadorCtrl.text.trim().toLowerCase();

    _filtrados = _todos.where((u) {
      if (_rolSeleccionado != 'Todos' && u.rol.nombre != _rolSeleccionado) {
        return false;
      }
      if (_rangoFechas != null) {
        final inicio = _rangoFechas!.start;
        final fin = _rangoFechas!.end
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
        if (u.fechaRegistro.isBefore(inicio) || u.fechaRegistro.isAfter(fin)) {
          return false;
        }
      }
      if (busqueda.isNotEmpty) {
        final coincide = u.nombreCompleto.toLowerCase().contains(busqueda) ||
            u.correo.toLowerCase().contains(busqueda);
        if (!coincide) return false;
      }
      return true;
    }).toList();

    _filtrados.sort((a, b) {
      if (a.estado != b.estado) return a.estado ? -1 : 1;
      return b.fechaRegistro.compareTo(a.fechaRegistro);
    });
  }

  void _abrirDetalle(UsuarioModel usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleUsuarioScreen(
          usuario: usuario,
          onDeshabilitar: () => _confirmarDeshabilitar(usuario),
          onHabilitar: () => _confirmarHabilitar(usuario),
        ),
      ),
    );
  }

  Future<void> _confirmarDeshabilitar(UsuarioModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogConfirmacion(usuario: usuario),
    );
    if (confirmar != true) return;

    setState(() {
      usuario.estado = false;
      _aplicarFiltros();
    });

    final exito = await _service.deshabilitarUsuario(usuario.idUsuario);

    if (!exito && mounted) {
      setState(() {
        usuario.estado = true;
        _aplicarFiltros();
      });
      _mostrarSnack('Error al deshabilitar el usuario.', esError: true);
    } else if (mounted) {
      _mostrarSnack('${usuario.nombreCompleto} fue deshabilitado.');
    }
  }

  Future<void> _confirmarHabilitar(UsuarioModel usuario) async {
    setState(() {
      usuario.estado = true;
      _aplicarFiltros();
    });

    final exito = await _service.habilitarUsuario(usuario.idUsuario);

    if (!exito && mounted) {
      setState(() {
        usuario.estado = false;
        _aplicarFiltros();
      });
      _mostrarSnack('Error al habilitar el usuario.', esError: true);
    } else if (mounted) {
      _mostrarSnack('${usuario.nombreCompleto} fue habilitado.');
    }
  }

  void _mostrarSnack(String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor:
        esError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _seleccionarFechas() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _rangoFechas,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9333EA),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (rango != null) {
      setState(() {
        _rangoFechas = rango;
        _aplicarFiltros();
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _rolSeleccionado = 'Todos';
      _rangoFechas = null;
      _buscadorCtrl.clear();
      _aplicarFiltros();
    });
  }

  int get _totalActivos => _filtrados.where((u) => u.estado).length;
  int get _totalInactivos => _filtrados.where((u) => !u.estado).length;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= _kWebBreakpoint;

    if (isWeb) {
      return _buildWebBlockedScreen();
    }

    return _buildMobileScreen();
  }

  Widget _buildWebBlockedScreen() {
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
        title: Text('Gestión de Usuarios',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android_rounded,
                  color: Colors.white.withOpacity(0.3), size: 80),
              const SizedBox(height: 24),
              Text(
                '📱 Solo disponible en móvil',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta pantalla de administración\nes exclusiva para dispositivos móviles.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver al dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _cargando
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9333EA),
            strokeWidth: 2.5,
          ),
        )
            : _error != null
            ? _buildError()
            : FadeTransition(
          opacity: _fadeAnim,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildEncabezadoStats(),
              const SizedBox(height: 16),
              _buildPanelFiltros(),
              const SizedBox(height: 16),
              _buildChipsFiltrosActivos(),
              if (_filtrados.isEmpty)
                _buildVacio()
              else
                _buildListaUsuarios(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.05),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestión de Usuarios',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text('Solo administradores',
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white.withOpacity(0.4))),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: Colors.white.withOpacity(0.6),
          tooltip: 'Actualizar',
          onPressed: _cargarUsuarios,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.white.withOpacity(0.4), size: 40),
          const SizedBox(height: 12),
          Text(_error!,
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _cargarUsuarios,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF9333EA), size: 18),
            label: Text('Reintentar',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF9333EA),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezadoStats() {
    return Row(
      children: [
        _statChip('${_filtrados.length}', 'Total', Icons.people_rounded,
            const Color(0xFF9333EA)),
        const SizedBox(width: 10),
        _statChip('$_totalActivos', 'Activos', Icons.check_circle_rounded,
            const Color(0xFF10B981)),
        const SizedBox(width: 10),
        _statChip('$_totalInactivos', 'Inactivos', Icons.cancel_rounded,
            const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _statChip(String valor, String label, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _buscadorCtrl,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.white.withOpacity(0.9)),
            onChanged: (_) => setState(_aplicarFiltros),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o correo…',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.white.withOpacity(0.3)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: Colors.white.withOpacity(0.4), size: 18),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9333EA)),
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _rolSeleccionado,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1A2E),
                      icon: Icon(Icons.expand_more_rounded,
                          color: Colors.white.withOpacity(0.4), size: 18),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85)),
                      items: _rolesDisponibles
                          .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _rolSeleccionado = v;
                          _aplicarFiltros();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _seleccionarFechas,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: _rangoFechas != null
                          ? const Color(0xFF9333EA).withOpacity(0.15)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _rangoFechas != null
                            ? const Color(0xFF9333EA).withOpacity(0.4)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: _rangoFechas != null
                              ? const Color(0xFFB06EF5)
                              : Colors.white.withOpacity(0.4),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _rangoFechas != null
                                ? '${_fmt(_rangoFechas!.start)} – ${_fmt(_rangoFechas!.end)}'
                                : 'Fecha',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _rangoFechas != null
                                    ? const Color(0xFFB06EF5)
                                    : Colors.white.withOpacity(0.45)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Widget _buildChipsFiltrosActivos() {
    final activos = _rolSeleccionado != 'Todos' || _rangoFechas != null;
    if (!activos) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (_rolSeleccionado != 'Todos')
            _filtroChip('Rol: $_rolSeleccionado', () {
              setState(() {
                _rolSeleccionado = 'Todos';
                _aplicarFiltros();
              });
            }),
          if (_rangoFechas != null) ...[
            const SizedBox(width: 8),
            _filtroChip(
              '${_fmt(_rangoFechas!.start)} – ${_fmt(_rangoFechas!.end)}',
                  () {
                setState(() {
                  _rangoFechas = null;
                  _aplicarFiltros();
                });
              },
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: _limpiarFiltros,
            child: Text('Limpiar todo',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF9333EA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF9333EA).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF9333EA).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  color: const Color(0xFFB06EF5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14,
                color: const Color(0xFFB06EF5).withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildListaUsuarios() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TarjetaUsuario(
        usuario: _filtrados[i],
        onDeshabilitar: () => _confirmarDeshabilitar(_filtrados[i]),
        onHabilitar: () => _confirmarHabilitar(_filtrados[i]),
      ),
    );
  }

  Widget _buildVacio() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              color: Colors.white.withOpacity(0.2), size: 44),
          const SizedBox(height: 12),
          Text('Sin resultados',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Ajusta los filtros para ver usuarios.',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// TARJETA DE USUARIO
// ══════════════════════════════════════════════════

class _TarjetaUsuario extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onDeshabilitar;
  final VoidCallback onHabilitar;

  const _TarjetaUsuario({
    required this.usuario,
    required this.onDeshabilitar,
    required this.onHabilitar,
  });

  Color get _colorRol {
    switch (usuario.rol.nombre) {
      case 'ADMIN':
        return const Color(0xFF9333EA);
      case 'MUNICIPALIDAD':
        return const Color(0xFF0EA5E9);
      case 'USUARIO':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _abrirDetalle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleUsuarioScreen(
          usuario: usuario,
          onDeshabilitar: onDeshabilitar,
          onHabilitar: onHabilitar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activo = usuario.estado;

    return GestureDetector(
      onTap: () => _abrirDetalle(context),
      child: AnimatedOpacity(
        opacity: activo ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activo
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _colorRol.withOpacity(0.2),
                    child: Text(
                      usuario.avatar,
                      style: GoogleFonts.poppins(
                          color: _colorRol,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                usuario.nombreCompleto,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: activo
                                    ? const Color(0xFF10B981).withOpacity(0.15)
                                    : const Color(0xFFEF4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                activo ? 'Activo' : 'Inactivo',
                                style: GoogleFonts.poppins(
                                    color: activo
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          usuario.correo,
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.3), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _meta(Icons.shield_outlined, usuario.rol.nombre, _colorRol),
                  const SizedBox(width: 12),
                  _meta(Icons.location_on_outlined, usuario.zona.nombre,
                      const Color(0xFF0EA5E9)),
                  const SizedBox(width: 12),
                  _meta(Icons.calendar_today_outlined,
                      _fmtFecha(usuario.fechaRegistro),
                      Colors.white.withOpacity(0.4)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _meta(Icons.phone_outlined, usuario.telefono,
                      Colors.white.withOpacity(0.4)),
                  const Spacer(),
                  if (activo)
                    _BotonDeshabilitar(onTap: onDeshabilitar)
                  else
                    _BotonHabilitar(onTap: onHabilitar),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icono, String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: 13),
        const SizedBox(width: 4),
        Text(texto,
            style: GoogleFonts.poppins(
                color: color.withOpacity(0.85), fontSize: 11)),
      ],
    );
  }

  String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ══════════════════════════════════════════════════
// BOTÓN DESHABILITAR
// ══════════════════════════════════════════════════

class _BotonDeshabilitar extends StatefulWidget {
  final VoidCallback onTap;
  const _BotonDeshabilitar({required this.onTap});

  @override
  State<_BotonDeshabilitar> createState() => _BotonDeshabilitarState();
}

class _BotonDeshabilitarState extends State<_BotonDeshabilitar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block_rounded,
                  color: Color(0xFFEF4444), size: 14),
              const SizedBox(width: 5),
              Text('Deshabilitar',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// BOTÓN HABILITAR
// ══════════════════════════════════════════════════

class _BotonHabilitar extends StatefulWidget {
  final VoidCallback onTap;
  const _BotonHabilitar({required this.onTap});

  @override
  State<_BotonHabilitar> createState() => _BotonHabilitarState();
}

class _BotonHabilitarState extends State<_BotonHabilitar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 5),
              Text('Habilitar',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// DIÁLOGO DE CONFIRMACIÓN
// ══════════════════════════════════════════════════

class _DialogConfirmacion extends StatelessWidget {
  final UsuarioModel usuario;
  const _DialogConfirmacion({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 10),
          Text('¿Deshabilitar usuario?',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estás a punto de deshabilitar a:',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.55), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nombreCompleto,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(usuario.correo,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12)),
                Text('Rol: ${usuario.rol.nombre}',
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'El usuario perderá acceso al sistema. Esta acción puede revertirse.',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.45), fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600)),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.block_rounded, size: 14),
          label: Text('Deshabilitar',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// PANTALLA DE DETALLE DE USUARIO
// ══════════════════════════════════════════════════════════════════

class DetalleUsuarioScreen extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback? onDeshabilitar;
  final VoidCallback? onHabilitar;

  const DetalleUsuarioScreen({
    super.key,
    required this.usuario,
    this.onDeshabilitar,
    this.onHabilitar,
  });

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
          'Detalle de Usuario',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAvatarGrande(),
            const SizedBox(height: 24),
            _buildSeccionInfo(
              titulo: 'Información Personal',
              icono: Icons.person_outline_rounded,
              children: [
                _infoRow('Nombre completo', usuario.nombreCompleto),
                _infoRow('Correo electrónico', usuario.correo),
                _infoRow('Teléfono', usuario.telefono),
                _infoRow('Fecha de registro',
                    _formatoFechaCompleta(usuario.fechaRegistro)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSeccionInfo(
              titulo: 'Información de Cuenta',
              icono: Icons.account_circle_outlined,
              children: [
                _infoRow('Rol', usuario.rol.nombre,
                    colorRol: _getColorRol(usuario.rol.nombre)),
                _infoRow(
                  'Estado',
                  usuario.estado ? 'Activo' : 'Inactivo',
                  colorEstado: usuario.estado
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                _infoRow('ID de usuario', '#${usuario.idUsuario}'),
              ],
            ),
            const SizedBox(height: 20),
            _buildSeccionInfo(
              titulo: 'Ubicación',
              icono: Icons.location_on_outlined,
              children: [
                _infoRow('Zona/Distrito', usuario.zona.nombre),
              ],
            ),
            const SizedBox(height: 30),
            if (usuario.estado) ...[
              _buildBotonAccion(
                label: 'Deshabilitar Usuario',
                icon: Icons.block_rounded,
                color: const Color(0xFFEF4444),
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 100),
                        () => onDeshabilitar?.call(),
                  );
                },
              ),
            ] else ...[
              _buildBotonAccion(
                label: 'Habilitar Usuario',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF10B981),
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 100),
                        () => onHabilitar?.call(),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarGrande() {
    final Color colorRol = _getColorRol(usuario.rol.nombre);
    final String avatarTexto =
    usuario.avatar.isNotEmpty ? usuario.avatar : '?';

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorRol, colorRol.withOpacity(0.6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorRol.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatarTexto,
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionInfo({
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: const Color(0xFF9333EA), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String valor,
      {Color? colorRol, Color? colorEstado}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorEstado ?? colorRol ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonAccion({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.4)),
          ),
        ),
      ),
    );
  }

  String _formatoFechaCompleta(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} · '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorRol(String rol) {
    switch (rol) {
      case 'ADMIN':
        return const Color(0xFF9333EA);
      case 'MUNICIPALIDAD':
        return const Color(0xFF0EA5E9);
      case 'USUARIO':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
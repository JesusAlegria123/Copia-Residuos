import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════════
// WIDGET SEGÚN ROL — muestra contenido distinto por rol de usuario
// Ubicación: lib/widgets/common/widget_segun_rol.dart
//
// USO:
//   WidgetSegunRol(
//     contenidoAdmin        : Text('Solo admin'),
//     contenidoUsuario      : Text('Solo usuario'),
//     contenidoInvitado     : Text('Solo invitado'),
//     contenidoMunicipalidad: Text('Solo municipalidad'),
//     contenidoCiudadano    : Text('Solo ciudadano'),
//     widgetCarga           : CircularProgressIndicator(),
//     widgetPorDefecto      : Text('Sin acceso'),
//   )
// ══════════════════════════════════════════════════════════════════

// Constantes de roles definidas aquí para no depender de GuardiaRoles
const String _rolAdmin         = 'Administrador';
const String _rolUsuario       = 'Usuario';
const String _rolInvitado      = 'Invitado';
const String _rolMunicipalidad = 'Municipalidad';
const String _rolCiudadano     = 'Ciudadano';

class WidgetSegunRol extends StatelessWidget {
  final Widget? contenidoAdmin;
  final Widget? contenidoUsuario;
  final Widget? contenidoInvitado;
  final Widget? contenidoMunicipalidad;
  final Widget? contenidoCiudadano;

  /// Se muestra mientras se consulta el rol (por defecto invisible)
  final Widget? widgetCarga;

  /// Se muestra si el rol no coincide con ninguna opción provista
  final Widget? widgetPorDefecto;

  const WidgetSegunRol({
    super.key,
    this.contenidoAdmin,
    this.contenidoUsuario,
    this.contenidoInvitado,
    this.contenidoMunicipalidad,
    this.contenidoCiudadano,
    this.widgetCarga,
    this.widgetPorDefecto,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _obtenerRol(),
      builder: (context, snapshot) {
        // ── Cargando ─────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widgetCarga ?? const SizedBox.shrink();
        }

        final rol = snapshot.data;

        // ── Selección por rol ─────────────────────────────────
        if (rol == _rolAdmin && contenidoAdmin != null) {
          return contenidoAdmin!;
        }
        if (rol == _rolMunicipalidad && contenidoMunicipalidad != null) {
          return contenidoMunicipalidad!;
        }
        if (rol == _rolUsuario && contenidoUsuario != null) {
          return contenidoUsuario!;
        }
        if (rol == _rolCiudadano && contenidoCiudadano != null) {
          return contenidoCiudadano!;
        }
        if (rol == _rolInvitado && contenidoInvitado != null) {
          return contenidoInvitado!;
        }

        // ── Fallback en orden de prioridad ────────────────────
        return widgetPorDefecto ??
            contenidoUsuario ??
            contenidoCiudadano ??
            contenidoInvitado ??
            const SizedBox.shrink();
      },
    );
  }

  Future<String?> _obtenerRol() async {
    final user = await AuthService().obtenerSesionActiva();
    return user?.rol;
  }
}
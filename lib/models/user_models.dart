// ══════════════════════════════════════════════════
// MODELOS PARA GESTIÓN DE USUARIOS
// ══════════════════════════════════════════════════

class RolModel {
  final int idRol;
  final String nombre;

  const RolModel({required this.idRol, required this.nombre});

  factory RolModel.fromJson(Map<String, dynamic> json) => RolModel(
    idRol: json['id_rol'] as int,
    nombre: json['nombre'] as String,
  );
}

class ZonaModel {
  final int idZona;
  final String nombre;

  const ZonaModel({required this.idZona, required this.nombre});

  factory ZonaModel.fromJson(Map<String, dynamic> json) => ZonaModel(
    idZona: json['id_zona'] as int,
    nombre: json['nombre'] as String,
  );
}

class UsuarioModel {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  bool estado;
  final RolModel rol;
  final ZonaModel zona;
  final DateTime fechaRegistro;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.estado,
    required this.rol,
    required this.zona,
    required this.fechaRegistro,
  });

  String get nombreCompleto => '$nombre $apellido';
  String get avatar => nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    idUsuario: json['id_usuario'] as int,
    nombre: json['nombre'] as String,
    apellido: json['apellido'] as String,
    correo: json['correo'] as String,
    telefono: json['telefono'] as String,
    estado: json['estado'] as bool,
    rol: RolModel.fromJson(json['rol'] as Map<String, dynamic>),
    zona: ZonaModel.fromJson(json['zona'] as Map<String, dynamic>),
    fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
  );
}
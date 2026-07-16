import '../models/user_models.dart';

// ══════════════════════════════════════════════════
// SERVICIO DE GESTIÓN DE USUARIOS
// ══════════════════════════════════════════════════

class UserManagementService {
  Future<List<UsuarioModel>> obtenerUsuarios() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockJson = {
      'usuarios': [
        {
          'id_usuario': 1,
          'nombre': 'Brandon',
          'apellido': 'Estrada',
          'correo': 'brandon@gmail.com',
          'telefono': '987654321',
          'estado': true,
          'rol': {'id_rol': 1, 'nombre': 'ADMIN'},
          'zona': {'id_zona': 1, 'nombre': 'Wanchaq'},
          'fecha_registro': '2026-06-08T10:30:00',
        },
        {
          'id_usuario': 2,
          'nombre': 'Lucía',
          'apellido': 'Quispe',
          'correo': 'lucia@unsaac.edu.pe',
          'telefono': '963214785',
          'estado': true,
          'rol': {'id_rol': 2, 'nombre': 'USUARIO'},
          'zona': {'id_zona': 2, 'nombre': 'Santiago'},
          'fecha_registro': '2026-05-15T08:00:00',
        },
        {
          'id_usuario': 3,
          'nombre': 'Carlos',
          'apellido': 'Mamani',
          'correo': 'carlos@demo.com',
          'telefono': '912345678',
          'estado': false,
          'rol': {'id_rol': 3, 'nombre': 'INVITADO'},
          'zona': {'id_zona': 3, 'nombre': 'Cusco'},
          'fecha_registro': '2026-04-20T14:00:00',
        },
        {
          'id_usuario': 4,
          'nombre': 'María',
          'apellido': 'Ccopa',
          'correo': 'maria@municipio.gob.pe',
          'telefono': '987001122',
          'estado': true,
          'rol': {'id_rol': 4, 'nombre': 'MUNICIPALIDAD'},
          'zona': {'id_zona': 1, 'nombre': 'Wanchaq'},
          'fecha_registro': '2026-03-10T09:15:00',
        },
        {
          'id_usuario': 5,
          'nombre': 'Diego',
          'apellido': 'Huanca',
          'correo': 'diego@gmail.com',
          'telefono': '956321478',
          'estado': true,
          'rol': {'id_rol': 2, 'nombre': 'USUARIO'},
          'zona': {'id_zona': 4, 'nombre': 'San Jerónimo'},
          'fecha_registro': '2026-06-01T11:45:00',
        },
        {
          'id_usuario': 6,
          'nombre': 'Ana',
          'apellido': 'Flores',
          'correo': 'ana@test.com',
          'telefono': '999888777',
          'estado': false,
          'rol': {'id_rol': 3, 'nombre': 'INVITADO'},
          'zona': {'id_zona': 2, 'nombre': 'Santiago'},
          'fecha_registro': '2026-02-28T16:30:00',
        },
      ],
    };

    final lista = (mockJson['usuarios'] as List)
        .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return lista;
  }

  Future<bool> deshabilitarUsuario(int idUsuario) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> habilitarUsuario(int idUsuario) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
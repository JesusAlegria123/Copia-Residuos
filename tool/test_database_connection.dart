import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🔍 Iniciando prueba de conexión a Supabase...\n');

  try {
    // Inicializar Supabase
    await Supabase.initialize(
      url: 'https://gbpovfuiqbwjkdhgnyvi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicG92ZnVpcWJ3amtkaGdueXZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc5MDcwMDksImV4cCI6MjA0MzQ4MzAwOX0.RN-SZi0g4ELn59_ov6oFqJYHR5zLZUCc-tBUqWMvY0U',
    );

    final supabase = Supabase.instance.client;

    print('✅ Conexión a Supabase establecida exitosamente!\n');

    // Prueba 1: Verificar acceso a la tabla 'roles'
    print('📋 Prueba 1: Consultando tabla "roles". c ..');
    final rolesData = await supabase.from('roles').select();
    print('✓ Registros en tabla roles: ${rolesData.length}');
    print('Datos: $rolesData\n');

    // Prueba 2: Verificar acceso a la tabla 'zonas'
    print('📋 Prueba 2: Consultando tabla "zonas"...');
    final zonasData = await supabase.from('zonas').select();
    print('✓ Registros en tabla zonas: ${zonasData.length}');
    print('Datos: $zonasData\n');

    // Prueba 3: Verificar acceso a la tabla 'usuarios'
    print('📋 Prueba 3: Consultando tabla "usuarios"...');
    final usuariosData = await supabase.from('usuarios').select();
    print('✓ Registros en tabla usuarios: ${usuariosData.length}');
    print('Datos: $usuariosData\n');

    // Prueba 4: Verificar acceso a la tabla 'rutas'
    print('📋 Prueba 4: Consultando tabla "rutas"...');
    final rutasData = await supabase.from('rutas').select();
    print('✓ Registros en tabla rutas: ${rutasData.length}');
    print('Datos: $rutasData\n');

    // Prueba 5: Verificar acceso a la tabla 'ruta_puntos'
    print('📋 Prueba 5: Consultando tabla "ruta_puntos"...');
    final puntosData = await supabase.from('ruta_puntos').select();
    print('✓ Registros en tabla ruta_puntos: ${puntosData.length}');
    print('Datos: $puntosData\n');

    // Prueba 6: Verificar acceso a la tabla 'horarios'
    print('📋 Prueba 6: Consultando tabla "horarios"...');
    final horariosData = await supabase.from('horarios').select();
    print('✓ Registros en tabla horarios: ${horariosData.length}');
    print('Datos: $horariosData\n');

    print('✅ ¡TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE!');
    print('🎉 El acceso a la base de datos está correctamente configurado.\n');

  } on SocketException catch (e) {
    print('❌ Error de conexión de red: $e');
    print('Verifica tu conexión a internet.\n');
  } on AuthException catch (e) {
    print('❌ Error de autenticación: ${e.message}');
    print('Verifica las credenciales de Supabase.\n');
  } on PostgrestException catch (e) {
    print('❌ Error de base de datos: ${e.message}');
    print('Detalles: ${e.details}\n');
  } catch (e) {
    print('❌ Error inesperado: $e\n');
    print('Stack trace: $e');
  }
}


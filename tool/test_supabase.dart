import 'package:supabase/supabase.dart';

// Script de consola para verificar conexión a Supabase usando la anon key.
// Ejecutar desde la raíz del proyecto con: dart run tool/test_supabase.dart

Future<void> main() async {
  const url = 'https://ybbhmauqilygldknzpcv.supabase.co';
  const anonKey = 'sb_publishable_c4fvqOdNYAouQPG3OBQ9OA_cr2IqnTR';

  final client = SupabaseClient(url, anonKey);

  try {
    print('Intentando consultar tabla "users" (si no existe, recibirá un error pero se probará conexión)...');
    final res = await client.from('users').select().limit(1).execute();
    print('Status: ${res.status}');
    print('Data: ${res.data}');
    // Si status >= 400 puede indicar error (tabla no existe o permisos)
    if (res.status >= 400) {
      print('Petición retornó status >= 400; revisa que la tabla exista y las políticas (RLS).');
    }
  } catch (e) {
    print('Excepción al consultar Supabase: $e');
  }
}


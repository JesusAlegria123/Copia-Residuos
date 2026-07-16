import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/exceptions.dart';

class SupabaseService {
  static const String _supabaseUrl =
      'https://ybbhmauqilygldknzpcv.supabase.co';
  static const String _anonKey =
      'sb_publishable_c4fvqOdNYAouQPG3OBQ9OA_cr2IqnTR';

  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _anonKey,
        debug: false,
      );
    } catch (e) {
      throw ExceptionHandler.handle(e, 'SupabaseService.init');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
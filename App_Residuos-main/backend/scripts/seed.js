/**
 * Crea un usuario de prueba en la tabla users.
 * Uso: npm run seed
 *
 * Requiere SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY en .env
 */
import dotenv from 'dotenv';
import { getSupabase } from '../src/config/supabase.js';
import { hashPassword } from '../src/utils/password.js';

dotenv.config();

const TEST_USER = {
  email: 'test@example.com',
  password: 'SecurePass123!@#',
  nombre: 'Test User',
  rol: 'Usuario',
};

async function seed() {
  const supabase = getSupabase();

  const { data: existing } = await supabase
    .from('users')
    .select('id, email')
    .eq('email', TEST_USER.email)
    .maybeSingle();

  if (existing) {
    console.log(`Usuario de prueba ya existe: ${TEST_USER.email}`);
    return;
  }

  const passwordHash = await hashPassword(TEST_USER.password);

  const { data, error } = await supabase
    .from('users')
    .insert({
      email: TEST_USER.email,
      password_hash: passwordHash,
      nombre: TEST_USER.nombre,
      rol: TEST_USER.rol,
      activo: true,
    })
    .select('id, email, nombre, rol')
    .single();

  if (error) {
    console.error('Error creando usuario de prueba:', error.message);
    process.exit(1);
  }

  console.log('Usuario de prueba creado:');
  console.log(`  Email: ${data.email}`);
  console.log(`  Password: ${TEST_USER.password}`);
  console.log(`  Rol: ${data.rol}`);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});

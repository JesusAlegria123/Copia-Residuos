import { getSupabase } from '../config/supabase.js';

const TIPOS_VALIDOS = ['Organicos', 'Plasticos', 'Papel y Carton', 'Metales', 'Vidrio', 'Otros'];

export async function createRecoleccion({ idUnidad, idRuta, tipoResiduo, pesoKg, registradoPor }) {
  if (!TIPOS_VALIDOS.includes(tipoResiduo)) {
    const err = new Error(`Tipo de residuo inválido. Usa: ${TIPOS_VALIDOS.join(', ')}`);
    err.code = 'INVALID_TIPO_RESIDUO';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  const peso = Number(pesoKg);
  if (!peso || peso <= 0) {
    const err = new Error('El peso en kg debe ser un número mayor a 0.');
    err.code = 'INVALID_PESO';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('recolecciones')
    .insert({
      id_unidad: idUnidad ?? null,
      id_ruta: idRuta ?? null,
      tipo_residuo: tipoResiduo,
      peso_kg: peso,
      registrado_por: registradoPor ?? null,
    })
    .select('*')
    .single();

  if (error) throw error;
  return data;
}

export async function listRecolecciones({ idRuta, idUnidad, desde, hasta } = {}) {
  const supabase = getSupabase();
  let query = supabase.from('recolecciones').select('*').order('fecha', { ascending: false }).limit(500);

  if (idRuta) query = query.eq('id_ruta', idRuta);
  if (idUnidad) query = query.eq('id_unidad', idUnidad);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);

  const { data, error } = await query;
  if (error) throw error;
  return data;
}

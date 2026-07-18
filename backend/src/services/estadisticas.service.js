import { getSupabase } from '../config/supabase.js';

function ultimosNMeses(n) {
  const meses = [];
  const ahora = new Date();
  for (let i = n - 1; i >= 0; i -= 1) {
    const d = new Date(ahora.getFullYear(), ahora.getMonth() - i, 1);
    meses.push({ year: d.getFullYear(), month: d.getMonth(), label: d.toLocaleDateString('es-PE', { month: 'short' }) });
  }
  return meses;
}

function agruparPorMes(rows, dateField, n = 6) {
  const meses = ultimosNMeses(n);
  const buckets = meses.map((m) => ({ ...m, total: 0 }));

  for (const row of rows) {
    const fecha = new Date(row[dateField]);
    const bucket = buckets.find(
      (b) => b.year === fecha.getFullYear() && b.month === fecha.getMonth()
    );
    if (bucket) bucket.total += 1;
  }

  return buckets.map((b) => ({ mes: b.label, total: b.total }));
}

// ─────────────────────────────────────────────────────────────
// ESTADÍSTICAS DE USUARIOS
// ─────────────────────────────────────────────────────────────
export async function getEstadisticasUsuarios() {
  const supabase = getSupabase();

  const { data: usuarios, error: errUsuarios } = await supabase
    .from('usuarios')
    .select('id_usuario, estado, fecha_registro, rol:roles(nombre), zona:zonas(nombre)');
  if (errUsuarios) throw errUsuarios;

  const { data: cuentas, error: errCuentas } = await supabase
    .from('users')
    .select('id, activo, rol, created_at');
  if (errCuentas) throw errCuentas;

  const porRol = {};
  const porZona = {};
  let activos = 0;
  let inactivos = 0;

  for (const u of usuarios) {
    const rolNombre = u.rol?.nombre ?? 'Sin rol';
    const zonaNombre = u.zona?.nombre ?? 'Sin zona';
    porRol[rolNombre] = (porRol[rolNombre] ?? 0) + 1;
    porZona[zonaNombre] = (porZona[zonaNombre] ?? 0) + 1;
    if (u.estado) activos += 1;
    else inactivos += 1;
  }

  const cuentasPorRol = {};
  let cuentasActivas = 0;
  let cuentasInactivas = 0;
  for (const c of cuentas) {
    cuentasPorRol[c.rol] = (cuentasPorRol[c.rol] ?? 0) + 1;
    if (c.activo) cuentasActivas += 1;
    else cuentasInactivas += 1;
  }

  return {
    usuarios: {
      total: usuarios.length,
      activos,
      inactivos,
      porRol: Object.entries(porRol).map(([nombre, total]) => ({ nombre, total })),
      porZona: Object.entries(porZona).map(([nombre, total]) => ({ nombre, total })),
      registrosPorMes: agruparPorMes(usuarios, 'fecha_registro'),
    },
    cuentas: {
      total: cuentas.length,
      activas: cuentasActivas,
      inactivas: cuentasInactivas,
      porRol: Object.entries(cuentasPorRol).map(([nombre, total]) => ({ nombre, total })),
      registrosPorMes: agruparPorMes(cuentas, 'created_at'),
    },
  };
}

// ─────────────────────────────────────────────────────────────
// ESTADÍSTICAS DE RUTAS
// ─────────────────────────────────────────────────────────────
export async function getEstadisticasRutas() {
  const supabase = getSupabase();

  const { data: rutas, error: errRutas } = await supabase
    .from('rutas')
    .select('id_ruta, nombre, estado, zona:zonas(nombre), ruta_puntos(id_punto)');
  if (errRutas) throw errRutas;

  const { data: recolecciones, error: errRecolecciones } = await supabase
    .from('recolecciones')
    .select('id_ruta, peso_kg');
  if (errRecolecciones) throw errRecolecciones;

  const { data: unidades, error: errUnidades } = await supabase
    .from('unidades_recoleccion')
    .select('id_unidad, estado, id_ruta');
  if (errUnidades) throw errUnidades;

  const kgPorRuta = {};
  for (const r of recolecciones) {
    if (r.id_ruta == null) continue;
    kgPorRuta[r.id_ruta] = (kgPorRuta[r.id_ruta] ?? 0) + Number(r.peso_kg);
  }

  const unidadesPorRuta = {};
  for (const u of unidades) {
    if (u.id_ruta == null) continue;
    unidadesPorRuta[u.id_ruta] = (unidadesPorRuta[u.id_ruta] ?? 0) + 1;
  }

  const porZona = {};
  let activas = 0;
  let inactivas = 0;
  let totalPuntos = 0;

  const detalle = rutas.map((r) => {
    const zonaNombre = r.zona?.nombre ?? 'Sin zona';
    porZona[zonaNombre] = (porZona[zonaNombre] ?? 0) + 1;
    if (r.estado) activas += 1;
    else inactivas += 1;
    const numPuntos = (r.ruta_puntos ?? []).length;
    totalPuntos += numPuntos;

    return {
      idRuta: r.id_ruta,
      nombre: r.nombre,
      estado: r.estado,
      zona: zonaNombre,
      numPuntos,
      unidadesAsignadas: unidadesPorRuta[r.id_ruta] ?? 0,
      kgRecolectados: Number((kgPorRuta[r.id_ruta] ?? 0).toFixed(2)),
    };
  });

  return {
    total: rutas.length,
    activas,
    inactivas,
    promedioPuntosPorRuta: rutas.length ? Number((totalPuntos / rutas.length).toFixed(1)) : 0,
    porZona: Object.entries(porZona).map(([nombre, total]) => ({ nombre, total })),
    detalle,
  };
}

// ─────────────────────────────────────────────────────────────
// ESTADÍSTICAS DE RESIDUOS
// ─────────────────────────────────────────────────────────────
export async function getEstadisticasResiduos({ desde, hasta } = {}) {
  const supabase = getSupabase();

  let query = supabase.from('recolecciones').select('tipo_residuo, peso_kg, fecha, id_ruta');
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);

  const { data: recolecciones, error: errRecolecciones } = await query;
  if (errRecolecciones) throw errRecolecciones;

  const { data: reportes, error: errReportes } = await supabase
    .from('reportes_malos_trabajos')
    .select('estado, distrito, created_at');
  if (errReportes) throw errReportes;

  const porTipo = {};
  let totalKg = 0;
  for (const r of recolecciones) {
    porTipo[r.tipo_residuo] = (porTipo[r.tipo_residuo] ?? 0) + Number(r.peso_kg);
    totalKg += Number(r.peso_kg);
  }

  const porMes = ultimosNMeses(7).map((m) => ({ mes: m.label, kg: 0, year: m.year, month: m.month }));
  for (const r of recolecciones) {
    const fecha = new Date(r.fecha);
    const bucket = porMes.find((b) => b.year === fecha.getFullYear() && b.month === fecha.getMonth());
    if (bucket) bucket.kg += Number(r.peso_kg);
  }

  const reportesPorEstado = {};
  const reportesPorDistrito = {};
  for (const r of reportes) {
    reportesPorEstado[r.estado] = (reportesPorEstado[r.estado] ?? 0) + 1;
    reportesPorDistrito[r.distrito] = (reportesPorDistrito[r.distrito] ?? 0) + 1;
  }

  return {
    totalKg: Number(totalKg.toFixed(2)),
    totalRecolecciones: recolecciones.length,
    porTipo: Object.entries(porTipo).map(([tipo, kg]) => ({
      tipo,
      kg: Number(kg.toFixed(2)),
    })),
    porMes: porMes.map(({ mes, kg }) => ({ mes, kg: Number(kg.toFixed(2)) })),
    reportesCiudadanos: {
      total: reportes.length,
      porEstado: Object.entries(reportesPorEstado).map(([nombre, total]) => ({ nombre, total })),
      porDistrito: Object.entries(reportesPorDistrito).map(([nombre, total]) => ({ nombre, total })),
    },
  };
}

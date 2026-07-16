require('dotenv').config();
const express = require('express');
const fetch = (...args) => import('node-fetch').then(({default: f}) => f(...args));
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error('Falta SUPABASE_URL o SUPABASE_SERVICE_KEY en .env');
  process.exit(1);
}

const SUPABASE_HEADERS = {
  'apikey': SERVICE_KEY,
  'Authorization': `Bearer ${SERVICE_KEY}`,
  'Content-Type': 'application/json'
};

// Helper: build query string for filters
function buildQuery(params) {
  const qs = [];
  if (params.start_date) {
    qs.push(`fecha_registro=gte.${encodeURIComponent(params.start_date)}`);
  }
  if (params.end_date) {
    qs.push(`fecha_registro=lte.${encodeURIComponent(params.end_date)}`);
  }
  if (params.role) {
    // if numeric, filter by id_rol; else will filter later by role name
    if (/^\d+$/.test(params.role)) {
      qs.push(`id_rol=eq.${params.role}`);
    }
  }
  if (params.search) {
    // use PostgREST 'or' with ilike for name, apellido or correo
    const s = params.search.replace(/\*/g, '%');
    const expr = `or=(nombre.ilike.*${encodeURIComponent(s)}*,apellido.ilike.*${encodeURIComponent(s)}*,correo.ilike.*${encodeURIComponent(s)}*)`;
    qs.push(expr);
  }

  return qs.join('&');
}

// GET /api/users
// Query params: start_date, end_date, role (id or name), search, page, limit, sort_by, sort_order
app.get('/api/users', async (req, res) => {
  try {
    const {
      start_date,
      end_date,
      role,
      search,
      page = '1',
      limit = '50',
      sort_by = 'fecha_registro',
      sort_order = 'desc'
    } = req.query;

    const pageNum = Math.max(1, parseInt(page));
    const lim = Math.max(1, Math.min(1000, parseInt(limit)));
    const offset = (pageNum - 1) * lim;

    const params = { start_date, end_date, role, search };
    let q = buildQuery(params);

    // Add order, limit, offset
    if (q.length) q += '&';
    q += `order=${encodeURIComponent(sort_by)}.${encodeURIComponent(sort_order)}`;
    q += `&limit=${lim}&offset=${offset}`;

    const url = `${SUPABASE_URL}/rest/v1/usuarios?select=id_usuario,nombre,apellido,correo,telefono,estado,id_rol,id_zona,fecha_registro&${q}`;

    // Fetch usuarios
    const usuariosResp = await fetch(url, { headers: SUPABASE_HEADERS });
    if (!usuariosResp.ok) {
      const text = await usuariosResp.text();
      return res.status(usuariosResp.status).json({ error: text });
    }
    const usuarios = await usuariosResp.json();

    // Fetch roles and zonas to map names
    const [rolesResp, zonasResp] = await Promise.all([
      fetch(`${SUPABASE_URL}/rest/v1/roles?select=id_rol,nombre`, { headers: SUPABASE_HEADERS }),
      fetch(`${SUPABASE_URL}/rest/v1/zonas?select=id_zona,nombre`, { headers: SUPABASE_HEADERS })
    ]);
    if (!rolesResp.ok || !zonasResp.ok) {
      const tr = await rolesResp.text();
      const tz = await zonasResp.text();
      return res.status(502).json({ error: 'Error obteniendo roles/zonas', roles: tr, zonas: tz });
    }
    const roles = await rolesResp.json();
    const zonas = await zonasResp.json();

    // Map role name to id if role filter provided as name
    let roleIdFilter = null;
    if (role && !/^\d+$/.test(role)) {
      const found = roles.find(r => r.nombre.toLowerCase() === role.toLowerCase());
      if (found) roleIdFilter = found.id_rol;
      else roleIdFilter = null; // will filter to none
    }

    // Build response users with embedded rol and zona
    let filteredUsers = usuarios.map(u => {
      const rol = roles.find(r => r.id_rol === u.id_rol) || null;
      const zona = zonas.find(z => z.id_zona === u.id_zona) || null;
      return {
        id_usuario: u.id_usuario,
        nombre: u.nombre,
        apellido: u.apellido,
        correo: u.correo,
        telefono: u.telefono,
        estado: u.estado,
        rol: rol ? { id_rol: rol.id_rol, nombre: rol.nombre } : null,
        zona: zona ? { id_zona: zona.id_zona, nombre: zona.nombre } : null,
        fecha_registro: u.fecha_registro
      };
    });

    // If role filter was provided as name, apply it
    if (role && !/^\d+$/.test(role)) {
      if (roleIdFilter === null) filteredUsers = [];
      else filteredUsers = filteredUsers.filter(u => u.rol && u.rol.id_rol === roleIdFilter);
    }

    // Build meta: to get total count we should call HEAD or count via PostgREST
    const countUrl = `${SUPABASE_URL}/rest/v1/usuarios?select=id_usuario&${buildQuery({ start_date, end_date, role: (typeof role === 'string' && /^\d+$/.test(role)) ? role : undefined, search })}&limit=1`;
    // Use HEAD with Range? PostgREST supports Range header to get Content-Range; simpler: request count using select=count
    const countQuery = `${SUPABASE_URL}/rest/v1/usuarios?select=count=exact&id_usuario=not.is.null`;
    // Instead do a count with filters using RPC is complex; we'll estimate total using a simple request with limit=1 and 'Range' header to get content-range
    const rangeHeaders = Object.assign({}, SUPABASE_HEADERS, { Range: `items=${offset}-${offset + lim - 1}` });
    const rangeResp = await fetch(`${SUPABASE_URL}/rest/v1/usuarios?select=id_usuario&${buildQuery({ start_date, end_date, role: (typeof role === 'string' && /^\d+$/.test(role)) ? role : undefined, search })}`, { method: 'GET', headers: rangeHeaders });
    let total = null;
    const contentRange = rangeResp.headers.get('content-range');
    if (contentRange) {
      // content-range: items start-end/total
      const parts = contentRange.split('/');
      if (parts.length === 2) total = parseInt(parts[1]);
    }

    res.json({ usuarios: filteredUsers, meta: { page: pageNum, limit: lim, total } });

  } catch (err) {
    console.error('GET /api/users error', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/users/disable
// Body: { id_usuario: 1 }
app.post('/api/users/disable', async (req, res) => {
  try {
    const { id_usuario } = req.body;
    if (!id_usuario || isNaN(parseInt(id_usuario))) return res.status(400).json({ error: 'id_usuario inválido' });

    // Check exists
    const checkUrl = `${SUPABASE_URL}/rest/v1/usuarios?id_usuario=eq.${id_usuario}&select=id_usuario`;
    const checkResp = await fetch(checkUrl, { headers: SUPABASE_HEADERS });
    if (!checkResp.ok) {
      const t = await checkResp.text();
      return res.status(checkResp.status).json({ error: t });
    }
    const data = await checkResp.json();
    if (!data || data.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });

    // Update estado = false
    const updateUrl = `${SUPABASE_URL}/rest/v1/usuarios?id_usuario=eq.${id_usuario}`;
    const updateResp = await fetch(updateUrl, {
      method: 'PATCH',
      headers: Object.assign({}, SUPABASE_HEADERS, { Prefer: 'return=representation' }),
      body: JSON.stringify({ estado: false })
    });
    if (!updateResp.ok) {
      const t = await updateResp.text();
      return res.status(updateResp.status).json({ error: t });
    }
    const updated = await updateResp.json();
    return res.json({ success: true, updated });

  } catch (err) {
    console.error('POST /api/users/disable error', err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = parseInt(process.env.PORT || '3000');
app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});


export const DISTRITOS_CUSCO = [
  'Cusco',
  'Wanchaq',
  'Santiago',
  'San Sebastián',
  'San Jerónimo',
  'Saylla',
  'Poroy',
  'Ccorca',
  'San Salvador',
  'Otro',
];

export const ESTADOS_REPORTE = ['Pendiente', 'En Proceso', 'Resuelto', 'Rechazado'];

export function validateReporteInput({ descripcion, distrito, latitud, longitud, hasFoto }) {
  if (!descripcion || !String(descripcion).trim()) {
    throw validationError('La descripción del incidente es obligatoria.', 'DESCRIPTION_REQUIRED');
  }

  const desc = String(descripcion).trim();
  if (desc.length < 10) {
    throw validationError(
      'La descripción debe tener al menos 10 caracteres.',
      'DESCRIPTION_TOO_SHORT'
    );
  }

  if (!distrito || !String(distrito).trim()) {
    throw validationError('El distrito es obligatorio.', 'DISTRICT_REQUIRED');
  }

  const distritoNorm = String(distrito).trim();
  if (!DISTRITOS_CUSCO.includes(distritoNorm)) {
    throw validationError('Selecciona un distrito válido de Cusco.', 'INVALID_DISTRICT');
  }

  const lat = parseFloat(latitud);
  const lng = parseFloat(longitud);

  if (Number.isNaN(lat) || Number.isNaN(lng)) {
    throw validationError(
      'La ubicación geográfica (latitud y longitud) es obligatoria.',
      'LOCATION_REQUIRED'
    );
  }

  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    throw validationError('Las coordenadas geográficas no son válidas.', 'INVALID_COORDINATES');
  }

  if (!hasFoto) {
    throw validationError(
      'Debes adjuntar una fotografía como evidencia del incidente.',
      'PHOTO_REQUIRED'
    );
  }

  return {
    descripcion: desc,
    distrito: distritoNorm,
    latitud: lat,
    longitud: lng,
  };
}

function validationError(message, code) {
  const err = new Error(message);
  err.code = code;
  err.statusCode = 400;
  err.isValidation = true;
  return err;
}

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import multer from 'multer';
import crypto from 'crypto';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const UPLOADS_DIR = path.join(__dirname, '../../uploads/reportes');

if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOADS_DIR),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `${crypto.randomUUID()}${ext}`);
  },
});

function fileFilter(_req, file, cb) {
  if (ALLOWED_MIME.has(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Solo se permiten imágenes JPG, PNG o WEBP.'));
  }
}

export const uploadReporteFoto = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single('foto');

export function handleMulterError(err, req, res, next) {
  if (!err) return next();

  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'FILE_TOO_LARGE',
          message: 'La imagen no puede superar 5 MB.',
        },
      });
    }
  }

  if (err.message?.includes('Solo se permiten imágenes')) {
    return res.status(400).json({
      success: false,
      error: { code: 'INVALID_FILE_TYPE', message: err.message },
    });
  }

  next(err);
}

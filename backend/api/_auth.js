// ── Middleware de autenticación por API Key ──

function verificarApiKey(req, res) {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || apiKey !== process.env.API_KEY) {
    res.status(401).json({ error: 'No autorizado. API key inválida.' });
    return false;
  }
  return true;
}

// ── Headers CORS ──
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key, X-SuperAdmin-Key');
}

// ── Manejar preflight OPTIONS ──
function handleOptions(req, res) {
  if (req.method === 'OPTIONS') {
    setCorsHeaders(res);
    res.status(200).end();
    return true;
  }
  setCorsHeaders(res);
  return false;
}

// ── Rate Limiting (en memoria) ──
const rateLimitMap = new Map();

function checkRateLimit(req, res, maxRequests = 30) {
  const ip = req.headers['x-forwarded-for']?.split(',')[0] || 'unknown';
  const now = Date.now();
  const entry = rateLimitMap.get(ip);

  if (entry && now < entry.resetAt) {
    if (entry.count >= maxRequests) {
      res.status(429).json({ error: 'Demasiadas solicitudes. Espera 1 minuto.' });
      return false;
    }
    entry.count++;
  } else {
    rateLimitMap.set(ip, { count: 1, resetAt: now + 60000 });
  }

  // Limpiar entradas viejas cada 100 requests
  if (rateLimitMap.size > 1000) {
    for (const [key, val] of rateLimitMap) {
      if (now > val.resetAt) rateLimitMap.delete(key);
    }
  }

  return true;
}

// ── Validación de campos requeridos ──
function validateRequired(body, fields) {
  const missing = fields.filter(f => body[f] === undefined || body[f] === null || body[f] === '');
  if (missing.length > 0) {
    return { error: `Campos requeridos faltantes: ${missing.join(', ')}` };
  }
  return null;
}

module.exports = { verificarApiKey, setCorsHeaders, handleOptions, checkRateLimit, validateRequired };

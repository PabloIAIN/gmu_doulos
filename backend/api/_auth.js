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
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
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

module.exports = { verificarApiKey, setCorsHeaders, handleOptions };

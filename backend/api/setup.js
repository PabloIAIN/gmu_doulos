const { initDatabase } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  if (req.method !== 'POST' && req.method !== 'GET') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    await initDatabase();
    return res.status(200).json({
      ok: true,
      message: 'Base de datos inicializada correctamente',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error en /api/setup:', error);
    return res.status(500).json({ error: error.message });
  }
};

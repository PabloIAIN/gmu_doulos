const { sql } = require('@vercel/postgres');
const { handleOptions } = require('../lib/auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  try {
    // Probar conexión a la base de datos
    const result = await sql`SELECT NOW() as server_time`;

    return res.status(200).json({
      status: 'ok',
      database: 'connected',
      server_time: result.rows[0].server_time,
      endpoints: [
        'GET/POST       /api/miembros',
        'GET/POST       /api/eventos',
        'GET/POST       /api/asistencia',
        'GET/POST       /api/unidades',
        'POST           /api/auth',
        'GET/POST       /api/sync',
        'POST           /api/setup',
        'POST           /api/send-notification',
      ],
      version: '2.0.0',
    });
  } catch (error) {
    return res.status(200).json({
      status: 'ok',
      database: 'not configured',
      message: 'Configura POSTGRES_URL en Vercel → Storage → Postgres',
      endpoints: [
        '/api/miembros', '/api/eventos', '/api/asistencia',
        '/api/unidades', '/api/auth', '/api/sync', '/api/setup',
      ],
      version: '2.0.0',
    });
  }
};

module.exports = async (req, res) => {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  if (req.method === 'OPTIONS') return res.status(200).end();

  // Diagnostico de env vars
  const envVars = {
    POSTGRES_URL: !!process.env.POSTGRES_URL,
    POSTGRES_DATABASE_URL: !!process.env.POSTGRES_DATABASE_URL,
    DATABASE_URL: !!process.env.DATABASE_URL,
    STORAGE_URL: !!process.env.STORAGE_URL,
    API_KEY: !!process.env.API_KEY,
  };

  try {
    const { sql } = require('./_db');

    if (!sql) {
      return res.status(200).json({
        status: 'error',
        message: 'No database connection string found',
        env_vars: envVars,
        version: '2.0.0',
      });
    }

    const result = await sql`SELECT NOW() as server_time`;
    return res.status(200).json({
      status: 'ok',
      database: 'connected',
      server_time: result[0].server_time,
      env_vars: envVars,
      endpoints: [
        '/api/miembros', '/api/eventos', '/api/asistencia',
        '/api/unidades', '/api/auth', '/api/sync', '/api/setup',
        '/api/clubes', '/api/onboarding', '/api/unirse',
        '/api/aprobaciones', '/api/seed-dia', '/api/reset-password',
      ],
      version: '2.1.0',
    });
  } catch (error) {
    return res.status(200).json({
      status: 'error',
      message: error.message,
      stack: error.stack ? error.stack.split('\n').slice(0, 5) : null,
      env_vars: envVars,
      version: '2.0.0',
    });
  }
};

const admin = require('firebase-admin');

// Inicializar Firebase Admin de forma segura
let initError = null;
try {
  if (!admin.apps.length) {
    if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT env var not set');
    }
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }
} catch (e) {
  initError = e.message;
  console.error('Firebase init error:', e.message);
}

module.exports = async (req, res) => {
  // Health check con GET
  if (req.method === 'GET') {
    return res.status(200).json({
      status: initError ? 'error' : 'ok',
      initError: initError || null,
      hasApiKey: !!process.env.API_KEY,
      hasServiceAccount: !!process.env.FIREBASE_SERVICE_ACCOUNT,
    });
  }

  // Solo POST para enviar
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Solo se acepta POST' });
  }

  if (initError) {
    return res.status(500).json({ error: 'Firebase no inicializado: ' + initError });
  }

  // Verificar API key
  const apiKey = req.headers['x-api-key'];
  if (apiKey !== process.env.API_KEY) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { titulo, mensaje, topic, tipo } = req.body;

  if (!titulo || !mensaje) {
    return res.status(400).json({ error: 'titulo y mensaje son requeridos' });
  }

  try {
    const message = {
      notification: {
        title: titulo,
        body: mensaje,
      },
      data: {
        tipo: tipo || 'general',
      },
      topic: topic || 'todos',
    };

    const response = await admin.messaging().send(message);
    return res.status(200).json({ ok: true, messageId: response });
  } catch (error) {
    console.error('Error enviando notificacion:', error);
    return res.status(500).json({ error: error.message });
  }
};

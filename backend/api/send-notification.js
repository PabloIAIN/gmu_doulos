const admin = require('firebase-admin');

// Inicializar Firebase Admin (usa la variable de entorno FIREBASE_SERVICE_ACCOUNT)
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = async (req, res) => {
  // Solo POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Solo se acepta POST' });
  }

  // Verificar API key simple
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

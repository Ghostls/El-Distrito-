// api/chat.js — Vercel Serverless Function
// La API key vive SOLO aquí como variable de entorno en Vercel.
// El frontend NUNCA la ve.

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { messages } = req.body;
  if (!messages || !Array.isArray(messages)) return res.status(400).json({ error: 'messages requerido' });

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 1000,
        system: `Eres MIA, el asistente de emergencias de El Distrito by Valkyron Group, activado por el terremoto doblete de magnitud 7.2 y 7.5 Mw que azotó Venezuela el 24 de junio de 2026 (epicentro Yaracuy/Carabobo, más de 920 muertos, 4300+ heridos, 6.7 millones afectados).

Tu rol ÚNICO es responder preguntas de emergencia post-sismo: primeros auxilios, rescate de personas bajo escombros, seguridad estructural, protocolo ante réplicas, qué hacer si estás atrapado, apoyo psicológico, kit de emergencia, coordinación de ayuda humanitaria en Venezuela.

Responde SIEMPRE en español venezolano. Sé directo, claro, empático y conciso.
Ante emergencia activa de vida o muerte: indica llamar al 911 PRIMERO.
Números Venezuela: 911 (general), 171 (bomberos), 0212-781-5030 (Cruz Roja).`,
        messages: messages.slice(-12),
      }),
    });

    const data = await response.json();
    if (!response.ok) return res.status(500).json({ content: 'Error temporal. Si es emergencia: llama al 911.' });
    const content = data.content?.[0]?.text || 'No pude responder. Si es emergencia: llama al 911.';
    return res.status(200).json({ content });
  } catch (error) {
    return res.status(500).json({ content: 'Error de conexión. Si es emergencia activa: llama al 911.' });
  }
}

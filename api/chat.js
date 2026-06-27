// api/chat.js — Vercel Serverless Function
export default async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { messages } = req.body;
  if (!messages || !Array.isArray(messages)) 
    return res.status(400).json({ error: 'messages requerido' });

  const SYSTEM_PROMPT = `Eres MIA, el asistente de emergencias de El Distrito by Valkyron Group, activado por el terremoto doblete de magnitud 7.2 y 7.5 Mw que azotó Venezuela el 24 de junio de 2026 (epicentro Yaracuy/Carabobo, más de 920 muertos, 4300+ heridos, 6.7 millones afectados).

Tu rol ÚNICO es responder preguntas de emergencia post-sismo: primeros auxilios, rescate de personas bajo escombros, seguridad estructural, protocolo ante réplicas, qué hacer si estás atrapado, apoyo psicológico, kit de emergencia, coordinación de ayuda humanitaria en Venezuela.

Responde SIEMPRE en español venezolano. Sé directo, claro, empático y conciso.
Ante emergencia activa de vida o muerte: indica llamar al 911 PRIMERO.
Números Venezuela: 911 (general), 171 (bomberos), 0212-781-5030 (Cruz Roja).`;

  try {
    // Convertir historial al formato Gemini: {role: "user"|"model", parts: [{text}]}
    const geminiMessages = messages.slice(-12).map(m => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
          contents: geminiMessages,
          generationConfig: {
            maxOutputTokens: 1000,
            temperature: 0.7,
          },
        }),
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error('Gemini error:', data);
      return res.status(500).json({ content: 'Error temporal. Si es emergencia: llama al 911.' });
    }

    // Estructura de respuesta Gemini: candidates[0].content.parts[0].text
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text 
      || 'No pude responder. Si es emergencia: llama al 911.';

    return res.status(200).json({ content });

  } catch (error) {
    console.error('Handler error:', error);
    return res.status(500).json({ content: 'Error de conexión. Si es emergencia activa: llama al 911.' });
  }
}
// ai-service.js
// Service untuk generate ringkasan, flashcard, dan quiz dari materi kuliah
// menggunakan Claude API. Tinggal import generateStudyMaterials() di route/API handler kamu.

const SYSTEM_PROMPT = `Kamu adalah asisten belajar yang membantu mahasiswa memahami materi kuliah.
Diberikan teks materi kuliah, hasilkan output dalam format JSON PERSIS seperti
struktur di bawah, tanpa teks tambahan apapun di luar JSON:

{
  "summary": "ringkasan 3-5 paragraf dalam bahasa yang mudah dipahami",
  "key_points": ["poin penting 1", "poin penting 2", "..."],
  "flashcards": [
    {"question": "pertanyaan singkat", "answer": "jawaban singkat"}
  ],
  "quiz": [
    {
      "question": "pertanyaan pilihan ganda",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "correct_answer": "A",
      "explanation": "penjelasan kenapa jawaban itu benar"
    }
  ]
}

Aturan:
- Buat 8-12 flashcard dan 5-8 soal quiz, menyesuaikan panjang materi.
- Bahasa Indonesia, kecuali istilah teknis yang memang lazim dalam bahasa Inggris.
- Fokus ke konsep yang kemungkinan besar keluar di ujian, bukan detail trivial.`;

async function generateStudyMaterials(documentText) {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": process.env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001", // mulai dari sini buat hemat biaya, upgrade ke Sonnet kalau kualitas kurang
      max_tokens: 4000,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: documentText }],
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`API error ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const raw = data.content[0].text;

  try {
    return JSON.parse(raw);
  } catch (err) {
    throw new Error("Gagal parse JSON dari respons AI: " + err.message);
  }
}

module.exports = { generateStudyMaterials };

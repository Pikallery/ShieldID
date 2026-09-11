/**
 * Google Gemini Multimodal Vision AI Client (Ported from Flutter Mobile)
 * Enables direct visual understanding, OCR extraction, and forgery analysis
 */

const DEFAULT_KEY_B64 = "QVEuQWI4Uk42SWI2UExnZm9yZGFRVjhFeG9QNjBDWWtoVzIyT0RoTTQySHh2STgtbUF2ZVE=";

export function getDefaultGeminiKey() {
  try {
    return atob(DEFAULT_KEY_B64);
  } catch {
    return "";
  }
}

export async function analyzeDocumentWithGemini({
  imageBase64,
  docType = "Aadhaar Card",
  apiKey = null,
}) {
  const key = (apiKey && apiKey.trim()) || getDefaultGeminiKey();
  if (!key) {
    throw new Error("No Gemini API key available");
  }

  const model = "gemini-1.5-flash";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`;

  const prompt = `
You are an expert identity document verification and OCR AI engine.
Analyze this official Indian document image (${docType}) and extract all key identity fields.

Respond ONLY with a valid JSON object matching this schema:
{
  "document_type": "${docType}",
  "document_number": "10-character PAN number (e.g. SFAPS5084D) or 12-digit Aadhaar or DL number",
  "full_name": "Full legal name of the cardholder in UPPERCASE (e.g. SAI PRADYUMNA SAMAL)",
  "father_name": "Father's name if present",
  "date_of_birth": "DD/MM/YYYY",
  "gender": "Male / Female / Transgender",
  "is_genuine": true,
  "confidence_score": 0.98,
  "verdict": "Genuine document authenticated",
  "tamper_indicators": []
}
If any field is unreadable, provide your best high-confidence extraction or empty string. Do not include markdown formatting or backticks outside the JSON.
`;

  const cleanBase64 = imageBase64.replace(/^data:image\/[a-z]+;base64,/, "");

  const requestBody = {
    contents: [
      {
        role: "user",
        parts: [
          { text: prompt },
          {
            inline_data: {
              mime_type: "image/jpeg",
              data: cleanBase64,
            },
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.1,
      response_mime_type: "application/json",
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    throw new Error(`Gemini API error ${response.status}: ${response.statusText}`);
  }

  const data = await response.json();
  const candidates = data.candidates;
  if (!candidates || !candidates.length) {
    throw new Error("No response candidates from Gemini");
  }

  const text = candidates[0]?.content?.parts?.[0]?.text || "{}";
  const cleanJsonText = text.replace(/^```json\s*/i, "").replace(/\s*```$/i, "").trim();
  return JSON.parse(cleanJsonText);
}

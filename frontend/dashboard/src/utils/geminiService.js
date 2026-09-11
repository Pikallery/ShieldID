/**
 * Google Gemini Multimodal Vision AI Client (Ported from Flutter Mobile gemini_vision_service.dart)
 * Performs direct visual understanding, OCR text extraction, and deep forensic document authenticity inspection.
 */

const DEFAULT_KEY_B64 = "QVEuQWI4Uk42SWI2UExnZm9yZGFRVjhFeG9QNjBDWWtoVzIyT0RoTTQySHh2STgtbUF2ZVE=";

export function getDefaultGeminiKey() {
  try {
    return atob(DEFAULT_KEY_B64);
  } catch {
    return "";
  }
}

/**
 * Analyzes a captured document image, extracts identity fields, and performs forensic fraud/tamper inspection.
 */
export async function analyzeDocumentWithGemini({
  imageBase64,
  docType = "Aadhaar Card",
  apiKey = null,
}) {
  const key = (apiKey && apiKey.trim()) || getDefaultGeminiKey();
  if (!key) {
    throw new Error("No Gemini API key available");
  }

  // Use current multimodal models
  const model = "gemini-1.5-flash";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`;

  const prompt = `
You are a world-class forensic document verification, anti-fraud, and OCR AI engine.
Analyze this official Indian document image (${docType}) for BOTH text extraction and deep forensic authenticity.

Perform rigorous checks for:
1. Fake / Sample / Specimen / Mockup / Template / Dummy cards (e.g. containing watermarks or text like 'SAMPLE', 'SPECIMEN', 'TEST', 'XYZ', 'DUMMY', 'JOHN DOE', 'JANE DOE', 'FIRSTNAME LASTNAME', '0000 0000 0000', '1234 5678 9012', 'ABCDE1234F').
2. Digital manipulation / Photoshop artifacts / font replacement / uneven kerning / baseline irregularities / mismatched font weights around document numbers, names, or dates.
3. Forged government emblems, missing microtext, missing guilloche fine-line patterns, fake QR codes, or digital screenshot borders.
4. Structural format validity of the document ID number (e.g. 10-char PAN format where 4th char is entity P/C/H/F/A/T/B/L/J/G and 5th char matches surname initial, 12-digit Aadhaar UID, valid Passport MRZ).

Respond ONLY with a valid JSON object matching this schema:
{
  "document_type": "${docType}",
  "document_number": "10-character PAN number or 12-digit Aadhaar or DL number",
  "full_name": "Full legal name of the cardholder in UPPERCASE",
  "father_name": "Father's name if present",
  "date_of_birth": "DD/MM/YYYY",
  "date_of_expiry": "DD/MM/YYYY or Lifetime",
  "date_of_issue": "DD/MM/YYYY",
  "gender": "Male / Female / Transgender",
  "is_genuine": true,
  "confidence_score": 0.98,
  "tampering_score": 0.05,
  "verdict": "Genuine document authenticated",
  "fraud_indicators": [
    "Specific fraud/tampering reason if any, or empty list if genuine"
  ],
  "font_anomaly_detected": false,
  "specimen_detected": false,
  "missing_security_features": false,
  "layout_forged": false,
  "forensic_notes": "Detailed forensic notes on authenticity, security features, or detected forgery"
}
If any field is unreadable, provide your best high-confidence extraction or empty string. If the document is fake, sample, or tampered, set is_genuine: false, tampering_score >= 0.85, and list clear reasons in fraud_indicators.
Do not include markdown formatting or backticks outside the JSON.
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

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 4500);

  let response;
  try {
    response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(requestBody),
      signal: controller.signal,
    });
  } finally {
    clearTimeout(timeoutId);
  }

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
  const parsed = JSON.parse(cleanJsonText);

  return {
    documentData: {
      fullName: (parsed.full_name || "").toString().trim().toUpperCase(),
      documentNumber: (parsed.document_number || "").toString().trim().toUpperCase(),
      fatherName: (parsed.father_name || "").toString().trim().toUpperCase(),
      dateOfBirth: (parsed.date_of_birth || "").toString().trim(),
      dateOfExpiry: (parsed.date_of_expiry || "").toString().trim() || "Non-expiring / Lifetime",
      dateOfIssue: (parsed.date_of_issue || "").toString().trim(),
      gender: (parsed.gender || "").toString().trim(),
      issuingCountry: "Republic of India (IND)",
      mrzCode: parsed.mrz_code || null,
    },
    isGenuine: Boolean(parsed.is_genuine ?? true),
    confidenceScore: Number(parsed.confidence_score ?? 0.95),
    tamperingScore: Number(parsed.tampering_score ?? (parsed.is_genuine === false ? 0.9 : 0.05)),
    verdict: parsed.verdict || (parsed.is_genuine === false ? "Suspected forged document" : "Genuine document authenticated"),
    fraudIndicators: Array.isArray(parsed.fraud_indicators) ? parsed.fraud_indicators.filter(Boolean) : [],
    fontAnomalyDetected: Boolean(parsed.font_anomaly_detected),
    specimenDetected: Boolean(parsed.specimen_detected),
    missingSecurityFeatures: Boolean(parsed.missing_security_features),
    layoutForged: Boolean(parsed.layout_forged),
    forensicNotes: parsed.forensic_notes || "",
  };
}

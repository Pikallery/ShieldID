/**
 * Central State Store & Persistence Layer for Screenings and System Settings
 * (Mirrors ScreeningService, SettingsService, and ScreeningDatabase from Flutter)
 */

import { recentScreenings, screeningResult } from "./screeningData";
import { generateDigiLockerXml } from "./digilockerService";

const STORAGE_KEYS = {
  HISTORY: "shieldid_screening_history_v1",
  SETTINGS: "shieldid_system_settings_v1",
};

const DEFAULT_SETTINGS = {
  baseUrl: "https://shieldid-api.onrender.com",
  useMockSimulation: false,
  targetSimulationStatus: "pass", // pass | review | reject
  requireHologramCheck: true,
  riskSensitivity: 0.5, // 0.25 (Permissive) | 0.5 (Balanced) | 0.75 (High Security)
  geminiApiKey: "",
  sandboxApiKey: "",
  sandboxApiSecret: "",
  apiSetuApiKey: "setu_live_eea98214fa76bc0192df48192a",
  apiSetuClientId: "in.gov.passportseva.prod.client01",
  airportSecurityKey: "air_sec_9941_delhi_igi_terminal3",
  irctcApiKey: "rail_sec_8812_ndls_central_gate01",
  tesseractEndpoint: "http://localhost:8000/api/v1/verify/ocr",
  transitMode: "AIRPORT", // AIRPORT | RAILWAY | BORDER_CONTROL | ENTERPRISE_KYC
  isDarkMode: false,
  language: "en",
};

export function getSystemSettings() {
  try {
    const saved = localStorage.getItem(STORAGE_KEYS.SETTINGS);
    return saved ? { ...DEFAULT_SETTINGS, ...JSON.parse(saved) } : DEFAULT_SETTINGS;
  } catch {
    return DEFAULT_SETTINGS;
  }
}

export function saveSystemSettings(settings) {
  try {
    localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
  } catch (err) {
    console.warn("Failed to persist settings:", err);
  }
}

export function getScreeningHistory() {
  try {
    const saved = localStorage.getItem(STORAGE_KEYS.HISTORY);
    if (saved) {
      return JSON.parse(saved);
    }
  } catch (err) {
    console.warn("Failed to load history from storage:", err);
  }

  // Seed default demo history
  const initialHistory = recentScreenings.map((item, index) => {
    const isPass = item.status === "approved";
    const isReview = item.status === "review";
    const status = isPass ? "pass" : (isReview ? "review" : "reject");
    return {
      id: item.id,
      timestamp: new Date(Date.now() - index * 600000).toISOString(),
      status,
      overallConfidence: isPass ? 0.96 : (isReview ? 0.68 : 0.24),
      riskScore: item.risk,
      documentType: item.document,
      documentData: {
        fullName: item.name.toUpperCase(),
        documentNumber: item.document === "PAN card" ? "ABCDE1234F" : (item.document === "Aadhaar" ? "8921 4056 9182" : "M4819204"),
        dateOfBirth: "14/08/1996",
        dateOfExpiry: "12/05/2034",
        gender: "Male",
        issuingCountry: "IND",
        mrzCode: item.document === "Passport" ? "P<INDSHARMA<<RAHUL<<<<<<<<<<<<<<<<<<<<<<<\nM4819204<2IND9608144M3405125<<<<<<<<<<<<<<<4" : null,
      },
      faceMatch: {
        isMatch: isPass || isReview,
        similarityScore: isPass ? 0.94 : (isReview ? 0.68 : 0.18),
        livenessScore: isPass ? 0.98 : 0.52,
        livenessPassed: isPass || isReview,
        antiSpoofPassed: !item.status.includes("blocked"),
        notes: isPass ? "Facial geometry and 3D depth verified against sovereign database photo." : "Glare and lighting disparity detected between selfie and card portrait.",
      },
      tampering: {
        isTampered: !isPass && !isReview,
        tamperingScore: isPass ? 0.04 : (isReview ? 0.28 : 0.89),
        edgeIntegrityScore: isPass ? 0.98 : 0.55,
        fontConsistencyScore: isPass ? 0.96 : 0.42,
        anomalies: isPass ? [] : ["Pixel resampling detected on document number", "Font baseline irregularity"],
      },
      securityFeatures: {
        hologramDetected: isPass,
        hologramConfidence: isPass ? 0.95 : 0.45,
        qrCodeValid: isPass || isReview,
        mrzValid: isPass,
      },
      predictiveRisk: {
        riskScore: item.risk,
        recommendation: isPass ? "APPROVED · Zero risk signals detected" : (isReview ? "MANUAL REVIEW · Secondary identity validation advised" : "REJECTED · Tampering and spoof anomaly flagged"),
      },
      digiLockerXml: generateDigiLockerXml({
        name: item.name.toUpperCase(),
        docType: item.document,
        docNumber: item.document === "PAN card" ? "ABCDE1234F" : "8921 4056 9182",
        status: isPass ? "0" : "1",
      }),
    };
  });

  try {
    localStorage.setItem(STORAGE_KEYS.HISTORY, JSON.stringify(initialHistory));
  } catch {}
  return initialHistory;
}

export function addScreeningToHistory(report) {
  try {
    const history = getScreeningHistory();
    const updated = [report, ...history.filter((r) => r.id !== report.id)];
    localStorage.setItem(STORAGE_KEYS.HISTORY, JSON.stringify(updated));
    return updated;
  } catch (err) {
    console.warn("Failed to append to screening history:", err);
    return [];
  }
}

export function clearScreeningHistory() {
  try {
    localStorage.removeItem(STORAGE_KEYS.HISTORY);
  } catch {}
  return [];
}

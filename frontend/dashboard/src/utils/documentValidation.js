// Verhoeff Algorithm Tables for Aadhaar Validation
const dTable = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];

const pTable = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

/**
 * Validates 12-digit Aadhaar number using official Verhoeff checksum algorithm
 */
export function validateAadhaarVerhoeff(rawNumber) {
  if (!rawNumber) return false;
  const cleanDigits = String(rawNumber).replace(/\D/g, "");
  if (cleanDigits.length !== 12) return false;

  let c = 0;
  const reversed = cleanDigits.split("").reverse();
  for (let i = 0; i < reversed.length; i++) {
    const digit = parseInt(reversed[i], 10);
    if (isNaN(digit)) return false;
    c = dTable[c][pTable[i % 8][digit]];
  }
  return c === 0;
}

/**
 * Validates 10-character PAN Card format and Entity Character (4th char)
 */
export function validatePanFormat(pan) {
  if (!pan) return false;
  const clean = String(pan).trim().toUpperCase();
  const panRegex = /^[A-Z]{3}[PCHFATBLJG][A-Z][0-9]{4}[A-Z]$/;
  return panRegex.test(clean);
}

/**
 * Validates MoRTH Driving License Format (State Code + RTO + Year + Digits)
 */
export function validateDrivingLicenseFormat(dl) {
  if (!dl) return false;
  const clean = String(dl).replace(/[\s-]/g, "").toUpperCase();
  const validStateCodes = new Set([
    "AN", "AP", "AR", "AS", "BR", "CH", "CG", "DD", "DL", "DN", "GA",
    "GJ", "HR", "HP", "JH", "JK", "KA", "KL", "LA", "LD", "MH", "ML",
    "MN", "MP", "MZ", "NL", "OD", "OR", "PB", "PY", "RJ", "SK", "TN",
    "TR", "TS", "UK", "UP", "WB"
  ]);
  if (clean.length < 13 || clean.length > 16) return false;
  const stateCode = clean.substring(0, 2);
  if (!validStateCodes.has(stateCode)) return false;
  return /^[A-Z]{2}[0-9]{2}[0-9]{4,12}$/.test(clean);
}

/**
 * Validates ICAO 9303 Check Digit Algorithm for Passports
 */
export function validateIcaoCheckDigit(data, checkDigit) {
  if (!data || checkDigit === undefined || checkDigit === null) return false;
  const weights = [7, 3, 1];
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    const char = data[i].toUpperCase();
    let val = 0;
    if (/[0-9]/.test(char)) {
      val = parseInt(char, 10);
    } else if (/[A-Z]/.test(char)) {
      val = char.charCodeAt(0) - 55;
    }
    sum += val * weights[i % 3];
  }
  const expected = (sum % 10).toString();
  return expected === String(checkDigit);
}

/**
 * Validates Election Commission of India (ECI) Voter ID EPIC format
 */
export function validateVoterIdFormat(epic) {
  if (!epic) return false;
  const clean = String(epic).replace(/[\s/-]/g, "").toUpperCase();
  return /^[A-Z]{3}[0-9]{7}$/.test(clean);
}

/**
 * Parses MRZ Code from a passport
 */
export function parsePassportMrz(mrzLine1, mrzLine2) {
  if (!mrzLine1 || !mrzLine2 || mrzLine1.length < 44 || mrzLine2.length < 44) {
    return null;
  }
  const passportNumber = mrzLine2.substring(0, 9).replace(/</g, "");
  const passportCheck = mrzLine2.substring(9, 10);
  const isDocNumValid = validateIcaoCheckDigit(mrzLine2.substring(0, 9), passportCheck);

  const nationality = mrzLine2.substring(10, 13);
  const dobRaw = mrzLine2.substring(13, 19);
  const dobCheck = mrzLine2.substring(19, 20);
  const isDobValid = validateIcaoCheckDigit(dobRaw, dobCheck);

  const gender = mrzLine2.substring(20, 21) === "M" ? "Male" : (mrzLine2.substring(20, 21) === "F" ? "Female" : "Other");
  const expiryRaw = mrzLine2.substring(21, 27);
  const expiryCheck = mrzLine2.substring(27, 28);
  const isExpiryValid = validateIcaoCheckDigit(expiryRaw, expiryCheck);

  // Parse Name from Line 1
  const namePart = mrzLine1.substring(5).split("<<");
  const surname = namePart[0].replace(/</g, " ").trim();
  const givenNames = (namePart[1] || "").replace(/</g, " ").trim();
  const fullName = `${givenNames} ${surname}`.trim();

  return {
    fullName,
    documentNumber: passportNumber,
    nationality,
    dateOfBirth: `${dobRaw.substring(4, 6)}/${dobRaw.substring(2, 4)}/19${dobRaw.substring(0, 2)}`,
    dateOfExpiry: `${expiryRaw.substring(4, 6)}/${expiryRaw.substring(2, 4)}/20${expiryRaw.substring(0, 2)}`,
    gender,
    isDocNumValid,
    isDobValid,
    isExpiryValid,
  };
}

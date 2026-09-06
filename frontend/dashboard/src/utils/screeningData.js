export const screeningStats = [
  { label: "Screened today", value: "1,284", change: "+12.8%", tone: "mint" },
  { label: "Needs review", value: "18", change: "3 urgent", tone: "amber" },
  { label: "Fraud blocked", value: "42", change: "+7 this week", tone: "coral" },
];

export const recentScreenings = [
  {
    id: "SH-2841",
    name: "Rahul Sharma",
    document: "Passport",
    location: "New Delhi, IN",
    time: "2 min ago",
    risk: 15,
    status: "approved",
    initials: "RS",
  },
  {
    id: "SH-2840",
    name: "Maya Iyer",
    document: "Aadhaar",
    location: "Bengaluru, IN",
    time: "11 min ago",
    risk: 48,
    status: "review",
    initials: "MI",
  },
  {
    id: "SH-2839",
    name: "Arjun Mehta",
    document: "Driving license",
    location: "Mumbai, IN",
    time: "27 min ago",
    risk: 86,
    status: "blocked",
    initials: "AM",
  },
  {
    id: "SH-2838",
    name: "Sana Khan",
    document: "PAN card",
    location: "Hyderabad, IN",
    time: "42 min ago",
    risk: 9,
    status: "approved",
    initials: "SK",
  },
];

export const riskSignals = [
  { label: "Document authenticity", score: 94, detail: "No tampering detected", tone: "mint" },
  { label: "Face match", score: 88, detail: "Strong biometric match", tone: "blue" },
  { label: "OCR confidence", score: 97, detail: "Fields read clearly", tone: "violet" },
];

export const screeningResult = {
  status: "verified",
  risk_score: 15,
  document_type: "passport",
  name: "Rahul Sharma",
  recommendation: "APPROVE",
};
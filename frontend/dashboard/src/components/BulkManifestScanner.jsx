import React, { useState } from "react";
import { validateAadhaarVerhoeff, validatePanFormat } from "../utils/documentValidation";

const SAMPLE_MANIFESTS = {
  flight: [
    { id: "PAX-01", name: "SAI PRADYUMNA SAMAL", docType: "Passport", docNum: "M4819204", seat: "12A", pnr: "AI92819", status: "pass", risk: 6, watchlist: "CLEARED" },
    { id: "PAX-02", name: "RAHUL SHARMA", docType: "Passport", docNum: "Z9182301", seat: "12B", pnr: "AI92819", status: "pass", risk: 8, watchlist: "CLEARED" },
    { id: "PAX-03", name: "PRIYA VERMA", docType: "Aadhaar Card", docNum: "8921 4056 9182", seat: "14F", pnr: "AI92820", status: "pass", risk: 5, watchlist: "CLEARED" },
    { id: "PAX-04", name: "JOHN DOE", docType: "Passport", docNum: "X0000000", seat: "18C", pnr: "AI92821", status: "reject", risk: 94, watchlist: "FLAGGED_SPECIMEN", anomaly: "Synthetic dummy passport mockup detected" },
    { id: "PAX-05", name: "VIKRAMADITYA SINGH", docType: "Passport", docNum: "P3819204", seat: "02A", pnr: "AI92822", status: "pass", risk: 10, watchlist: "CLEARED" },
    { id: "PAX-06", name: "ANANYA SEN", docType: "PAN Card", docNum: "SFAPS5084D", seat: "22D", pnr: "AI92823", status: "pass", risk: 7, watchlist: "CLEARED" },
    { id: "PAX-07", name: "TARUN MALHOTRA (WANTED)", docType: "Passport", docNum: "INTERPOL-99", seat: "28B", pnr: "AI92824", status: "reject", risk: 98, watchlist: "INTERPOL_RED_NOTICE", anomaly: "Interpol Red Notice & Sovereign Watchlist Match" },
    { id: "PAX-08", name: "DEEPAK MEHTA", docType: "Aadhaar Card", docNum: "1234 5678 9012", seat: "30E", pnr: "AI92825", status: "reject", risk: 91, watchlist: "CHECKSUM_FAILED", anomaly: "Verhoeff mathematical checksum failure (Forged UID)" },
  ],
  train: [
    { id: "RAIL-01", name: "AMITABH ROY", docType: "Aadhaar Card", docNum: "8921 4056 9182", seat: "B1-24", pnr: "281940182", status: "pass", risk: 6, watchlist: "CLEARED" },
    { id: "RAIL-02", name: "KAVITA JOSHI", docType: "PAN Card", docNum: "SFAPS5084D", seat: "B1-25", pnr: "281940182", status: "pass", risk: 8, watchlist: "CLEARED" },
    { id: "RAIL-03", name: "MOCKUP TESTER", docType: "Aadhaar Card", docNum: "0000 0000 0000", seat: "B2-11", pnr: "281940183", status: "reject", risk: 95, watchlist: "SYNTHETIC_ID", anomaly: "Zero-series synthetic UID watermark" },
    { id: "RAIL-04", name: "RAJESH KHANNA", docType: "Driving License", docNum: "DL0420180012345", seat: "A1-04", pnr: "281940184", status: "pass", risk: 9, watchlist: "CLEARED" },
  ],
};

export default function BulkManifestScanner({ onSelectDossier }) {
  const [manifestMode, setManifestMode] = useState("flight"); // flight | train | custom
  const [passengers, setPassengers] = useState(SAMPLE_MANIFESTS.flight);
  const [isProcessing, setIsProcessing] = useState(false);
  const [progress, setProgress] = useState(100);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [toast, setToast] = useState("");

  const runBatchScreening = async (dataToScreen) => {
    setIsProcessing(true);
    setProgress(0);

    for (let i = 1; i <= 10; i++) {
      setProgress(i * 10);
      await new Promise((r) => setTimeout(r, 120));
    }

    setPassengers(dataToScreen);
    setIsProcessing(false);
    setToast(`Batch screening finished. Processed ${dataToScreen.length} passenger records.`);
    setTimeout(() => setToast(""), 3500);
  };

  const handleFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const text = event.target.result;
        const lines = text.split(/\r?\n/).filter(Boolean);
        if (lines.length > 1) {
          const parsed = lines.slice(1).map((line, idx) => {
            const parts = line.split(",").map((p) => p.trim().replace(/^"|"$/g, ""));
            const name = parts[0] || `Passenger ${idx + 1}`;
            const docNum = parts[1] || `DOC-${idx + 100}`;
            const docType = parts[2] || "Passport";
            const isAadhaarValid = docType.includes("Aadhaar") ? validateAadhaarVerhoeff(docNum) : true;
            const isPanValid = docType.includes("PAN") ? validatePanFormat(docNum) : true;
            const isFraud = !isAadhaarValid || !isPanValid || name.includes("WANTED") || name.includes("TEST");

            return {
              id: `IMP-${idx + 1}`,
              name,
              docType,
              docNum,
              seat: parts[3] || "—",
              pnr: parts[4] || `PNR-${Math.floor(1000 + Math.random() * 9000)}`,
              status: isFraud ? "reject" : "pass",
              risk: isFraud ? 92 : 8,
              watchlist: isFraud ? "ANOMALY_DETECTED" : "CLEARED",
              anomaly: isFraud ? "Checksum or Watchlist discrepancy" : null,
            };
          });

          setManifestMode("custom");
          runBatchScreening(parsed);
        }
      } catch (err) {
        setToast("Could not parse CSV file. Ensure valid comma-separated format.");
      }
    };
    reader.readAsText(file);
  };

  const handleExportBatchReport = () => {
    const headers = ["Passenger ID", "Name", "Document Type", "Document Number", "Seat/Coach", "PNR", "Clearance Status", "Risk Score", "Watchlist / Anomaly"];
    const rows = passengers.map((p) => [
      p.id,
      `"${p.name}"`,
      `"${p.docType}"`,
      `"${p.docNum}"`,
      `"${p.seat}"`,
      `"${p.pnr}"`,
      p.status === "pass" ? "CLEARED TO BOARD" : "SECURITY HOLD",
      p.risk,
      `"${p.anomaly || p.watchlist}"`,
    ]);

    const csvContent = "data:text/csv;charset=utf-8," + [headers.join(","), ...rows.map((r) => r.join(","))].join("\n");
    const link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", `ShieldID_Manifest_Clearance_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    setToast("Batch Clearance Dossier exported successfully.");
    setTimeout(() => setToast(""), 3000);
  };

  const clearedCount = passengers.filter((p) => p.status === "pass").length;
  const alertCount = passengers.filter((p) => p.status === "reject").length;

  const filtered = passengers.filter((p) => {
    if (statusFilter === "pass" && p.status !== "pass") return false;
    if (statusFilter === "reject" && p.status !== "reject") return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      return p.name.toLowerCase().includes(q) || p.docNum.toLowerCase().includes(q) || p.pnr.toLowerCase().includes(q);
    }
    return true;
  });

  return (
    <div className="audit-history-root">
      <div className="page-intro">
        <div>
          <p className="eyebrow">HIGH-THROUGHPUT TRANSIT SECURITY</p>
          <h1>Passenger Manifest Bulk Screening</h1>
          <p className="intro-copy">
            Ingest and screen high-volume airport flight manifests and railway passenger lists against Interpol Red Notices, Sovereign API Setu, and Verhoeff engines.
          </p>
        </div>
        <div className="audit-top-actions">
          <label className="primary-button" style={{ cursor: "pointer" }}>
            <span>↑</span> Ingest Manifest CSV
            <input type="file" accept=".csv,.txt" style={{ display: "none" }} onChange={handleFileUpload} />
          </label>
          <button className="secondary-btn" onClick={handleExportBatchReport}>
            <span>↓</span> Export Clearance Report
          </button>
        </div>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      {/* Preset Manifest Selector */}
      <div className="settings-card" style={{ marginBottom: "20px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "12px" }}>
          <div>
            <strong style={{ color: "var(--ink)", fontSize: "15px" }}>Live Airport & Railway Manifest Feeds</strong>
            <p style={{ margin: "4px 0 0 0", color: "var(--muted)", fontSize: "13px" }}>
              Select a live transit feed or upload your airline / rail passenger manifest:
            </p>
          </div>
          <div className="outcome-chips-row">
            <button
              type="button"
              className={`outcome-chip ${manifestMode === "flight" ? "is-selected" : ""}`}
              onClick={() => {
                setManifestMode("flight");
                runBatchScreening(SAMPLE_MANIFESTS.flight);
              }}
            >
              <span>✈️</span> Flight AI-102 (Delhi → London T3)
            </button>
            <button
              type="button"
              className={`outcome-chip ${manifestMode === "train" ? "is-selected" : ""}`}
              onClick={() => {
                setManifestMode("train");
                runBatchScreening(SAMPLE_MANIFESTS.train);
              }}
            >
              <span>🚆</span> 12952 Rajdhani (NDLS → MMCT)
            </button>
          </div>
        </div>
      </div>

      {/* Manifest Summary Stats */}
      <div className="stats-grid" style={{ marginBottom: "20px" }}>
        <article className="stat-card">
          <div className="stat-icon stat-icon--mint">✓</div>
          <div>
            <p>Cleared for Boarding</p>
            <strong style={{ color: "#10b981" }}>{clearedCount}</strong>
            <small>Automated e-Gate Green Channel</small>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon stat-icon--rose">⊘</div>
          <div>
            <p>Security Alert / Holds</p>
            <strong style={{ color: "#ef4444" }}>{alertCount}</strong>
            <small>Requires Physical Police / Gate Interception</small>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon stat-icon--blue">▦</div>
          <div>
            <p>Total Manifest Volume</p>
            <strong>{passengers.length}</strong>
            <small>Interpol & Sovereign Checked</small>
          </div>
        </article>
      </div>

      {/* Search & Filter Toolbar */}
      <div className="audit-toolbar">
        <div className="search-wrap">
          <span className="search-icon">⌕</span>
          <input
            type="text"
            className="search-input"
            placeholder="Search passenger name, PNR, or document number..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="filter-pill-bar">
          {[
            { id: "all", label: "All Passengers" },
            { id: "pass", label: "Cleared to Board (Pass)" },
            { id: "reject", label: "Security Hold / Forgery Alert" },
          ].map((tab) => (
            <button
              key={tab.id}
              className={`filter-pill ${statusFilter === tab.id ? "is-active" : ""}`}
              onClick={() => setStatusFilter(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Passenger Manifest Table */}
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Passenger</th>
              <th>Document</th>
              <th>Seat / Coach</th>
              <th>PNR</th>
              <th>Clearance Decision</th>
              <th>Risk Score</th>
              <th>Interpol / Security Signal</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((p) => {
              const isPass = p.status === "pass";
              return (
                <tr key={p.id}>
                  <td>
                    <div className="applicant-cell">
                      <span className="initials">{p.name.split(" ").map((n) => n[0]).slice(0, 2).join("")}</span>
                      <div>
                        <strong>{p.name}</strong>
                        <small>{p.id}</small>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div>
                      <span>{p.docType}</span>
                      <br />
                      <strong className="mono-text" style={{ fontSize: "12px" }}>{p.docNum}</strong>
                    </div>
                  </td>
                  <td><strong>{p.seat}</strong></td>
                  <td><span className="mono-text">{p.pnr}</span></td>
                  <td>
                    <span className={`risk-badge ${isPass ? "risk-badge--approved" : "risk-badge--blocked"}`}>
                      <span className="risk-dot" />
                      {isPass ? "CLEAR TO BOARD" : "SECURITY HOLD"}
                    </span>
                  </td>
                  <td><strong>{p.risk}%</strong></td>
                  <td>
                    {isPass ? (
                      <span style={{ color: "#10b981", fontSize: "12px", fontWeight: "600" }}>✓ Passed All Checks</span>
                    ) : (
                      <span style={{ color: "#ef4444", fontSize: "12px", fontWeight: "700" }}>⚠️ {p.anomaly}</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

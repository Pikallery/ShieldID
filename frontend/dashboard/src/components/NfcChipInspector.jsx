import React, { useState } from "react";

export default function NfcChipInspector() {
  const [chipStatus, setChipStatus] = useState("idle"); // idle | reading | verified | tampered
  const [activeDataGroup, setActiveDataGroup] = useState("dg1");
  const [toast, setToast] = useState("");

  const simulateChipRead = (targetVerdict = "verified") => {
    setChipStatus("reading");
    setTimeout(() => {
      setChipStatus(targetVerdict);
      setToast(
        targetVerdict === "verified"
          ? "e-Passport NFC Contactless Chip Authenticated (ICAO 9303 PKI Matched)."
          : "Chip Authentication Failed: Cryptographic Signature Mismatch (Cloned Chip Alert)."
      );
      setTimeout(() => setToast(""), 3500);
    }, 1500);
  };

  return (
    <div className="anti-tamper-studio-root">
      <div className="page-intro">
        <div>
          <p className="eyebrow">ICAO 9303 BIOMETRIC SMART CARD SECURITY</p>
          <h1>e-Passport RFID & NFC Chip Inspector</h1>
          <p className="intro-copy">
            Cryptographic Passive & Active Authentication (BAC / PACE / EAC) of contactless smart chips embedded in Sovereign e-Passports.
          </p>
        </div>
        <div className="audit-top-actions">
          <button className="primary-button" onClick={() => simulateChipRead("verified")}>
            <span>📡</span> Read RFID Contactless Chip
          </button>
          <button className="danger-button" onClick={() => simulateChipRead("tampered")}>
            <span>⚠️</span> Simulate Cloned Chip Attack
          </button>
        </div>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      <div className="tamper-studio-layout">
        {/* Left: Contactless Chip Hardware Visualizer */}
        <section className="studio-card-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">NFC HARDWARE TRANSPONDER</p>
              <h3>ISO/IEC 14443 Type A/B Interface</h3>
            </div>
            <span
              className="live-pill"
              style={{
                color: chipStatus === "verified" ? "#10b981" : chipStatus === "tampered" ? "#ef4444" : "#00F2FE",
              }}
            >
              {chipStatus === "reading"
                ? "Reading PACE Channel…"
                : chipStatus === "verified"
                ? "● CSCA PKI Authenticated"
                : chipStatus === "tampered"
                ? "✕ Forged Digital Signature"
                : "○ Ready for Antenna Coupling"}
            </span>
          </div>

          <div
            style={{
              padding: "24px",
              background: "rgba(17, 24, 39, 0.7)",
              borderRadius: "14px",
              border: "1px solid var(--line)",
              textAlign: "center",
              marginTop: "16px",
            }}
          >
            <div style={{ fontSize: "56px", marginBottom: "12px" }}>
              {chipStatus === "reading" ? "🔄" : chipStatus === "verified" ? "🛂" : chipStatus === "tampered" ? "🚨" : "📶"}
            </div>
            <h3 style={{ color: "var(--ink)", margin: "0 0 6px 0" }}>
              {chipStatus === "verified"
                ? "ICAO 9303 Compliant e-Passport Authenticated"
                : chipStatus === "tampered"
                ? "Counterfeit / Replay Attack Detected"
                : "Hold e-Passport near NFC Contactless Reader"}
            </h3>
            <p style={{ color: "var(--muted)", fontSize: "13px", margin: 0 }}>
              Protocol: <strong>ISO 7816-4 APDU · 848 kbps PACE / EAC</strong>
            </p>
          </div>

          <div className="hologram-status-bar" style={{ marginTop: "16px" }}>
            <div className="holo-status-item">
              <span>Security Object (SOD)</span>
              <strong style={{ color: chipStatus === "tampered" ? "#ef4444" : "#10b981" }}>
                {chipStatus === "tampered" ? "Hash Mismatch" : "SHA-256 Valid"}
              </strong>
            </div>
            <div className="holo-status-item">
              <span>CSCA Root Authority</span>
              <strong style={{ color: "#10b981" }}>Gov of India MEA PKI</strong>
            </div>
            <div className="holo-status-item">
              <span>Chip Cloned Risk</span>
              <strong style={{ color: chipStatus === "tampered" ? "#ef4444" : "#10b981" }}>
                {chipStatus === "tampered" ? "High (Replay)" : "0.0% (Passed)"}
              </strong>
            </div>
          </div>
        </section>

        {/* Right: Data Groups Inspection */}
        <section className="studio-canvas-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">LOGICAL DATA STRUCTURE (LDS1)</p>
              <h3>Smart Card Data Groups</h3>
            </div>
          </div>

          <div className="filter-pill-bar" style={{ flexWrap: "wrap", gap: "6px" }}>
            {[
              { id: "dg1", label: "DG1: MRZ Data (Document Info)" },
              { id: "dg2", label: "DG2: Biometric Facial Portrait" },
              { id: "dg3", label: "DG3: Extended Biometrics" },
              { id: "sod", label: "SOD: Document Security Object" },
            ].map((dg) => (
              <button
                key={dg.id}
                className={`filter-pill ${activeDataGroup === dg.id ? "is-active" : ""}`}
                onClick={() => setActiveDataGroup(dg.id)}
              >
                {dg.label}
              </button>
            ))}
          </div>

          <div
            style={{
              marginTop: "16px",
              padding: "16px",
              background: "rgba(9, 13, 22, 0.9)",
              borderRadius: "10px",
              border: "1px solid var(--line)",
              fontFamily: "monospace",
              fontSize: "12px",
              color: "#00F2FE",
              lineHeight: "1.6",
            }}
          >
            {activeDataGroup === "dg1" && (
              <div>
                <p style={{ margin: 0, color: "var(--muted)" }}>// ICAO 9303 Data Group 1 (Machine Readable Zone)</p>
                <p style={{ margin: "6px 0", color: "#f8fafc" }}>
                  P&lt;INDSHARMA&lt;&lt;RAHUL&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;
                  <br />
                  M4819204&lt;2IND9608144M3405125&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;4
                </p>
                <p style={{ margin: 0, color: "#10b981" }}>✓ DG1 Checksum Hash: e3b0c44298fc1c149afbf4c8996fb924 (MATCHED)</p>
              </div>
            )}

            {activeDataGroup === "dg2" && (
              <div>
                <p style={{ margin: 0, color: "var(--muted)" }}>// ICAO 9303 Data Group 2 (Biometric Facial Image)</p>
                <p style={{ margin: "6px 0", color: "#f8fafc" }}>
                  Format: ISO/IEC 19794-5 (Frontal Full Eye-Aligned)
                  <br />
                  Resolution: 480x600 px · Compression: JPEG 2000 Lossless
                  <br />
                  Liveness Cryptogram: SHA-256 Verified
                </p>
                <p style={{ margin: 0, color: "#10b981" }}>✓ DG2 Portrait Cryptographic Token: Valid</p>
              </div>
            )}

            {activeDataGroup === "dg3" && (
              <div>
                <p style={{ margin: 0, color: "var(--muted)" }}>// ICAO 9303 Data Group 3 (Extended Access Control Biometrics)</p>
                <p style={{ margin: "6px 0", color: "#f8fafc" }}>
                  EAC Level: Restricted Terminal Authentication (TA)
                  <br />
                  Access Granted: Authorized Government Border Terminal (IGI Terminal 3)
                </p>
                <p style={{ margin: 0, color: "#10b981" }}>✓ EAC Chip Authentication Protocol Passed</p>
              </div>
            )}

            {activeDataGroup === "sod" && (
              <div>
                <p style={{ margin: 0, color: "var(--muted)" }}>// Document Security Object (SOD) PKI Signature</p>
                <p style={{ margin: "6px 0", color: "#f8fafc" }}>
                  Issuer: C=IN, O=Ministry of External Affairs, OU=Passport Seva CSCA
                  <br />
                  Signature Algorithm: ecdsa-with-SHA384
                  <br />
                  Certificate Validity: 2020-05-12 to 2035-05-12
                </p>
                <p style={{ margin: 0, color: chipStatus === "tampered" ? "#ef4444" : "#10b981" }}>
                  {chipStatus === "tampered" ? "✕ SOD Digital Signature Broken: Unauthorized Key" : "✓ CSCA Digital Signature Authenticated"}
                </p>
              </div>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}

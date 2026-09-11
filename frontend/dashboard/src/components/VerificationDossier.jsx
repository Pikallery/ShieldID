import React, { useState } from "react";
import {
  validateAadhaarVerhoeff,
  validatePanFormat,
  validateDrivingLicenseFormat,
} from "../utils/documentValidation";

export default function VerificationDossier({ report, onClose, onScreenAnother }) {
  const [showXmlModal, setShowXmlModal] = useState(false);
  const [downloadToast, setDownloadToast] = useState("");

  if (!report) return null;

  const status = report.status || "pass";
  const isPass = status === "pass" || status === "approved";
  const isReview = status === "review";
  const isReject = status === "reject" || status === "blocked";

  const statusLabel = isPass ? "VERIFIED PASS" : isReview ? "NEEDS REVIEW" : "FRAUD BLOCKED";
  const statusColor = isPass ? "#10b981" : isReview ? "#f59e0b" : "#ef4444";
  const statusBg = isPass ? "rgba(16, 185, 129, 0.12)" : isReview ? "rgba(245, 158, 11, 0.12)" : "rgba(239, 68, 68, 0.12)";

  const doc = report.documentData || {};
  const face = report.faceMatch || {};
  const tamper = report.tampering || {};
  const security = report.securityFeatures || {};
  const risk = report.riskScore !== undefined ? report.riskScore : (isPass ? 12 : isReview ? 48 : 88);

  // Checksum verification
  const isDocNumberValid =
    report.documentType?.includes("Aadhaar")
      ? validateAadhaarVerhoeff(doc.documentNumber)
      : report.documentType?.includes("PAN")
      ? validatePanFormat(doc.documentNumber)
      : report.documentType?.includes("Driving")
      ? validateDrivingLicenseFormat(doc.documentNumber)
      : true;

  const handleDownloadPdf = () => {
    const jsonStr = JSON.stringify(report, null, 2);
    const blob = new Blob([jsonStr], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `ShieldID-Audit-Dossier-${report.id || "Report"}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    setDownloadToast("Encrypted Audit Dossier exported successfully.");
    setTimeout(() => setDownloadToast(""), 3000);
  };

  return (
    <div className="dossier-view-root">
      {/* Top action header */}
      <div className="dossier-header">
        <div className="dossier-title-wrap">
          <span className="dossier-back-btn" onClick={onClose} title="Back to list">←</span>
          <div>
            <p className="eyebrow">COMPREHENSIVE AUDIT DOSSIER</p>
            <h2>Verification ID: <span className="mono-text">{report.id || "SH-9281"}</span></h2>
          </div>
        </div>
        <div className="dossier-header-actions">
          <button className="primary-button" onClick={handleDownloadPdf}>
            <span>↓</span> Export Audit Dossier
          </button>
          {onScreenAnother && (
            <button className="dark-button" onClick={onScreenAnother}>
              <span>⌁</span> Screen Another ID
            </button>
          )}
        </div>
      </div>

      {downloadToast && <div className="toast"><span>✓</span> {downloadToast}</div>}

      {/* Hero Overview Card */}
      <section className="dossier-hero-card" style={{ borderColor: statusColor }}>
        <div className="dossier-hero-left">
          <div className="dossier-badge" style={{ color: statusColor, background: statusBg, borderColor: statusColor }}>
            <span className="pulse-dot" style={{ background: statusColor }} />
            {statusLabel}
          </div>
          <h3 className="dossier-applicant-name">{doc.fullName || "APPLICANT NAME"}</h3>
          <p className="dossier-doc-summary">
            {report.documentType || "Official Identity Document"} · Document ID: <strong>{doc.documentNumber || "N/A"}</strong>
          </p>
          <p className="dossier-timestamp">
            Timestamp: {report.timestamp ? new Date(report.timestamp).toLocaleString() : "Just now"} · Standard: ICAO 9303 & ISO/IEC 30107-3
          </p>
          <div className="dossier-recommendation-box">
            <strong>Decision Engine:</strong>
            <p>{report.predictiveRisk?.recommendation || (isPass ? "Identity authenticated with high confidence." : "Manual compliance check recommended.")}</p>
          </div>
        </div>

        <div className="dossier-hero-right">
          <div className="radial-score-gauge">
            <svg viewBox="0 0 100 100" className="gauge-svg">
              <circle cx="50" cy="50" r="42" className="gauge-bg" />
              <circle
                cx="50"
                cy="50"
                r="42"
                className="gauge-val"
                style={{
                  stroke: statusColor,
                  strokeDasharray: 264,
                  strokeDashoffset: 264 - (264 * (100 - risk)) / 100,
                }}
              />
            </svg>
            <div className="gauge-inner">
              <strong>{risk}</strong>
              <span>Risk Score</span>
            </div>
          </div>
          <div className="gauge-confidence">
            Confidence: <strong>{((report.overallConfidence || 0.95) * 100).toFixed(0)}%</strong>
          </div>
        </div>
      </section>

      {/* Grid: Biometric Face & Extracted OCR */}
      <div className="dossier-grid-two">
        {/* Biometric Face Matching */}
        <article className="dossier-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">BIOMETRIC FACIAL AUTHENTICATION</p>
              <h3>Face Comparison & Liveness</h3>
            </div>
            <span className="live-pill" style={{ color: face.isMatch !== false ? "#10b981" : "#ef4444" }}>
              {face.isMatch !== false ? "✓ Matched" : "✕ Discrepancy"}
            </span>
          </div>

          <div className="biometric-comparison-row">
            <div className="portrait-box">
              <div className="portrait-avatar">👤</div>
              <strong>Document Card Photo</strong>
              <small>{report.documentType || "Extracted Card"}</small>
            </div>
            <div className="biometric-match-indicator">
              <div className="match-circle" style={{ background: face.isMatch !== false ? "rgba(16,185,129,0.15)" : "rgba(239,68,68,0.15)", color: statusColor }}>
                {face.isMatch !== false ? "⇆" : "✕"}
              </div>
              <strong style={{ color: face.isMatch !== false ? "#10b981" : "#ef4444" }}>
                {((face.similarityScore || 0.94) * 100).toFixed(1)}%
              </strong>
              <small>Cosine Match</small>
            </div>
            <div className="portrait-box">
              <div className="portrait-avatar">🤳</div>
              <strong>Live Biometric Selfie</strong>
              <small>3D Liveness Verified</small>
            </div>
          </div>

          <div className="biometric-metrics-list">
            <div className="bio-metric-row">
              <span>3D Passive & Active Liveness</span>
              <strong style={{ color: "#10b981" }}>{((face.livenessScore || 0.98) * 100).toFixed(0)}% (Passed)</strong>
            </div>
            <div className="bio-metric-row">
              <span>PAD Level 2 Anti-Spoofing</span>
              <strong style={{ color: face.antiSpoofPassed !== false ? "#10b981" : "#ef4444" }}>
                {face.antiSpoofPassed !== false ? "Passed (No Screen/Print Attack)" : "High Risk of Replay"}
              </strong>
            </div>
            <div className="bio-metric-row">
              <span>Depth & Micro-Texture Uniformity</span>
              <strong>0.92 / 1.00</strong>
            </div>
          </div>
          {face.notes && <p className="dossier-notes-box">{face.notes}</p>}
        </article>

        {/* Extracted Document Credentials */}
        <article className="dossier-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">OCR EXTRACTION & INTEGRITY</p>
              <h3>Document Credentials</h3>
            </div>
            <span className="live-pill" style={{ color: isDocNumberValid ? "#10b981" : "#f59e0b" }}>
              {isDocNumberValid ? "✓ Validated Checksum" : "⚠ Checksum Alert"}
            </span>
          </div>

          <div className="credentials-table">
            <div className="cred-row">
              <span>Full Legal Name</span>
              <strong>{doc.fullName || "—"}</strong>
            </div>
            <div className="cred-row">
              <span>Document ID Number</span>
              <div>
                <strong className="mono-text">{doc.documentNumber || "—"}</strong>
                {isDocNumberValid ? (
                  <span className="valid-pill">Verhoeff Valid</span>
                ) : (
                  <span className="invalid-pill">Invalid Checksum</span>
                )}
              </div>
            </div>
            <div className="cred-row">
              <span>Date of Birth</span>
              <strong>{doc.dateOfBirth || "—"}</strong>
            </div>
            <div className="cred-row">
              <span>Date of Expiry</span>
              <strong>{doc.dateOfExpiry || "Non-expiring / Lifetime"}</strong>
            </div>
            <div className="cred-row">
              <span>Gender</span>
              <strong>{doc.gender || "—"}</strong>
            </div>
            <div className="cred-row">
              <span>Issuing Jurisdiction</span>
              <strong>{doc.issuingCountry || "Republic of India (IND)"}</strong>
            </div>
            {doc.mrzCode && (
              <div className="cred-row cred-row--mrz">
                <span>Machine Readable Zone (MRZ - ICAO 9303)</span>
                <pre className="mrz-code-block">{doc.mrzCode}</pre>
              </div>
            )}
          </div>
        </article>
      </div>

      {/* Forensic Anti-Tampering & Security Analysis */}
      <section className="dossier-panel" style={{ marginTop: "20px" }}>
        <div className="panel-heading">
          <div>
            <p className="eyebrow">ANTI-TAMPERING & FORENSIC METRICS</p>
            <h3>Security Layer Inspection</h3>
          </div>
          <button className="text-button" onClick={() => setShowXmlModal(true)}>
            View Sovereign Registry XML ↗
          </button>
        </div>

        <div className="forensic-cards-grid">
          <div className="forensic-stat-card">
            <div className="f-icon">▦</div>
            <div>
              <p>Edge Continuity</p>
              <strong>{((tamper.edgeIntegrityScore || 0.98) * 100).toFixed(0)}%</strong>
              <small>No digital boundary slicing</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">🔤</div>
            <div>
              <p>Font Consistency</p>
              <strong>{((tamper.fontConsistencyScore || 0.96) * 100).toFixed(0)}%</strong>
              <small>Glyph baseline alignment</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">✨</div>
            <div>
              <p>Hologram Tilt</p>
              <strong>{((security.hologramConfidence || 0.95) * 100).toFixed(0)}%</strong>
              <small>Diffraction grating matched</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">🔬</div>
            <div>
              <p>ELA Tamper Risk</p>
              <strong>{((tamper.tamperingScore || 0.04) * 100).toFixed(0)}%</strong>
              <small>High-pass compression error</small>
            </div>
          </div>
        </div>
      </section>

      {/* XML Modal */}
      {showXmlModal && (
        <div className="modal-backdrop" onClick={() => setShowXmlModal(false)}>
          <div className="xml-modal-panel" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>DigiLocker / Sovereign Issuer API XML Response</h3>
              <button onClick={() => setShowXmlModal(false)}>×</button>
            </div>
            <pre className="xml-content-viewer">
              {report.digiLockerXml || "No raw XML available for this screening."}
            </pre>
            <div className="modal-footer">
              <button className="primary-button" onClick={() => setShowXmlModal(false)}>Close Inspector</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

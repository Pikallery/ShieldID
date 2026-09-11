import React, { useState } from "react";
import { getScreeningHistory, clearScreeningHistory } from "../utils/screeningStore";
import VerificationDossier from "./VerificationDossier";

export default function AuditHistory({ onSelectDossier }) {
  const [history, setHistory] = useState(getScreeningHistory());
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all"); // all | pass | review | reject
  const [selectedReport, setSelectedReport] = useState(null);
  const [showClearConfirm, setShowClearConfirm] = useState(false);
  const [toast, setToast] = useState("");

  const filtered = history.filter((item) => {
    const status = item.status || "pass";
    if (statusFilter !== "all") {
      if (statusFilter === "pass" && status !== "pass" && status !== "approved") return false;
      if (statusFilter === "review" && status !== "review") return false;
      if (statusFilter === "reject" && status !== "reject" && status !== "blocked") return false;
    }

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const name = (item.documentData?.fullName || item.name || "").toLowerCase();
      const id = (item.id || "").toLowerCase();
      const docNum = (item.documentData?.documentNumber || "").toLowerCase();
      const docType = (item.documentType || item.document || "").toLowerCase();
      return name.includes(q) || id.includes(q) || docNum.includes(q) || docType.includes(q);
    }
    return true;
  });

  const handleClearHistory = () => {
    clearScreeningHistory();
    setHistory([]);
    setShowClearConfirm(false);
    setToast("Audit log cleared.");
    setTimeout(() => setToast(""), 3000);
  };

  const handleExportCsv = () => {
    if (!history.length) return;
    const headers = ["Verification ID", "Applicant Name", "Document Type", "Document Number", "Status", "Risk Score", "Timestamp"];
    const rows = history.map((item) => [
      item.id,
      `"${item.documentData?.fullName || item.name || ""}"`,
      `"${item.documentType || item.document || ""}"`,
      `"${item.documentData?.documentNumber || ""}"`,
      item.status,
      item.riskScore || item.risk || 0,
      `"${item.timestamp || ""}"`,
    ]);

    const csvContent = "data:text/csv;charset=utf-8," + [headers.join(","), ...rows.map((e) => e.join(","))].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `ShieldID_Audit_Logs_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    setToast("CSV Audit Log exported.");
    setTimeout(() => setToast(""), 3000);
  };

  if (selectedReport) {
    return (
      <VerificationDossier
        report={selectedReport}
        onClose={() => setSelectedReport(null)}
      />
    );
  }

  return (
    <div className="audit-history-root">
      <div className="page-intro">
        <div>
          <p className="eyebrow">COMPLIANCE & AUDIT LOGS</p>
          <h1>Identity Screening History</h1>
          <p className="intro-copy">
            Search, filter, and inspect immutable audit dossiers for all past document verifications.
          </p>
        </div>
        <div className="audit-top-actions">
          <button className="primary-button" onClick={handleExportCsv} disabled={!history.length}>
            <span>↓</span> Export CSV
          </button>
          {history.length > 0 && (
            <button className="danger-button" onClick={() => setShowClearConfirm(true)}>
              <span>🗑</span> Clear Logs
            </button>
          )}
        </div>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      {/* Search & Filter Toolbar */}
      <div className="audit-toolbar">
        <div className="audit-search-wrap">
          <span className="search-icon">⌕</span>
          <input
            type="text"
            className="audit-search-input"
            placeholder="Search by applicant name, verification ID, or document number..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          {searchQuery && (
            <button className="clear-search-btn" onClick={() => setSearchQuery("")}>×</button>
          )}
        </div>

        <div className="status-filter-pills">
          {[
            { id: "all", label: "All Screenings" },
            { id: "pass", label: "Verified (Pass)" },
            { id: "review", label: "Review Required" },
            { id: "reject", label: "Blocked (Fraud)" },
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

      {/* History Table */}
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Applicant</th>
              <th>Document Type</th>
              <th>Document Number</th>
              <th>Risk Status</th>
              <th>Timestamp</th>
              <th style={{ textAlign: "right" }}>Action</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length > 0 ? (
              filtered.map((item) => {
                const isPass = item.status === "pass" || item.status === "approved";
                const isReview = item.status === "review";
                const badgeClass = isPass ? "risk-badge--approved" : isReview ? "risk-badge--review" : "risk-badge--blocked";
                const badgeText = isPass ? "Approved" : isReview ? "Review" : "Blocked";
                const name = item.documentData?.fullName || item.name || "Unknown Applicant";
                const docNum = item.documentData?.documentNumber || "—";
                const initials = name.split(" ").map((p) => p[0]).slice(0, 2).join("").toUpperCase();

                return (
                  <tr key={item.id} className="clickable-row" onClick={() => setSelectedReport(item)}>
                    <td>
                      <div className="applicant-cell">
                        <span className="initials">{initials || "SH"}</span>
                        <div>
                          <strong>{name}</strong>
                          <small>{item.id}</small>
                        </div>
                      </div>
                    </td>
                    <td>{item.documentType || item.document || "ID Card"}</td>
                    <td><span className="mono-text">{docNum}</span></td>
                    <td>
                      <span className={`risk-badge ${badgeClass}`}>
                        <span className="risk-dot" />
                        {badgeText} · {item.riskScore || item.risk || 0}%
                      </span>
                    </td>
                    <td>
                      {item.timestamp ? new Date(item.timestamp).toLocaleDateString() : "Recent"}
                    </td>
                    <td style={{ textAlign: "right" }}>
                      <button
                        className="view-dossier-btn"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedReport(item);
                        }}
                      >
                        Inspect Dossier <span>→</span>
                      </button>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: "center", padding: "40px 20px" }}>
                  <p style={{ margin: 0, color: "var(--muted)", fontSize: "14px" }}>
                    No screening records match your search or filter.
                  </p>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Confirm Clear Modal */}
      {showClearConfirm && (
        <div className="modal-backdrop" onClick={() => setShowClearConfirm(false)}>
          <div className="confirm-modal-panel" onClick={(e) => e.stopPropagation()}>
            <h3>Clear All Audit Records?</h3>
            <p>
              Are you sure you want to permanently clear all stored scan audit records from local browser storage? This action cannot be undone.
            </p>
            <div className="modal-actions">
              <button className="dark-button" onClick={() => setShowClearConfirm(false)}>Cancel</button>
              <button className="danger-button" onClick={handleClearHistory}>Clear All Logs</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

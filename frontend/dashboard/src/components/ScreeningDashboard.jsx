import React, { useEffect, useState } from "react";
import {
  recentScreenings,
  riskSignals,
  screeningResult,
  screeningStats,
} from "../utils/screeningData";
import { verifyDocument } from "../utils/verificationApi";
import "./ScreeningDashboard.css";

const icon = (name) => {
  const icons = {
    grid: "▦",
    scan: "⌁",
    report: "▤",
    settings: "⚙",
    help: "?",
    search: "⌕",
    bell: "♧",
    upload: "↑",
    arrow: "↗",
    shield: "◇",
    chevron: "›",
  };
  return icons[name] || "•";
};

function RiskBadge({ status, risk }) {
  const labels = { approved: "Approved", review: "Review", blocked: "Blocked" };
  return (
    <span className={`risk-badge risk-badge--${status}`}>
      <span className="risk-dot" />
      {labels[status]} · {risk}%
    </span>
  );
}

function ScreeningDashboard() {
  const [isLoading, setIsLoading] = useState(true);
  const [activeNav, setActiveNav] = useState("Overview");
  const [selectedFile, setSelectedFile] = useState(null);
  const [isScreening, setIsScreening] = useState(false);
  const [toast, setToast] = useState("");
  const [latestResult, setLatestResult] = useState(screeningResult);

  useEffect(() => {
    const loadingTimer = window.setTimeout(() => setIsLoading(false), 900);

    return () => window.clearTimeout(loadingTimer);
  }, []);

  const handleFile = (event) => {
    const file = event.target.files?.[0];
    if (file) setSelectedFile(file);
  };

  const runScreening = async () => {
    if (!selectedFile) return;

    setIsScreening(true);
    try {
      const result = await verifyDocument(selectedFile);
      setLatestResult({ ...screeningResult, ...result });
      setToast("Screening complete. Results received from ShieldID AI.");
    } catch {
      setLatestResult(screeningResult);
      setToast("Demo result shown. Start the ShieldID API to verify live documents.");
    } finally {
      setIsScreening(false);
      window.setTimeout(() => setToast(""), 3600);
    }
  };

  if (isLoading) {
    return (
      <main className="loading-screen" aria-label="Loading ShieldID" aria-live="polite">
        <div className="loading-brand">
          <span className="loading-icon">{icon("shield")}</span>
          <span>Shield<span className="brand-accent">ID</span></span>
        </div>
        <div className="loading-indicator" aria-hidden="true"><span /></div>
        <p>Preparing secure screening workspace</p>
      </main>
    );
  }

  return (
    <div className="shield-app">
      <aside className="sidebar">
        <div className="brand-mark">
          <span className="brand-icon">{icon("shield")}</span>
          <span>Shield<span className="brand-accent">ID</span></span>
        </div>
        <div className="workspace-switcher">
          <span className="workspace-avatar">N</span>
          <span><strong>Northstar Ops</strong><small>Enterprise workspace</small></span>
          <span className="workspace-chevron">⌄</span>
        </div>
        <nav className="main-nav" aria-label="Main navigation">
          <p className="nav-label">Workspace</p>
          {[{ label: "Overview", icon: "grid" }, { label: "Screen a document", icon: "scan" }, { label: "Reports", icon: "report" }].map((item) => (
            <button className={`nav-item ${activeNav === item.label ? "is-active" : ""}`} key={item.label} onClick={() => setActiveNav(item.label)}>
              <span className="nav-icon">{icon(item.icon)}</span>{item.label}
            </button>
          ))}
          <p className="nav-label nav-label--spaced">Manage</p>
          {[{ label: "Settings", icon: "settings" }, { label: "Help center", icon: "help" }].map((item) => (
            <button className={`nav-item ${activeNav === item.label ? "is-active" : ""}`} key={item.label} onClick={() => setActiveNav(item.label)}>
              <span className="nav-icon">{icon(item.icon)}</span>{item.label}
            </button>
          ))}
        </nav>
        <div className="sidebar-footer"><span className="status-pulse" />All systems operational</div>
      </aside>

      <main className="main-content">
        <header className="topbar">
          <div className="mobile-brand"><span className="brand-icon">{icon("shield")}</span><span>Shield<span className="brand-accent">ID</span></span></div>
          <div className="breadcrumbs"><span>Workspace</span><b>/</b><strong>{activeNav}</strong></div>
          <div className="topbar-actions">
            <button className="icon-button" aria-label="Search">{icon("search")}</button>
            <button className="icon-button notification" aria-label="Notifications">{icon("bell")}<span /></button>
            <div className="profile-chip"><span className="profile-avatar">AK</span><span className="profile-name">Aarav Kapoor</span><span className="chevron">⌄</span></div>
          </div>
        </header>

        <div className="content-wrap">
          <section className="page-intro">
            <div><p className="eyebrow">MONDAY, 06 SEPTEMBER 2026</p><h1>Identity screening overview</h1><p className="intro-copy">Monitor verification activity and review identity documents from one workspace.</p></div>
            <button className="primary-button" onClick={() => document.getElementById("document-upload")?.click()}><span>{icon("upload")}</span>Screen a document</button>
          </section>

          <section className="stats-grid" aria-label="Screening summary">
            {screeningStats.map((stat) => <article className="stat-card" key={stat.label}><div className={`stat-icon stat-icon--${stat.tone}`}>{stat.tone === "mint" ? "↗" : stat.tone === "amber" ? "!" : "⊘"}</div><div><p>{stat.label}</p><strong>{stat.value}</strong><small className={`stat-change stat-change--${stat.tone}`}>{stat.change}</small></div></article>)}
          </section>

          <section className="workspace-grid">
            <article className="upload-panel panel">
              <div className="panel-heading"><div><p className="eyebrow">AI VERIFICATION</p><h2>Screen a new document</h2></div><span className="live-pill"><i />Live</span></div>
              <p className="panel-copy">Upload an identity document and let ShieldID inspect its authenticity, data, and risk signals.</p>
              <label className={`drop-zone ${selectedFile ? "has-file" : ""}`} htmlFor="document-upload">
                <input id="document-upload" type="file" accept="image/*,.pdf" onChange={handleFile} />
                <span className="upload-symbol">{selectedFile ? "✓" : icon("upload")}</span>
                <strong>{selectedFile ? selectedFile.name : "Drop a document here"}</strong>
                <span>{selectedFile ? "Ready to run an AI screening" : "or click to browse · JPG, PNG or PDF up to 10 MB"}</span>
              </label>
              <div className="upload-actions"><span className="privacy-note">{icon("shield")} Encrypted in transit</span><button className="dark-button" onClick={runScreening} disabled={!selectedFile || isScreening}>{isScreening ? "Analyzing…" : "Run screening"}<span>{icon("arrow")}</span></button></div>
            </article>

            <article className="result-panel panel"><div className="panel-heading"><div><p className="eyebrow">LATEST RESULT</p><h2>Screening overview</h2></div><button className="more-button" aria-label="More options">•••</button></div><div className="result-summary"><div className="score-ring"><div><strong>{latestResult.risk_score}</strong><span>risk score</span></div></div><div><span className="approved-label">● {latestResult.recommendation}</span><h3>{latestResult.name}</h3><p>{latestResult.document_type[0].toUpperCase() + latestResult.document_type.slice(1)} · ID ending 4567</p></div></div><div className="signal-list">{riskSignals.map((signal) => <div className="signal-row" key={signal.label}><span className={`signal-icon signal-icon--${signal.tone}`}>✓</span><span className="signal-copy"><strong>{signal.label}</strong><small>{signal.detail}</small></span><span className="signal-score">{signal.score}%</span></div>)}</div><button className="text-button">View full report <span>{icon("arrow")}</span></button></article>
          </section>

          <section className="recent-section"><div className="section-heading"><div><p className="eyebrow">ACTIVITY LOG</p><h2>Recent screenings</h2></div><button className="filter-button">Last 7 days <span>⌄</span></button></div><div className="table-wrap"><table><thead><tr><th>Applicant</th><th>Document</th><th>Location</th><th>Time</th><th>Risk status</th><th /></tr></thead><tbody>{recentScreenings.map((item) => <tr key={item.id}><td><div className="applicant-cell"><span className="initials">{item.initials}</span><span><strong>{item.name}</strong><small>{item.id}</small></span></div></td><td>{item.document}</td><td>{item.location}</td><td>{item.time}</td><td><RiskBadge status={item.status} risk={item.risk} /></td><td><button className="row-arrow" aria-label={`Open ${item.name}`}>{icon("chevron")}</button></td></tr>)}</tbody></table></div><button className="mobile-view-all">View all screenings <span>{icon("arrow")}</span></button></section>
        </div>
      </main>
      {toast && <div className="toast"><span>✓</span>{toast}</div>}
    </div>
  );
}

export default ScreeningDashboard;
import React, { useState } from "react";
import {
  recentScreenings,
  riskSignals,
  screeningResult,
  screeningStats,
} from "../utils/screeningData";
import { verifyDocument } from "../utils/verificationApi";
import "./ScreeningDashboard.css";
import LoginPage from "./LoginPage";
import RegisterPage from "./RegisterPage";
import ProfileAuthPanel from "./ProfileAuthPanel";
import ForgotPasswordPage from "./ForgotPasswordPage";

const icon = (name) => {
  const icons = {
    grid: "▦",
    scan: "⌁",
    report: "▥",
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

const displayNameFromEmail = (email) => email
  .split("@")[0]
  .replace(/[._-]+/g, " ")
  .replace(/\b\w/g, (letter) => letter.toUpperCase());

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
  const [activeNav, setActiveNav] = useState("Overview");
  const [selectedFile, setSelectedFile] = useState(null);
  const [isScreening, setIsScreening] = useState(false);
  const [toast, setToast] = useState("");
  const [latestResult, setLatestResult] = useState(screeningResult);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authView, setAuthView] = useState("login");
  const [profileName, setProfileName] = useState(() => {
    const savedProfile = localStorage.getItem("shieldid-profile-name");
    return savedProfile || "Guest workspace";
  });
  const [profileEmail, setProfileEmail] = useState(() => {
    const savedEmail = localStorage.getItem("shieldid-profile-email");
    return savedEmail || "Not signed in";
  });
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [isNightMode, setIsNightMode] = useState(false);
  const [isNotificationsOpen, setIsNotificationsOpen] = useState(false);
  const [documentType, setDocumentType] = useState("passport");
  const [screeningStep, setScreeningStep] = useState("selection");
  const [frontFile, setFrontFile] = useState(null);
  const [backFile, setBackFile] = useState(null);
  const [selfieFile, setSelfieFile] = useState(null);
  const [processingProgress, setProcessingProgress] = useState(0);
  const [processingTask, setProcessingTask] = useState("Preparing verification pipeline...");
  const [apiUrl, setApiUrl] = useState("https://shieldid-api.onrender.com");
  const [useMockSimulation, setUseMockSimulation] = useState(true);
  const [riskSensitivity, setRiskSensitivity] = useState(0.55);
  const [requireHologramCheck, setRequireHologramCheck] = useState(true);
  const [language, setLanguage] = useState("English");
  const [demoOutcome, setDemoOutcome] = useState("approved");
  const [reportEntries, setReportEntries] = useState([
    {
      id: "report-weekly-digest",
      title: "Weekly screening digest",
      period: "02–08 Sep 2026",
      screenings: 1284,
      alerts: 60,
      status: "Ready",
      documentType: "passport",
      resultStatus: "APPROVE",
      riskScore: 15,
      name: "Rahul Sharma",
    },
    {
      id: "report-fraud-summary",
      title: "Fraud risk summary",
      period: "August 2026",
      screenings: 5842,
      alerts: 214,
      status: "Ready",
      documentType: "aadhaar",
      resultStatus: "REVIEW",
      riskScore: 46,
      name: "Maya Iyer",
    },
  ]);
  const [historyItems, setHistoryItems] = useState([
    { id: "SH-3201", name: "Rahul Sharma", document: "Passport", location: "New Delhi, IN", time: "Just now", risk: 12, status: "approved" },
    { id: "SH-3199", name: "Aisha Khan", document: "PAN card", location: "Mumbai, IN", time: "18 min ago", risk: 26, status: "review" },
    { id: "SH-3198", name: "Vikram Nair", document: "Driving license", location: "Bengaluru, IN", time: "41 min ago", risk: 68, status: "blocked" },
    { id: "SH-3196", name: "Meera Iyer", document: "Aadhaar", location: "Hyderabad, IN", time: "1 hr ago", risk: 17, status: "approved" },
  ]);

  const documentOptions = [
    { id: "passport", label: "Passport", hint: "International travel" },
    { id: "aadhaar", label: "Aadhaar", hint: "National ID" },
    { id: "pan", label: "PAN card", hint: "Tax identity" },
    { id: "dl", label: "Driving license", hint: "Operator license" },
  ];

  const getDocumentLabel = (type = documentType) => (
    documentOptions.find((option) => option.id === type)?.label || "Passport"
  );

  const getCurrentSystemTimestamp = (date = new Date()) => (
    date.toLocaleString("en-IN", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  );

  const getLoggedInUserName = (fallbackName = "Applicant profile") => (
    profileName !== "Guest workspace" ? profileName : fallbackName
  );

  const persistProfile = (nextName, nextEmail) => {
    const safeName = nextName || "Guest workspace";
    const safeEmail = nextEmail || "Not signed in";
    localStorage.setItem("shieldid-profile-name", safeName);
    localStorage.setItem("shieldid-profile-email", safeEmail);
  };

  const handleFile = (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setSelectedFile(file);
    if (!frontFile) {
      setFrontFile(file);
    }
  };

  const handleWorkflowFile = (kind, event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setSelectedFile(file);
    if (kind === "front") setFrontFile(file);
    if (kind === "back") setBackFile(file);
    if (kind === "selfie") setSelfieFile(file);
  };

  const resetWorkflow = () => {
    setSelectedFile(null);
    setFrontFile(null);
    setBackFile(null);
    setSelfieFile(null);
    setScreeningStep("selection");
    setProcessingProgress(0);
    setProcessingTask("Preparing verification pipeline...");
  };

  const buildDemoResult = () => {
    const safetyBias = demoOutcome === "approved" ? -18 : demoOutcome === "review" ? 8 : 38;
    const score = Math.min(96, Math.max(8, Math.round((1 - riskSensitivity) * 100 + safetyBias)));
    const recommendation = score < 35 ? "APPROVE" : score < 72 ? "REVIEW" : "BLOCK";

    return {
      risk_score: score,
      recommendation,
      status: recommendation.toLowerCase(),
      document_type: documentType,
      name: getLoggedInUserName("Applicant profile"),
    };
  };

  const documentLabel = getDocumentLabel();

  const buildReportEntry = (result, docLabelOverride) => {
    const resolvedName = getLoggedInUserName(result?.name || "Applicant profile");
    const resolvedDocument = docLabelOverride || documentLabel;
    const riskScore = Math.max(8, Number(result?.risk_score ?? 18));
    const recommendation = String(result?.recommendation || "APPROVE").toUpperCase();

    return {
      id: `report-${Date.now()}-${Math.random().toString(16).slice(2, 8)}`,
      title: `${resolvedDocument} screening result`,
      period: getCurrentSystemTimestamp(),
      screenings: 1,
      alerts: riskScore > 70 ? 1 : 0,
      status: "Ready",
      documentType: documentType,
      resultStatus: recommendation,
      riskScore,
      name: resolvedName,
    };
  };

  const syncLatestReport = (result, docLabelOverride) => {
    const reportEntry = buildReportEntry(result, docLabelOverride);
    setReportEntries((prev) => [reportEntry, ...prev].slice(0, 4));
    setActiveNav("Reports");
  };

  const exportReportAsImage = () => {
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    const width = 1200;
    const height = 820;

    if (!ctx) {
      setToast("Unable to export the report in this browser.");
      return;
    }

    canvas.width = width;
    canvas.height = height;

    const currentName = getLoggedInUserName(latestResult?.name || "Applicant profile");
    const currentDocument = getDocumentLabel(documentType);
    const currentScore = Math.max(8, Number(latestResult?.risk_score ?? 18));
    const currentRecommendation = String(latestResult?.recommendation || "APPROVE").toUpperCase();

    ctx.fillStyle = "#f8fbff";
    ctx.fillRect(0, 0, width, height);
    ctx.fillStyle = "#0b1f3a";
    ctx.fillRect(0, 0, width, 120);

    ctx.fillStyle = "#ffffff";
    ctx.font = "700 48px sans-serif";
    ctx.fillText("ShieldID screening report", 56, 76);

    ctx.fillStyle = "#0d47a1";
    ctx.fillRect(56, 160, 250, 120);
    ctx.fillStyle = "#ffffff";
    ctx.font = "700 52px sans-serif";
    ctx.fillText(String(currentScore), 96, 225);
    ctx.font = "600 18px sans-serif";
    ctx.fillText("risk score", 96, 255);

    ctx.fillStyle = "#102b4d";
    ctx.font = "700 32px sans-serif";
    ctx.fillText(currentRecommendation, 360, 200);
    ctx.font = "600 26px sans-serif";
    ctx.fillText(currentName, 360, 245);
    ctx.font = "500 20px sans-serif";
    ctx.fillStyle = "#4c5d6c";
    ctx.fillText(`${currentDocument} · ${currentRecommendation}`, 360, 285);

    ctx.fillStyle = "#ffffff";
    ctx.fillRect(56, 330, 1088, 360);

    ctx.fillStyle = "#1a2d3f";
    ctx.font = "700 24px sans-serif";
    ctx.fillText("Verification summary", 86, 382);
    ctx.font = "500 20px sans-serif";
    ctx.fillStyle = "#496077";
    ctx.fillText(`Applicant: ${currentName}`, 86, 432);
    ctx.fillText(`Document type: ${currentDocument}`, 86, 468);
    ctx.fillText(`Date: ${getCurrentSystemTimestamp()}`, 86, 504);
    ctx.fillText(`Status: ${currentRecommendation}`, 86, 540);
    ctx.fillText(`Detection confidence: ${Math.max(76, 100 - currentScore)}%`, 86, 576);
    ctx.fillText("Result saved from the ShieldID dashboard workflow", 86, 612);

    ctx.fillStyle = "#dceaff";
    ctx.fillRect(760, 390, 300, 130);
    ctx.fillStyle = "#0d47a1";
    ctx.font = "700 20px sans-serif";
    ctx.fillText("ACTIONS", 790, 430);
    ctx.font = "600 24px sans-serif";
    ctx.fillText("Exported PNG", 790, 475);

    const dataUrl = canvas.toDataURL("image/png");
    const link = document.createElement("a");
    link.download = `shieldid-report-${Date.now()}.png`;
    link.href = dataUrl;
    link.click();

    setToast("Report exported as PNG to your downloads folder.");
  };

  const normalizeResult = (result) => {
    const baseResult = {
      ...screeningResult,
      ...buildDemoResult(),
      ...result,
    };
    const recommendation = String(baseResult?.recommendation || "APPROVE").toUpperCase();
    const nextResult = {
      ...baseResult,
      name: getLoggedInUserName(baseResult?.name || baseResult?.extracted_data?.full_name || "Applicant profile"),
      document_type: baseResult?.document_type || documentType,
      recommendation,
      status: recommendation === "APPROVE" ? "approved" : recommendation === "REVIEW" ? "review" : "blocked",
    };

    return nextResult;
  };

  const runScreening = async () => {
    if (!selectedFile) return;

    setIsScreening(true);
    try {
      const result = await verifyDocument(selectedFile, selfieFile || null, {
        frontFile: frontFile || selectedFile,
        backFile,
        documentType,
      });
      const mergedResult = normalizeResult(result);
      setLatestResult(mergedResult);
      setHistoryItems((prev) => [{
        id: `SH-${Math.floor(Math.random() * 9000 + 1000)}`,
        name: mergedResult.name,
        document: getDocumentLabel(documentType),
        location: "New Delhi, IN",
        time: getCurrentSystemTimestamp(),
        risk: Math.max(8, mergedResult.risk_score || 18),
        status: mergedResult.recommendation === "APPROVE" ? "approved" : mergedResult.recommendation === "REVIEW" ? "review" : "blocked",
      }, ...prev].slice(0, 6));
      syncLatestReport(mergedResult, getDocumentLabel(documentType));
      setToast("Screening complete. Results received from ShieldID AI.");
    } catch {
      const demoResult = normalizeResult({
        ...screeningResult,
        ...buildDemoResult(),
        name: getLoggedInUserName("Applicant profile"),
      });
      setLatestResult(demoResult);
      setHistoryItems((prev) => [{
        id: `SH-${Math.floor(Math.random() * 9000 + 1000)}`,
        name: demoResult.name,
        document: getDocumentLabel(documentType),
        location: "New Delhi, IN",
        time: getCurrentSystemTimestamp(),
        risk: Math.max(8, demoResult.risk_score || 18),
        status: demoResult.recommendation === "APPROVE" ? "approved" : demoResult.recommendation === "REVIEW" ? "review" : "blocked",
      }, ...prev].slice(0, 6));
      syncLatestReport(demoResult, getDocumentLabel(documentType));
      setToast("Demo result shown. Start the ShieldID API to verify live documents.");
    } finally {
      setIsScreening(false);
      window.setTimeout(() => setToast(""), 3600);
    }
  };

  const runWorkflow = async () => {
    const activeDocument = frontFile || selectedFile;
    if (!activeDocument) {
      setToast("Add a document before starting the workflow.");
      return;
    }

    setScreeningStep("processing");
    setProcessingProgress(0);
    setProcessingTask("Submitting document to ShieldID neural engine...");

    const pipelineSteps = [
      { progress: 18, task: "Parsing identity fields..." },
      { progress: 42, task: "Running tamper and OCR checks..." },
      { progress: 68, task: "Comparing biometric attributes..." },
      { progress: 92, task: "Finalizing risk score..." },
    ];

    for (const step of pipelineSteps) {
      await new Promise((resolve) => window.setTimeout(resolve, 350));
      setProcessingProgress(step.progress);
      setProcessingTask(step.task);
    }

    try {
      const result = await verifyDocument(activeDocument, selfieFile || null, {
        frontFile: frontFile || selectedFile,
        backFile,
        documentType,
      });
      const mergedResult = normalizeResult(result);
      setLatestResult(mergedResult);
      syncLatestReport(mergedResult, getDocumentLabel(documentType));
      setHistoryItems((prev) => [{
        id: `SH-${Math.floor(Math.random() * 9000 + 1000)}`,
        name: mergedResult.name,
        document: getDocumentLabel(documentType),
        location: "New Delhi, IN",
        time: getCurrentSystemTimestamp(),
        risk: Math.max(8, mergedResult.risk_score || 18),
        status: mergedResult.recommendation === "APPROVE" ? "approved" : mergedResult.recommendation === "REVIEW" ? "review" : "blocked",
      }, ...prev].slice(0, 6));
      setToast("Verification pipeline complete.");
    } catch {
      const demoResult = normalizeResult({
        ...screeningResult,
        ...buildDemoResult(),
        name: getLoggedInUserName("Applicant profile"),
        document_type: documentType,
      });
      setLatestResult(demoResult);
      syncLatestReport(demoResult, getDocumentLabel(documentType));
      setHistoryItems((prev) => [{
        id: `SH-${Math.floor(Math.random() * 9000 + 1000)}`,
        name: demoResult.name,
        document: getDocumentLabel(documentType),
        location: "New Delhi, IN",
        time: getCurrentSystemTimestamp(),
        risk: Math.max(8, demoResult.risk_score || 18),
        status: demoResult.recommendation === "APPROVE" ? "approved" : demoResult.recommendation === "REVIEW" ? "review" : "blocked",
      }, ...prev].slice(0, 6));
      setToast("Demo verification used. Connect the API to run live screening.");
    }

    setProcessingProgress(100);
    setProcessingTask("Verification complete.");
    setScreeningStep("result");
    window.setTimeout(() => setToast(""), 3600);
  };

  if (!isAuthenticated) {
    if (authView === "forgot") {
      return <ForgotPasswordPage onGoToLogin={() => setAuthView("login")} />;
    }

    if (authView === "register") {
      return <RegisterPage onGoToLogin={() => setAuthView("login")} />;
    }

    return (
      <LoginPage
        onLogin={({ email }) => {
          const nextName = displayNameFromEmail(email);
          setProfileName(nextName);
          setProfileEmail(email);
          persistProfile(nextName, email);
          setIsAuthenticated(true);
        }}
        onGoToRegister={() => setAuthView("register")}
        onForgotPassword={() => setAuthView("forgot")}
      />
    );
  }

  return (
    <div className={`shield-app ${isNightMode ? "is-night-mode" : ""}`}>
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
          {[{ label: "Overview", icon: "grid" }, { label: "Reports", icon: "report" }].map((item) => (
            <button className={`nav-item ${activeNav === item.label ? "is-active" : ""}`} key={item.label} title={item.label} onClick={() => setActiveNav(item.label)}>
              <span className="nav-icon">{icon(item.icon)}</span>{item.label}
            </button>
          ))}
          <p className="nav-label nav-label--spaced">Manage</p>
          {[{ label: "Settings", icon: "settings" }, { label: "Help center", icon: "help" }].map((item) => (
            <button className={`nav-item ${activeNav === item.label ? "is-active" : ""}`} key={item.label} title={item.label} onClick={() => setActiveNav(item.label)}>
              <span className="nav-icon">{icon(item.icon)}</span>{item.label}
            </button>
          ))}
          <a
            className="nav-item"
            href="/docs.html"
            target="_blank"
            rel="noopener noreferrer"
            style={{ textDecoration: "none" }}
          >
            <span className="nav-icon">▤</span>Live documentation ↗
          </a>
          <a
            className="nav-item"
            href="/kiosk.html"
            target="_blank"
            rel="noopener noreferrer"
            style={{ textDecoration: "none" }}
          >
            <span className="nav-icon">⌁</span>Verification kiosk ↗
          </a>
        </nav>
        <div className="sidebar-footer"><span className="status-pulse" />All systems operational</div>
      </aside>

      <main className="main-content">
        <header className="topbar">
          <div className="mobile-brand"><span className="brand-icon">{icon("shield")}</span><span>Shield<span className="brand-accent">ID</span></span></div>
          <div className="breadcrumbs"><span>Workspace</span><b>/</b><strong>{activeNav}</strong></div>
          <div className="topbar-actions">
            <button className={`mode-toggle ${isNightMode ? "is-night" : ""}`} type="button" onClick={() => setIsNightMode((night) => !night)} aria-label={isNightMode ? "Switch to day mode" : "Switch to night mode"} aria-pressed={isNightMode} title={isNightMode ? "Switch to day mode" : "Switch to night mode"}>
              <span className="mode-toggle-track"><span className="mode-toggle-thumb">{isNightMode ? "☾" : "☀"}</span></span>
            </button>
            <div className="notification-wrap">
              <button className={`icon-button notification ${isNotificationsOpen ? "is-open" : ""}`} type="button" onClick={() => setIsNotificationsOpen((open) => !open)} aria-label="Notifications" aria-expanded={isNotificationsOpen} title="Notifications">{icon("bell")}<span /></button>
              {isNotificationsOpen && <section className="notification-panel" aria-label="Notifications panel"><div className="notification-heading"><strong>Notifications</strong><button type="button" onClick={() => setIsNotificationsOpen(false)} aria-label="Close notifications">×</button></div><article><span className="notification-dot" /><div><strong>Review queue updated</strong><small>3 documents need attention</small></div><time>2m</time></article><article><span className="notification-dot notification-dot--blue" /><div><strong>Weekly report ready</strong><small>Your screening digest is available</small></div><time>1h</time></article><button className="notification-footer" type="button" onClick={() => setIsNotificationsOpen(false)}>Mark all as read</button></section>}
            </div>
            <button className={`profile-chip ${isProfileOpen ? "is-open" : ""}`} type="button" onClick={() => setIsProfileOpen((open) => !open)} aria-expanded={isProfileOpen} aria-label={profileName === "Guest workspace" ? "Open profile login" : "Open profile details"}>
              <span className="profile-avatar">{profileName === "Guest workspace" ? "G" : profileName.split(" ").map((part) => part[0]).slice(0, 2).join("").toUpperCase()}</span>
              <span className="profile-name">{profileName}</span>
              <span className="chevron">⌄</span>
            </button>
            {isProfileOpen && (
              <ProfileAuthPanel
                isAuthenticated={profileName !== "Guest workspace"}
                profileName={profileName}
                profileEmail={profileEmail}
                onClose={() => setIsProfileOpen(false)}
                onLogin={() => {
                  setAuthView("login");
                  setIsAuthenticated(false);
                  setIsProfileOpen(false);
                }}
                onRegister={() => {
                  setAuthView("register");
                  setIsAuthenticated(false);
                  setIsProfileOpen(false);
                }}
              />
            )}
          </div>
        </header>

        <div className="content-wrap">
          {activeNav === "Overview" && <>
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

          <section className="feature-view" style={{ marginTop: 24 }}>
            <div className="page-intro" style={{ marginBottom: 18 }}>
              <div>
                <p className="eyebrow">VERIFICATION WORKFLOW</p>
                <h1>Document screening flow</h1>
                <p className="intro-copy">Select document type, confirm capture steps, and run the full ShieldID verification journey with the same workflow used in the mobile app.</p>
              </div>
            </div>

            <div className="feature-grid" style={{ display: "grid", gap: 20, gridTemplateColumns: "1.3fr 0.7fr" }}>
              <article className="feature-card feature-card--wide" style={{ padding: 20 }}>
                <div className="panel-heading" style={{ marginBottom: 16 }}><div><p className="eyebrow">FLOW SETUP</p><h2>Verification staging</h2></div><button className="more-button" type="button" onClick={resetWorkflow}>Reset</button></div>

                <div style={{ display: "grid", gap: 12, marginBottom: 18 }}>
                  {documentOptions.map((option) => (
                    <button
                      key={option.id}
                      type="button"
                      onClick={() => setDocumentType(option.id)}
                      style={{
                        width: "100%",
                        textAlign: "left",
                        padding: "12px 14px",
                        borderRadius: 12,
                        border: documentType === option.id ? "1px solid rgba(130,177,255,0.75)" : "1px solid rgba(255,255,255,0.08)",
                        background: documentType === option.id ? "rgba(130,177,255,0.12)" : "rgba(9,16,25,0.35)",
                        color: "#eaf1ff",
                        cursor: "pointer",
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                      }}
                    >
                      <span>
                        <strong style={{ display: "block" }}>{option.label}</strong>
                        <small style={{ opacity: 0.7 }}>{option.hint}</small>
                      </span>
                      <span>{documentType === option.id ? "●" : "○"}</span>
                    </button>
                  ))}
                </div>

                <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 18 }}>
                  {[
                    { id: "selection", label: "Select" },
                    { id: "front", label: "Front" },
                    { id: "back", label: "Back" },
                    { id: "selfie", label: "Selfie" },
                    { id: "processing", label: "AI check" },
                    { id: "result", label: "Result" },
                  ].map((step) => (
                    <span key={step.id} style={{
                      padding: "6px 10px",
                      borderRadius: 999,
                      background: screeningStep === step.id ? "rgba(130,177,255,0.18)" : "rgba(255,255,255,0.04)",
                      border: screeningStep === step.id ? "1px solid rgba(130,177,255,0.5)" : "1px solid rgba(255,255,255,0.08)",
                      fontSize: 11,
                      color: screeningStep === step.id ? "#dbe8ff" : "#aac2eb",
                    }}>{step.label}</span>
                  ))}
                </div>

                {screeningStep !== "result" && (
                  <div style={{ display: "grid", gap: 12 }}>
                    <label className="drop-zone has-file" htmlFor="workflow-front-upload" style={{ cursor: "pointer", marginBottom: 0 }}>
                      <input id="workflow-front-upload" type="file" accept="image/*,.pdf" onChange={(event) => handleWorkflowFile("front", event)} />
                      <span className="upload-symbol">{frontFile ? "✓" : "↑"}</span>
                      <strong>{frontFile ? frontFile.name : "Upload front side"}</strong>
                      <span>{frontFile ? "Document captured" : "Front document capture"}</span>
                    </label>

                    {requireHologramCheck && (
                      <label className="drop-zone has-file" htmlFor="workflow-back-upload" style={{ cursor: "pointer", marginBottom: 0 }}>
                        <input id="workflow-back-upload" type="file" accept="image/*,.pdf" onChange={(event) => handleWorkflowFile("back", event)} />
                        <span className="upload-symbol">{backFile ? "✓" : "↑"}</span>
                        <strong>{backFile ? backFile.name : "Upload back side"}</strong>
                        <span>{backFile ? "Back side captured" : "Secondary side / hologram check"}</span>
                      </label>
                    )}

                    <label className="drop-zone has-file" htmlFor="workflow-selfie-upload" style={{ cursor: "pointer", marginBottom: 0 }}>
                      <input id="workflow-selfie-upload" type="file" accept="image/*,.pdf" onChange={(event) => handleWorkflowFile("selfie", event)} />
                      <span className="upload-symbol">{selfieFile ? "✓" : "◉"}</span>
                      <strong>{selfieFile ? selfieFile.name : "Upload selfie"}</strong>
                      <span>{selfieFile ? "Selfie available" : "Liveness / face match"}</span>
                    </label>
                  </div>
                )}

                {screeningStep === "processing" && (
                  <div style={{ marginTop: 20, padding: 16, borderRadius: 14, background: "rgba(130,177,255,0.08)", border: "1px solid rgba(130,177,255,0.28)" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
                      <strong>AI pipeline</strong>
                      <span>{processingProgress}%</span>
                    </div>
                    <div style={{ height: 10, borderRadius: 999, background: "rgba(255,255,255,0.08)" }}>
                      <div style={{ width: `${processingProgress}%`, height: "100%", borderRadius: 999, background: "linear-gradient(90deg, #8ad1ff, #7cc7ff, #95ffdb)" }} />
                    </div>
                    <p style={{ marginTop: 12, marginBottom: 0, color: "#cbe5ff" }}>{processingTask}</p>
                  </div>
                )}

                <div className="upload-actions" style={{ marginTop: 20 }}>
                  <span className="privacy-note">{icon("shield")} End-to-end validation</span>
                  <button className="dark-button" type="button" onClick={runWorkflow} disabled={isScreening || !((frontFile || selectedFile) && (selfieFile || true))}>
                    {screeningStep === "result" ? "Run again" : "Run ShieldID workflow"}
                    <span>{icon("arrow")}</span>
                  </button>
                </div>
              </article>

              <article className="feature-card" style={{ padding: 20 }}>
                <p className="eyebrow">SMART CONTROLS</p>
                <h2>Simulation settings</h2>
                <div style={{ display: "grid", gap: 16, marginTop: 18 }}>
                  <div>
                    <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
                      <strong>Risk sensitivity</strong>
                      <span>{riskSensitivity.toFixed(2)}</span>
                    </div>
                    <input type="range" min="0.1" max="0.95" step="0.05" value={riskSensitivity} onChange={(event) => setRiskSensitivity(Number(event.target.value))} style={{ width: "100%" }} />
                  </div>

                  <label style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <span>Mock engine</span>
                    <input type="checkbox" checked={useMockSimulation} onChange={(event) => setUseMockSimulation(event.target.checked)} />
                  </label>

                  <label style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <span>Hologram check</span>
                    <input type="checkbox" checked={requireHologramCheck} onChange={(event) => setRequireHologramCheck(event.target.checked)} />
                  </label>

                  <label style={{ display: "grid", gap: 8 }}>
                    <span>Language</span>
                    <select value={language} onChange={(event) => setLanguage(event.target.value)} style={{ background: "#0f1c2c", color: "#eaf1ff", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 8, padding: 10 }}>
                      <option>English</option>
                      <option>Hindi</option>
                      <option>Marathi</option>
                      <option>Kannada</option>
                    </select>
                  </label>

                  <label style={{ display: "grid", gap: 8 }}>
                    <span>API URL</span>
                    <input value={apiUrl} onChange={(event) => setApiUrl(event.target.value)} style={{ background: "#0f1c2c", color: "#eaf1ff", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 8, padding: 10 }} />
                  </label>

                  <label style={{ display: "grid", gap: 8 }}>
                    <span>Demo outcome</span>
                    <select value={demoOutcome} onChange={(event) => setDemoOutcome(event.target.value)} style={{ background: "#0f1c2c", color: "#eaf1ff", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 8, padding: 10 }}>
                      <option value="approved">Approved</option>
                      <option value="review">Needs review</option>
                      <option value="blocked">Blocked</option>
                    </select>
                  </label>
                </div>
              </article>
            </div>
          </section>

          <section className="recent-section"><div className="section-heading"><div><p className="eyebrow">ACTIVITY LOG</p><h2>Recent screenings</h2></div><button className="filter-button">Last 7 days <span>⌄</span></button></div><div className="table-wrap"><table><thead><tr><th>Applicant</th><th>Document</th><th>Location</th><th>Time</th><th>Risk status</th><th /></tr></thead><tbody>{historyItems.map((item) => <tr key={item.id}><td><div className="applicant-cell"><span className="initials">{item.name.split(" ").map((part) => part[0]).slice(0, 2).join("")}</span><span><strong>{item.name}</strong><small>{item.id}</small></span></div></td><td>{item.document}</td><td>{item.location}</td><td>{item.time}</td><td><RiskBadge status={item.status} risk={item.risk} /></td><td><button className="row-arrow" aria-label={`Open ${item.name}`}>{icon("chevron")}</button></td></tr>)}</tbody></table></div><button className="mobile-view-all">View all screenings <span>{icon("arrow")}</span></button></section>
          </>}

          {activeNav === "History" && (
            <section className="feature-view">
              <div className="page-intro"><div><p className="eyebrow">AUDIT HISTORY</p><h1>Recent verification activity</h1><p className="intro-copy">A clean audit trail of every document screened, reviewed, and resolved in the workspace.</p></div></div>
              <div className="table-wrap" style={{ marginTop: 18 }}><table><thead><tr><th>Applicant</th><th>Document</th><th>Location</th><th>Time</th><th>Risk status</th><th /></tr></thead><tbody>{historyItems.map((item) => <tr key={item.id}><td><div className="applicant-cell"><span className="initials">{item.name.split(" ").map((part) => part[0]).slice(0, 2).join("")}</span><span><strong>{item.name}</strong><small>{item.id}</small></span></div></td><td>{item.document}</td><td>{item.location}</td><td>{item.time}</td><td><RiskBadge status={item.status} risk={item.risk} /></td><td><button className="row-arrow" aria-label={`Open ${item.name}`}>{icon("chevron")}</button></td></tr>)}</tbody></table></div>
            </section>
          )}

          {activeNav === "Reports" && (
            <section className="feature-view">
              <div className="page-intro">
                <div><p className="eyebrow">ANALYTICS CENTER</p><h1>Screening reports</h1><p className="intro-copy">Review verification volume, risk trends, and outcomes across your workspace.</p></div>
                <button className="primary-button" type="button" onClick={exportReportAsImage}><span>↓</span>Export report</button>
              </div>

              <div className="feature-grid">
                <article className="feature-card feature-card--wide">
                  <div className="panel-heading">
                    <div><p className="eyebrow">CURRENT RESULT</p><h2>{reportEntries[0]?.title || `${documentLabel} screening result`}</h2></div>
                    <span className="report-period">{reportEntries[0]?.period || new Date().toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })}</span>
                  </div>
                  <div className="result-summary" style={{ paddingTop: 18 }}>
                    <div className="score-ring"><div><strong>{reportEntries[0]?.riskScore ?? latestResult.risk_score}</strong><span>risk score</span></div></div>
                    <div>
                      <span className="approved-label">● {reportEntries[0]?.resultStatus ?? latestResult.recommendation}</span>
                      <h3>{reportEntries[0]?.name ?? latestResult.name}</h3>
                      <p>{(reportEntries[0]?.documentType || latestResult.document_type || documentType).toString().replace(/(^\w)/, (letter) => letter.toUpperCase())} · {reportEntries[0]?.status || "Ready"}</p>
                    </div>
                  </div>
                  <div className="signal-list">
                    {riskSignals.map((signal) => (
                      <div className="signal-row" key={signal.label}>
                        <span className={`signal-icon signal-icon--${signal.tone}`}>✓</span>
                        <span className="signal-copy"><strong>{signal.label}</strong><small>{signal.detail}</small></span>
                        <span className="signal-score">{signal.score}%</span>
                      </div>
                    ))}
                  </div>
                </article>

                <article className="feature-card">
                  <p className="eyebrow">OUTCOME MIX</p>
                  <h2>Verification outcomes</h2>
                  <div className="outcome-list">
                    <div><span className="outcome-dot outcome-dot--approved" />Approved <strong>{Math.max(40, 100 - (reportEntries[0]?.riskScore ?? latestResult.risk_score) - 8)}%</strong></div>
                    <div><span className="outcome-dot outcome-dot--review" />Needs review <strong>{Math.min(26, Math.max(8, ((reportEntries[0]?.riskScore ?? latestResult.risk_score) / 3.5).toFixed(0)))}%</strong></div>
                    <div><span className="outcome-dot outcome-dot--blocked" />Blocked <strong>{Math.min(22, Math.max(5, 100 - (Math.max(40, 100 - (reportEntries[0]?.riskScore ?? latestResult.risk_score) - 8)) - Math.min(26, Math.max(8, ((reportEntries[0]?.riskScore ?? latestResult.risk_score) / 3.5).toFixed(0)))))}%</strong></div>
                  </div>
                </article>
              </div>

              <div className="table-wrap report-table">
                <table>
                  <thead>
                    <tr><th>Report</th><th>Period</th><th>Screenings</th><th>Risk alerts</th><th>Status</th></tr>
                  </thead>
                  <tbody>
                    {reportEntries.map((entry) => (
                      <tr key={entry.id}>
                        <td><strong>{entry.title}</strong></td>
                        <td>{entry.period}</td>
                        <td>{entry.screenings}</td>
                        <td>{entry.alerts}</td>
                        <td><span className="report-status">{entry.status}</span></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          )}

          {activeNav === "Settings" && (
            <section className="feature-view">
              <div className="page-intro"><div><p className="eyebrow">WORKSPACE CONTROL</p><h1>Workspace settings</h1><p className="intro-copy">Manage the preferences used by your screening operations team.</p></div></div>
              <div className="settings-list" style={{ display: "grid", gap: 18 }}>
                <article className="settings-row"><div><h2>Workspace notifications</h2><p>Receive alerts when a document needs manual review.</p></div><button className="toggle is-on" type="button" aria-label="Workspace notifications enabled"><span /></button></article>
                <article className="settings-row"><div><h2>Automatic risk summaries</h2><p>Include a risk summary with every completed screening.</p></div><button className="toggle is-on" type="button" aria-label="Automatic risk summaries enabled"><span /></button></article>
                <article className="settings-row"><div><h2>Review threshold</h2><p>Flag screenings with a risk score above this value.</p></div><select defaultValue="50" aria-label="Review threshold"><option value="40">40%</option><option value="50">50%</option><option value="60">60%</option></select></article>
                <article className="settings-row"><div><h2>Theme mode</h2><p>Switch the dashboard interface between day and night visuals.</p></div><button className={`toggle ${isNightMode ? "is-on" : ""}`} type="button" aria-label="Theme mode" onClick={() => setIsNightMode((current) => !current)}><span /></button></article>
                <article className="settings-row"><div><h2>Mock AI engine</h2><p>Use realistic offline simulation while the API remains disconnected.</p></div><button className={`toggle ${useMockSimulation ? "is-on" : ""}`} type="button" onClick={() => setUseMockSimulation((current) => !current)} aria-label="Toggle mock AI engine"><span /></button></article>
                <article className="settings-row"><div><h2>Risk sensitivity</h2><p>Set the score threshold used to simulate review and block decisions.</p></div><input type="range" min="0.1" max="0.95" step="0.05" value={riskSensitivity} onChange={(event) => setRiskSensitivity(Number(event.target.value))} aria-label="Risk sensitivity" style={{ width: 180 }} /></article>
                <article className="settings-row"><div><h2>ShieldID API endpoint</h2><p>Point the dashboard to the backend service you want to test.</p></div><input value={apiUrl} onChange={(event) => setApiUrl(event.target.value)} aria-label="ShieldID API endpoint" style={{ width: 260, background: "#0f1c2c", color: "#eaf1ff", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 8, padding: 10 }} /></article>
                <article className="settings-row"><div><h2>Language</h2><p>Choose the UI language that matches your operations team.</p></div><select value={language} onChange={(event) => setLanguage(event.target.value)} aria-label="Language" style={{ width: 180, background: "#0f1c2c", color: "#eaf1ff", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 8, padding: 10 }}><option>English</option><option>Hindi</option><option>Marathi</option><option>Kannada</option></select></article>
              </div>
            </section>
          )}

          {activeNav === "Help center" && (
            <section className="feature-view">
              <div className="page-intro"><div><p className="eyebrow">SUPPORT HUB</p><h1>How can we help?</h1><p className="intro-copy">Find guidance for document screening, reports, and workspace administration.</p></div><button className="primary-button" type="button" onClick={() => setToast("Support request started in demo mode.")}><span>↗</span>Contact support</button></div>
              <div className="help-grid"><button className="help-card" type="button"><span className="help-card-icon">▤</span><span><strong>Screening guides</strong><small>Learn how ShieldID evaluates identity documents.</small></span><span>↗</span></button><button className="help-card" type="button"><span className="help-card-icon">?</span><span><strong>Common questions</strong><small>Get quick answers about review statuses and alerts.</small></span><span>↗</span></button><button className="help-card" type="button"><span className="help-card-icon">◇</span><span><strong>System status</strong><small>All verification services are operational.</small></span><span>↗</span></button></div>
            </section>
          )}

          {activeNav === "Live documentation" && (
            <section className="embedded-view">
              <div className="page-intro"><div><p className="eyebrow">DEVELOPER RESOURCES</p><h1>Live API documentation</h1><p className="intro-copy">Explore ShieldID endpoints and integration details without leaving the workspace.</p></div></div>
              <iframe className="embedded-frame" src="/docs.html" title="ShieldID live API documentation" />
            </section>
          )}

          {activeNav === "Verification kiosk" && (
            <section className="embedded-view">
              <div className="page-intro"><div><p className="eyebrow">VERIFICATION TOOLS</p><h1>Verification kiosk</h1><p className="intro-copy">Run a document verification workflow inside the ShieldID workspace.</p></div></div>
              <iframe className="embedded-frame embedded-frame--kiosk" src="/kiosk.html" title="ShieldID verification kiosk" />
            </section>
          )}
        </div>
      </main>
      {toast && <div className="toast"><span>✓</span>{toast}</div>}
    </div>
  );
}

export default ScreeningDashboard;
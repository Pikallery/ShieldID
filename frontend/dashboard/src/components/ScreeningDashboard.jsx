import React, { useState, useEffect, useRef } from "react";
import {
  recentScreenings,
  riskSignals,
  screeningResult,
  screeningStats,
} from "../utils/screeningData";
import { verifyDocument } from "../utils/verificationApi";
import { oauthService } from "../utils/oauthService";
import "./ScreeningDashboard.css";
import LoginPage from "./LoginPage";
import RegisterPage from "./RegisterPage";
import ProfileAuthPanel from "./ProfileAuthPanel";
import ForgotPasswordPage from "./ForgotPasswordPage";

// Modular feature components ported from mobile & enterprise security
import IdentityScanner from "./IdentityScanner";
import VerificationDossier from "./VerificationDossier";
import AntiTamperStudio from "./AntiTamperStudio";
import AuditHistory from "./AuditHistory";
import SystemSettings from "./SystemSettings";
import BulkManifestScanner from "./BulkManifestScanner";
import NfcChipInspector from "./NfcChipInspector";

const ROUTE_TO_NAV = {
  "/overview": "Overview",
  "/scanner": "Identity Scanner",
  "/manifest": "Bulk Manifest",
  "/chip": "e-Passport Chip",
  "/studio": "Anti-Tamper Studio",
  "/audit": "Audit History",
  "/reports": "Reports",
  "/settings": "Settings",
  "/help": "Help center",
  "/docs": "Live documentation",
  "/kiosk": "Verification kiosk",
};

const NAV_TO_ROUTE = {
  "Overview": "/overview",
  "Identity Scanner": "/scanner",
  "Bulk Manifest": "/manifest",
  "e-Passport Chip": "/chip",
  "Anti-Tamper Studio": "/studio",
  "Audit History": "/audit",
  "Reports": "/reports",
  "Settings": "/settings",
  "Help center": "/help",
  "Live documentation": "/docs",
  "Verification kiosk": "/kiosk",
};

const icon = (name) => {
  const icons = {
    grid: "▦",
    scan: "⌁",
    manifest: "✈",
    chip: "📶",
    studio: "🔬",
    history: "📜",
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

const displayNameFromEmail = (email) =>
  email
    .split("@")[0]
    .replace(/[._-]+/g, " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase());

function RiskBadge({ status, risk }) {
  const labels = { approved: "Approved", review: "Review", blocked: "Blocked", pass: "Approved", reject: "Blocked" };
  const normalized = status === "pass" ? "approved" : status === "reject" ? "blocked" : status;
  return (
    <span className={`risk-badge risk-badge--${normalized}`}>
      <span className="risk-dot" />
      {labels[status] || "Approved"} · {risk}%
    </span>
  );
}

function ScreeningDashboard() {
  const [activeNav, setActiveNav] = useState("Overview");
  const [selectedFile, setSelectedFile] = useState(null);
  const [isScreening, setIsScreening] = useState(false);
  const [toast, setToast] = useState("");
  const [latestResult, setLatestResult] = useState(screeningResult);
  const [activeDossier, setActiveDossier] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [session, setSession] = useState(null);
  const [authView, setAuthView] = useState("login");
  const [profileName, setProfileName] = useState("Guest workspace");
  const [profileEmail, setProfileEmail] = useState("Not signed in");
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [isNightMode, setIsNightMode] = useState(false);
  const [isNotificationsOpen, setIsNotificationsOpen] = useState(false);

  const dossierCache = useRef(null);

  // Synchronize hash with application state and listen to browser Back / Forward events
  useEffect(() => {
    // Check for existing OAuth / officer session
    const savedSession = oauthService.getCurrentSession();
    if (savedSession) {
      setIsAuthenticated(true);
      setSession(savedSession);
      setProfileName(savedSession.fullName || displayNameFromEmail(savedSession.email));
      setProfileEmail(savedSession.email);
    }

    const parseRouteFromHash = () => {
      const hash = window.location.hash.replace(/^#\/?/, "");
      const segments = hash.split("/").filter(Boolean);
      const rootPath = segments[0] || "";

      // Auth routes
      if (rootPath === "login") {
        setAuthView("login");
        return;
      }
      if (rootPath === "register") {
        setAuthView("register");
        return;
      }
      if (rootPath === "forgot") {
        setAuthView("forgot");
        return;
      }

      // Dossier inspection route
      if (rootPath === "dossier") {
        if (!activeDossier && dossierCache.current) {
          setActiveDossier(dossierCache.current);
        }
        return;
      }

      // Normal tab routes
      const tabRoute = "/" + (rootPath || "overview");
      if (ROUTE_TO_NAV[tabRoute]) {
        setActiveNav(ROUTE_TO_NAV[tabRoute]);
        setActiveDossier(null);
      } else {
        setActiveNav("Overview");
        setActiveDossier(null);
      }
    };

    // Ensure initial hash exists so browser back has a defined origin
    if (!window.location.hash || window.location.hash === "#" || window.location.hash === "#/") {
      const defaultHash = savedSession ? "#/overview" : "#/login";
      window.history.replaceState({ route: defaultHash }, "", defaultHash);
    }

    parseRouteFromHash();

    window.addEventListener("hashchange", parseRouteFromHash);
    window.addEventListener("popstate", parseRouteFromHash);

    return () => {
      window.removeEventListener("hashchange", parseRouteFromHash);
      window.removeEventListener("popstate", parseRouteFromHash);
    };
  }, []);

  // Intentional navigation that pushes history
  const navigateTo = (tabName, replace = false) => {
    setActiveDossier(null);
    setActiveNav(tabName);
    const route = NAV_TO_ROUTE[tabName] || "/overview";
    const targetHash = `#${route}`;
    if (window.location.hash !== targetHash) {
      if (replace) {
        window.history.replaceState({ tab: tabName }, "", targetHash);
      } else {
        window.location.hash = targetHash;
      }
    }
  };

  const openDossier = (report) => {
    dossierCache.current = report;
    setActiveDossier(report);
    const dossierId = report.id || "inspection";
    const targetHash = `#/dossier/${dossierId}`;
    if (window.location.hash !== targetHash) {
      window.location.hash = targetHash;
    }
  };

  const closeDossier = () => {
    if (window.location.hash.startsWith("#/dossier")) {
      window.history.back();
    } else {
      setActiveDossier(null);
      navigateTo(activeNav, true);
    }
  };

  const handleLogin = (sessionData) => {
    const ses = sessionData.token ? sessionData : oauthService.saveSession(sessionData);
    setProfileName(ses.fullName || displayNameFromEmail(ses.email));
    setProfileEmail(ses.email);
    setSession(ses);
    setIsAuthenticated(true);
    navigateTo("Overview");
  };

  const handleLogout = () => {
    oauthService.signOut();
    setIsAuthenticated(false);
    setSession(null);
    setProfileName("Guest workspace");
    setProfileEmail("Not signed in");
    setIsProfileOpen(false);
    window.location.hash = "#/login";
  };

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

  const handleCompleteVerification = (newReport) => {
    openDossier(newReport);
    setLatestResult({
      status: newReport.status,
      risk_score: newReport.riskScore,
      document_type: newReport.documentType.toLowerCase(),
      name: newReport.documentData.fullName,
      recommendation: newReport.predictiveRisk.recommendation,
    });
    setToast("Identity verification pipeline completed successfully.");
    setTimeout(() => setToast(""), 3600);
  };

  if (!isAuthenticated) {
    if (authView === "forgot") {
      return (
        <ForgotPasswordPage
          onGoToLogin={() => {
            setAuthView("login");
            window.location.hash = "#/login";
          }}
        />
      );
    }

    if (authView === "register") {
      return (
        <RegisterPage
          onGoToLogin={() => {
            setAuthView("login");
            window.location.hash = "#/login";
          }}
          onRegister={handleLogin}
        />
      );
    }

    return (
      <LoginPage
        onLogin={handleLogin}
        onGoToRegister={() => {
          setAuthView("register");
          window.location.hash = "#/register";
        }}
        onForgotPassword={() => {
          setAuthView("forgot");
          window.location.hash = "#/forgot";
        }}
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
          <p className="nav-label">Identity Workflows</p>
          {[
            { label: "Overview", icon: "grid" },
            { label: "Identity Scanner", icon: "scan" },
            { label: "Bulk Manifest", icon: "manifest" },
            { label: "e-Passport Chip", icon: "chip" },
            { label: "Anti-Tamper Studio", icon: "studio" },
            { label: "Audit History", icon: "history" },
            { label: "Reports", icon: "report" },
          ].map((item) => (
            <button
              className={`nav-item ${activeNav === item.label && !activeDossier ? "is-active" : ""}`}
              key={item.label}
              title={item.label}
              onClick={() => navigateTo(item.label)}
            >
              <span className="nav-icon">{icon(item.icon)}</span>{item.label}
            </button>
          ))}
          <p className="nav-label nav-label--spaced">Platform & Tools</p>
          {[
            { label: "Settings", icon: "settings" },
            { label: "Help center", icon: "help" },
          ].map((item) => (
            <button
              className={`nav-item ${activeNav === item.label && !activeDossier ? "is-active" : ""}`}
              key={item.label}
              title={item.label}
              onClick={() => navigateTo(item.label)}
            >
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
          <div className="mobile-brand">
            <span className="brand-icon">{icon("shield")}</span>
            <span>Shield<span className="brand-accent">ID</span></span>
          </div>
          <div className="breadcrumbs">
            <span>Workspace</span>
            <b>/</b>
            <strong>{activeDossier ? "Verification Dossier" : activeNav}</strong>
          </div>
          <div className="topbar-actions">
            <button
              className={`mode-toggle ${isNightMode ? "is-night" : ""}`}
              type="button"
              onClick={() => setIsNightMode((night) => !night)}
              aria-label={isNightMode ? "Switch to day mode" : "Switch to night mode"}
              aria-pressed={isNightMode}
              title={isNightMode ? "Switch to day mode" : "Switch to night mode"}
            >
              <span className="mode-toggle-track">
                <span className="mode-toggle-thumb">{isNightMode ? "☾" : "☀"}</span>
              </span>
            </button>
            <div className="notification-wrap">
              <button
                className={`icon-button notification ${isNotificationsOpen ? "is-open" : ""}`}
                type="button"
                onClick={() => setIsNotificationsOpen((open) => !open)}
                aria-label="Notifications"
                aria-expanded={isNotificationsOpen}
                title="Notifications"
              >
                {icon("bell")}
                <span />
              </button>
              {isNotificationsOpen && (
                <section className="notification-panel" aria-label="Notifications panel">
                  <div className="notification-heading">
                    <strong>Notifications</strong>
                    <button type="button" onClick={() => setIsNotificationsOpen(false)} aria-label="Close notifications">×</button>
                  </div>
                  <article>
                    <span className="notification-dot" />
                    <div>
                      <strong>Review queue updated</strong>
                      <small>3 documents need attention</small>
                    </div>
                    <time>2m</time>
                  </article>
                  <article>
                    <span className="notification-dot notification-dot--blue" />
                    <div>
                      <strong>Weekly report ready</strong>
                      <small>Your screening digest is available</small>
                    </div>
                    <time>1h</time>
                  </article>
                  <button className="notification-footer" type="button" onClick={() => setIsNotificationsOpen(false)}>
                    Mark all as read
                  </button>
                </section>
              )}
            </div>
            <button
              className={`profile-chip ${isProfileOpen ? "is-open" : ""}`}
              type="button"
              onClick={() => setIsProfileOpen((open) => !open)}
              aria-expanded={isProfileOpen}
              aria-label={profileName === "Guest workspace" ? "Open profile login" : "Open profile details"}
            >
              <span className="profile-avatar">
                {profileName === "Guest workspace" ? "G" : profileName.split(" ").map((part) => part[0]).slice(0, 2).join("").toUpperCase()}
              </span>
              <span className="profile-name">{profileName}</span>
              <span className="chevron">⌄</span>
            </button>
            {isProfileOpen && (
              <ProfileAuthPanel
                isAuthenticated={isAuthenticated}
                profileName={profileName}
                profileEmail={profileEmail}
                session={session}
                onClose={() => setIsProfileOpen(false)}
                onLogout={handleLogout}
                onLogin={() => {
                  setAuthView("login");
                  setIsAuthenticated(false);
                  setIsProfileOpen(false);
                  window.location.hash = "#/login";
                }}
                onRegister={() => {
                  setAuthView("register");
                  setIsAuthenticated(false);
                  setIsProfileOpen(false);
                  window.location.hash = "#/register";
                }}
              />
            )}
          </div>
        </header>

        <div className="content-wrap">
          {/* If a dossier is actively opened, show it */}
          {activeDossier ? (
            <VerificationDossier
              report={activeDossier}
              onClose={closeDossier}
              onScreenAnother={() => {
                setActiveDossier(null);
                navigateTo("Identity Scanner");
              }}
            />
          ) : (
            <>
              {/* VIEW: OVERVIEW */}
              {activeNav === "Overview" && (
                <>
                  <section className="page-intro">
                    <div>
                      <p className="eyebrow">IDENTITY VERIFICATION ENGINE</p>
                      <h1>Identity screening overview</h1>
                      <p className="intro-copy">Monitor real-time verification activity, anti-tamper forensics, and review identity documents.</p>
                    </div>
                    <button
                      className="primary-button"
                      onClick={() => navigateTo("Identity Scanner")}
                    >
                      <span>{icon("scan")}</span> Start Identity Scanner
                    </button>
                  </section>

                  <section className="stats-grid" aria-label="Screening summary">
                    {screeningStats.map((stat) => (
                      <article className="stat-card" key={stat.label}>
                        <div className={`stat-icon stat-icon--${stat.tone}`}>
                          {stat.tone === "mint" ? "↗" : stat.tone === "amber" ? "!" : "⊘"}
                        </div>
                        <div>
                          <p>{stat.label}</p>
                          <strong>{stat.value}</strong>
                          <small className={`stat-change stat-change--${stat.tone}`}>{stat.change}</small>
                        </div>
                      </article>
                    ))}
                  </section>

                  <section className="workspace-grid">
                    <article className="upload-panel panel">
                      <div className="panel-heading">
                        <div>
                          <p className="eyebrow">AI VERIFICATION</p>
                          <h2>Quick document screening</h2>
                        </div>
                        <span className="live-pill"><i />Live</span>
                      </div>
                      <p className="panel-copy">Upload an identity document or launch the full biometric camera flow.</p>
                      <label className={`drop-zone ${selectedFile ? "has-file" : ""}`} htmlFor="document-upload">
                        <input id="document-upload" type="file" accept="image/*,.pdf" onChange={handleFile} />
                        <span className="upload-symbol">{selectedFile ? "✓" : icon("upload")}</span>
                        <strong>{selectedFile ? selectedFile.name : "Drop a document here"}</strong>
                        <span>{selectedFile ? "Ready to run AI screening" : "or click to browse · JPG, PNG or PDF up to 10 MB"}</span>
                      </label>
                      <div className="upload-actions">
                        <span className="privacy-note">{icon("shield")} Encrypted in transit</span>
                        <div style={{ display: "flex", gap: "8px" }}>
                          <button
                            className="secondary-btn"
                            onClick={() => navigateTo("Identity Scanner")}
                          >
                            Open Camera Scanner ⌁
                          </button>
                          <button className="dark-button" onClick={runScreening} disabled={!selectedFile || isScreening}>
                            {isScreening ? "Analyzing…" : "Run screening"}<span>{icon("arrow")}</span>
                          </button>
                        </div>
                      </div>
                    </article>

                    <article className="result-panel panel">
                      <div className="panel-heading">
                        <div>
                          <p className="eyebrow">LATEST RESULT</p>
                          <h2>Screening overview</h2>
                        </div>
                        <button className="more-button" aria-label="More options">•••</button>
                      </div>
                      <div className="result-summary">
                        <div className="score-ring">
                          <div>
                            <strong>{latestResult.risk_score}</strong>
                            <span>risk score</span>
                          </div>
                        </div>
                        <div>
                          <span className="approved-label">● {latestResult.recommendation}</span>
                          <h3>{latestResult.name}</h3>
                          <p>{latestResult.document_type[0].toUpperCase() + latestResult.document_type.slice(1)} · ID ending 4567</p>
                        </div>
                      </div>
                      <div className="signal-list">
                        {riskSignals.map((signal) => (
                          <div className="signal-row" key={signal.label}>
                            <span className={`signal-icon signal-icon--${signal.tone}`}>✓</span>
                            <span className="signal-copy">
                              <strong>{signal.label}</strong>
                              <small>{signal.detail}</small>
                            </span>
                            <span className="signal-score">{signal.score}%</span>
                          </div>
                        ))}
                      </div>
                      <button
                        className="text-button"
                        onClick={() => {
                          openDossier({
                            id: "SH-2841",
                            status: latestResult.status || "pass",
                            riskScore: latestResult.risk_score,
                            documentType: latestResult.document_type,
                            documentData: {
                              fullName: latestResult.name,
                              documentNumber: "M4819204",
                              dateOfBirth: "14/08/1996",
                              dateOfExpiry: "12/05/2034",
                              gender: "Male",
                              issuingCountry: "IND",
                              mrzCode: "P<INDSHARMA<<RAHUL<<<<<<<<<<<<<<<<<<<<<<<\nM4819204<2IND9608144M3405125<<<<<<<<<<<<<<<4",
                            },
                            faceMatch: {
                              isMatch: true,
                              similarityScore: 0.94,
                              livenessScore: 0.98,
                              livenessPassed: true,
                              antiSpoofPassed: true,
                              notes: "Biometric match verified against passport portrait.",
                            },
                            tampering: {
                              isTampered: false,
                              tamperingScore: 0.04,
                              edgeIntegrityScore: 0.98,
                              fontConsistencyScore: 0.96,
                            },
                            securityFeatures: {
                              hologramDetected: true,
                              hologramConfidence: 0.95,
                              qrCodeValid: true,
                              mrzValid: true,
                            },
                            predictiveRisk: {
                              riskScore: latestResult.risk_score,
                              recommendation: latestResult.recommendation,
                            },
                          });
                        }}
                      >
                        View full dossier report <span>{icon("arrow")}</span>
                      </button>
                    </article>
                  </section>

                  <section className="recent-section">
                    <div className="section-heading">
                      <div>
                        <p className="eyebrow">ACTIVITY LOG</p>
                        <h2>Recent screenings</h2>
                      </div>
                      <button className="filter-button" onClick={() => navigateTo("Audit History")}>
                        View all audit logs <span>→</span>
                      </button>
                    </div>
                    <div className="table-wrap">
                      <table>
                        <thead>
                          <tr>
                            <th>Applicant</th>
                            <th>Document</th>
                            <th>Location</th>
                            <th>Time</th>
                            <th>Risk status</th>
                            <th />
                          </tr>
                        </thead>
                        <tbody>
                          {recentScreenings.map((item) => (
                            <tr
                              key={item.id}
                              className="clickable-row"
                              onClick={() => {
                                openDossier({
                                  id: item.id,
                                  status: item.status,
                                  riskScore: item.risk,
                                  documentType: item.document,
                                  documentData: {
                                    fullName: item.name,
                                    documentNumber: item.document === "PAN card" ? "ABCDE1234F" : "8921 4056 9182",
                                    dateOfBirth: "14/08/1996",
                                    gender: "Male",
                                  },
                                  faceMatch: {
                                    isMatch: item.status === "approved",
                                    similarityScore: item.status === "approved" ? 0.94 : 0.65,
                                    livenessScore: 0.98,
                                    livenessPassed: true,
                                    antiSpoofPassed: item.status !== "blocked",
                                  },
                                  tampering: {
                                    isTampered: item.status === "blocked",
                                    tamperingScore: item.status === "blocked" ? 0.88 : 0.05,
                                    edgeIntegrityScore: 0.98,
                                    fontConsistencyScore: 0.95,
                                  },
                                  securityFeatures: {
                                    hologramDetected: item.status === "approved",
                                    hologramConfidence: 0.95,
                                    qrCodeValid: true,
                                    mrzValid: true,
                                  },
                                  predictiveRisk: {
                                    riskScore: item.risk,
                                    recommendation: item.status === "approved" ? "APPROVED · Zero risk signals detected" : (item.status === "review" ? "MANUAL REVIEW · Secondary identity validation advised" : "REJECTED · Tampering anomaly flagged"),
                                  },
                                });
                              }}
                            >
                              <td>
                                <div className="applicant-cell">
                                  <span className="initials">{item.initials}</span>
                                  <span><strong>{item.name}</strong><small>{item.id}</small></span>
                                </div>
                              </td>
                              <td>{item.document}</td>
                              <td>{item.location}</td>
                              <td>{item.time}</td>
                              <td><RiskBadge status={item.status} risk={item.risk} /></td>
                              <td><button className="row-arrow" aria-label={`Open ${item.name}`}>{icon("chevron")}</button></td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </section>
                </>
              )}

              {/* VIEW: IDENTITY SCANNER */}
              {activeNav === "Identity Scanner" && (
                <IdentityScanner onCompleteVerification={handleCompleteVerification} />
              )}

              {/* VIEW: BULK MANIFEST */}
              {activeNav === "Bulk Manifest" && (
                <BulkManifestScanner onSelectDossier={(report) => openDossier(report)} />
              )}

              {/* VIEW: E-PASSPORT CHIP */}
              {activeNav === "e-Passport Chip" && (
                <NfcChipInspector />
              )}

              {/* VIEW: ANTI-TAMPER STUDIO */}
              {activeNav === "Anti-Tamper Studio" && (
                <AntiTamperStudio />
              )}

              {/* VIEW: AUDIT HISTORY */}
              {activeNav === "Audit History" && (
                <AuditHistory onSelectDossier={(report) => openDossier(report)} />
              )}

              {/* VIEW: REPORTS */}
              {activeNav === "Reports" && (
                <section className="feature-view">
                  <div className="page-intro">
                    <div>
                      <p className="eyebrow">ANALYTICS CENTER</p>
                      <h1>Screening reports</h1>
                      <p className="intro-copy">Review verification volume, risk trends, and outcomes across your workspace.</p>
                    </div>
                    <button className="primary-button" type="button" onClick={() => setToast("Report export is ready in demo mode.")}>
                      <span>↓</span>Export report
                    </button>
                  </div>
                  <div className="feature-grid">
                    <article className="feature-card feature-card--wide">
                      <div className="panel-heading">
                        <div>
                          <p className="eyebrow">WEEKLY VOLUME</p>
                          <h2>Screening activity</h2>
                        </div>
                        <span className="report-period">Last 7 days</span>
                      </div>
                      <div className="report-bars">
                        {[58, 72, 46, 84, 68, 91, 76].map((height, index) => (
                          <div className="report-bar-group" key={index}>
                            <span className="report-bar" style={{ height: `${height}%` }} />
                            <small>{["M", "T", "W", "T", "F", "S", "S"][index]}</small>
                          </div>
                        ))}
                      </div>
                    </article>
                    <article className="feature-card">
                      <p className="eyebrow">OUTCOME MIX</p>
                      <h2>Verification outcomes</h2>
                      <div className="outcome-list">
                        <div><span className="outcome-dot outcome-dot--approved" />Approved <strong>78%</strong></div>
                        <div><span className="outcome-dot outcome-dot--review" />Needs review <strong>14%</strong></div>
                        <div><span className="outcome-dot outcome-dot--blocked" />Blocked <strong>8%</strong></div>
                      </div>
                    </article>
                  </div>
                  <div className="table-wrap report-table">
                    <table>
                      <thead>
                        <tr>
                          <th>Report</th>
                          <th>Period</th>
                          <th>Screenings</th>
                          <th>Risk alerts</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td><strong>Weekly screening digest</strong></td>
                          <td>02–08 Sep 2026</td>
                          <td>1,284</td>
                          <td>60</td>
                          <td><span className="report-status">Ready</span></td>
                        </tr>
                        <tr>
                          <td><strong>Fraud risk summary</strong></td>
                          <td>August 2026</td>
                          <td>5,842</td>
                          <td>214</td>
                          <td><span className="report-status">Ready</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </section>
              )}

              {/* VIEW: SETTINGS */}
              {activeNav === "Settings" && (
                <SystemSettings isNightMode={isNightMode} onToggleNightMode={() => setIsNightMode((n) => !n)} />
              )}

              {/* VIEW: HELP CENTER */}
              {activeNav === "Help center" && (
                <section className="feature-view">
                  <div className="page-intro">
                    <div>
                      <p className="eyebrow">SUPPORT HUB</p>
                      <h1>How can we help?</h1>
                      <p className="intro-copy">Find guidance for document screening, reports, and workspace administration.</p>
                    </div>
                    <button className="primary-button" type="button" onClick={() => setToast("Support request started in demo mode.")}>
                      <span>↗</span>Contact support
                    </button>
                  </div>
                  <div className="help-grid">
                    <button className="help-card" type="button">
                      <span className="help-card-icon">▤</span>
                      <span><strong>Screening guides</strong><small>Learn how ShieldID evaluates identity documents.</small></span>
                      <span>↗</span>
                    </button>
                    <button className="help-card" type="button">
                      <span className="help-card-icon">?</span>
                      <span><strong>Common questions</strong><small>Get quick answers about review statuses and alerts.</small></span>
                      <span>↗</span>
                    </button>
                    <button className="help-card" type="button">
                      <span className="help-card-icon">◇</span>
                      <span><strong>System status</strong><small>All verification services are operational.</small></span>
                      <span>↗</span>
                    </button>
                  </div>
                </section>
              )}

              {/* VIEW: LIVE DOCS */}
              {activeNav === "Live documentation" && (
                <section className="embedded-view">
                  <div className="page-intro">
                    <div>
                      <p className="eyebrow">DEVELOPER RESOURCES</p>
                      <h1>Live API documentation</h1>
                      <p className="intro-copy">Explore ShieldID endpoints and integration details without leaving the workspace.</p>
                    </div>
                  </div>
                  <iframe className="embedded-frame" src="/docs.html" title="ShieldID live API documentation" />
                </section>
              )}

              {/* VIEW: KIOSK */}
              {activeNav === "Verification kiosk" && (
                <section className="embedded-view">
                  <div className="page-intro">
                    <div>
                      <p className="eyebrow">VERIFICATION TOOLS</p>
                      <h1>Verification kiosk</h1>
                      <p className="intro-copy">Run a document verification workflow inside the ShieldID workspace.</p>
                    </div>
                  </div>
                  <iframe className="embedded-frame embedded-frame--kiosk" src="/kiosk.html" title="ShieldID verification kiosk" />
                </section>
              )}
            </>
          )}
        </div>
      </main>
      {toast && <div className="toast"><span>✓</span>{toast}</div>}
    </div>
  );
}

export default ScreeningDashboard;
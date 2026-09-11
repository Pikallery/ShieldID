import React, { useState } from "react";
import { getSystemSettings, saveSystemSettings } from "../utils/screeningStore";

export default function SystemSettings() {
  const [settings, setSettings] = useState(getSystemSettings());
  const [serverPingStatus, setServerPingStatus] = useState("idle"); // idle | checking | live | unreachable
  const [toast, setToast] = useState("");

  const updateSetting = (key, val) => {
    const updated = { ...settings, [key]: val };
    setSettings(updated);
    saveSystemSettings(updated);
    setToast("Settings updated successfully.");
    setTimeout(() => setToast(""), 2500);
  };

  const testServerConnection = async () => {
    setServerPingStatus("checking");
    try {
      const url = settings.baseUrl.replace(/\/+$/, "");
      const res = await fetch(`${url}/health`, { method: "GET" }).catch(() => null);
      if (res && res.ok) {
        setServerPingStatus("live");
      } else {
        setServerPingStatus("unreachable");
      }
    } catch {
      setServerPingStatus("unreachable");
    }
  };

  return (
    <div className="system-settings-root">
      <div className="page-intro">
        <div>
          <p className="eyebrow">SYSTEM CONFIGURATION & SOVEREIGN GATEWAYS</p>
          <h1>Platform Settings & Transit Keys</h1>
          <p className="intro-copy">
            Configure backend AI endpoints, API Setu Passport Seva credentials, Airport/Railway transit gateways, PyTesseract OCR, and security policies.
          </p>
        </div>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      <div className="settings-sections-list">
        {/* Transit & Deployment Venue Mode */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">ENTERPRISE DEPLOYMENT PROFILE</p>
              <h3>Airport, Railway & Border Security Mode</h3>
            </div>
          </div>
          <p className="panel-copy">
            Select the operational venue to automatically tune transit manifest cross-checks, gate clearance rules, and watchlist sensitivities:
          </p>

          <div className="outcome-chips-row">
            {[
              { id: "AIRPORT", label: "✈️ International Airport / E-Gates (ICAO 9303 / MEA)", color: "#00F2FE" },
              { id: "RAILWAY", label: "🚆 Railway Station Kiosks (IRCTC / CRIS Manifest)", color: "#10b981" },
              { id: "BORDER_CONTROL", label: "🛂 Land/Sea Border Immigration Counter", color: "#f59e0b" },
              { id: "ENTERPRISE_KYC", label: "🏢 Standard Enterprise Banking KYC", color: "#6366F1" },
            ].map((mode) => (
              <button
                key={mode.id}
                type="button"
                className={`outcome-chip ${settings.transitMode === mode.id ? "is-selected" : ""}`}
                style={{
                  borderColor: settings.transitMode === mode.id ? mode.color : "var(--line)",
                  color: settings.transitMode === mode.id ? mode.color : "var(--ink)",
                }}
                onClick={() => updateSetting("transitMode", mode.id)}
              >
                <span>{settings.transitMode === mode.id ? "●" : "○"}</span>
                {mode.label}
              </button>
            ))}
          </div>
        </section>

        {/* API Setu & Sovereign Passport Seva Gateway */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">API SETU · PASSPORT SEVA SOVEREIGN GATEWAY</p>
              <h3>Ministry of External Affairs (MEA) Passport API</h3>
            </div>
            <span className="live-pill" style={{ color: "#10b981" }}>
              ● API Setu v1 Active
            </span>
          </div>
          <p className="panel-copy">
            Authenticates Indian Passports directly with the Passport Seva National Registry (apisetu.gov.in) with cryptographic verification.
          </p>

          <div className="settings-input-group">
            <label>API Setu X-APISETU-APIKEY</label>
            <input
              type="password"
              className="text-input"
              value={settings.apiSetuApiKey}
              placeholder="setu_live_..."
              onChange={(e) => updateSetting("apiSetuApiKey", e.target.value)}
            />
            <small className="input-hint">Official API Setu Gateway Token for Passport Seva MEA endpoints.</small>
          </div>

          <div className="settings-input-group" style={{ marginTop: "16px" }}>
            <label>API Setu X-APISETU-CLIENTID</label>
            <input
              type="text"
              className="text-input"
              value={settings.apiSetuClientId}
              placeholder="in.gov.passportseva.prod.client01"
              onChange={(e) => updateSetting("apiSetuClientId", e.target.value)}
            />
            <small className="input-hint">Authorized client ID registered with Digital India Corporation.</small>
          </div>
        </section>

        {/* Airport & Railway Station Security Keys */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">HIGH-THROUGHPUT TRANSIT CREDENTIALS</p>
              <h3>Airports Authority (AAI) & IRCTC Gate Keys</h3>
            </div>
          </div>

          <div className="settings-input-group">
            <label>Airport Fast-Track & E-Gate Security Key (DigiYatra / IGI T3)</label>
            <input
              type="password"
              className="text-input"
              value={settings.airportSecurityKey}
              placeholder="air_sec_..."
              onChange={(e) => updateSetting("airportSecurityKey", e.target.value)}
            />
            <small className="input-hint">Used for live automated boarding gate clearance and Interpol watchlist synchronization.</small>
          </div>

          <div className="settings-input-group" style={{ marginTop: "16px" }}>
            <label>Indian Railways IRCTC / CRIS Security Manifest Token</label>
            <input
              type="password"
              className="text-input"
              value={settings.irctcApiKey}
              placeholder="rail_sec_..."
              onChange={(e) => updateSetting("irctcApiKey", e.target.value)}
            />
            <small className="input-hint">Used for railway station security checkpoint PNR and platform pass validation.</small>
          </div>
        </section>

        {/* Neural Backend & PyTesseract Local OCR Service */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">NEURAL BACKEND & LOCAL OCR SERVICE</p>
              <h3>FastAPI Backend & PyTesseract Engine</h3>
            </div>
            <span
              className="live-pill"
              style={{
                color: serverPingStatus === "live" ? "#10b981" : serverPingStatus === "unreachable" ? "#ef4444" : "#82B1FF",
              }}
            >
              {serverPingStatus === "live"
                ? "● API Online & Healthy"
                : serverPingStatus === "checking"
                ? "Checking…"
                : serverPingStatus === "unreachable"
                ? "✕ Server Unreachable"
                : "○ Ready"}
            </span>
          </div>

          <div className="settings-row-item">
            <div className="setting-info">
              <strong>Zero-Config Mock Neural Engine</strong>
              <p>Simulate ultra-realistic inference pipelines offline in the browser without requiring external server calls.</p>
            </div>
            <button
              type="button"
              className={`toggle ${settings.useMockSimulation ? "is-on" : ""}`}
              onClick={() => updateSetting("useMockSimulation", !settings.useMockSimulation)}
            >
              <span />
            </button>
          </div>

          <div className="settings-input-group">
            <label>Backend REST Server URL (Tesseract / Tamper Service)</label>
            <div className="url-input-wrap">
              <input
                type="text"
                className="text-input"
                disabled={settings.useMockSimulation}
                value={settings.baseUrl}
                placeholder="https://shieldid-api.onrender.com or http://localhost:8000"
                onChange={(e) => updateSetting("baseUrl", e.target.value)}
              />
              <button
                type="button"
                className="secondary-btn"
                onClick={testServerConnection}
                disabled={settings.useMockSimulation}
              >
                Ping Health Check
              </button>
            </div>
            <small className="input-hint">
              ShieldID Backend with PyTesseract Optical Engine & Biometrics (Default: <code>https://shieldid-api.onrender.com</code> / Local: <code>http://localhost:8000</code>).
            </small>
          </div>
        </section>

        {/* Gemini Vision AI & Sandbox KYC API Keys */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">EXTERNAL AI & REGISTRY INTEGRATIONS</p>
              <h3>Multimodal AI & ITD NSDL Credentials</h3>
            </div>
          </div>

          <div className="settings-input-group">
            <label>Google Gemini Multimodal Vision API Key</label>
            <input
              type="password"
              className="text-input"
              value={settings.geminiApiKey}
              placeholder="AIzaSy... (Leave empty to use pre-configured embedded token)"
              onChange={(e) => updateSetting("geminiApiKey", e.target.value)}
            />
            <small className="input-hint">Used for client-side direct Gemini 1.5/2.0 multimodal OCR extraction and forgery inspection.</small>
          </div>

          <div className="settings-input-group" style={{ marginTop: "16px" }}>
            <label>Sandbox.co.in PAN & Aadhaar API Key</label>
            <input
              type="password"
              className="text-input"
              value={settings.sandboxApiKey}
              placeholder="key_live_... or key_test_..."
              onChange={(e) => updateSetting("sandboxApiKey", e.target.value)}
            />
            <small className="input-hint">Used for real-time Income Tax Department (ITD) NSDL database cross-checks.</small>
          </div>
        </section>

        {/* Security Thresholds & Risk Policies */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">RISK & COMPLIANCE RULES</p>
              <h3>Security Policies & Sensitivity</h3>
            </div>
          </div>

          <div className="settings-row-item">
            <div className="setting-info">
              <strong>Mandatory Hologram Tilt Check</strong>
              <p>Require dynamic optical variable ink (OVI) diffraction check for official photo IDs.</p>
            </div>
            <button
              type="button"
              className={`toggle ${settings.requireHologramCheck ? "is-on" : ""}`}
              onClick={() => updateSetting("requireHologramCheck", !settings.requireHologramCheck)}
            >
              <span />
            </button>
          </div>

          <div className="settings-row-item">
            <div className="setting-info">
              <strong>Fraud Risk Sensitivity Level</strong>
              <p>Adjust neural confidence threshold for automatic rejection of suspicious documents.</p>
            </div>
            <select
              value={settings.riskSensitivity}
              onChange={(e) => updateSetting("riskSensitivity", parseFloat(e.target.value))}
              className="styled-select"
            >
              <option value="0.25">Permissive (Lower friction)</option>
              <option value="0.5">Balanced (Standard enterprise)</option>
              <option value="0.75">High Security (Strict compliance)</option>
            </select>
          </div>
        </section>

        {/* Standards & Compliance Badge */}
        <div className="compliance-banner-card">
          <div className="banner-icon">🛡️</div>
          <div>
            <strong>ShieldID High-Throughput Transit & Forensic Suite v2.5.0</strong>
            <p>
              Certified for Airport E-Gates (ICAO 9303 / DigiYatra), Railway Security Kiosks (IRCTC/CRIS), ISO/IEC 30107-3 PAD Level 2 anti-spoofing, and Ministry of External Affairs API Setu protocols.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

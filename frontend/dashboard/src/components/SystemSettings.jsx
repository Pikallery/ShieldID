import React, { useState, useEffect } from "react";
import { getSystemSettings, saveSystemSettings } from "../utils/screeningStore";

export default function SystemSettings({ isNightMode, onToggleNightMode }) {
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
          <p className="eyebrow">SYSTEM CONFIGURATION & INTEGRATIONS</p>
          <h1>Platform Settings</h1>
          <p className="intro-copy">
            Configure backend AI endpoints, sovereign registry API credentials, security policies, and simulation modes.
          </p>
        </div>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      <div className="settings-sections-list">
        {/* Backend REST API Configuration */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">NEURAL BACKEND CONNECTIVITY</p>
              <h3>FastAPI Backend REST Service</h3>
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
            <label>Backend REST Server URL</label>
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
              Default cloud deployment: <code>https://shieldid-api.onrender.com</code> · Local: <code>http://localhost:8000</code>
            </small>
          </div>
        </section>

        {/* Demo Simulation Target Outcome */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">INTERACTIVE DEMO HARNESS</p>
              <h3>Simulation Target Outcome</h3>
            </div>
          </div>
          <p className="panel-copy">
            Select the expected decision verdict for subsequent demo screenings:
          </p>

          <div className="outcome-chips-row">
            {[
              { id: "pass", label: "Pass (Verified Genuine)", color: "#10b981" },
              { id: "review", label: "Review (Glare / Anomaly)", color: "#f59e0b" },
              { id: "reject", label: "Reject (Tampered Fraud)", color: "#ef4444" },
            ].map((target) => (
              <button
                key={target.id}
                type="button"
                className={`outcome-chip ${settings.targetSimulationStatus === target.id ? "is-selected" : ""}`}
                style={{
                  borderColor: settings.targetSimulationStatus === target.id ? target.color : "var(--line)",
                  color: settings.targetSimulationStatus === target.id ? target.color : "var(--ink)",
                }}
                onClick={() => updateSetting("targetSimulationStatus", target.id)}
              >
                <span>{settings.targetSimulationStatus === target.id ? "●" : "○"}</span>
                {target.label}
              </button>
            ))}
          </div>
        </section>

        {/* Third-Party API Keys */}
        <section className="settings-card">
          <div className="card-header">
            <div>
              <p className="eyebrow">EXTERNAL AI & REGISTRY INTEGRATIONS</p>
              <h3>Direct Provider API Keys</h3>
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
            <strong>ShieldID Identity Verification & Forensic Suite v2.4.0</strong>
            <p>
              Engine compliant with ICAO 9303 Doc Specifications, ISO/IEC 30107-3 PAD (Presentation Attack Detection) Level 2, and NIST FRS biometric standards.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

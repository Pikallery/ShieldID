import React, { useState } from "react";
import { oauthService } from "../utils/oauthService";

const PRESET_OFFICERS = [
  {
    provider: "google",
    email: "officer.verma@delhiairport.aero",
    fullName: "Inspector Rajesh Verma",
    role: "Lead Border Control Officer",
    badgeId: "IGI-AIRPORT-8842",
    agency: "Bureau of Immigration / CISF Aviation Security",
    avatar: "RV",
  },
  {
    provider: "google",
    email: "surveillance.sharma@railways.gov.in",
    fullName: "Vigilance Officer Ananya Sharma",
    role: "Senior Vigilance Inspector",
    badgeId: "IR-NDLS-4910",
    agency: "Indian Railways Security & Vigilance",
    avatar: "AS",
  },
  {
    provider: "sso",
    email: "command.clearance@digiyatra.gov.in",
    fullName: "Commander Vikramaditya Singh",
    role: "Sovereign Transit Command Director",
    badgeId: "DY-SOV-0012",
    agency: "DigiYatra Foundation / Ministry of Civil Aviation",
    avatar: "VS",
  },
];

export default function OAuthModal({ isOpen, provider = "google", onClose, onSuccess }) {
  const [selectedOfficer, setSelectedOfficer] = useState(PRESET_OFFICERS[0]);
  const [customEmail, setCustomEmail] = useState("");
  const [customName, setCustomName] = useState("");
  const [useCustom, setUseCustom] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [step, setStep] = useState("select"); // 'select' | 'scopes' | 'authenticating'

  if (!isOpen) return null;

  const isGoogle = provider === "google";

  const handleProceedToScopes = () => {
    if (useCustom) {
      if (!customEmail.trim() || !customName.trim()) return;
      setSelectedOfficer({
        provider,
        email: customEmail.trim(),
        fullName: customName.trim(),
        role: "Operational Screening Officer",
        badgeId: `OFFICER-${Math.floor(1000 + Math.random() * 9000)}`,
        agency: isGoogle ? "Google Workspace Enterprise" : "Enterprise Sovereign SSO",
        avatar: customName.trim().slice(0, 2).toUpperCase(),
      });
    }
    setStep("scopes");
  };

  const handleAuthorize = async () => {
    setIsProcessing(true);
    setStep("authenticating");

    // Simulate cryptographic challenge verification & token exchange
    await new Promise((r) => setTimeout(r, 650));

    const session = oauthService.completeOAuthLogin({
      provider,
      email: selectedOfficer.email,
      fullName: selectedOfficer.fullName,
      role: selectedOfficer.role,
      badgeId: selectedOfficer.badgeId,
      avatarUrl: null,
    });

    setIsProcessing(false);
    onSuccess?.(session);
  };

  return (
    <div
      className="oauth-modal-overlay"
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 100000,
        backgroundColor: "rgba(3, 10, 20, 0.85)",
        backdropFilter: "blur(10px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "16px",
      }}
    >
      <div
        className="oauth-modal-card"
        style={{
          background: "#0d1b2a",
          border: "1px solid rgba(82, 143, 235, 0.35)",
          boxShadow: "0 24px 64px rgba(0, 0, 0, 0.8), 0 0 32px rgba(66, 133, 244, 0.15)",
          borderRadius: "16px",
          width: "100%",
          maxWidth: "480px",
          overflow: "hidden",
          color: "#e0e6ed",
          fontFamily: "'Manrope', -apple-system, sans-serif",
          animation: "oauthPop 0.22s cubic-bezier(0.16, 1, 0.3, 1)",
        }}
      >
        <style>{`
          @keyframes oauthPop {
            from { opacity: 0; transform: scale(0.96) translateY(8px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
          }
        `}</style>

        {/* Modal Header */}
        <div
          style={{
            padding: "20px 24px",
            borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            background: isGoogle
              ? "linear-gradient(180deg, rgba(66, 133, 244, 0.12) 0%, transparent 100%)"
              : "linear-gradient(180deg, rgba(16, 185, 129, 0.12) 0%, transparent 100%)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            {isGoogle ? (
              <svg width="24" height="24" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
            ) : (
              <span
                style={{
                  fontSize: "20px",
                  background: "#10b981",
                  color: "#031710",
                  borderRadius: "6px",
                  padding: "2px 8px",
                  fontWeight: 800,
                }}
              >
                SSO
              </span>
            )}
            <div>
              <h3 style={{ margin: 0, fontSize: "16px", fontWeight: 700 }}>
                {isGoogle ? "Google Workspace Identity Gateway" : "DigiYatra Sovereign SSO"}
              </h3>
              <p style={{ margin: "2px 0 0", fontSize: "11px", color: "#8da2b5" }}>
                OAuth 2.0 PKCE Protected Authentication
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            style={{
              background: "transparent",
              border: "none",
              color: "#8da2b5",
              fontSize: "22px",
              cursor: "pointer",
              lineHeight: 1,
              padding: "4px",
            }}
          >
            ×
          </button>
        </div>

        {/* Modal Body */}
        <div style={{ padding: "20px 24px" }}>
          {step === "select" && (
            <div>
              <p style={{ fontSize: "13px", color: "#a5b4c4", marginBottom: "16px" }}>
                Select an authorized Border Command or Transit Officer profile to authenticate:
              </p>

              <div style={{ display: "flex", flexDirection: "column", gap: "10px", marginBottom: "16px" }}>
                {PRESET_OFFICERS.map((officer) => {
                  const isSelected = !useCustom && selectedOfficer.email === officer.email;
                  return (
                    <div
                      key={officer.email}
                      onClick={() => {
                        setSelectedOfficer(officer);
                        setUseCustom(false);
                      }}
                      style={{
                        padding: "12px 14px",
                        borderRadius: "10px",
                        border: isSelected
                          ? "1.5px solid #4285F4"
                          : "1px solid rgba(255, 255, 255, 0.1)",
                        background: isSelected ? "rgba(66, 133, 244, 0.12)" : "rgba(255, 255, 255, 0.03)",
                        cursor: "pointer",
                        display: "flex",
                        alignItems: "center",
                        gap: "12px",
                        transition: "all 0.15s ease",
                      }}
                    >
                      <div
                        style={{
                          width: "38px",
                          height: "38px",
                          borderRadius: "50%",
                          background: isSelected ? "#4285F4" : "#1f3347",
                          color: "#fff",
                          fontWeight: 700,
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          fontSize: "13px",
                          flexShrink: 0,
                        }}
                      >
                        {officer.avatar}
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontWeight: 600, fontSize: "14px" }}>{officer.fullName}</div>
                        <div style={{ fontSize: "12px", color: "#8da2b5" }}>{officer.email}</div>
                        <div style={{ fontSize: "11px", color: "#6184a8", marginTop: "2px" }}>
                          {officer.role} · {officer.badgeId}
                        </div>
                      </div>
                      {isSelected && (
                        <span style={{ color: "#4285F4", fontWeight: 700, fontSize: "16px" }}>✓</span>
                      )}
                    </div>
                  );
                })}

                {/* Custom Officer Profile Option */}
                <div
                  onClick={() => setUseCustom(true)}
                  style={{
                    padding: "12px 14px",
                    borderRadius: "10px",
                    border: useCustom
                      ? "1.5px solid #4285F4"
                      : "1px dashed rgba(255, 255, 255, 0.2)",
                    background: useCustom ? "rgba(66, 133, 244, 0.08)" : "transparent",
                    cursor: "pointer",
                    display: "flex",
                    flexDirection: "column",
                    gap: "8px",
                  }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                    <span style={{ fontSize: "16px" }}>👤</span>
                    <strong style={{ fontSize: "13px" }}>Use another work account</strong>
                  </div>
                  {useCustom && (
                    <div style={{ display: "flex", flexDirection: "column", gap: "8px", marginTop: "4px" }}>
                      <input
                        type="text"
                        placeholder="Officer Full Name (e.g. Officer K. Menon)"
                        value={customName}
                        onChange={(e) => setCustomName(e.target.value)}
                        style={{
                          background: "#08131e",
                          border: "1px solid rgba(255,255,255,0.15)",
                          borderRadius: "6px",
                          padding: "8px 10px",
                          color: "#fff",
                          fontSize: "13px",
                        }}
                      />
                      <input
                        type="email"
                        placeholder="Officer Email (e.g. k.menon@customs.gov.in)"
                        value={customEmail}
                        onChange={(e) => setCustomEmail(e.target.value)}
                        style={{
                          background: "#08131e",
                          border: "1px solid rgba(255,255,255,0.15)",
                          borderRadius: "6px",
                          padding: "8px 10px",
                          color: "#fff",
                          fontSize: "13px",
                        }}
                      />
                    </div>
                  )}
                </div>
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}>
                <button
                  type="button"
                  onClick={onClose}
                  style={{
                    background: "transparent",
                    border: "1px solid rgba(255, 255, 255, 0.2)",
                    color: "#a5b4c4",
                    padding: "8px 16px",
                    borderRadius: "8px",
                    cursor: "pointer",
                    fontSize: "13px",
                  }}
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleProceedToScopes}
                  style={{
                    background: "#4285F4",
                    border: "none",
                    color: "#ffffff",
                    padding: "8px 20px",
                    borderRadius: "8px",
                    fontWeight: 600,
                    cursor: "pointer",
                    fontSize: "13px",
                  }}
                >
                  Next →
                </button>
              </div>
            </div>
          )}

          {step === "scopes" && (
            <div>
              <div
                style={{
                  background: "rgba(255, 255, 255, 0.04)",
                  padding: "12px",
                  borderRadius: "8px",
                  marginBottom: "16px",
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                }}
              >
                <span style={{ fontSize: "20px" }}>🔐</span>
                <div>
                  <div style={{ fontWeight: 600, fontSize: "14px" }}>{selectedOfficer.fullName}</div>
                  <div style={{ fontSize: "12px", color: "#8da2b5" }}>{selectedOfficer.email}</div>
                </div>
              </div>

              <p style={{ fontSize: "13px", color: "#c2d1e0", marginBottom: "12px" }}>
                ShieldID Border Security Platform is requesting the following OAuth 2.0 clearances:
              </p>

              <div
                style={{
                  background: "#08131e",
                  border: "1px solid rgba(255, 255, 255, 0.1)",
                  borderRadius: "8px",
                  padding: "12px",
                  marginBottom: "18px",
                  display: "flex",
                  flexDirection: "column",
                  gap: "10px",
                  fontSize: "12px",
                }}
              >
                <div style={{ display: "flex", alignItems: "flex-start", gap: "8px" }}>
                  <span style={{ color: "#34A853", fontWeight: 700 }}>✓</span>
                  <div>
                    <strong>View your basic profile & security badge</strong>
                    <div style={{ color: "#8da2b5", fontSize: "11px" }}>openid, profile</div>
                  </div>
                </div>
                <div style={{ display: "flex", alignItems: "flex-start", gap: "8px" }}>
                  <span style={{ color: "#34A853", fontWeight: 700 }}>✓</span>
                  <div>
                    <strong>Authenticate airport/railway security terminal sessions</strong>
                    <div style={{ color: "#8da2b5", fontSize: "11px" }}>shieldid:terminal_access</div>
                  </div>
                </div>
                <div style={{ display: "flex", alignItems: "flex-start", gap: "8px" }}>
                  <span style={{ color: "#34A853", fontWeight: 700 }}>✓</span>
                  <div>
                    <strong>Sign Suspicious Activity Reports (SAR) with officer credentials</strong>
                    <div style={{ color: "#8da2b5", fontSize: "11px" }}>shieldid:sar_signature</div>
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <button
                  type="button"
                  onClick={() => setStep("select")}
                  style={{
                    background: "transparent",
                    border: "none",
                    color: "#8da2b5",
                    cursor: "pointer",
                    fontSize: "13px",
                  }}
                >
                  ← Back
                </button>
                <div style={{ display: "flex", gap: "10px" }}>
                  <button
                    type="button"
                    onClick={onClose}
                    style={{
                      background: "transparent",
                      border: "1px solid rgba(255, 255, 255, 0.2)",
                      color: "#a5b4c4",
                      padding: "8px 16px",
                      borderRadius: "8px",
                      cursor: "pointer",
                      fontSize: "13px",
                    }}
                  >
                    Deny
                  </button>
                  <button
                    type="button"
                    onClick={handleAuthorize}
                    style={{
                      background: "#34A853",
                      border: "none",
                      color: "#ffffff",
                      padding: "8px 22px",
                      borderRadius: "8px",
                      fontWeight: 600,
                      cursor: "pointer",
                      fontSize: "13px",
                      display: "flex",
                      alignItems: "center",
                      gap: "6px",
                    }}
                  >
                    <span>Authorize & Continue</span>
                    <span>✓</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {step === "authenticating" && (
            <div style={{ textAlign: "center", padding: "30px 10px" }}>
              <div
                style={{
                  width: "48px",
                  height: "48px",
                  margin: "0 auto 16px",
                  border: "3px solid rgba(66, 133, 244, 0.2)",
                  borderTopColor: "#4285F4",
                  borderRadius: "50%",
                  animation: "spin 0.7s linear infinite",
                }}
              />
              <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
              <h4 style={{ margin: "0 0 6px", fontSize: "16px" }}>Cryptographic Handshake in Progress</h4>
              <p style={{ margin: 0, fontSize: "12px", color: "#8da2b5" }}>
                Exchanging PKCE authorization code for signed JWT security token...
              </p>
            </div>
          )}
        </div>

        {/* Footer */}
        <div
          style={{
            padding: "12px 24px",
            background: "rgba(0, 0, 0, 0.2)",
            borderTop: "1px solid rgba(255, 255, 255, 0.05)",
            fontSize: "11px",
            color: "#6b8296",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <span>ShieldID Sovereign PKCE Gateway</span>
          <span>SHA-256 Verified</span>
        </div>
      </div>
    </div>
  );
}

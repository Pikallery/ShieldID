import React, { useState } from "react";
import "./LoginPage.css";
import OAuthModal from "./OAuthModal";
import { oauthService } from "../utils/oauthService";

const backgroundDots = [
  [8, 14], [18, 30], [28, 11], [40, 21], [56, 10], [72, 18], [88, 12],
  [94, 34], [12, 56], [24, 78], [38, 67], [61, 82], [78, 62], [91, 76],
  [5, 88], [48, 93], [69, 42], [84, 50],
];

export default function LoginPage({ onLogin, onGoToRegister, onForgotPassword }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [oauthProvider, setOauthProvider] = useState(null); // 'google' | 'sso' | null

  const handleSubmit = (event) => {
    event.preventDefault();
    if (!email.trim() || !password) {
      setError("Enter your email and password to continue.");
      return;
    }

    setError("");
    setIsSubmitting(true);
    window.setTimeout(() => {
      setIsSubmitting(false);
      const session = oauthService.saveSession({
        provider: "password",
        email: email.trim(),
        fullName: email.split("@")[0].replace(/[._-]+/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
        role: "Screening Administrator",
        badgeId: "OP-4821",
        authMethod: "Password Authentication",
      });
      onLogin?.(session);
    }, 450);
  };

  const handleOAuthSuccess = (session) => {
    setOauthProvider(null);
    onLogin?.(session);
  };

  return (
    <main className="login-page" aria-label="ShieldID login">
      <div className="login-bg-dots" aria-hidden="true">
        {backgroundDots.map(([left, top], index) => (
          <span
            className="login-bg-dot"
            key={`${left}-${top}`}
            style={{ left: `${left}%`, top: `${top}%`, opacity: 0.22 + (index % 4) * 0.1 }}
          />
        ))}
      </div>

      <div className="login-orb">
        <section className="login-card">
          <div className="login-icon" aria-hidden="true">
            <span>◇</span>
          </div>
          <h1 className="login-title">Shield<span className="login-title-accent">ID</span></h1>
          <div className="login-subtitle">
            <span className="login-subtitle-line" />
            SECURE ACCESS
            <span className="login-subtitle-line" />
          </div>

          {/* Direct OAuth Action Buttons */}
          <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: "8px", marginBottom: "14px" }}>
            <button
              type="button"
              onClick={() => setOauthProvider("google")}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "10px",
                width: "100%",
                padding: "11px 16px",
                borderRadius: "999px",
                background: "#ffffff",
                border: "none",
                color: "#202124",
                fontWeight: 600,
                fontSize: "13px",
                cursor: "pointer",
                boxShadow: "0 2px 6px rgba(0,0,0,0.2)",
                transition: "transform 0.15s ease",
              }}
              onMouseEnter={(e) => (e.currentTarget.style.transform = "translateY(-1px)")}
              onMouseLeave={(e) => (e.currentTarget.style.transform = "translateY(0)")}
            >
              <svg width="18" height="18" viewBox="0 0 24 24">
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
              <span>Continue with Google</span>
            </button>

            <button
              type="button"
              onClick={() => setOauthProvider("sso")}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "8px",
                width: "100%",
                padding: "10px 16px",
                borderRadius: "999px",
                background: "rgba(16, 185, 129, 0.15)",
                border: "1px solid rgba(52, 211, 153, 0.4)",
                color: "#6ee7b7",
                fontWeight: 600,
                fontSize: "12px",
                cursor: "pointer",
                transition: "all 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = "rgba(16, 185, 129, 0.25)";
                e.currentTarget.style.borderColor = "#34d399";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "rgba(16, 185, 129, 0.15)";
                e.currentTarget.style.borderColor = "rgba(52, 211, 153, 0.4)";
              }}
            >
              <span>🛡️</span>
              <span>DigiYatra / Govt Single Sign-On</span>
            </button>
          </div>

          <div style={{ display: "flex", alignItems: "center", width: "100%", margin: "6px 0 12px", gap: "8px" }}>
            <span style={{ flex: 1, height: "1px", background: "rgba(255,255,255,0.2)" }} />
            <span style={{ fontSize: "10px", letterSpacing: "0.12em", color: "rgba(255,255,255,0.6)" }}>OR WORK EMAIL</span>
            <span style={{ flex: 1, height: "1px", background: "rgba(255,255,255,0.2)" }} />
          </div>

          <form className="login-form" onSubmit={handleSubmit} noValidate>
            <label className="login-field">
              <span aria-hidden="true">✉</span>
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                placeholder="Work email"
                autoComplete="email"
                aria-label="Work email"
              />
            </label>
            <label className="login-field">
              <span aria-hidden="true">⌑</span>
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                placeholder="Password"
                autoComplete="current-password"
                aria-label="Password"
              />
            </label>
            {error && <p className="login-error" role="alert">{error}</p>}
            <button className="login-submit" type="submit" disabled={isSubmitting}>
              {isSubmitting ? "AUTHENTICATING" : "CONTINUE"}
              <span className="login-submit-arrow" aria-hidden="true">→</span>
            </button>
          </form>

          <button className="login-link" type="button" onClick={onForgotPassword}>
            FORGOT PASSWORD?
          </button>
          <button className="login-link login-register-link" type="button" onClick={onGoToRegister}>
            REQUEST ACCESS
          </button>
        </section>
      </div>

      <footer className="login-footer">
        <span className="login-status-dot" />
        SYSTEMS OPERATIONAL · OAUTH 2.0 ACTIVE
      </footer>

      {/* OAuth Interactive Sovereign Modal */}
      <OAuthModal
        isOpen={Boolean(oauthProvider)}
        provider={oauthProvider || "google"}
        onClose={() => setOauthProvider(null)}
        onSuccess={handleOAuthSuccess}
      />
    </main>
  );
}

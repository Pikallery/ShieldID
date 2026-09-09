import React, { useState } from "react";
import "./LoginPage.css";

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
      onLogin?.({ email: email.trim() });
    }, 450);
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
          <div className="login-alt-icons" aria-label="Alternative sign in options">
            <button type="button" aria-label="Sign in with Google">G</button>
            <button type="button" aria-label="Sign in with single sign-on">S</button>
          </div>
        </section>
      </div>

      <footer className="login-footer">
        <span className="login-status-dot" />
        SYSTEMS OPERATIONAL
      </footer>
    </main>
  );
}

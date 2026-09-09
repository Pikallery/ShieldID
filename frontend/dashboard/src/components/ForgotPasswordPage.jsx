import React, { useState } from "react";
import "./LoginPage.css";

const backgroundDots = [
  [10, 16], [24, 31], [42, 12], [62, 20], [84, 14],
  [8, 57], [30, 72], [58, 86], [80, 64], [94, 42],
];

export default function ForgotPasswordPage({ onGoToLogin }) {
  const [email, setEmail] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [isSaved, setIsSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = (event) => {
    event.preventDefault();
    setError("");

    if (!email.trim() || !newPassword || !confirmPassword) {
      setError("Complete all fields to continue.");
      return;
    }
    if (newPassword.length < 8) {
      setError("Your new password must be at least 8 characters.");
      return;
    }
    if (newPassword !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    setIsSubmitting(true);
    window.setTimeout(() => {
      setIsSubmitting(false);
      setIsSaved(true);
    }, 500);
  };

  return (
    <main className="login-page" aria-label="ShieldID password reset">
      <div className="login-bg-dots" aria-hidden="true">
        {backgroundDots.map(([left, top]) => (
          <span className="login-bg-dot" key={`${left}-${top}`} style={{ left: `${left}%`, top: `${top}%` }} />
        ))}
      </div>

      <div className="login-orb">
        <section className="login-card">
          <div className="login-icon" aria-hidden="true"><span>◇</span></div>
          <h1 className="login-title">Shield<span className="login-title-accent">ID</span></h1>
          <div className="login-subtitle">
            <span className="login-subtitle-line" />
            {isSaved ? "PASSWORD UPDATED" : "RESET ACCESS"}
            <span className="login-subtitle-line" />
          </div>

          {isSaved ? (
            <>
              <p className="login-success-text">Your password has been updated locally. You can now continue to sign in.</p>
              <button type="button" className="login-submit" onClick={onGoToLogin}>BACK TO SIGN IN <span className="login-submit-arrow">→</span></button>
            </>
          ) : (
            <form className="login-form" onSubmit={handleSubmit} noValidate>
              <label className="login-field">
                <span aria-hidden="true">✉</span>
                <input type="email" placeholder="Work email" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="email" aria-label="Work email" />
              </label>
              <label className="login-field">
                <span aria-hidden="true">⌑</span>
                <input type="password" placeholder="New password" value={newPassword} onChange={(event) => setNewPassword(event.target.value)} autoComplete="new-password" aria-label="New password" />
              </label>
              <label className="login-field">
                <span aria-hidden="true">⌑</span>
                <input type="password" placeholder="Confirm new password" value={confirmPassword} onChange={(event) => setConfirmPassword(event.target.value)} autoComplete="new-password" aria-label="Confirm new password" />
              </label>
              {error && <p className="login-error" role="alert">{error}</p>}
              <button className="login-submit" type="submit" disabled={isSubmitting}>
                {isSubmitting ? "UPDATING" : "UPDATE PASSWORD"}
                <span className="login-submit-arrow">→</span>
              </button>
            </form>
          )}

          {!isSaved && <button type="button" className="login-link" onClick={onGoToLogin}>BACK TO SIGN IN</button>}
        </section>
      </div>

      <footer className="login-footer">
        <span className="login-status-dot" />
        SYSTEM SECURE: 256-BIT AES ENCRYPTED
      </footer>
    </main>
  );
}

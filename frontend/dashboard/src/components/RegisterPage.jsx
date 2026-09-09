import React, { useState } from "react";
import "./LoginPage.css";

const UserIcon = () => (
  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
    <circle cx="12" cy="8" r="3.5" />
    <path d="M5 20c0-3.9 3.1-7 7-7s7 3.1 7 7" />
  </svg>
);

const MailIcon = () => (
  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
    <rect x="3" y="5" width="18" height="14" rx="2" />
    <path d="M3 7l9 6 9-6" />
  </svg>
);

const LockIcon = ({ checked = false }) => (
  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
    <rect x="5" y="11" width="14" height="9" rx="2" />
    <path d="M8 11V7a4 4 0 0 1 8 0v4" />
    {checked && <path d="M9.5 15.2l1.3 1.3 3-3" />}
  </svg>
);

const ShieldPlusIcon = () => (
  <svg viewBox="0 0 24 24" width="36" height="36" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
    <path d="M12 2l8 3v6c0 5-3.4 8.7-8 10-4.6-1.3-8-5-8-10V5l8-3z" />
    <path d="M12 9v6M9 12h6" />
  </svg>
);

const backgroundDots = [
  [22, 18], [62, 10], [8, 34], [88, 46],
  [16, 62], [78, 70], [38, 84], [92, 26],
];

function RegisterBrand() {
  return (
    <>
      <div className="login-icon"><ShieldPlusIcon /></div>
      <h1 className="login-title">SHIELD <span className="login-title-accent">ID</span></h1>
    </>
  );
}

export default function RegisterPage({ onRegister, onGoToLogin }) {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [accessKey, setAccessKey] = useState("");
  const [confirmKey, setConfirmKey] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const simulateRegister = () => new Promise((resolve) => {
    window.setTimeout(resolve, 500);
  });

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");

    if (!fullName.trim() || !email.trim() || !accessKey || !confirmKey) {
      setError("All fields are required.");
      return;
    }
    if (accessKey !== confirmKey) {
      setError("Access keys don't match.");
      return;
    }

    setIsSubmitting(true);
    try {
      await (onRegister || simulateRegister)({
        fullName: fullName.trim(),
        email: email.trim(),
        accessKey,
      });
      setSuccess(true);
    } catch {
      setError("Registration failed. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <main className="login-page" aria-label="ShieldID registration">
      <div className="login-bg-dots" aria-hidden="true">
        {backgroundDots.map(([left, top]) => (
          <span className="login-bg-dot" key={`${left}-${top}`} style={{ left: `${left}%`, top: `${top}%` }} />
        ))}
      </div>

      <div className="login-orb">
        <section className="login-card">
          <RegisterBrand />
          {success ? (
            <>
              <div className="login-subtitle">
                <span className="login-subtitle-line" />
                CLEARANCE REQUESTED
                <span className="login-subtitle-line" />
              </div>
              <p className="login-success-text">Your access request has been recorded. Sign in once your clearance is approved.</p>
              <button type="button" className="login-submit" onClick={onGoToLogin}>
                BACK TO SIGN IN <span className="login-submit-arrow">→</span>
              </button>
            </>
          ) : (
            <>
              <div className="login-subtitle">
                <span className="login-subtitle-line" />
                REQUEST CLEARANCE
                <span className="login-subtitle-line" />
              </div>

              <form className="login-form" onSubmit={handleSubmit} noValidate>
                <label className="login-field">
                  <UserIcon />
                  <input type="text" placeholder="Full Name" value={fullName} onChange={(event) => setFullName(event.target.value)} autoComplete="name" aria-label="Full name" />
                </label>
                <label className="login-field">
                  <MailIcon />
                  <input type="email" placeholder="Email Address" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="email" aria-label="Email address" />
                </label>
                <label className="login-field">
                  <LockIcon />
                  <input type="password" placeholder="Access Key" value={accessKey} onChange={(event) => setAccessKey(event.target.value)} autoComplete="new-password" aria-label="Access key" />
                </label>
                <label className="login-field">
                  <LockIcon checked />
                  <input type="password" placeholder="Confirm Access Key" value={confirmKey} onChange={(event) => setConfirmKey(event.target.value)} autoComplete="new-password" aria-label="Confirm access key" />
                </label>
                {error && <p className="login-error" role="alert">{error}</p>}
                <button type="submit" className="login-submit" disabled={isSubmitting}>
                  {isSubmitting ? "REGISTERING" : "REGISTER"}
                  <span className="login-submit-arrow">→</span>
                </button>
              </form>

              <button type="button" className="login-link" onClick={onGoToLogin}>ALREADY CLEARED? SIGN IN</button>
            </>
          )}
        </section>
      </div>

      <footer className="login-footer">
        <span className="login-status-dot" />
        SYSTEM SECURE: 256-BIT AES ENCRYPTED
      </footer>
    </main>
  );
}

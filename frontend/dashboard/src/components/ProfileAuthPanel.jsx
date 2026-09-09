import React from "react";

export default function ProfileAuthPanel({ isAuthenticated, profileName, profileEmail, onLogin, onRegister, onClose }) {
  return (
    <section className="profile-auth-panel" aria-label={isAuthenticated ? "Profile details" : "Profile authentication"}>
      <div className="profile-auth-heading">
        <div>
          <p className="eyebrow">PROFILE ACCESS</p>
          <h2>{isAuthenticated ? "Your profile" : "Account access"}</h2>
        </div>
        <button className="profile-auth-close" type="button" onClick={onClose} aria-label="Close profile access">×</button>
      </div>
      {isAuthenticated ? (
        <div className="profile-details">
          <div className="profile-detail-identity"><span className="profile-detail-avatar">{profileName.split(" ").map((part) => part[0]).slice(0, 2).join("").toUpperCase()}</span><div><strong>{profileName}</strong><small>Authenticated user</small></div></div>
          <div className="profile-detail-group"><p>Gmail account</p><strong>{profileEmail}</strong></div>
          <div className="profile-detail-group"><p>Business workspace</p><strong>Northstar Ops</strong><small>Enterprise identity operations</small></div>
          <div className="profile-detail-group"><p>Role</p><strong>Screening administrator</strong></div>
        </div>
      ) : (
        <>
          <p className="profile-auth-copy">Choose an account option to continue in the full-screen access page.</p>
          <div className="profile-auth-options">
            <button className="profile-auth-option" type="button" onClick={onLogin}>
              <span className="profile-auth-option-icon">↗</span>
              <span><strong>Login</strong><small>Access your workspace</small></span>
            </button>
            <button className="profile-auth-option" type="button" onClick={onRegister}>
              <span className="profile-auth-option-icon">＋</span>
              <span><strong>Register</strong><small>Create a new profile</small></span>
            </button>
          </div>
        </>
      )}
    </section>
  );
}

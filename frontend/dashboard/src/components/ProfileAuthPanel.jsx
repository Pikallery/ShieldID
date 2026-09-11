import React from "react";

export default function ProfileAuthPanel({
  isAuthenticated,
  profileName,
  profileEmail,
  session,
  onLogin,
  onRegister,
  onLogout,
  onClose,
}) {
  return (
    <section className="profile-auth-panel" aria-label={isAuthenticated ? "Profile details" : "Profile authentication"}>
      <div className="profile-auth-heading">
        <div>
          <p className="eyebrow">SECURITY CLEARANCE</p>
          <h2>{isAuthenticated ? "Officer profile" : "Account access"}</h2>
        </div>
        <button className="profile-auth-close" type="button" onClick={onClose} aria-label="Close profile access">×</button>
      </div>
      {isAuthenticated ? (
        <div className="profile-details">
          <div className="profile-detail-identity">
            <span className="profile-detail-avatar">
              {profileName.split(" ").map((part) => part[0]).slice(0, 2).join("").toUpperCase()}
            </span>
            <div>
              <strong>{profileName}</strong>
              <small style={{ color: "#34d399", display: "flex", alignItems: "center", gap: "4px" }}>
                <span>●</span> {session?.authMethod || "Authenticated Officer"}
              </small>
            </div>
          </div>
          <div className="profile-detail-group">
            <p>Work identity</p>
            <strong>{profileEmail}</strong>
          </div>
          <div className="profile-detail-group">
            <p>Role & Clearance</p>
            <strong>{session?.role || "Screening administrator"}</strong>
            <small style={{ color: "#93c5fd" }}>Badge: {session?.badgeId || "SHIELD-OPS-1"}</small>
          </div>
          <div className="profile-detail-group">
            <p>Session Security</p>
            <strong>OAuth 2.0 PKCE Verified</strong>
            <small style={{ color: "#a5b4c4", fontFamily: "monospace", fontSize: "10px" }}>
              Token: {session?.token ? `${session.token.slice(0, 18)}...` : "Active"}
            </small>
          </div>

          <div style={{ marginTop: "16px", paddingTop: "12px", borderTop: "1px solid rgba(255,255,255,0.1)" }}>
            <button
              type="button"
              onClick={onLogout}
              style={{
                width: "100%",
                padding: "10px 14px",
                background: "rgba(239, 68, 68, 0.15)",
                border: "1px solid rgba(239, 68, 68, 0.35)",
                borderRadius: "8px",
                color: "#fca5a5",
                fontWeight: 600,
                fontSize: "12px",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "8px",
                transition: "all 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = "rgba(239, 68, 68, 0.25)";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "rgba(239, 68, 68, 0.15)";
              }}
            >
              <span>⎋</span>
              <span>Sign Out / Switch Terminal</span>
            </button>
          </div>
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

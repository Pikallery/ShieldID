import React, { useState } from "react";
import ScreeningDashboard from "../components/ScreeningDashboard";

// Helper to compute regular pointy-topped hexagon SVG points
function hexPoints(cx, cy, r) {
  const w = r * 0.866025; // r * sqrt(3)/2
  const h = r * 0.5;
  return `${cx},${cy - r} ${cx + w},${cy - h} ${cx + w},${cy + h} ${cx},${cy + r} ${cx - w},${cy + h} ${cx - w},${cy - h}`;
}

export default function Dashboard() {
  const [showLoading, setShowLoading] = useState(true);
  const [isFadingOut, setIsFadingOut] = useState(false);
  const [authStatus, setAuthStatus] = useState("idle"); // idle | ready

  const triggerTransition = () => {
    if (isFadingOut) return;
    setAuthStatus("ready");
    setIsFadingOut(true);
    setTimeout(() => {
      setShowLoading(false);
      setIsFadingOut(false);
    }, 700); // Match the blur and circular reveal handoff duration
  };

  return (
    <div className="app-transition-root" style={{ position: "relative", minHeight: "100vh" }}>
      {/* Pre-mounted dashboard eliminates any waiting time or second loading screen */}
      <div className="shield-dashboard-content">
        {!showLoading && (
          <button
            onClick={() => {
              setAuthStatus("idle");
              setIsFadingOut(false);
              setShowLoading(true);
            }}
            style={{
              position: "fixed",
              bottom: "20px",
              left: "20px",
              zIndex: 9999,
              background: "rgba(11, 31, 58, 0.85)",
              color: "#82B1FF",
              border: "1px solid rgba(130, 177, 255, 0.4)",
              borderRadius: "20px",
              padding: "6px 14px",
              fontSize: "11px",
              fontFamily: "'DM Mono', monospace",
              cursor: "pointer",
              boxShadow: "0 4px 12px rgba(0,0,0,0.2)",
              backdropFilter: "blur(8px)",
              display: "flex",
              alignItems: "center",
              gap: "6px",
              transition: "all 0.2s ease",
            }}
            title="Replay authenticating loading animation"
          >
            <span>↺</span>
            <span>View Loading Screen</span>
          </button>
        )}
        <ScreeningDashboard />
      </div>

      {/* Floating Loading Screen Overlay */}
      {showLoading ? (
        <div className={`shield-loading-viewport ${isFadingOut ? "is-fading-out" : ""}`}>
          <style>{`
            @import url('https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500;600&family=Manrope:wght@400;500;600;700;800;900&display=swap');

            .shield-loading-viewport {
              position: fixed;
              inset: 0;
              width: 100vw;
              height: 100vh;
              overflow: hidden;
              background: radial-gradient(circle at 50% 46%, #8ca6be 0%, #7d9cb6 42%, #68859e 85%, #5a768f 100%);
              font-family: 'Manrope', -apple-system, BlinkMacSystemFont, sans-serif;
              display: flex;
              align-items: center;
              justify-content: center;
              user-select: none;
              -webkit-font-smoothing: antialiased;
              z-index: 99999;
              opacity: 1;
              transform: scale(1);
              transition: opacity 0.32s cubic-bezier(0.2, 0.8, 0.2, 1),
                          transform 0.32s cubic-bezier(0.2, 0.8, 0.2, 1);
              pointer-events: auto;
            }

            .shield-loading-viewport.is-fading-out {
              animation: app-loading-exit 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards;
              transition: none;
              pointer-events: none;
            }

            .app-reveal-in {
              animation: app-reveal-in 0.9s cubic-bezier(0.16, 1, 0.3, 1) both;
            }

            @keyframes app-loading-exit {
              0% { opacity: 1; filter: blur(0); transform: scale(1); }
              100% { opacity: 0; filter: blur(10px); transform: scale(1.06); }
            }

            @keyframes app-reveal-in {
              0% { clip-path: circle(0% at 50% 50%); opacity: 0.6; }
              100% { clip-path: circle(75% at 50% 50%); opacity: 1; }
            }

            .app-scan-sweep {
              position: fixed;
              inset: 0;
              z-index: 100000;
              pointer-events: none;
              background: linear-gradient(100deg, transparent 45%, rgba(255, 255, 255, 0.55) 50%, transparent 55%);
              transform: translateX(-120%);
              animation: app-scan-sweep 0.9s cubic-bezier(0.4, 0, 0.2, 1) forwards;
            }

            @keyframes app-scan-sweep {
              0% { transform: translateX(-120%); }
              100% { transform: translateX(120%); }
            }

            @media (prefers-reduced-motion: reduce) {
              .shield-loading-viewport.is-fading-out,
              .app-reveal-in,
              .app-scan-sweep,
              .center-floating-wrapper,
              .loading-bar-fill {
                animation: none !important;
              }
            }

            /* Prevent inner duplicate loading screen from flashing */
            .loading-screen {
              display: none !important;
            }

            /* SVG Background Canvas */
            .shield-bg-canvas {
              position: absolute;
              inset: 0;
              width: 100%;
              height: 100%;
              pointer-events: none;
            }

            /* Floating Hexagon Animations */
            .hex-float-1 {
              animation: floatHex1 8s ease-in-out infinite alternate;
              transform-origin: 170px 180px;
            }
            .hex-float-2 {
              animation: floatHex2 10.5s ease-in-out infinite alternate;
              transform-origin: 150px 780px;
            }
            .hex-float-3 {
              animation: floatHex3 9s ease-in-out infinite alternate;
              transform-origin: 150px 1150px;
            }
            .hex-float-4 {
              animation: floatHex2 11s ease-in-out infinite alternate;
              transform-origin: 840px 220px;
            }
            .hex-float-5 {
              animation: floatHex1 12s ease-in-out infinite alternate;
              transform-origin: 850px 580px;
            }
            .hex-float-6 {
              animation: floatHex3 8.5s ease-in-out infinite alternate;
              transform-origin: 870px 940px;
            }
            .hex-float-7 {
              animation: floatHex2 9.5s ease-in-out infinite alternate;
              transform-origin: 750px 1380px;
            }

            @keyframes floatHex1 {
              0% { transform: translateY(0px) rotate(0deg); }
              100% { transform: translateY(-16px) rotate(2deg); }
            }
            @keyframes floatHex2 {
              0% { transform: translateY(0px) rotate(0deg); }
              100% { transform: translateY(14px) rotate(-1.5deg); }
            }
            @keyframes floatHex3 {
              0% { transform: translateY(0px) scale(1); }
              100% { transform: translateY(-12px) scale(1.02); }
            }

            /* Glowing Blue Dots */
            .glowing-dot {
              animation: pulseGlow 4s ease-in-out infinite alternate;
              transform-box: fill-box;
              transform-origin: center;
            }
            .glowing-dot-delay-1 { animation-delay: 0.8s; }
            .glowing-dot-delay-2 { animation-delay: 1.6s; }
            .glowing-dot-delay-3 { animation-delay: 2.4s; }

            @keyframes pulseGlow {
              0% {
                opacity: 0.55;
                transform: scale(0.85);
                filter: drop-shadow(0 0 4px #4f80ff);
              }
              100% {
                opacity: 1;
                transform: scale(1.25);
                filter: drop-shadow(0 0 12px #6da0ff) drop-shadow(0 0 20px rgba(95, 160, 255, 0.8));
              }
            }

            /* White Twinkling Particles */
            .twinkle-dot {
              animation: twinkleDot 3.5s ease-in-out infinite alternate;
              transform-box: fill-box;
              transform-origin: center;
            }
            .twinkle-delay-1 { animation-delay: 0.7s; }
            .twinkle-delay-2 { animation-delay: 1.5s; }
            .twinkle-delay-3 { animation-delay: 2.3s; }

            @keyframes twinkleDot {
              0% { opacity: 0.25; transform: scale(0.75); }
              100% { opacity: 0.9; transform: scale(1.2); filter: drop-shadow(0 0 3px #ffffff); }
            }

            /* Main Floating Center Circle */
            .center-floating-wrapper {
              position: relative;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              z-index: 10;
              animation: mainLevitate 5.8s ease-in-out infinite;
            }

            @keyframes mainLevitate {
              0% {
                transform: translateY(0px);
              }
              50% {
                transform: translateY(-18px);
              }
              100% {
                transform: translateY(0px);
              }
            }

            /* Glassmorphic Circle */
            .floating-circle {
              position: relative;
              width: clamp(330px, 46vw, 560px);
              height: clamp(330px, 46vw, 560px);
              border-radius: 50%;
              /* Frosted Glass Background */
              background: radial-gradient(circle at 50% 48%, rgba(255, 255, 255, 0.22) 0%, rgba(255, 255, 255, 0.13) 55%, rgba(190, 215, 240, 0.08) 100%);
              backdrop-filter: blur(14px) saturate(110%);
              -webkit-backdrop-filter: blur(14px) saturate(110%);
              border: 1.5px solid rgba(255, 255, 255, 0.52);
              box-shadow:
                0 0 45px rgba(255, 255, 255, 0.16),
                0 28px 70px rgba(20, 45, 75, 0.28),
                inset 0 0 35px rgba(255, 255, 255, 0.15),
                inset 0 2px 4px rgba(255, 255, 255, 0.4);
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              text-align: center;
              padding: 40px;
              box-sizing: border-box;
              transition: all 0.5s ease;
            }

            /* Ambient Depth Shadow below the circle */
            .floating-circle-shadow {
              width: clamp(220px, 32vw, 380px);
              height: 24px;
              border-radius: 50%;
              background: radial-gradient(ellipse, rgba(18, 38, 62, 0.28) 0%, rgba(18, 38, 62, 0) 72%);
              margin-top: 14px;
              filter: blur(9px);
              animation: shadowBreath 5.8s ease-in-out infinite;
            }

            @keyframes shadowBreath {
              0% {
                transform: scale(1);
                opacity: 0.8;
              }
              50% {
                transform: scale(0.86);
                opacity: 0.4;
              }
              100% {
                transform: scale(1);
                opacity: 0.8;
              }
            }

            /* Brand Container */
            .brand-row {
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 8px;
              margin-bottom: 22px;
            }

            .brand-name {
              color: #ffffff;
              font-family: 'Manrope', -apple-system, BlinkMacSystemFont, sans-serif;
              font-size: clamp(34px, 4.4vw, 54px);
              font-weight: 900;
              letter-spacing: -0.025em;
              line-height: 1;
              text-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            }

            .brand-id-mark {
              height: clamp(28px, 3.7vw, 44px);
              width: auto;
              display: block;
              filter: drop-shadow(0 2px 8px rgba(0, 0, 0, 0.08));
            }

            /* Subtitle: INITIALIZE SCREENING */
            .screening-subtitle {
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 12px;
              margin-bottom: 46px;
            }

            .sub-dash {
              width: clamp(16px, 2.2vw, 28px);
              height: 1.5px;
              background: rgba(255, 255, 255, 0.48);
              border-radius: 1px;
            }

            .sub-text {
              color: rgba(255, 255, 255, 0.9);
              font-family: 'DM Mono', monospace;
              font-size: clamp(10px, 1.1vw, 13.5px);
              font-weight: 600;
              letter-spacing: 0.28em;
              text-transform: uppercase;
              text-shadow: 0 1px 4px rgba(0, 0, 0, 0.12);
            }

            /* Authenticating Pill Button */
            .auth-pill-btn {
              position: relative;
              background: #ffffff;
              border: none;
              outline: none;
              border-radius: 9999px;
              padding: clamp(12px, 1.4vw, 16px) clamp(28px, 3.4vw, 42px);
              cursor: pointer;
              display: inline-flex;
              align-items: center;
              justify-content: center;
              gap: 12px;
              box-shadow:
                0 10px 28px rgba(25, 45, 75, 0.24),
                0 3px 8px rgba(0, 0, 0, 0.06);
              transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
              overflow: hidden;
            }

            .auth-pill-btn::before {
              content: '';
              position: absolute;
              top: 0;
              left: -100%;
              width: 100%;
              height: 100%;
              background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
              animation: shimmer 3s infinite;
            }

            @keyframes shimmer {
              0% { left: -100%; }
              50%, 100% { left: 100%; }
            }

            .auth-pill-btn:hover {
              transform: translateY(-2px) scale(1.02);
              box-shadow:
                0 15px 35px rgba(25, 45, 75, 0.3),
                0 4px 12px rgba(0, 0, 0, 0.08);
            }

            .auth-pill-btn:active {
              transform: translateY(0px) scale(0.99);
            }

            .auth-pill-text {
              color: #718ea9;
              font-family: 'Manrope', -apple-system, sans-serif;
              font-size: clamp(12px, 1.25vw, 14.5px);
              font-weight: 800;
              letter-spacing: 0.15em;
              text-transform: uppercase;
              transition: color 0.2s ease;
            }

            .auth-pill-arrow {
              display: flex;
              align-items: center;
              justify-content: center;
              transition: transform 0.25s ease;
            }

            .auth-pill-btn:hover .auth-pill-arrow {
              transform: translateX(3px);
            }

            /* Responsive tweaks */
            @media (max-width: 600px) {
              .floating-circle {
                width: 88vw;
                height: 88vw;
                padding: 24px;
              }
              .screening-subtitle {
                margin-bottom: 32px;
              }
            }
          `}</style>

          {/* SVG Canvas for Hexagons & Glowing Stars */}
          <svg
            className="shield-bg-canvas"
            viewBox="0 0 1000 1600"
            preserveAspectRatio="xMidYMid slice"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <filter id="glow-blue" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="6" result="coloredBlur" />
                <feMerge>
                  <feMergeNode in="coloredBlur" />
                  <feMergeNode in="SourceGraphic" />
                </feMerge>
              </filter>
            </defs>

            {/* TOP LEFT HEXAGONS */}
            <g className="hex-float-1">
              <polygon
                points={hexPoints(170, 180, 130)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.42)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(110, 290, 95)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.38)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(205, 610, 42)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.35)"
                strokeWidth="1.6"
              />
            </g>

            {/* MID LEFT HEXAGON */}
            <g className="hex-float-2">
              <polygon
                points={hexPoints(150, 780, 120)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.42)"
                strokeWidth="1.8"
              />
            </g>

            {/* BOTTOM LEFT HEXAGONS */}
            <g className="hex-float-3">
              <polygon
                points={hexPoints(105, 1090, 100)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.35)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(175, 1210, 125)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.44)"
                strokeWidth="1.8"
              />
            </g>

            {/* TOP RIGHT HEXAGONS */}
            <g className="hex-float-4">
              <polygon
                points={hexPoints(845, 180, 115)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.4)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(810, 260, 90)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.35)"
                strokeWidth="1.8"
              />
            </g>

            {/* MID RIGHT HEXAGONS */}
            <g className="hex-float-5">
              <polygon
                points={hexPoints(865, 500, 145)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.45)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(830, 630, 125)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.4)"
                strokeWidth="1.8"
              />
            </g>

            {/* LOWER MID RIGHT HEXAGONS */}
            <g className="hex-float-6">
              <polygon
                points={hexPoints(880, 900, 105)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.36)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(850, 980, 100)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.32)"
                strokeWidth="1.8"
              />
            </g>

            {/* BOTTOM RIGHT HEXAGONS */}
            <g className="hex-float-7">
              <polygon
                points={hexPoints(780, 1350, 115)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.38)"
                strokeWidth="1.8"
              />
              <polygon
                points={hexPoints(730, 1440, 85)}
                fill="none"
                stroke="rgba(145, 175, 255, 0.32)"
                strokeWidth="1.8"
              />
            </g>

            {/* GLOWING VIBRANT BLUE DOTS */}
            <circle cx="140" cy="120" r="5" fill="#598cff" className="glowing-dot" />
            <circle cx="230" cy="190" r="4.5" fill="#598cff" className="glowing-dot glowing-dot-delay-1" />
            <circle cx="205" cy="620" r="5" fill="#598cff" className="glowing-dot glowing-dot-delay-2" />
            <circle cx="65" cy="780" r="5.5" fill="#598cff" className="glowing-dot glowing-dot-delay-3" />
            <circle cx="105" cy="1230" r="5" fill="#598cff" className="glowing-dot glowing-dot-delay-1" />
            <circle cx="840" cy="1090" r="5.5" fill="#598cff" className="glowing-dot glowing-dot-delay-2" />
            <circle cx="890" cy="1360" r="5.5" fill="#598cff" className="glowing-dot glowing-dot-delay-3" />
            <circle cx="915" cy="310" r="5" fill="#598cff" className="glowing-dot glowing-dot-delay-1" />

            {/* SOFT WHITE MICRO PARTICLES */}
            <circle cx="410" cy="60" r="3.5" fill="#ffffff" className="twinkle-dot" />
            <circle cx="310" cy="135" r="3" fill="#ffffff" className="twinkle-dot twinkle-delay-1" />
            <circle cx="890" cy="50" r="3" fill="#ffffff" className="twinkle-dot twinkle-delay-2" />
            <circle cx="860" cy="280" r="2.5" fill="#ffffff" className="twinkle-dot twinkle-delay-3" />
            <circle cx="740" cy="285" r="3" fill="#ffffff" className="twinkle-dot twinkle-delay-1" />
            <circle cx="285" cy="1230" r="3" fill="#ffffff" className="twinkle-dot twinkle-delay-2" />
            <circle cx="970" cy="965" r="2.5" fill="#ffffff" className="twinkle-dot twinkle-delay-3" />
            <circle cx="895" cy="1185" r="3" fill="#ffffff" className="twinkle-dot twinkle-delay-1" />
          </svg>

          {/* MAIN FLOATING CIRCLE CONTAINER */}
          <div className="center-floating-wrapper">
            <div className="floating-circle">
              {/* SHIELD ID BRAND LOGO */}
              <div className="brand-row">
                <span className="brand-name">SHIELD</span>
                <svg
                  className="brand-id-mark"
                  viewBox="0 0 54 42"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  {/* The 'I' rounded capsule outline */}
                  <rect
                    x="2.5"
                    y="2.5"
                    width="8"
                    height="37"
                    rx="4"
                    stroke="#FFFFFF"
                    strokeWidth="3.2"
                    fill="none"
                  />
                  {/* The 'D' outer contour */}
                  <path
                    d="M 19 2.5 H 33 C 44 2.5 51.5 10.5 51.5 21 C 51.5 31.5 44 39.5 33 39.5 H 19 Z"
                    stroke="#FFFFFF"
                    strokeWidth="3.2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    fill="none"
                  />
                  {/* The 'D' inner concentric contour */}
                  <path
                    d="M 25 10 H 31.5 C 37.5 10 42.5 14.5 42.5 21 C 42.5 27.5 37.5 32 31.5 32 H 25 Z"
                    stroke="#FFFFFF"
                    strokeWidth="3"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    fill="none"
                  />
                </svg>
              </div>

              {/* DIVIDER & SUBTITLE */}
              <div className="screening-subtitle">
                <span className="sub-dash" />
                <span className="sub-text">INITIALIZE SCREENING</span>
                <span className="sub-dash" />
              </div>

              {/* AUTHENTICATING PILL BUTTON */}
              <button
                className="auth-pill-btn"
                onClick={triggerTransition}
                aria-label="Authenticate and open dashboard"
              >
                <span className="auth-pill-text">
                  {authStatus === "idle" && "GET STARTED"}
                  {authStatus === "authenticating" && "OPENING..."}
                  {authStatus === "ready" && "READY ✓"}
                </span>
                <span className="auth-pill-arrow">
                  <svg
                    width="9"
                    height="14"
                    viewBox="0 0 9 14"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M 2 2 L 7 7 L 2 12"
                      stroke="#718ea9"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </span>
              </button>
            </div>

            {/* FLOATING SHADOW BENEATH */}
            <div className="floating-circle-shadow" />
          </div>
        </div>
      ) : (
        <div className="app-reveal-in" style={{ position: "relative" }}>
          {/* Subtle floating replay button in dashboard */}
          <button
            onClick={() => {
              setAuthStatus("idle");
              setIsFadingOut(false);
              setShowLoading(true);
            }}
            style={{
              position: "fixed",
              bottom: "20px",
              left: "20px",
              zIndex: 9999,
              background: "rgba(11, 31, 58, 0.85)",
              color: "#82B1FF",
              border: "1px solid rgba(130, 177, 255, 0.4)",
              borderRadius: "20px",
              padding: "6px 14px",
              fontSize: "11px",
              fontFamily: "'DM Mono', monospace",
              cursor: "pointer",
              boxShadow: "0 4px 12px rgba(0,0,0,0.2)",
              backdropFilter: "blur(8px)",
              display: "flex",
              alignItems: "center",
              gap: "6px",
              transition: "all 0.2s ease",
            }}
            title="Replay authenticating loading animation"
          >
            <span>↺</span>
            <span>View Loading Screen</span>
          </button>
          <ScreeningDashboard />
        </div>
      )}
      {isFadingOut && <div className="app-scan-sweep" aria-hidden="true" />}
    </div>
  );
}
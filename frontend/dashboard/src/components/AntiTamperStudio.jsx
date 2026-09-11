import React, { useState, useRef, useEffect } from "react";
import {
  applyElaFilter,
  applySobelFilter,
  applyHeatmapFilter,
  applyInvertFilter,
  applyUvFilter,
  applyInfraredFilter,
  applyCoaxialFilter,
} from "../utils/forensicCanvas";

export default function AntiTamperStudio() {
  const [activeFilter, setActiveFilter] = useState("uv"); // original | uv | ir | coaxial | ela | sobel | heatmap | invert
  const [tilt, setTilt] = useState({ x: 0, y: 0 });
  const [isHologramVerified, setIsHologramVerified] = useState(false);
  const [uploadedImage, setUploadedImage] = useState(null);
  const [zoomLevel, setZoomLevel] = useState(1);
  const [toast, setToast] = useState("");

  const canvasRef = useRef(null);
  const cardRef = useRef(null);

  // Render forensic filters whenever filter or image changes
  useEffect(() => {
    renderForensicCanvas();
  }, [activeFilter, uploadedImage]);

  const renderForensicCanvas = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");

    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = uploadedImage || "/mobile/icons/Icon-512.png"; // fallback or default card

    img.onload = () => {
      canvas.width = img.width || 600;
      canvas.height = img.height || 380;
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

      if (activeFilter === "uv") {
        applyUvFilter(canvas);
      } else if (activeFilter === "ir") {
        applyInfraredFilter(canvas);
      } else if (activeFilter === "coaxial") {
        applyCoaxialFilter(canvas);
      } else if (activeFilter === "ela") {
        applyElaFilter(canvas, 0.75, 18);
      } else if (activeFilter === "sobel") {
        applySobelFilter(canvas);
      } else if (activeFilter === "heatmap") {
        applyHeatmapFilter(canvas);
      } else if (activeFilter === "invert") {
        applyInvertFilter(canvas);
      }
    };
  };

  // Mouse move 3D tilt tracking for hologram inspection
  const handleMouseMove = (e) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;
    const tiltX = (y / (rect.height / 2)) * -14;
    const tiltY = (x / (rect.width / 2)) * 14;
    setTilt({ x: tiltX, y: tiltY });

    if (Math.abs(tiltX) > 8 && Math.abs(tiltY) > 8 && !isHologramVerified) {
      setIsHologramVerified(true);
    }
  };

  const handleMouseLeave = () => {
    setTilt({ x: 0, y: 0 });
  };

  const handleFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (event) => {
      setUploadedImage(event.target.result);
      setToast("New document loaded into Forensic Studio.");
      setTimeout(() => setToast(""), 3000);
    };
    reader.readAsDataURL(file);
  };

  return (
    <div className="anti-tamper-studio-root">
      <div className="page-intro">
        <div>
          <p className="eyebrow">MULTI-SPECTRAL FORENSIC SECURITY SUITE</p>
          <h1>Anti-Tampering & Multi-Spectral Lighting Studio</h1>
          <p className="intro-copy">
            Multi-spectral inspection under White Light, Ultraviolet (365nm), Infrared (850nm B900), Coaxial Glare, and Error Level Analysis.
          </p>
        </div>
        <label className="primary-button" style={{ cursor: "pointer" }}>
          <span>📁</span> Upload Document to Inspect
          <input
            type="file"
            accept="image/*"
            style={{ display: "none" }}
            onChange={handleFileUpload}
          />
        </label>
      </div>

      {toast && <div className="toast"><span>✓</span> {toast}</div>}

      <div className="tamper-studio-layout">
        {/* Left: 3D Holographic Card & Tilt Simulator */}
        <section className="studio-card-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">OPTICAL VARIABLE INK & HOLOGRAM</p>
              <h3>Kinetic Hologram & Tilt Verifier</h3>
            </div>
            <span
              className="live-pill"
              style={{
                color: isHologramVerified ? "#10b981" : "#82B1FF",
                background: isHologramVerified ? "rgba(16,185,129,0.15)" : "rgba(130,177,255,0.15)",
              }}
            >
              {isHologramVerified ? "✓ Diffraction Grating Verified" : "⌁ Move Cursor to Tilt"}
            </span>
          </div>

          <p className="panel-copy">
            Hover over the card to simulate multi-angle incident illumination and reveal kinetic guilloche patterns, embossed state emblems, and microtext.
          </p>

          <div
            className="tilt-stage-container"
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeave}
          >
            <div
              ref={cardRef}
              className="holo-card"
              style={{
                transform: `perspective(900px) rotateX(${tilt.x}deg) rotateY(${tilt.y}deg)`,
              }}
            >
              {/* Holographic Shimmer Overlay */}
              <div
                className="holo-shimmer-layer"
                style={{
                  background: `linear-gradient(${115 + tilt.y * 3}deg, rgba(255,0,128,0.3) 0%, rgba(0,255,255,0.35) 40%, rgba(255,255,0,0.3) 70%, rgba(0,255,128,0.25) 100%)`,
                  opacity: 0.65 + Math.abs(tilt.x + tilt.y) / 40,
                }}
              />

              <div className="holo-card-inner">
                <div className="card-top-row">
                  <span className="card-emblem">🛡️ SHIELD·ID SECURE</span>
                  <span className="card-chip">💳</span>
                </div>
                <div className="card-chip-graphic">
                  <div className="chip-lines" />
                </div>
                <div className="card-number-demo">8921 · 4056 · 9182 · 0042</div>
                <div className="card-bottom-row">
                  <div>
                    <small>CARDHOLDER NAME</small>
                    <strong>SAI PRADYUMNA SAMAL</strong>
                  </div>
                  <div className="holo-seal">
                    <span className="holo-seal-icon">◇</span>
                    <small>GOVT REGISTRY</small>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="hologram-status-bar">
            <div className="holo-status-item">
              <span>Diffraction Angle</span>
              <strong>{Math.round(tilt.y * 2.5)}° X / {Math.round(tilt.x * 2.5)}° Y</strong>
            </div>
            <div className="holo-status-item">
              <span>Kinetic Guilloche Integrity</span>
              <strong style={{ color: "#10b981" }}>98.4% Matched</strong>
            </div>
            <div className="holo-status-item">
              <span>Optical Variable Ink (OVI)</span>
              <strong style={{ color: "#10b981" }}>Active Refraction</strong>
            </div>
          </div>
        </section>

        {/* Right: Multi-Spectral Forensic Canvas Filters */}
        <section className="studio-canvas-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">MULTI-SPECTRAL & FORENSIC BANDS</p>
              <h3>Multi-Spectral Optical & Compression Inspector</h3>
            </div>
            <div className="zoom-controls">
              <button onClick={() => setZoomLevel((z) => Math.max(0.75, z - 0.25))}>-</button>
              <span>{Math.round(zoomLevel * 100)}%</span>
              <button onClick={() => setZoomLevel((z) => Math.min(2.5, z + 0.25))}>+</button>
            </div>
          </div>

          {/* Filter Pills */}
          <div className="filter-pill-bar" style={{ flexWrap: "wrap", gap: "6px" }}>
            {[
              { id: "uv", label: "🟣 Ultraviolet (UV 365nm)" },
              { id: "ir", label: "🔴 Infrared (IR 850nm / B900)" },
              { id: "coaxial", label: "✨ Coaxial Retro-Reflective" },
              { id: "ela", label: "🔬 Error Level (ELA)" },
              { id: "sobel", label: "📐 Sobel Edge Gradient" },
              { id: "heatmap", label: "🔥 Forgery Heatmap" },
              { id: "invert", label: "🌓 Invert Noise Floor" },
              { id: "original", label: "⚪ White Light (Visible)" },
            ].map((f) => (
              <button
                key={f.id}
                className={`filter-pill ${activeFilter === f.id ? "is-active" : ""}`}
                onClick={() => setActiveFilter(f.id)}
              >
                {f.label}
              </button>
            ))}
          </div>

          <div className="canvas-viewport-wrap">
            <div
              className="canvas-zoom-container"
              style={{ transform: `scale(${zoomLevel})` }}
            >
              <canvas ref={canvasRef} className="forensic-canvas" />
            </div>
          </div>

          {/* Filter Description Box */}
          <div className="filter-desc-card">
            {activeFilter === "uv" && (
              <p>
                <strong>Ultraviolet 365nm Spectrometry:</strong> Isolates optical brightener dead substrates, fluorescent fibers, and glowing sovereign seals invisible under standard light.
              </p>
            )}
            {activeFilter === "ir" && (
              <p>
                <strong>Infrared 850nm / B900 Ink Drop-Out:</strong> Differentiates carbon-based inks (MRZ & black portrait text) from standard dye-based inks which disappear under IR illumination.
              </p>
            )}
            {activeFilter === "coaxial" && (
              <p>
                <strong>Coaxial Retro-Reflective Glare:</strong> Verifies laminate integrity, hologram micro-prisms, and uncovers physical abrasion or razor-spliced photos.
              </p>
            )}
            {activeFilter === "ela" && (
              <p>
                <strong>Error Level Analysis (ELA):</strong> Highlights compression discrepancies and pixel modifications created during digital photo manipulation (Photoshop).
              </p>
            )}
            {activeFilter === "sobel" && (
              <p>
                <strong>Sobel Gradient Edge Detection:</strong> Maps high-frequency spatial gradients to detect artificial boundaries around portrait cutouts and altered numbers.
              </p>
            )}
            {activeFilter === "heatmap" && (
              <p>
                <strong>Thermal Forgery Heatmap:</strong> Generates a false-color representation of high-risk pixel density clusters.
              </p>
            )}
            {activeFilter === "invert" && (
              <p>
                <strong>Inverted Noise Floor:</strong> Isolates background noise distribution across the document matrix to expose clone stamp artifacts.
              </p>
            )}
            {activeFilter === "original" && (
              <p>
                <strong>White Light (Visible Spectrum 400-700nm):</strong> Standard daylight inspection showing original un-filtered color composition.
              </p>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}

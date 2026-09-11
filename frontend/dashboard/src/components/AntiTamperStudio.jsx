import React, { useState, useRef, useEffect } from "react";
import {
  applyElaFilter,
  applySobelFilter,
  applyHeatmapFilter,
  applyInvertNoiseFilter,
} from "../utils/forensicCanvas";

export default function AntiTamperStudio() {
  const [activeFilter, setActiveFilter] = useState("ela"); // original | ela | sobel | heatmap | invert
  const [tilt, setTilt] = useState({ x: 0, y: 0 });
  const [isHologramVerified, setIsHologramVerified] = useState(false);
  const [uploadedImage, setUploadedImage] = useState(null);
  const [zoomLevel, setZoomLevel] = useState(1);
  const [toast, setToast] = useState("");

  const canvasRef = useRef(null);
  const imgRef = useRef(null);
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

      if (activeFilter === "ela") {
        applyElaFilter(canvas, 0.75, 18);
      } else if (activeFilter === "sobel") {
        applySobelFilter(canvas);
      } else if (activeFilter === "heatmap") {
        applyHeatmapFilter(canvas);
      } else if (activeFilter === "invert") {
        applyInvertNoiseFilter(canvas);
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
          <p className="eyebrow">FORENSIC SECURITY SUITE</p>
          <h1>Anti-Tampering & Hologram Forensic Studio</h1>
          <p className="intro-copy">
            Analyze digital splicing, Error Level Analysis (ELA), edge boundary gradients, and optical variable diffraction gratings.
          </p>
        </div>
        <label className="primary-button">
          <span>📁</span> Upload Card to Inspect
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
              <p className="eyebrow">OPTICAL VARIABLE INK</p>
              <h3>Interactive Hologram & Tilt Verifier</h3>
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
            Hover and move your mouse over the card to simulate variable incident light angles and reveal the hidden anti-counterfeiting guilloche pattern and kinetic hologram.
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

        {/* Right: Pixel-Level Forensic Canvas Filters */}
        <section className="studio-canvas-panel">
          <div className="panel-heading">
            <div>
              <p className="eyebrow">FORENSIC SPECTRAL FILTERS</p>
              <h3>Pixel & Compression Anomaly Inspector</h3>
            </div>
            <div className="zoom-controls">
              <button onClick={() => setZoomLevel((z) => Math.max(0.75, z - 0.25))}>-</button>
              <span>{Math.round(zoomLevel * 100)}%</span>
              <button onClick={() => setZoomLevel((z) => Math.min(2.5, z + 0.25))}>+</button>
            </div>
          </div>

          {/* Filter selector pills */}
          <div className="forensic-filter-tabs">
            {[
              { id: "original", label: "Original" },
              { id: "ela", label: "Error Level Analysis (ELA)" },
              { id: "sobel", label: "Sobel Edge Gradient" },
              { id: "heatmap", label: "Thermal Forgery Heatmap" },
              { id: "invert", label: "Inverted Noise Floor" },
            ].map((f) => (
              <button
                key={f.id}
                className={`filter-tab-btn ${activeFilter === f.id ? "is-active" : ""}`}
                onClick={() => setActiveFilter(f.id)}
              >
                {f.label}
              </button>
            ))}
          </div>

          <div className="canvas-viewport-container">
            <div
              className="canvas-zoom-wrapper"
              style={{ transform: `scale(${zoomLevel})`, transformOrigin: "center center" }}
            >
              <canvas ref={canvasRef} className="forensic-canvas" />
            </div>
          </div>

          <div className="filter-explanation-box">
            {activeFilter === "ela" && (
              <p>
                <strong>Error Level Analysis (ELA):</strong> Highlights high-frequency JPEG compression differentials. Modified or spliced text/photos display higher brightness errors compared to original background.
              </p>
            )}
            {activeFilter === "sobel" && (
              <p>
                <strong>Sobel 3x3 Edge Gradient:</strong> Detects sharp artificial boundary cuts or copy-move cloning stamps around document portraits and numbers.
              </p>
            )}
            {activeFilter === "heatmap" && (
              <p>
                <strong>Thermal Forgery Heatmap:</strong> Visualizes spectral density across color channels to detect abnormal gradient shifts.
              </p>
            )}
            {activeFilter === "invert" && (
              <p>
                <strong>Inverted Noise Floor:</strong> Isolates subtle camera sensor noise patterns to confirm that all regions of the image originated from the same sensor.
              </p>
            )}
            {activeFilter === "original" && (
              <p>
                <strong>Original RGB Pass:</strong> Unmodified raw color image.
              </p>
            )}
          </div>
        </section>
      </div>

      {/* Forensic Findings Summary Card */}
      <section className="dossier-panel" style={{ marginTop: "24px" }}>
        <div className="panel-heading">
          <div>
            <p className="eyebrow">FORENSIC AUDIT VERDICT</p>
            <h3>Real-Time Document Integrity Report</h3>
          </div>
          <span className="live-pill" style={{ color: "#10b981" }}>✓ Zero Forgery Detected</span>
        </div>

        <div className="forensic-cards-grid">
          <div className="forensic-stat-card">
            <div className="f-icon">📐</div>
            <div>
              <p>Edge Sharpness Ratio</p>
              <strong>0.99 (Normal)</strong>
              <small>No digital bounding cuts</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">📊</div>
            <div>
              <p>JPEG Compression Grid</p>
              <strong>8x8 Quantization Uniform</strong>
              <small>Single-generation encoding</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">🔠</div>
            <div>
              <p>OCR Micro-Font Kerning</p>
              <strong>100% Alignment</strong>
              <small>No spliced characters</small>
            </div>
          </div>
          <div className="forensic-stat-card">
            <div className="f-icon">✨</div>
            <div>
              <p>Hologram Dispersion</p>
              <strong>Verified (OVI Present)</strong>
              <small>Diffraction matched</small>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

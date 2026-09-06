# ShieldID - AI-Based Identity & Document Screening System (Mobile)

A Google Flutter mobile frontend for **ShieldID**, designed for automated AI-powered identity and document screening.

## Key Features
- **Smart Document Viewfinder**: Animated laser scan beam with corner brackets, automatic aspect-ratio framing, and real-time glare/blur detection.
- **Multi-Document Support**: Passports (ICAO 9303 MRZ), National ID Cards, Driver's Licenses, and Residence Permits.
- **Anti-Tampering & Hologram Tilt Check**: 3D perspective simulated tilt screen to verify diffraction grating, Optical Variable Ink (OVI), microprinting, and substrate continuity.
- **Biometric 3D Face Match & Liveness**: Facial landmark mesh overlay with active anti-spoof challenges (blink, head tilt, expression) preventing screen replays and 3D mask attacks.
- **AI Neural Scan Visualizer**: High-tech concentric radar scanning animation showing live multi-phase neural extraction.
- **Comprehensive Screening Dossier**:
  - Radial confidence risk gauge (Pass, Review, Reject/Fraud)
  - Biometric side-by-side comparison with facial embedding similarity score
  - Extracted OCR credentials with confidence scores
  - Error Level Analysis (ELA) and forgery diagnostic heatmap
  - Exportable audit trail
- **Zero-Config Interactive Testing**: Built-in mock simulation engine switchable directly to live ShieldID Python backend (`http://localhost:8000`).

## Running the Application
```bash
cd frontend/mobile
flutter pub get
flutter run
```

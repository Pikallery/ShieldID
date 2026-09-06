# Models Directory

This directory contains trained models, pre-trained weights, and calibration benchmarks used by ShieldID AI processors:

- `models/easyocr/`: Model storage directory for EasyOCR text detection and recognition weights (`craft_mlt_25k.pth`, language recognition models).
- `models/currency/benchmarks.json`: Denomination benchmarks, HSV color specifications, and security feature thresholds for Indian Banknotes (₹10, ₹50, ₹100, ₹200, ₹500).
# ShieldID AI Model Artifacts

This directory houses pre-trained model checkpoints, weights, neural architecture configurations, and cascade classifiers utilized by ShieldID inference processors.

## Directory Structure

```text
models/
├── tampering/
│   └── tamper_config.json        # CNN/ResNet ensemble weights & detection thresholds
└── face/
    └── facenet_weights.json      # 128-d FaceNet embedding configurations & liveness thresholds
```

## Load Mechanisms

- **TamperingProcessor (`src/processors/tampering/processor.py`)**: Automatically resolves weights from `models/tampering/` or custom `model_path`. Fallbacks gracefully to heuristic computer vision signal processing if deep learning weights are absent.
- **FaceProcessor (`src/processors/face/processor.py`)**: Loads FaceNet embedding parameters from `models/face/` and applies calibrated cosine similarity thresholds.

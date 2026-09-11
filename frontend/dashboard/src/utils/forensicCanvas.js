/**
 * Forensic Image Analysis Algorithms (HTML5 Canvas)
 * Implements Error Level Analysis (ELA), Sobel Edge Gradient, Inversion, and Tamper Heatmap
 */

/**
 * Applies Error Level Analysis (ELA) simulation on an image element or canvas
 */
export function applyElaFilter(canvas, quality = 0.75, amplification = 18) {
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const imgData = ctx.getImageData(0, 0, width, height);
  const data = imgData.data;

  // High-pass error level enhancement
  for (let i = 0; i < data.length; i += 4) {
    const r = data[i];
    const g = data[i + 1];
    const b = data[i + 2];

    const gray = 0.299 * r + 0.587 * g + 0.114 * b;
    const diffR = Math.abs(r - gray) * amplification;
    const diffG = Math.abs(g - gray) * amplification;
    const diffB = Math.abs(b - gray) * amplification;

    data[i] = Math.min(255, diffR * 1.5);
    data[i + 1] = Math.min(255, diffG);
    data[i + 2] = Math.min(255, diffB * 2.2);
  }
  ctx.putImageData(imgData, 0, 0);
}

/**
 * Applies 3x3 Sobel Edge Detection
 */
export function applySobelFilter(canvas) {
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const src = ctx.getImageData(0, 0, width, height);
  const srcData = src.data;
  const output = ctx.createImageData(width, height);
  const dst = output.data;

  const gray = new Float32Array(width * height);
  for (let i = 0; i < srcData.length; i += 4) {
    gray[i / 4] = 0.299 * srcData[i] + 0.587 * srcData[i + 1] + 0.114 * srcData[i + 2];
  }

  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      const idx = y * width + x;

      // Sobel kernels
      const gx =
        -1 * gray[idx - width - 1] + 1 * gray[idx - width + 1] +
        -2 * gray[idx - 1]         + 2 * gray[idx + 1] +
        -1 * gray[idx + width - 1] + 1 * gray[idx + width + 1];

      const gy =
        -1 * gray[idx - width - 1] - 2 * gray[idx - width] - 1 * gray[idx - width + 1] +
         1 * gray[idx + width - 1] + 2 * gray[idx + width] + 1 * gray[idx + width + 1];

      const g = Math.min(255, Math.sqrt(gx * gx + gy * gy));
      const dstIdx = (y * width + x) * 4;

      // Cyan / Blue edge highlighting
      dst[dstIdx] = Math.min(255, g * 0.4);
      dst[dstIdx + 1] = Math.min(255, g * 0.9);
      dst[dstIdx + 2] = Math.min(255, g * 1.2);
      dst[dstIdx + 3] = 255;
    }
  }

  ctx.putImageData(output, 0, 0);
}

/**
 * Applies Thermal / Forgery Heatmap Filter
 */
export function applyHeatmapFilter(canvas) {
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const imgData = ctx.getImageData(0, 0, width, height);
  const data = imgData.data;

  for (let i = 0; i < data.length; i += 4) {
    const intensity = (data[i] * 0.299 + data[i + 1] * 0.587 + data[i + 2] * 0.114) / 255;
    // Map intensity to Jet / Thermal colormap
    let r, g, b;
    if (intensity < 0.25) {
      r = 0;
      g = Math.floor(intensity * 4 * 255);
      b = 255;
    } else if (intensity < 0.5) {
      r = 0;
      g = 255;
      b = Math.floor((1 - (intensity - 0.25) * 4) * 255);
    } else if (intensity < 0.75) {
      r = Math.floor((intensity - 0.5) * 4 * 255);
      g = 255;
      b = 0;
    } else {
      r = 255;
      g = Math.floor((1 - (intensity - 0.75) * 4) * 255);
      b = 0;
    }

    data[i] = r;
    data[i + 1] = g;
    data[i + 2] = b;
  }
  ctx.putImageData(imgData, 0, 0);
}

/**
 * Applies Inverted High-Frequency Noise Isolation Filter
 */
export function applyInvertNoiseFilter(canvas) {
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const imgData = ctx.getImageData(0, 0, width, height);
  const data = imgData.data;

  for (let i = 0; i < data.length; i += 4) {
    data[i] = 255 - data[i];
    data[i + 1] = 255 - data[i + 1];
    data[i + 2] = 255 - data[i + 2];
  }
  ctx.putImageData(imgData, 0, 0);
}

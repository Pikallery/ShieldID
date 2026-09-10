# Currency Processing

ShieldID keeps currency verification headless and service-friendly. The production path is `src/processors/currency/processor.py`; exploratory notebooks are not required at runtime.

## Pipeline

1. Load and normalize the uploaded image.
2. Detect the banknote boundary and rectify it to a canonical 1000x440 image.
3. Estimate the denomination using color and aspect-ratio benchmarks.
4. Inspect watermark, security thread, microprinting, and substrate signals.
5. Optionally compare a region against a trusted denomination template with ORB and structural similarity.
6. Return a validated `CurrencyVerificationResult` with confidence and reasons.

## Template comparison

The reusable notebook logic is available through `CurrencyProcessor.compare_with_template(reference, query)`. Both arguments are OpenCV BGR or grayscale arrays. It returns:

- `ssim_score`: structural similarity in the range 0 to 1.
- `matched_keypoints`: ratio-tested ORB matches.
- `inlier_matches`: geometrically consistent matches after RANSAC.
- `homography_found`: whether a valid perspective relationship was found.
- `is_similar`: conservative combined decision.

Trusted reference templates should be supplied by denomination and stored outside Git when they come from a licensed dataset. Do not hard-code Kaggle paths or commit downloaded datasets to the repository.

## Notebook migration rule

The supplied notebooks are useful experiments, but their Tkinter UI, `%store` state, fixed `/kaggle/input` paths, and plotting calls do not belong in the API process. Their reusable computer-vision logic has been extracted into the processor package and tested with synthetic images.

For a local experiment, load an image explicitly and pass the resulting arrays to the processor. For production, call the processor from the service layer and persist only the structured result and approved diagnostic artifacts.

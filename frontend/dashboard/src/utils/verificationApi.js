const API_BASE_URL =
  (typeof window !== "undefined" && window.SHIELDID_API_URL)
    ? window.SHIELDID_API_URL
    : (import.meta.env?.VITE_API_URL || "https://shieldid-api.onrender.com");

export async function verifyDocument(documentFile, selfieFile = null, options = {}) {
  const {
    frontFile = null,
    backFile = null,
    documentType = "passport",
  } = options;

  const primaryDocument = frontFile || documentFile;
  const useMultiDocumentFlow = Boolean(frontFile || backFile || selfieFile);

  const formData = new FormData();

  if (primaryDocument) {
    formData.append("front_image", primaryDocument);
    if (!frontFile && documentFile) {
      formData.append("document", documentFile);
    }
  }

  if (backFile) {
    formData.append("back_image", backFile);
  }

  if (selfieFile) {
    formData.append("selfie", selfieFile);
    formData.append("selfie_image", selfieFile);
  }

  if (documentFile && !frontFile && !backFile && !selfieFile) {
    formData.append("document", documentFile);
  }

  if (documentType) {
    formData.append("document_type", documentType);
  }

  const endpoint = useMultiDocumentFlow
    ? `${API_BASE_URL}/api/v1/verify/full-screening`
    : `${API_BASE_URL}/api/v1/verify/document`;

  const response = await fetch(endpoint, {
    method: "POST",
    body: formData,
  });

  if (!response.ok) {
    throw new Error(`Verification failed with status ${response.status}`);
  }

  return response.json();
}
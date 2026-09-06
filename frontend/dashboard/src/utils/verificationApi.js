const API_BASE_URL =
  typeof window !== "undefined" && window.SHIELDID_API_URL
    ? window.SHIELDID_API_URL
    : "http://localhost:8080";

export async function verifyDocument(documentFile, selfieFile) {
  const formData = new FormData();
  formData.append("document", documentFile);

  if (selfieFile) {
    formData.append("selfie", selfieFile);
  }

  const response = await fetch(`${API_BASE_URL}/api/v1/verify/document`, {
    method: "POST",
    body: formData,
  });

  if (!response.ok) {
    throw new Error(`Verification failed with status ${response.status}`);
  }

  return response.json();
}
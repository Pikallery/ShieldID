/**
 * DigiLocker Issuer API v1.13 XML PullURI Generator & Parser (Ported from Flutter Mobile)
 */

export function generateDigiLockerXml({
  name = "SAI PRADYUMNA SAMAL",
  docType = "AADHAAR",
  docNumber = "XXXX-XXXX-8921",
  dob = "14/08/2002",
  gender = "Male",
  status = "0", // 0 = Valid / Success
  orgId = "in.gov.uidai",
  txnId = null,
}) {
  const ts = new Date().toISOString();
  const txn = txnId || `DL-TXN-${Date.now()}`;
  const statusLabel = status === "0" ? "VERIFIED_GENUINE" : "FAILED_VALIDATION";
  const signatureStatus = status === "0" ? "VALID_DIGITAL_SIGNATURE_CCA" : "SIGNATURE_INVALID";
  const digiLockerId = `DL-IN-${Math.floor(10000000 + Math.random() * 90000000)}-${orgId}`;

  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<PullURIResponse xmlns:ns2="http://tempuri.org/">
  <ResponseStatus Status="${status}" ts="${ts}" txn="${txn}">${statusLabel}</ResponseStatus>
  <DocDetails>
    <DocType>${docType.toUpperCase()}</DocType>
    <DigiLockerId>${digiLockerId}</DigiLockerId>
    <OrgId>${orgId}</OrgId>
    <IssuedTo>
      <Persons>
        <Person name="${name}" dob="${dob}" gender="${gender}">
          <SignatureStatus>${signatureStatus}</SignatureStatus>
          <DocumentNumber>${docNumber}</DocumentNumber>
          <IssuerCertificate>
            <CertID>CCA-INDIA-ROOT-CA-G3</CertID>
            <Status>ACTIVE_VALID</Status>
            <Algorithm>SHA256withRSA-2048</Algorithm>
          </IssuerCertificate>
        </Person>
      </Persons>
    </IssuedTo>
  </DocDetails>
</PullURIResponse>`;
}

export function parseDigiLockerXml(xmlString) {
  if (!xmlString) return null;
  const matchStatus = xmlString.match(/Status="([^"]+)"/);
  const matchTxn = xmlString.match(/txn="([^"]+)"/);
  const matchDocType = xmlString.match(/<DocType>([^<]+)<\/DocType>/);
  const matchDigiLockerId = xmlString.match(/<DigiLockerId>([^<]+)<\/DigiLockerId>/);
  const matchOrgId = xmlString.match(/<OrgId>([^<]+)<\/OrgId>/);
  const matchPerson = xmlString.match(/<Person name="([^"]+)" dob="([^"]+)" gender="([^"]+)">/);
  const matchSignature = xmlString.match(/<SignatureStatus>([^<]+)<\/SignatureStatus>/);
  const matchDocNum = xmlString.match(/<DocumentNumber>([^<]+)<\/DocumentNumber>/);

  return {
    status: matchStatus ? matchStatus[1] : "0",
    isVerified: matchStatus ? matchStatus[1] === "0" : true,
    txn: matchTxn ? matchTxn[1] : "",
    docType: matchDocType ? matchDocType[1] : "",
    digiLockerId: matchDigiLockerId ? matchDigiLockerId[1] : "",
    orgId: matchOrgId ? matchOrgId[1] : "",
    name: matchPerson ? matchPerson[1] : "",
    dob: matchPerson ? matchPerson[2] : "",
    gender: matchPerson ? matchPerson[3] : "",
    signatureStatus: matchSignature ? matchSignature[1] : "VALID",
    docNumber: matchDocNum ? matchDocNum[1] : "",
  };
}

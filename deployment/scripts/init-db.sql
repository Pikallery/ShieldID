-- deployment/scripts/init-db.sql
-- ⚠️ OWNER: Dev 1 - Initial database setup ⚠️
-- This script runs automatically when the PostgreSQL container starts for the first time.

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create the verifications table
CREATE TABLE IF NOT EXISTS verifications (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(50) NOT NULL,
    risk_score FLOAT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    location_lat FLOAT,
    location_lng FLOAT,
    timestamp TIMESTAMP DEFAULT NOW(),
    extracted_data JSONB NOT NULL,
    tamper_result JSONB
);

-- Create the reports table
CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    fir_number VARCHAR(50) UNIQUE NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    description VARCHAR(500) NOT NULL,
    reporter_name VARCHAR(100),
    reporter_phone VARCHAR(15),
    location_lat FLOAT,
    location_lng FLOAT,
    status VARCHAR(20) DEFAULT 'pending',
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_verifications_status ON verifications(status);
CREATE INDEX IF NOT EXISTS idx_verifications_risk ON verifications(risk_score);
CREATE INDEX IF NOT EXISTS idx_verifications_timestamp ON verifications(timestamp);
CREATE INDEX IF NOT EXISTS idx_verifications_doc_number ON verifications(document_number);
CREATE INDEX IF NOT EXISTS idx_reports_fir ON reports(fir_number);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_timestamp ON reports(timestamp);

-- Log success
DO $$
BEGIN
    RAISE NOTICE '✅ ShieldID database initialized successfully';
END $$;

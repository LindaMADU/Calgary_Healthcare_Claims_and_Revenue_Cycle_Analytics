CREATE DATABASE calgary_healthcare;

CREATE SCHEMA staging;

CREATE SCHEMA healthcare;

--- To create the staging 

CREATE TABLE staging.patients (
    patient_id TEXT,
    gender TEXT,
    birth_year TEXT,
    age TEXT,
    postal_prefix TEXT,
    health_zone TEXT
);

CREATE TABLE staging.hospitals (
    hospital_id TEXT,
    hospital_name TEXT,
    facility_type TEXT,
    health_zone TEXT
);

CREATE TABLE staging.providers (
    provider_id TEXT,
    specialty TEXT,
    department TEXT,
    hospital_id TEXT
);

CREATE TABLE staging.encounters (
    encounter_id TEXT,
    patient_id TEXT,
    hospital_id TEXT,
    provider_id TEXT,
    encounter_type TEXT,
    admission_date TEXT,
    discharge_date TEXT,
    department TEXT,
    diagnosis_code TEXT,
    procedure_code TEXT,
    length_of_stay TEXT
);

CREATE TABLE staging.claims (
    claim_id TEXT,
    encounter_id TEXT,
    claim_date TEXT,
    claim_type TEXT,
    service_code TEXT,
    billed_amount TEXT,
    approved_amount TEXT,
    paid_amount TEXT,
    claim_status TEXT,
    denial_code TEXT,
    processing_days TEXT,
    payment_date TEXT
);

CREATE TABLE staging.claim_transactions (
    transaction_id TEXT,
    claim_id TEXT,
    transaction_date TEXT,
    transaction_type TEXT,
    billed_amount TEXT,
    adjustment_amount TEXT,
    paid_amount TEXT
);

CREATE TABLE staging.denial_reasons (
    denial_code TEXT,
    denial_reason TEXT,
    category TEXT
);


--- To create schema for patients

CREATE TABLE healthcare.patients (
    patient_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(20),
    birth_year INTEGER,
    age INTEGER,
    postal_prefix VARCHAR(10),
    health_zone VARCHAR(50)
);



--- Creating schema for Hospitals

CREATE TABLE healthcare.hospitals (
    hospital_id VARCHAR(20) PRIMARY KEY,
    hospital_name VARCHAR(150) NOT NULL,
    facility_type VARCHAR(50),
    health_zone VARCHAR(50)
);



CREATE TABLE healthcare.providers (
    provider_id VARCHAR(20) PRIMARY KEY,
    specialty VARCHAR(100),
    department VARCHAR(100),
    hospital_id VARCHAR(20),

    CONSTRAINT fk_provider_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES healthcare.hospitals(hospital_id)
);




CREATE TABLE healthcare.encounters (
    encounter_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20) NOT NULL,
    hospital_id VARCHAR(20) NOT NULL,
    provider_id VARCHAR(20),
    encounter_type VARCHAR(50),
    admission_date DATE,
    discharge_date DATE,
    department VARCHAR(100),
    diagnosis_code VARCHAR(20),
    procedure_code VARCHAR(30),
    length_of_stay INTEGER,

    CONSTRAINT fk_encounter_patient
        FOREIGN KEY (patient_id)
        REFERENCES healthcare.patients(patient_id),

    CONSTRAINT fk_encounter_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES healthcare.hospitals(hospital_id),

    CONSTRAINT fk_encounter_provider
        FOREIGN KEY (provider_id)
        REFERENCES healthcare.providers(provider_id)
);




CREATE TABLE healthcare.claims (
    claim_id VARCHAR(20) PRIMARY KEY,
    encounter_id VARCHAR(20) NOT NULL,
    claim_date DATE,
    claim_type VARCHAR(50),
    service_code VARCHAR(30),

    billed_amount NUMERIC(12,2),
    approved_amount NUMERIC(12,2),
    paid_amount NUMERIC(12,2),

    claim_status VARCHAR(30),
    denial_code VARCHAR(10),

    processing_days INTEGER,
    payment_date DATE,

    CONSTRAINT fk_claim_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES healthcare.encounters(encounter_id)
);



CREATE TABLE healthcare.claims (
    claim_id VARCHAR(20) PRIMARY KEY,
    encounter_id VARCHAR(20) NOT NULL,
    claim_date DATE,
    claim_type VARCHAR(50),
    service_code VARCHAR(30),

    billed_amount NUMERIC(12,2),
    approved_amount NUMERIC(12,2),
    paid_amount NUMERIC(12,2),

    claim_status VARCHAR(30),
    denial_code VARCHAR(10),

    processing_days INTEGER,
    payment_date DATE,

    CONSTRAINT fk_claim_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES healthcare.encounters(encounter_id)
);




CREATE TABLE healthcare.claim_transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    claim_id VARCHAR(20) NOT NULL,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    billed_amount NUMERIC(12,2),
    adjustment_amount NUMERIC(12,2),
    paid_amount NUMERIC(12,2),

    CONSTRAINT fk_transaction_claim
        FOREIGN KEY (claim_id)
        REFERENCES healthcare.claims(claim_id)
);




CREATE TABLE healthcare.denial_reasons (
    denial_code VARCHAR(10) PRIMARY KEY,
    denial_reason VARCHAR(150),
    category VARCHAR(50)
);



--- Next, move from staging to production

INSERT INTO healthcare.patients (
    patient_id,
    gender,
    birth_year,
    age,
    postal_prefix,
    health_zone
)
SELECT
    patient_id,
    gender,
    CAST(birth_year AS INTEGER),
    CAST(age AS INTEGER),
    postal_prefix,
    health_zone
FROM staging.patients;


INSERT INTO healthcare.hospitals
SELECT
    hospital_id,
    hospital_name,
    facility_type,
    health_zone
FROM staging.hospitals;



INSERT INTO healthcare.providers
SELECT
    provider_id,
    specialty,
    department,
    hospital_id
FROM staging.providers;



INSERT INTO healthcare.encounters (
    encounter_id,
    patient_id,
    hospital_id,
    provider_id,
    encounter_type,
    admission_date,
    discharge_date,
    department,
    diagnosis_code,
    procedure_code,
    length_of_stay
)
SELECT
    encounter_id,
    patient_id,
    hospital_id,
    provider_id,
    encounter_type,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE),
    department,
    diagnosis_code,
    procedure_code,
    CAST(length_of_stay AS INTEGER)
FROM staging.encounters;




INSERT INTO healthcare.claims (
    claim_id,
    encounter_id,
    claim_date,
    claim_type,
    service_code,
    billed_amount,
    approved_amount,
    paid_amount,
    claim_status,
    denial_code,
    processing_days,
    payment_date
)
SELECT
    claim_id,
    encounter_id,
    CAST(claim_date AS DATE),
    claim_type,
    service_code,
    CAST(billed_amount AS NUMERIC(12,2)),
    CAST(approved_amount AS NUMERIC(12,2)),
    CAST(paid_amount AS NUMERIC(12,2)),
    claim_status,
    denial_code,
    CAST(processing_days AS INTEGER),
    CAST(payment_date AS DATE)
FROM staging.claims;




INSERT INTO healthcare.denial_reasons
SELECT
    denial_code,
    denial_reason,
    category
FROM staging.denial_reasons;


--- To perform necessary data validations after loading

SELECT COUNT(*)
FROM healthcare.patients;


SELECT COUNT(*)
FROM healthcare.encounters;


SELECT COUNT(*)
FROM healthcare.claims;


--- Then check for data integrity
--- for the patient dataset (finding claims without encoutners)

SELECT c.*
FROM healthcare.claims c
LEFT JOIN healthcare.encounters e
    ON c.encounter_id = e.encounter_id
WHERE e.encounter_id IS NULL;


--- for the encounters dataset 

SELECT e.*
FROM healthcare.encounters e
LEFT JOIN healthcare.patients p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


--- To verify the financial data (ie, billed amount, approved amount, and paid amount )

SELECT
    SUM(billed_amount) AS total_billed,
    SUM(approved_amount) AS total_approved,
    SUM(paid_amount) AS total_paid
FROM healthcare.claims;


--- Check for the gap in revenue
SELECT
    SUM(billed_amount - paid_amount)
        AS simulated_revenue_gap
FROM healthcare.claims;


--- To create an analytical view for power bi visualization

CREATE VIEW healthcare.claims_analytics AS

SELECT
    c.claim_id,
    c.claim_date,
    c.claim_type,
    c.service_code,
    c.billed_amount,
    c.approved_amount,
    c.paid_amount,
    c.claim_status,
    c.denial_code,
    c.processing_days,

    e.encounter_type,
    e.department,
    e.diagnosis_code,

    h.hospital_name,
    h.facility_type,

    p.specialty

FROM healthcare.claims c

JOIN healthcare.encounters e
    ON c.encounter_id = e.encounter_id

JOIN healthcare.hospitals h
    ON e.hospital_id = h.hospital_id

LEFT JOIN healthcare.providers p
    ON e.provider_id = p.provider_id;



--- To check the claims_analytics
SELECT *
FROM healthcare.claims_analytics
LIMIT 10;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'healthcare'
  AND table_name = 'claims_analytics'
ORDER BY ordinal_position;


--- monthly claims trend

CREATE OR REPLACE VIEW healthcare.claim_trends AS

WITH monthly_claims AS (
    SELECT
        DATE_TRUNC('month', claim_date)::date AS claim_month,
        COUNT(*) AS total_claims,
        SUM(billed_amount) AS total_billed,
        SUM(approved_amount) AS total_approved,
        SUM(paid_amount) AS total_paid
    FROM healthcare.claims_analytics
    GROUP BY 1
)

SELECT
    claim_month,
    total_claims,
    total_billed,
    total_approved,
    total_paid,
    total_billed - total_paid AS revenue_leakage,

    ROUND(
        total_paid / NULLIF(total_billed, 0) * 100,
        2
    ) AS reimbursement_rate

FROM monthly_claims
ORDER BY claim_month;


--- To derive 10 high-value claims using (windows function)

CREATE OR REPLACE VIEW healthcare.high_value_claims AS

SELECT
    claim_id,
    claim_date,
    hospital_name,
    department,
    claim_type,
    billed_amount,
    approved_amount,
    paid_amount,

    RANK() OVER (
        ORDER BY billed_amount DESC
    ) AS claim_rank,

    SUM(billed_amount) OVER () AS total_billed,

    ROUND(
        billed_amount /
        NULLIF(SUM(billed_amount) OVER (), 0) * 100,
        2
    ) AS percent_of_total_billed

FROM healthcare.claims_analytics;



--- To perform Revenue analysis

CREATE OR REPLACE VIEW healthcare.revenue_analysis AS

SELECT
    hospital_name,
    department,

    COUNT(*) AS total_claims,

    SUM(billed_amount) AS total_billed,

    SUM(approved_amount) AS total_approved,

    SUM(paid_amount) AS total_paid,

    SUM(billed_amount - approved_amount)
        AS approval_gap,

    SUM(billed_amount - paid_amount)
        AS revenue_leakage,

    ROUND(
        SUM(paid_amount) /
        NULLIF(SUM(billed_amount), 0) * 100,
        2
    ) AS reimbursement_rate

FROM healthcare.claims_analytics

GROUP BY
    hospital_name,
    department;



--- For Denial analysis


CREATE OR REPLACE VIEW healthcare.denial_analysis AS

SELECT
    c.denial_code,
    d.denial_reason,
    d.category AS denial_category,
    c.hospital_name,
    c.department,

    COUNT(*) AS denied_claims,

    SUM(c.billed_amount) AS denied_billed_amount,

    SUM(c.billed_amount - c.paid_amount)
        AS potential_revenue_loss,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_denials

FROM healthcare.claims_analytics c

LEFT JOIN healthcare.denial_reasons d
    ON c.denial_code = d.denial_code

WHERE c.claim_status IN ('Denied', 'Rejected')

GROUP BY
    c.denial_code,
    d.denial_reason,
    d.category,
    c.hospital_name,
    c.department;




CREATE OR REPLACE VIEW healthcare.claims_kpi AS

SELECT

    COUNT(*) AS total_claims,

    SUM(billed_amount) AS total_billed,

    SUM(approved_amount) AS total_approved,

    SUM(paid_amount) AS total_paid,

    SUM(billed_amount - paid_amount)
        AS revenue_leakage,

    ROUND(
        SUM(paid_amount) /
        NULLIF(SUM(billed_amount), 0) * 100,
        2
    ) AS reimbursement_rate,

    ROUND(
        COUNT(*) FILTER (
            WHERE claim_status IN ('Denied', 'Rejected')
        ) * 100.0 / COUNT(*),
        2
    ) AS denial_rate,

    ROUND(
        AVG(processing_days),
        2
    ) AS avg_processing_days,

    COUNT(*) FILTER (
        WHERE claim_status = 'Pending'
    ) AS pending_claims

FROM healthcare.claims_analytics;





CREATE OR REPLACE VIEW healthcare.department_analysis AS

SELECT
    department,

    COUNT(*) AS total_claims,

    SUM(billed_amount) AS total_billed,

    SUM(paid_amount) AS total_paid,

    SUM(billed_amount - paid_amount)
        AS revenue_leakage,

    ROUND(
        AVG(processing_days),
        2
    ) AS avg_processing_days,

    ROUND(
        COUNT(*) FILTER (
            WHERE claim_status IN ('Denied', 'Rejected')
        ) * 100.0 / COUNT(*),
        2
    ) AS denial_rate

FROM healthcare.claims_analytics

GROUP BY department;



--- Claims Aging

CREATE OR REPLACE VIEW healthcare.claim_aging AS

SELECT
    claim_id,
    claim_date,
    hospital_name,
    department,
    claim_status,
    billed_amount,
    paid_amount,
    processing_days,

    CASE
        WHEN processing_days <= 7
            THEN '0-7 Days'

        WHEN processing_days <= 14
            THEN '8-14 Days'

        WHEN processing_days <= 30
            THEN '15-30 Days'

        ELSE '31+ Days'
    END AS aging_bucket

FROM healthcare.claims_analytics;



--- To perform necessary data quality checks

CREATE OR REPLACE VIEW healthcare.data_quality AS

SELECT

    COUNT(*) AS total_claims,

    COUNT(*) FILTER (
        WHERE claim_id IS NULL
    ) AS missing_claim_id,

    COUNT(*) FILTER (
        WHERE billed_amount IS NULL
    ) AS missing_billed_amount,

    COUNT(*) FILTER (
        WHERE paid_amount IS NULL
    ) AS missing_paid_amount,

    COUNT(*) FILTER (
        WHERE billed_amount < 0
    ) AS negative_billed_amount,

    COUNT(*) FILTER (
        WHERE paid_amount < 0
    ) AS negative_paid_amount,

    COUNT(*) FILTER (
        WHERE paid_amount > billed_amount
    ) AS paid_greater_than_billed,

    COUNT(*) FILTER (
        WHERE approved_amount > billed_amount
    ) AS approved_greater_than_billed,

    COUNT(*) FILTER (
        WHERE processing_days < 0
    ) AS negative_processing_days,

    COUNT(*) FILTER (
        WHERE claim_status IN ('Denied', 'Rejected')
        AND denial_code IS NULL
    ) AS missing_denial_code

FROM healthcare.claims_analytics;




--- For monthly claims trend

CREATE OR REPLACE VIEW healthcare.claim_trends AS

WITH monthly_claims AS (
    SELECT
        DATE_TRUNC('month', claim_date)::date AS claim_month,
        COUNT(*) AS total_claims,
        SUM(billed_amount) AS total_billed,
        SUM(approved_amount) AS total_approved,
        SUM(paid_amount) AS total_paid
    FROM healthcare.claims_analytics
    GROUP BY DATE_TRUNC('month', claim_date)
)

SELECT
    claim_month,
    total_claims,
    total_billed,
    total_approved,
    total_paid,

    total_billed - total_paid AS revenue_leakage,

    ROUND(
        total_paid / NULLIF(total_billed, 0) * 100,
        2
    ) AS reimbursement_rate

FROM monthly_claims
ORDER BY claim_month;



CREATE OR REPLACE VIEW healthcare.high_value_claims AS

SELECT
    claim_id,
    claim_date,
    hospital_name,
    department,
    claim_type,
    billed_amount,
    approved_amount,
    paid_amount,

    RANK() OVER (
        ORDER BY billed_amount DESC
    ) AS claim_rank,

    SUM(billed_amount) OVER () AS total_billed,

    ROUND(
        billed_amount /
        NULLIF(SUM(billed_amount) OVER (), 0) * 100,
        2
    ) AS percent_of_total_billed

FROM healthcare.claims_analytics;







CREATE OR REPLACE VIEW healthcare.encounter_analytics AS

SELECT
    e.encounter_id,
    e.patient_id,
    e.hospital_id,
    e.provider_id,
    e.encounter_type,
    e.admission_date,
    e.discharge_date,
    e.length_of_stay,
    e.department,
    e.diagnosis_code,
    e.procedure_code,

    h.hospital_name,
    h.facility_type,

    p.specialty

FROM healthcare.encounters e

JOIN healthcare.hospitals h
    ON e.hospital_id::text = h.hospital_id::text

LEFT JOIN healthcare.providers p
    ON e.provider_id::text = p.provider_id::text;




UPDATE healthcare.encounters
SET discharge_date =
    admission_date + (FLOOR(RANDOM() * 7) + 1)::integer
WHERE encounter_type = 'Inpatient'
  AND admission_date IS NOT NULL
  AND discharge_date IS NULL;



--- To calculate the length of stay

UPDATE healthcare.encounters
SET length_of_stay =
    discharge_date - admission_date
WHERE admission_date IS NOT NULL
  AND discharge_date IS NOT NULL
  AND length_of_stay IS NULL;







UPDATE healthcare.encounters
SET procedure_code =
    CASE
        WHEN department = 'Cardiology' AND encounter_type = 'Inpatient'
            THEN 'CAR-IP'
        WHEN department = 'Cardiology' AND encounter_type = 'Outpatient'
            THEN 'CAR-OP'
        WHEN department = 'Cardiology' AND encounter_type = 'Emergency'
            THEN 'CAR-ER'
        WHEN department = 'Cardiology' AND encounter_type = 'Diagnostic Imaging'
            THEN 'CAR-IMG'
        WHEN department = 'Cardiology' AND encounter_type = 'Day Surgery'
            THEN 'CAR-SUR'

        WHEN department = 'Emergency' AND encounter_type = 'Inpatient'
            THEN 'ER-IP'
        WHEN department = 'Emergency' AND encounter_type = 'Outpatient'
            THEN 'ER-OP'
        WHEN department = 'Emergency' AND encounter_type = 'Emergency'
            THEN 'ER-ER'
        WHEN department = 'Emergency' AND encounter_type = 'Diagnostic Imaging'
            THEN 'ER-IMG'
        WHEN department = 'Emergency' AND encounter_type = 'Day Surgery'
            THEN 'ER-SUR'

        WHEN department = 'General Medicine' AND encounter_type = 'Inpatient'
            THEN 'GM-IP'
        WHEN department = 'General Medicine' AND encounter_type = 'Outpatient'
            THEN 'GM-OP'
        WHEN department = 'General Medicine' AND encounter_type = 'Emergency'
            THEN 'GM-ER'
        WHEN department = 'General Medicine' AND encounter_type = 'Diagnostic Imaging'
            THEN 'GM-IMG'
        WHEN department = 'General Medicine' AND encounter_type = 'Day Surgery'
            THEN 'GM-SUR'

        WHEN department = 'Radiology' AND encounter_type = 'Diagnostic Imaging'
            THEN 'RAD-IMG'
        WHEN department = 'Radiology' AND encounter_type = 'Outpatient'
            THEN 'RAD-OP'
        WHEN department = 'Radiology' AND encounter_type = 'Emergency'
            THEN 'RAD-ER'
        WHEN department = 'Radiology' AND encounter_type = 'Inpatient'
            THEN 'RAD-IP'
        WHEN department = 'Radiology' AND encounter_type = 'Day Surgery'
            THEN 'RAD-SUR'

        WHEN department = 'Surgery' AND encounter_type = 'Day Surgery'
            THEN 'SUR-DAY'
        WHEN department = 'Surgery' AND encounter_type = 'Inpatient'
            THEN 'SUR-IP'
        WHEN department = 'Surgery' AND encounter_type = 'Outpatient'
            THEN 'SUR-OP'
        WHEN department = 'Surgery' AND encounter_type = 'Emergency'
            THEN 'SUR-ER'
        WHEN department = 'Surgery' AND encounter_type = 'Diagnostic Imaging'
            THEN 'SUR-IMG'

        ELSE 'OTHER'
    END
WHERE procedure_code IS NULL;




SELECT
    encounter_id,
    encounter_type,
    admission_date,
    discharge_date,
    length_of_stay,
    procedure_code,
    department,
    hospital_name
FROM healthcare.encounter_analytics
LIMIT 10;


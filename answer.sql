-- Get total payments
WITH invoice_payments AS (
  SELECT
    document_id,
    SUM(amount_paid) AS total_paid
  FROM `apt-memento-466113-j6.littlelives.payments`
  WHERE document_type = 'invoice'
  GROUP BY document_id
),

-- Join invoices with their payments and compute aging
-- Assuming invoice id is unique  
invoice_ageging AS (
  SELECT
    iv.centre_id,
    iv.class_id,
    iv.id AS document_id,
    iv.invoice_date AS document_date,
    iv.student_id,
    iv.total_amount,
    'invoice'  AS document_type,
    COALESCE(p.total_paid, 0) AS amount_paid,
    iv.total_amount - COALESCE(p.total_paid, 0) AS unpaid_amount, -- with each unique invoice, unpaid amount is total amount minus total paid
    DATE_DIFF('2025-07-07', iv.invoice_date, DAY) AS age_in_days -- number of days since the invoice date as as '2025-07-07'
  FROM `apt-memento-466113-j6.littlelives.invoices` iv
  LEFT JOIN invoice_payments p ON iv.id = p.document_id
  WHERE iv.total_amount - COALESCE(p.total_paid, 0) > 0 -- filter to only include unpaid invoices 
),

-- -- Get total payments
cr_payments AS (
  SELECT
    document_id,
    SUM(amount_paid) AS total_paid
  FROM `apt-memento-466113-j6.littlelives.payments`
  WHERE document_type = 'credit_note'
  GROUP BY document_id
),

-- Assuming cr id is unique  
cr_ageging AS (
  SELECT
    cr.centre_id,
    cr.class_id,
    cr.id AS document_id,
    cr.credit_note_date AS document_date,
    cr.student_id,
    cr.total_amount,
    'credit_note' AS document_type,
    COALESCE(p.total_paid, 0) AS amount_paid,
    cr.total_amount - COALESCE(p.total_paid, 0) AS unpaid_amount, 
    DATE_DIFF('2025-07-07', cr.credit_note_date, DAY) AS age_in_days
  FROM `apt-memento-466113-j6.littlelives.credit_notes` cr
  LEFT JOIN cr_payments p ON cr.id = p.document_id
  WHERE cr.total_amount - COALESCE(p.total_paid, 0) > 0  
    
),

output_iv_ageging AS (
  SELECT
    centre_id,
    class_id,
    document_id,
    document_date,
    student_id,
    total_amount,
    CASE WHEN age_in_days <= 30 THEN unpaid_amount ELSE 0 END AS day_30,
    CASE WHEN age_in_days BETWEEN 31 AND 60 THEN unpaid_amount ELSE 0 END AS day_60,
    CASE WHEN age_in_days BETWEEN 61 AND 90 THEN unpaid_amount ELSE 0 END AS day_90,
    CASE WHEN age_in_days BETWEEN 91 AND 120 THEN unpaid_amount ELSE 0 END AS day_120,
    CASE WHEN age_in_days BETWEEN 121 AND 150 THEN unpaid_amount ELSE 0 END AS day_150,
    CASE WHEN age_in_days BETWEEN 151 AND 180 THEN unpaid_amount ELSE 0 END AS day_180,
    CASE WHEN age_in_days > 180 THEN unpaid_amount ELSE 0 END AS day_180_and_above,
    document_type,
    '2025-07-07' AS as_at_date
  FROM invoice_ageging
),
output_cr_ageging AS (
  SELECT
    centre_id,
    class_id,
    document_id,
    document_date,
    student_id,
    total_amount,
    CASE WHEN age_in_days <= 30 THEN unpaid_amount ELSE 0 END AS day_30,
    CASE WHEN age_in_days BETWEEN 31 AND 60 THEN unpaid_amount ELSE 0 END AS day_60,
    CASE WHEN age_in_days BETWEEN 61 AND 90 THEN unpaid_amount ELSE 0 END AS day_90,
    CASE WHEN age_in_days BETWEEN 91 AND 120 THEN unpaid_amount ELSE 0 END AS day_120,
    CASE WHEN age_in_days BETWEEN 121 AND 150 THEN unpaid_amount ELSE 0 END AS day_150,
    CASE WHEN age_in_days BETWEEN 151 AND 180 THEN unpaid_amount ELSE 0 END AS day_180,
    CASE WHEN age_in_days > 180 THEN unpaid_amount ELSE 0 END AS day_180_and_above,
    document_type,
    '2025-07-07' AS as_at_date
  FROM cr_ageging
)

SELECT * FROM output_iv_ageging
UNION ALL
SELECT * FROM output_cr_ageging;


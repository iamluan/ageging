Steps:
1. Invoices/CreditNotes payments CTE
Aggregates amount_paid SUM(amount_paid) from the payments table for documents of type with GROUP BY (document_id).

2. Invoices/CreditNotes aging CTE
- Using LEGT JOIN invoices and credit notes with their payments to only take the payment document.
- Calculate the number unpaid days with DATE_DIFF('2025-07-07', iv.invoice_date, DAY) AS age_in_days
- Calculate the unpaid amount of each document iv.total_amount - COALESCE(p.total_paid, 0) AS unpaid_amount
- Filters for invoices with unpaid balances WHERE iv.total_amount - COALESCE(p.total_paid, 0) > 0

5. output_iv_ageging and output_cr_ageging
Apply CASE WHEN to categorize unpaid amounts into aging buckets.

6. Final Output
Combines both invoice and credit_note aging tables using UNION ALL.

Note: ALL SQL is written in BigQuery

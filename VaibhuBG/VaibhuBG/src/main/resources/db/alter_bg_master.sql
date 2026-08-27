-- Migration: add PO_NUMBER and PO_AMOUNT to BG_MASTER
-- Pick the statement appropriate for your database and run it (via SQL client or migration tool).

-- For MySQL / MariaDB / PostgreSQL (generic):
ALTER TABLE BG_MASTER
  ADD COLUMN PO_NUMBER VARCHAR(255),
  ADD COLUMN PO_AMOUNT DECIMAL(15,2);

-- For Oracle (example):
-- ALTER TABLE BG_MASTER ADD (PO_NUMBER VARCHAR2(255), PO_AMOUNT NUMBER(15,2));

-- Oracle (explicit):
ALTER TABLE BG_MASTER ADD (PO_NUMBER VARCHAR2(255), PO_AMOUNT NUMBER(15,2));

ALTER TABLE BG_MASTER ADD (BG_WORKDESC VARCHAR2(255));


-- For SQL Server:
-- ALTER TABLE BG_MASTER ADD PO_NUMBER VARCHAR(255), PO_AMOUNT DECIMAL(15,2);

-- Note: adjust types and sizes to match your conventions. If the table already contains data,
-- consider adding the columns as NULLABLE (above statements add nullable columns), and then
-- backfill values as needed.

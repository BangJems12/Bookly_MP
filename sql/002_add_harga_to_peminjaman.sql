-- Migration: add numeric harga column to peminjaman
-- Adds a nullable numeric column with 2 decimals precision
ALTER TABLE public.peminjaman
  ADD COLUMN IF NOT EXISTS harga numeric(12,2);

-- Optional: Cast existing text values to numeric if you previously stored formatted strings
-- WARNING: review backups before running any coercion.
-- Example to attempt cast where possible (may fail for values like 'Rp 1.000,00'):
-- UPDATE public.peminjaman
-- SET harga = NULLIF(regexp_replace(harga::text, '[^0-9\-,.]', '', 'g'), '')::numeric
-- WHERE harga IS NOT NULL;

-- Migration: add `harga` column to `books` table
-- Run this in psql or Supabase SQL editor.

BEGIN;

-- Add numeric column if it doesn't exist (Postgres supports IF NOT EXISTS)
ALTER TABLE public.books
  ADD COLUMN IF NOT EXISTS harga numeric(12,2);

-- Optional: set default 0 for existing null values (uncomment if desired)
-- UPDATE public.books SET harga = 0 WHERE harga IS NULL;

COMMIT;

-- Notes:
-- - `numeric(12,2)` stores up to ~9999999999.99. Change type if you prefer `double precision`.
-- - On Supabase you can run this in the SQL editor or via psql with the project's connection.
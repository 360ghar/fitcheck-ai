-- FitCheck AI - Durable batch generation reservation
--
-- Batch jobs reserve generation quota at admission (total_images x 3) to
-- guarantee every item can be generated. The reservation lives only on the
-- in-memory BatchJob, so a process restart before the job reaches a terminal
-- state leaks the reservation forever: the recovered shell carries
-- reserved_generations = 0 and no pipeline later reconciles the unused
-- quota (A3-xx). Persisting the count lets recovery restore it and release
-- `reserved - len(generation_completed)` when a recovered non-terminal job
-- is cancelled or evicted.
--
-- Rerunnable (ADD COLUMN IF NOT EXISTS): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.extraction_jobs
    ADD COLUMN IF NOT EXISTS reserved_generations INTEGER NOT NULL DEFAULT 0;

COMMIT;

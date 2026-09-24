-- Enable pg_trgm: lets Postgres index "contains" / ILIKE-style substring
-- matches (title.contains(), search bar typos, partial words) instead of
-- doing a full table scan on every search request.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- GIN + trigram index on title and description — this is what actually
-- speeds up Resource search. Prisma's `contains` with `mode: "insensitive"`
-- compiles to an ILIKE query on Postgres, and a plain b-tree index can't
-- help a "%term%" pattern at all — a trigram GIN index can, because it
-- breaks text into overlapping 3-character chunks and indexes those.
CREATE INDEX IF NOT EXISTS "Resource_title_trgm_idx"
  ON "Resource" USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "Resource_description_trgm_idx"
  ON "Resource" USING GIN (description gin_trgm_ops);

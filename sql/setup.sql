-- Run once in the Supabase SQL editor (or any Postgres with pgvector).

create extension if not exists vector with schema extensions;

-- Document chunks and their embeddings
create table if not exists public.rag_documents (
  id uuid primary key default gen_random_uuid(),
  text text,
  metadata jsonb,          -- file_id, file_name, ingest_id
  embedding extensions.vector
);
create index if not exists rag_documents_file_id_idx
  on public.rag_documents ((metadata->>'file_id'));

-- Message log, used for rate limiting
create table if not exists public.rag_message_log (
  id bigserial primary key,
  chat_id bigint not null,
  user_id bigint,
  level int,               -- -1 non-text, 0 quick reply, 1 AI question, 2 handoff
  message text,
  created_at timestamptz not null default now()
);
create index if not exists rag_message_log_chat_time_idx
  on public.rag_message_log (chat_id, created_at desc);

alter table public.rag_documents enable row level security;
alter table public.rag_message_log enable row level security;

-- The chat memory table (rag_chat_memory) is created automatically by n8n.

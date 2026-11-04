-- See which documents are in the knowledge base
select metadata->>'file_name' as file, count(*) as chunks
from public.rag_documents
group by 1
order by 1;

-- Remove a document that was deleted from Google Drive
delete from public.rag_documents
where metadata->>'file_name' = 'Old price list.pdf';

-- Optional: delete message logs older than 30 days, every day at 03:00
create extension if not exists pg_cron;
select cron.schedule(
  'rag-log-cleanup',
  '0 3 * * *',
  $$delete from public.rag_message_log where created_at < now() - interval '30 days'$$
);

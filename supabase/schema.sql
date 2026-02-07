-- Enable the pgvector extension to work with embeddings
create extension if not exists vector;

-- Create the remotes table
create table remotes (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  brand text not null,
  category text,
  price int4 default 0,
  rack_no text,
  image_url text,
  embedding vector(1280) -- Matches MobileNetV3 feature vector size
);

-- Create the search function (Cosine Similarity)
create or replace function match_remotes (
  query_embedding vector(1280),
  match_threshold float,
  match_count int
)
returns table (
  id uuid,
  brand text,
  category text,
  price int4,
  rack_no text,
  image_url text,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    remotes.id,
    remotes.brand,
    remotes.category,
    remotes.price,
    remotes.rack_no,
    remotes.image_url,
    1 - (remotes.embedding <=> query_embedding) as similarity
  from remotes
  where 1 - (remotes.embedding <=> query_embedding) > match_threshold
  order by similarity desc
  limit match_count;
end;
$$;
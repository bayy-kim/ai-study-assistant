-- AI Study Assistant — Database Schema (Postgres / Supabase)

-- Profil user, extend dari auth.users bawaan Supabase
create table profiles (
  id uuid primary key references auth.users(id),
  email text not null,
  name text,
  credits_balance integer default 0,
  created_at timestamptz default now()
);

-- Kode redeem yang di-generate setiap ada pembelian di lynk.id
create table redeem_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  credit_amount integer not null,
  is_used boolean default false,
  used_by uuid references profiles(id),
  created_at timestamptz default now(),
  used_at timestamptz
);

-- Dokumen yang diupload user (PDF/PPT materi kuliah)
create table documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  title text not null,
  subject text,
  file_url text not null,
  raw_text text, -- hasil ekstraksi PDF, dipakai sebagai input prompt AI
  uploaded_at timestamptz default now()
);

create table summaries (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id) not null,
  content text not null,
  key_points jsonb, -- array of strings
  created_at timestamptz default now()
);

create table flashcards (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id) not null,
  question text not null,
  answer text not null,
  created_at timestamptz default now()
);

create table quizzes (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id) not null,
  title text not null,
  created_at timestamptz default now()
);

create table quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid references quizzes(id) not null,
  question text not null,
  options jsonb not null, -- ["A. ...", "B. ...", "C. ...", "D. ..."]
  correct_answer text not null,
  explanation text
);

create table quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  quiz_id uuid references quizzes(id) not null,
  score integer not null,
  answers jsonb not null,
  completed_at timestamptz default now()
);

create table credit_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  type text not null, -- 'redeem' atau 'usage'
  amount integer not null, -- positif untuk redeem, negatif untuk usage
  description text,
  created_at timestamptz default now()
);

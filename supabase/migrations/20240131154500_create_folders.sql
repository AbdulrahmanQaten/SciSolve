-- Create folders table
create table public.folders (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add RLS for folders
alter table public.folders enable row level security;

create policy "Users can view their own folders"
  on public.folders for select
  using (auth.uid() = user_id);

create policy "Users can insert their own folders"
  on public.folders for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own folders"
  on public.folders for update
  using (auth.uid() = user_id);

create policy "Users can delete their own folders"
  on public.folders for delete
  using (auth.uid() = user_id);

-- Ensure chats has folder_id (already there from previous, but good to check or add FK if missing)
-- alter table public.chats add column if not exists folder_id uuid references public.folders(id) on delete set null;
-- Adding explicit FK constraint if not consistent
do $$
begin
  if not exists (select 1 from information_schema.table_constraints where constraint_name = 'chats_folder_id_fkey') then
    alter table public.chats add constraint chats_folder_id_fkey foreign key (folder_id) references public.folders(id) on delete set null;
  end if;
end
$$;

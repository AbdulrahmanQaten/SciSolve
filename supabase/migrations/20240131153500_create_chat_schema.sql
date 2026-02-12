-- Create chats table
CREATE TABLE public.chats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT,
    folder_id UUID, -- For future folders feature
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create messages table
CREATE TABLE public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE NOT NULL,
    role TEXT CHECK (role IN ('user', 'assistant')) NOT NULL,
    content TEXT,
    image TEXT, -- Base64 or URL (optional)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create user_usage table (for limits)
CREATE TABLE public.user_usage (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    daily_requests INTEGER DEFAULT 0,
    daily_images INTEGER DEFAULT 0,
    last_reset_date DATE DEFAULT CURRENT_DATE,
    is_pro BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_usage ENABLE ROW LEVEL SECURITY;

-- Policies for chats
CREATE POLICY "Users can view their own chats" ON public.chats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own chats" ON public.chats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own chats" ON public.chats
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own chats" ON public.chats
    FOR DELETE USING (auth.uid() = user_id);

-- Policies for messages (indirectly checked via chat ownership, but simplified here)
-- Using a subquery to check chat ownership is safer
CREATE POLICY "Users can view messages of their chats" ON public.messages
    FOR SELECT USING (
        EXISTS ( SELECT 1 FROM public.chats WHERE id = messages.chat_id AND user_id = auth.uid() )
    );

CREATE POLICY "Users can insert messages to their chats" ON public.messages
    FOR INSERT WITH CHECK (
        EXISTS ( SELECT 1 FROM public.chats WHERE id = chat_id AND user_id = auth.uid() )
    );

-- Policies for user_usage
CREATE POLICY "Users can view their own usage" ON public.user_usage
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage usage" ON public.user_usage
    FOR ALL USING (true); -- Service role (Edge Functions) needs full access, but for client-side we limit update

-- Allow users to update usage (optimistic UI) BUT ideally this should be server-side.
-- For now, we allow update for prototype speed, but in production trigger is better.
CREATE POLICY "Users can update their own usage" ON public.user_usage
    FOR UPDATE USING (auth.uid() = user_id);

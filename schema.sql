-- Create trader_analysts table
CREATE TABLE IF NOT EXISTS public.trader_analysts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create unique index on name to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS trader_analysts_name_unique ON public.trader_analysts (name);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_trader_analysts_updated_at 
    BEFORE UPDATE ON public.trader_analysts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.trader_analysts ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS (adjust based on your auth requirements)
-- For now, allow all operations for authenticated users
CREATE POLICY "Allow all operations for authenticated users" ON public.trader_analysts
    FOR ALL USING (auth.role() = 'authenticated');

-- If you want to allow anonymous access, use this policy instead:
-- CREATE POLICY "Allow all operations for everyone" ON public.trader_analysts
--     FOR ALL USING (true);

-- Grant necessary permissions
GRANT ALL ON public.trader_analysts TO authenticated;
GRANT ALL ON public.trader_analysts TO anon;
GRANT USAGE, SELECT ON SEQUENCE trader_analysts_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE trader_analysts_id_seq TO anon;
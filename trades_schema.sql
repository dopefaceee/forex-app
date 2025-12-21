-- Create trades table to store detailed trade information
CREATE TABLE IF NOT EXISTS public.trades (
    id BIGSERIAL PRIMARY KEY,
    trader_id BIGINT NOT NULL REFERENCES public.trader_analysts(id) ON DELETE CASCADE,
    symbol VARCHAR(50) NOT NULL,
    price DECIMAL(10, 5) NOT NULL,
    sl DECIMAL(10, 5),
    tp DECIMAL(10, 5),
    close_price DECIMAL(10, 5),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    close_time TIMESTAMP WITH TIME ZONE,
    pips INTEGER,
    profit DECIMAL(15, 2),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS trades_trader_id_idx ON public.trades (trader_id);
CREATE INDEX IF NOT EXISTS trades_created_at_idx ON public.trades (created_at);
CREATE INDEX IF NOT EXISTS trades_symbol_idx ON public.trades (symbol);

-- Create updated_at trigger for trades table
CREATE TRIGGER update_trades_updated_at 
    BEFORE UPDATE ON public.trades 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
CREATE POLICY "Allow all operations for authenticated users" ON public.trades
    FOR ALL USING (auth.role() = 'authenticated');

-- Grant necessary permissions
GRANT ALL ON public.trades TO authenticated;
GRANT ALL ON public.trades TO anon;
GRANT USAGE, SELECT ON SEQUENCE trades_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE trades_id_seq TO anon;

-- Sample data insertion for trader_id = 1
INSERT INTO public.trades (trader_id, symbol, price, sl, tp, close_price, created_at, close_time, pips, profit) VALUES
(1, 'XAUUSD', 3987.21, 3962.21, 4037.21, 4037.21, '2025-11-06 15:40:20', '2025-11-10 01:21:00', 5000, 5000.00),
(1, 'XAUUSD', 3950.15, 3925.15, 4000.15, 3925.15, '2025-11-07 09:15:30', '2025-11-07 14:22:10', -2500, -2500.00),
(1, 'EURUSD', 1.0850, 1.0800, 1.0900, 1.0900, '2025-11-08 08:30:00', '2025-11-08 16:45:20', 500, 750.00),
(1, 'GBPUSD', 1.2750, 1.2700, 1.2850, 1.2820, '2025-11-09 10:20:15', '2025-11-09 18:30:40', 700, 1200.00),
(1, 'XAUUSD', 4012.30, 3987.30, 4062.30, 4062.30, '2025-11-10 13:45:00', '2025-11-10 20:15:30', 5000, 5000.00)
ON CONFLICT DO NOTHING;
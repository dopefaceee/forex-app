-- Real trade data from NADIM'S CHANNEL
-- Clear existing dummy data first (optional)
DELETE FROM public.trades WHERE trader_id = 1;

-- =============================================
-- NOVEMBER 2025 TRADES
-- =============================================

INSERT INTO public.trades (trader_id, symbol, price, sl, tp, close_price, created_at, close_time, pips, profit) VALUES
-- Trade 1: Nov 10 - Win +4500 pips
(1, 'XAUUSD', 4095.00, 4070.45, 4140.00, 4140.00, '2025-11-10 12:02:53+00', '2025-11-11 01:32:28+00', 4500, 4500.00),

-- Trade 2: Nov 10 - Win +4980 pips  
(1, 'XAUUSD', 4083.81, 4058.81, 4133.61, 4133.61, '2025-11-10 14:26:28+00', '2025-11-11 00:55:59+00', 4980, 4980.00),

-- Trade 3: Nov 10 - Break Even (op: 2 = sell, closed manually)
(1, 'XAUUSD', 4065.20, 4040.20, 4115.20, 4103.99, '2025-11-10 11:27:06+00', '2025-11-10 13:37:41+00', 0, 0.00),

-- Trade 4: Nov 7-10 - Win +5000 pips
(1, 'XAUUSD', 4006.51, 3981.51, 4056.51, 4056.51, '2025-11-07 16:52:34+00', '2025-11-10 04:14:23+00', 5000, 5000.00),

-- Trade 5: Nov 6-10 - Win +5000 pips
(1, 'XAUUSD', 3987.21, 3962.21, 4037.21, 4037.21, '2025-11-06 15:40:20+00', '2025-11-10 01:21:00+00', 5000, 5000.00),

-- Trade 6: Nov 6-7 - Win +5000 pips
(1, 'XAUUSD', 3977.21, 3952.21, 4027.21, 4027.21, '2025-11-06 15:35:53+00', '2025-11-07 16:39:12+00', 5000, 5000.00),

-- Trade 7: Nov 6 - Break Even (op: 4 = sell limit, closed manually)
(1, 'XAUUSD', 4002.00, 3977.00, 4052.00, 3976.96, '2025-11-06 15:33:37+00', '2025-11-06 15:38:50+00', 0, 0.00),

-- Trade 8: Nov 3-4 - Loss -2509 pips (hit SL)
(1, 'XAUUSD', 3987.35, 3962.35, 4037.35, 3962.26, '2025-11-03 00:43:38+00', '2025-11-04 14:29:18+00', -2509, -2509.00),

-- Trade 9: Nov 3-4 - Loss -2500 pips (hit SL)
(1, 'XAUUSD', 4004.32, 3979.32, 4054.32, 3979.32, '2025-11-03 08:24:40+00', '2025-11-04 00:43:19+00', -2500, -2500.00),

-- Trade 10: Nov 2-3 - Win +5006 pips
(1, 'XAUUSD', 3977.29, 3952.35, 4027.35, 4027.35, '2025-11-02 23:51:46+00', '2025-11-03 08:05:08+00', 5006, 5006.00),

-- Trade 11: Nov 2-3 - Break Even (op: 2 = sell, closed manually)
(1, 'XAUUSD', 3963.00, 3943.00, 4013.00, 3971.66, '2025-11-02 23:39:15+00', '2025-11-03 00:42:14+00', 0, 0.00),

-- Trade 12: Nov 2 - Break Even (op: 4 = sell limit, closed manually)
(1, 'XAUUSD', 4070.00, 4045.00, 4120.00, 3989.36, '2025-11-02 23:29:16+00', '2025-11-02 23:50:22+00', 0, 0.00)

ON CONFLICT DO NOTHING;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Check total trades inserted
SELECT COUNT(*) as total_trades FROM public.trades WHERE trader_id = 1;

-- Monthly summary for November 2025
SELECT 
    'November 2025' as month,
    COUNT(*) as total_trades,
    SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END) as winning_trades,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) as losing_trades,
    SUM(CASE WHEN profit = 0 THEN 1 ELSE 0 END) as break_even_trades,
    ROUND(AVG(CASE WHEN profit > 0 THEN profit ELSE NULL END), 2) as avg_win,
    ROUND(AVG(CASE WHEN profit < 0 THEN profit ELSE NULL END), 2) as avg_loss,
    SUM(pips) as total_pips,
    SUM(profit) as total_profit,
    ROUND(
        (SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END)::decimal / COUNT(*)) * 100, 
        2
    ) as win_rate_percentage
FROM public.trades 
WHERE trader_id = 1 
  AND DATE_TRUNC('month', created_at) = '2025-11-01';

-- Show all trades ordered by date
SELECT 
    symbol,
    price as entry_price,
    sl,
    tp,
    close_price,
    created_at::date as trade_date,
    EXTRACT(HOUR FROM created_at) as hour,
    pips,
    profit,
    CASE 
        WHEN profit > 0 THEN 'WIN'
        WHEN profit < 0 THEN 'LOSS'
        ELSE 'BREAK EVEN'
    END as outcome
FROM public.trades 
WHERE trader_id = 1
ORDER BY created_at DESC;

-- Daily performance summary
SELECT 
    created_at::date as trade_date,
    COUNT(*) as daily_trades,
    SUM(profit) as daily_profit,
    SUM(pips) as daily_pips
FROM public.trades 
WHERE trader_id = 1
GROUP BY created_at::date
ORDER BY trade_date DESC;
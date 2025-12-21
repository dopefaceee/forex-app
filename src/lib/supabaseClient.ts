import { createClient } from '@supabase/supabase-js'
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public'

if (!PUBLIC_SUPABASE_URL || !PUBLIC_SUPABASE_ANON_KEY) {
  throw new Error('Missing Supabase environment variables. Please check your .env file and ensure variables are prefixed with PUBLIC_.')
}

export const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY)

export type Database = {
  public: {
    Tables: {
      trader_analysts: {
        Row: {
          id: number
          name: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: number
          name: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          name?: string
          created_at?: string
          updated_at?: string
        }
      }
      trades: {
        Row: {
          id: number
          trader_id: number
          symbol: string
          price: number
          sl?: number
          tp?: number
          close_price?: number
          created_at: string
          close_time?: string
          pips?: number
          profit?: number
          updated_at: string
        }
        Insert: {
          id?: number
          trader_id: number
          symbol: string
          price: number
          sl?: number
          tp?: number
          close_price?: number
          created_at: string
          close_time?: string
          pips?: number
          profit?: number
          updated_at?: string
        }
        Update: {
          id?: number
          trader_id?: number
          symbol?: string
          price?: number
          sl?: number
          tp?: number
          close_price?: number
          created_at?: string
          close_time?: string
          pips?: number
          profit?: number
          updated_at?: string
        }
      }
    }
  }
}
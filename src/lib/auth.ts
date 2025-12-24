import { supabase } from '$lib/supabaseClient';
import { redirect } from '@sveltejs/kit';
import type { LayoutLoad } from './$types';

export async function requireAuth() {
  const { data: { session }, error } = await supabase.auth.getSession();
  
  if (error) {
    console.error('Auth error:', error);
    throw redirect(303, '/');
  }
  
  if (!session?.user) {
    throw redirect(303, '/');
  }
  
  return session;
}

// List of protected routes that require authentication
const protectedRoutes = [
  '/simulation',
  '/simulation/trader'
];

export function shouldProtectRoute(pathname: string): boolean {
  return protectedRoutes.some(route => pathname.startsWith(route));
}
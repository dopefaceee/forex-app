import { writable, get } from 'svelte/store';
import type { User, AuthError, Session } from '@supabase/supabase-js';
import { supabase } from '$lib/supabaseClient';
import { goto } from '$app/navigation';
import { browser } from '$app/environment';
import { page } from '$app/stores';

export interface AuthState {
  user: User | null;
  session: Session | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  session: null,
  loading: true,
  error: null,
};

// Create the writable store first
const { subscribe, set, update } = writable<AuthState>(initialState);

// Create the auth store object
export const authStore = {
  subscribe,
  
  // Initialize auth state by checking current session
  initialize: async () => {
    try {
      const { data: { session }, error } = await supabase.auth.getSession();
      
      if (error) {
        throw error;
      }

      set({
        user: session?.user || null,
        session,
        loading: false,
        error: null,
      });
    } catch (error) {
      set({
        user: null,
        session: null,
        loading: false,
        error: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  },

  // Sign in with Google
  signInWithGoogle: async () => {
    try {
      update(state => ({ ...state, loading: true, error: null }));
      
      // Detect environment and set appropriate redirect
      const origin = window.location.origin;
      const isLocalhost = origin.includes('localhost') || origin.includes('127.0.0.1');
      
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: isLocalhost 
            ? `${origin}/auth/callback`  // Local: custom callback
            : 'https://forex-app-mu.vercel.app/'  // Production: your domain
        },
      });

      if (error) {
        throw error;
      }
    } catch (error) {
      update(state => ({
        ...state,
        loading: false,
        error: error instanceof Error ? error.message : 'Failed to sign in with Google',
      }));
    }
  },

  // Sign out
  signOut: async () => {
    try {
      update(state => ({ ...state, loading: true, error: null }));
      
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        throw error;
      }

      set({
        user: null,
        session: null,
        loading: false,
        error: null,
      });

      // Redirect to landing page after successful sign out
      if (browser) {
        await goto('/');
      }
    } catch (error) {
      update(state => ({
        ...state,
        loading: false,
        error: error instanceof Error ? error.message : 'Failed to sign out',
      }));
    }
  },

  // Clear error
  clearError: () => {
    update(state => ({ ...state, error: null }));
  },

  // Internal method for auth state changes
  _updateState: (user: User | null, session: Session | null) => {
    update(state => ({
      ...state,
      user,
      session,
      loading: false,
      error: null,
    }));
  },

  // Check if current route needs authentication
  _checkRouteAccess: (pathname: string) => {
    const protectedRoutes = ['/simulation'];
    const needsAuth = protectedRoutes.some(route => pathname.startsWith(route));
    
    if (browser && needsAuth) {
      const currentState = get(authStore);
      if (!currentState.loading && !currentState.user) {
        console.log('Protected route accessed without auth, redirecting to landing page');
        goto('/');
      }
    }
  },
};

// Set up auth state listener
supabase.auth.onAuthStateChange(async (event, session) => {
  console.log('Auth state change:', event, session?.user?.email || 'no user');
  
  if (event === 'INITIAL_SESSION') {
    // Handle initial session load
    authStore._updateState(session?.user || null, session);
  } else if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
    authStore._updateState(session?.user || null, session);
  } else if (event === 'SIGNED_OUT') {
    authStore._updateState(null, null);
  }
});
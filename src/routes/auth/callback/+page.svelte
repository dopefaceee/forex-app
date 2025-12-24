<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { authStore } from '$lib/stores/auth';

  let status = $state('Processing authentication...');
  let error = $state('');

  onMount(async () => {
    try {
      // Initialize auth store to handle the callback
      await authStore.initialize();
      
      // Check if we have a user after initialization
      if ($authStore.user) {
        status = 'Authentication successful! Redirecting...';
        // Redirect to simulation page after successful auth
        setTimeout(() => {
          goto('/simulation');
        }, 1500);
      } else {
        throw new Error('No user found after authentication');
      }
    } catch (err) {
      console.error('Auth callback error:', err);
      error = err instanceof Error ? err.message : 'Authentication failed';
      status = 'Authentication failed. Redirecting to home...';
      
      // Redirect to landing page after error
      setTimeout(() => {
        goto('/');
      }, 3000);
    }
  });
</script>

<svelte:head>
  <title>Trading Simulation</title>
</svelte:head>

<div class="min-h-screen bg-background flex items-center justify-center">
  <div class="text-center space-y-4 max-w-md mx-auto p-6">
    {#if error}
      <div class="text-center space-y-4">
        <div class="h-12 w-12 mx-auto rounded-full bg-red-100 dark:bg-red-900 flex items-center justify-center">
          <svg class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </div>
        <h1 class="text-xl font-semibold text-foreground">{status}</h1>
        <p class="text-sm text-red-600 dark:text-red-400">{error}</p>
      </div>
    {:else}
      <div class="text-center space-y-4">
        <div class="h-12 w-12 mx-auto">
          <div class="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
        </div>
        <h1 class="text-xl font-semibold text-foreground">{status}</h1>
        <p class="text-sm text-muted-foreground">Please wait while we complete your sign-in...</p>
      </div>
    {/if}
  </div>
</div>
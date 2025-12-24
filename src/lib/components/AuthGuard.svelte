<script lang="ts">
  import { authStore } from '$lib/stores/auth';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { browser } from '$app/environment';

  let { children } = $props();

  // List of routes that should be protected
  const protectedRoutes = ['/simulation'];
  
  let isRedirecting = $state(false);
  
  $effect(() => {
    if (browser && !$authStore.loading) {
      const currentPath = $page.url.pathname;
      const isProtectedRoute = protectedRoutes.some(route => currentPath.startsWith(route));
      
      if (isProtectedRoute && !$authStore.user) {
        console.log('User not authenticated, redirecting to landing page');
        isRedirecting = true;
        goto('/').then(() => {
          isRedirecting = false;
        });
      }
    }
  });

  const shouldShowContent = $derived(browser ? 
    (!$authStore.loading && !isRedirecting && ($authStore.user || !protectedRoutes.some(route => $page.url.pathname.startsWith(route)))) :
    true); // Always show content during SSR
</script>

{#if $authStore.loading || isRedirecting}
  <!-- Loading state while checking authentication or redirecting -->
  <div class="min-h-screen flex items-center justify-center bg-background">
    <div class="flex items-center gap-2">
      <div class="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
      <span class="text-muted-foreground">
        {isRedirecting ? 'Redirecting...' : 'Checking authentication...'}
      </span>
    </div>
  </div>
{:else if shouldShowContent}
  <!-- Render content if authenticated or on public pages -->
  {@render children()}
{:else}
  <!-- Fallback loading state -->
  <div class="min-h-screen flex items-center justify-center bg-background">
    <div class="flex items-center gap-2">
      <div class="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
      <span class="text-muted-foreground">Loading...</span>
    </div>
  </div>
{/if}
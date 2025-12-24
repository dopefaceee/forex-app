<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { authStore } from "$lib/stores/auth";
  import { LogOut } from "@lucide/svelte";
  import * as Popover from "$lib/components/ui/popover/index.js";

  const auth = authStore;
  let isOpen = $state(false);

  async function handleSignOut() {
    try {
      await auth.signOut();
      isOpen = false;
    } catch (error) {
      console.error('Sign out error:', error);
      isOpen = false;
    }
  }

  function getInitials(name: string): string {
    return name
      .split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  }

  // Debug function to see user data structure
  $effect(() => {
    if ($auth.user) {
      console.log('User data:', $auth.user);
      console.log('User metadata:', $auth.user.user_metadata);
    }
  });

  // Function to get avatar URL from different possible properties
  function getAvatarUrl(user: any): string | null {
    // Try different possible properties where Google might store the avatar
    return user.user_metadata?.avatar_url ||
           user.user_metadata?.picture ||
           user.identities?.[0]?.identity_data?.avatar_url ||
           user.identities?.[0]?.identity_data?.picture ||
           null;
  }
</script>

{#if $auth.user}
  <Popover.Root bind:open={isOpen}>
    <Popover.Trigger>
      {#snippet child({ props })}
        <Button
          {...props}
          variant="ghost"
          size="sm"
          class="gap-2 h-9 rounded-full px-3"
        >
          {#if getAvatarUrl($auth.user)}
            <img
              src={getAvatarUrl($auth.user)}
              alt="Profile"
              class="h-6 w-6 rounded-full"
              loading="lazy"
              onerror={(e) => {
                console.log('Avatar failed to load:', getAvatarUrl($auth.user));
                e.target.style.display = 'none';
                e.target.nextElementSibling.style.display = 'flex';
              }}
            />
            <div class="h-6 w-6 rounded-full bg-primary/10 flex items-center justify-center text-xs font-medium" style="display: none;">
              {getInitials($auth.user.user_metadata?.full_name || $auth.user.email || 'U')}
            </div>
          {:else}
            <div class="h-6 w-6 rounded-full bg-primary/10 flex items-center justify-center text-xs font-medium">
              {getInitials($auth.user.user_metadata?.full_name || $auth.user.email || 'U')}
            </div>
          {/if}
          <span class="hidden sm:inline-block text-sm font-medium">
            {$auth.user.user_metadata?.full_name?.split(' ')[0] || 'User'}
          </span>
        </Button>
      {/snippet}
    </Popover.Trigger>

    <Popover.Content class="w-64 p-3" align="end">
      <div class="space-y-3">
        <!-- User Info -->
        <div class="flex items-center space-x-3 pb-3 border-b border-border">
          {#if getAvatarUrl($auth.user)}
            <img
              src={getAvatarUrl($auth.user)}
              alt="Profile"
              class="h-10 w-10 rounded-full"
              loading="lazy"
              onerror={(e) => {
                console.log('Large avatar failed to load:', getAvatarUrl($auth.user));
                e.target.style.display = 'none';
                e.target.nextElementSibling.style.display = 'flex';
              }}
            />
            <div class="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium" style="display: none;">
              {getInitials($auth.user.user_metadata?.full_name || $auth.user.email || 'U')}
            </div>
          {:else}
            <div class="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium">
              {getInitials($auth.user.user_metadata?.full_name || $auth.user.email || 'U')}
            </div>
          {/if}
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium truncate">
              {$auth.user.user_metadata?.full_name || 'User'}
            </p>
            <p class="text-xs text-muted-foreground truncate">
              {$auth.user.email}
            </p>
          </div>
        </div>

        <!-- Menu Items -->
        <div class="space-y-1">
          <Button
            variant="ghost"
            size="sm"
            class="w-full justify-start gap-2 h-8 text-red-600 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-950"
            onclick={handleSignOut}
            disabled={$auth.loading}
          >
            {#if $auth.loading}
              <div class="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent"></div>
              Signing out...
            {:else}
              <LogOut class="h-4 w-4" />
              Sign out
            {/if}
          </Button>
        </div>
      </div>
    </Popover.Content>
  </Popover.Root>
{/if}
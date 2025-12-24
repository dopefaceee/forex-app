<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import GoogleSignInButton from "$lib/components/GoogleSignInButton.svelte";
  import { authStore } from "$lib/stores/auth";
  import {
    TrendingUp,
    Target,
    Activity,
    ChartBar,
    Users,
    Brain,
  } from "@lucide/svelte";
</script>

<section class="min-h-screen bg-background">
  <!-- Hero Section -->
  <div class="flex flex-col items-center justify-center min-h-screen px-6">
    <div class="text-center space-y-16 max-w-4xl">
      <div class="space-y-4">
        <h1 class="text-5xl md:text-6xl font-bold tracking-tight text-foreground">
          Trading Simulation
        </h1>
        <p class="text-xl leading-relaxed text-muted-foreground">
          Simulasi trading menggunakan analyst dari
          <a
            href="https://tradersfamily.id/"
            target="_blank"
            rel="noopener noreferrer"
            class="font-bold text-green-600 hover:text-green-500 dark:text-green-400 dark:hover:text-green-300 transition-colors"
          >
            TradersFamily
          </a>
          <br />
          Bantu investor
          <span
            class="inline-block px-2 py-0.5 rounded bg-card border font-bold text-green-600 dark:text-green-400"
          >
            memaksimalkan profit
          </span>
          dan mengelola
          <span
            class="inline-block px-2 py-0.5 rounded bg-card border font-bold text-red-600 dark:text-red-400"
          >
            risiko drawdown
          </span>.
        </p>
      </div>

      <div class="flex flex-col sm:flex-row justify-center items-center gap-4">
        {#if $authStore.user}
          <!-- Logged in: Only show simulation button -->
          <a href="/simulation">
            <Button size="lg" class="min-w-[200px]">Mulai Simulasi</Button>
          </a>
        {:else if !$authStore.loading}
          <!-- Not logged in: Show both buttons side by side -->
          <GoogleSignInButton size="lg" class="min-w-[200px]" />
          <Button 
            size="lg" 
            variant="outline" 
            class="min-w-[200px]" 
            onclick={() => authStore.signInWithGoogle()}
          >
            Mulai Simulasi
          </Button>
        {:else}
          <!-- Loading state -->
          <div class="flex items-center gap-2">
            <div class="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
            <span class="text-muted-foreground">Loading...</span>
          </div>
        {/if}
      </div>
    </div>
  </div>
</section>

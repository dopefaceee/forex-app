<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { ChartLine, TrendingUp, Target } from "@lucide/svelte";
</script>

<section class="min-h-screen bg-background">
  <!-- Hero Section -->
  <div class="flex flex-col items-center justify-center min-h-screen px-6">
    <div class="text-center space-y-8 max-w-3xl">
      <div class="space-y-4">
        <h1 class="text-5xl md:text-6xl font-bold tracking-tight">
          Trading Journey
        </h1>
        <p class="text-xl text-muted-foreground">
          Document your trades. Track your progress. Improve your strategy.
        </p>
      </div>

      <div class="flex flex-col sm:flex-row gap-4 justify-center">
        <a href="/dashboard">
          <Button size="lg" class="min-w-[200px]">
            Start Tracking
          </Button>
        </a>
      </div>

      <!-- Features -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16">
        <div class="space-y-3">
          <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mx-auto">
            <ChartLine class="w-6 h-6 text-primary" />
          </div>
          <h3 class="font-semibold">Track Performance</h3>
          <p class="text-sm text-muted-foreground">
            Monitor your win rate, profit factor, and overall trading statistics
          </p>
        </div>

        <div class="space-y-3">
          <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mx-auto">
            <TrendingUp class="w-6 h-6 text-primary" />
          </div>
          <h3 class="font-semibold">Analyze Patterns</h3>
          <p class="text-sm text-muted-foreground">
            Identify what works and what doesn't in your trading approach
          </p>
        </div>

        <div class="space-y-3">
          <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mx-auto">
            <Target class="w-6 h-6 text-primary" />
          </div>
          <h3 class="font-semibold">Improve Strategy</h3>
          <p class="text-sm text-muted-foreground">
            Make data-driven decisions to refine your trading system
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

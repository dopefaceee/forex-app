<script lang="ts">
  import { Button } from "$lib/components/ui/button";
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
        <h1 class="text-5xl md:text-6xl font-bold tracking-tight">
          Trading Simulation
        </h1>
        <p class="text-xl leading-relaxed text-muted-foreground">
          Simulasi trading menggunakan analyst dari
          <a
            href="https://tradersfamily.id/"
            target="_blank"
            rel="noopener noreferrer"
            class="font-bold text-green-800 hover:text-green-700 transition-colors"
          >
            TradersFamily
          </a>
          <br />
          Bantu investor
          <span
            class="inline-block px-2 py-0.5 rounded bg-black font-bold text-green-400"
          >
            memaksimalkan profit
          </span>
          dan mengelola
          <span
            class="inline-block px-2 py-0.5 rounded bg-black font-bold text-red-500"
          >
            risiko drawdown
          </span>.
        </p>
      </div>

      <div class="flex justify-center">
        <a href="/simulation">
          <Button size="lg" class="min-w-[200px]">Mulai Simulasi</Button>
        </a>
      </div>
    </div>
  </div>
</section>

<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { TrendingUp, Target, Activity, ChartBar, Users, Brain } from "@lucide/svelte";
</script>

<section class="min-h-screen bg-background">
  <!-- Hero Section -->
  <div class="flex flex-col items-center justify-center min-h-screen px-6">
    <div class="text-center space-y-8 max-w-4xl">
      <div class="space-y-4">
        <h1 class="text-5xl md:text-6xl font-bold tracking-tight">
          TradersFamily Analyst
        </h1>
        <p class="text-xl text-muted-foreground">
          Advanced trading simulation environment for TradersFamily analysts. 
          Analyze trader performance, test strategies, and provide data-driven insights.
        </p>
      </div>

      <div class="flex justify-center">
        <a href="/simulation">
          <Button size="lg" class="min-w-[200px]">
            Start Simulation
          </Button>
        </a>
      </div>

    </div>
  </div>
</section>

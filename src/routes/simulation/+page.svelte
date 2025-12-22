<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { Card, CardContent, CardHeader, CardTitle } from "$lib/components/ui/card";
  import TraderAnalystForm from "$lib/components/TraderAnalystForm.svelte";

  let showTraderForm = true;

  function handleTraderAdded(trader: any) {
    console.log('New trader added:', trader);
    // You can add any additional logic here when a trader is added
  }
</script>

<section class="min-h-screen bg-background p-6">
  <div class="w-full mx-auto space-y-8">
    <div class="text-center space-y-6">
      <h1 class="text-4xl font-bold">Trading Simulation</h1>
      <p class="text-xl text-muted-foreground">
        Manage trader analysts and their trading data
      </p>
    </div>

    <!-- Trader Analyst Management -->
    <div class="space-y-6">
      <TraderAnalystForm onTraderAdded={handleTraderAdded} />
    </div>
  </div>
</section>
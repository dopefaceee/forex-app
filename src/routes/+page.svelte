<script lang="ts">
  import { Button } from "$lib/components/ui/button";
</script>

<section class="min-h-screen flex flex-col items-center justify-center px-6">
  <div class="text-center space-y-6">
    <h1 class="text-4xl font-bold">
      Forex Risk Tools
    </h1>

    <p class="text-muted-foreground max-w-xl">
      Tools untuk membantu trader Indonesia menghitung lot size,
      mengontrol risiko, dan menghindari margin call.
    </p>

    <!-- BUTTON TO NEW PAGE -->
    <a href="/lot-calculator">
      <Button size="lg">
        Hitung Lot Size (Risk %)
      </Button>
    </a>
     <a href="/trade-tracker">
      <Button size="lg">
        Trade Tracker
      </Button>
    </a>
  </div>
</section>

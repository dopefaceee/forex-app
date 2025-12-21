<script lang="ts">
  import { page } from '$app/stores';
  import { Button } from "$lib/components/ui/button";
  import { Card, CardContent, CardHeader, CardTitle } from "$lib/components/ui/card";
  import { 
    Table, 
    TableBody, 
    TableCell, 
    TableHead, 
    TableHeader, 
    TableRow 
  } from "$lib/components/ui/table";
  import { supabase } from "$lib/supabaseClient";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";

  let trader: any = null;
  let trades: any[] = [];
  let traderId: string;
  let isLoading = true;
  let tradesLoading = true;
  let error = "";

  $: traderId = $page.params.id;

  onMount(async () => {
    await Promise.all([loadTrader(), loadTrades()]);
  });

  async function loadTrader() {
    if (!traderId) return;
    
    try {
      console.log('Loading trader with ID:', traderId);
      const { data, error: fetchError } = await supabase
        .from('trader_analysts')
        .select('*')
        .eq('id', traderId)
        .single();

      if (fetchError) {
        console.error('Error loading trader:', fetchError);
        error = fetchError.message;
        return;
      }

      trader = data;
      console.log('Loaded trader:', trader);
    } catch (err) {
      console.error('Error loading trader:', err);
      error = "Failed to load trader details";
    } finally {
      isLoading = false;
    }
  }

  async function loadTrades() {
    if (!traderId) return;
    
    try {
      console.log('Loading trades for trader ID:', traderId);
      const { data, error: fetchError } = await supabase
        .from('trades')
        .select('*')
        .eq('trader_id', traderId)
        .order('created_at', { ascending: false });

      if (fetchError) {
        console.error('Error loading trades:', fetchError);
        return;
      }

      trades = data || [];
      console.log('Loaded trades:', trades.length);
    } catch (err) {
      console.error('Error loading trades:', err);
    } finally {
      tradesLoading = false;
    }
  }

  function goBack() {
    goto('/simulation');
  }

  function formatPrice(price: number | null | undefined): string {
    if (price == null) return '-';
    return price.toFixed(2);
  }

  function formatProfit(profit: number | null | undefined): string {
    if (profit == null) return '-';
    return profit >= 0 ? `+$${profit.toFixed(2)}` : `-$${Math.abs(profit).toFixed(2)}`;
  }

  function formatDateTime(dateTime: string | null | undefined): string {
    if (!dateTime) return '-';
    const date = new Date(dateTime);
    const options: Intl.DateTimeFormatOptions = {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Asia/Jakarta'
    };
    return date.toLocaleDateString('en-GB', options).replace(',', '');
  }

  function formatPips(pips: number | null | undefined): string {
    if (pips == null) return '-';
    return pips >= 0 ? `+${pips}` : `${pips}`;
  }

  // Filter state
  let selectedYear: number | null = null;
  let selectedMonth: number | null = null;

  // Month names
  const months = [
    { name: 'Jan', number: 0 },
    { name: 'Feb', number: 1 },
    { name: 'Mar', number: 2 },
    { name: 'Apr', number: 3 },
    { name: 'Mei', number: 4 },
    { name: 'Jun', number: 5 },
    { name: 'Jul', number: 6 },
    { name: 'Agu', number: 7 },
    { name: 'Sep', number: 8 },
    { name: 'Okt', number: 9 },
    { name: 'Nov', number: 10 },
    { name: 'Des', number: 11 }
  ];

  // Get available years and months from trades data
  $: availableYears = [...new Set(trades.map(trade => {
    return new Date(trade.created_at).getFullYear();
  }))].sort((a, b) => b - a);

  $: availableMonths = [...new Set(trades.map(trade => {
    const date = new Date(trade.created_at);
    if (selectedYear && date.getFullYear() === selectedYear) {
      return date.getMonth();
    }
    return null;
  }).filter(month => month !== null))].sort((a, b) => a - b);

  // Filter trades based on selected year and month
  $: filteredTrades = trades.filter(trade => {
    const date = new Date(trade.created_at);
    if (selectedYear && date.getFullYear() !== selectedYear) return false;
    if (selectedMonth !== null && date.getMonth() !== selectedMonth) return false;
    return true;
  });

  // Calculate summary statistics based on filtered trades
  $: totalTrades = filteredTrades.length;
  $: profitableTrades = filteredTrades.filter(t => (t.profit || 0) > 0).length;
  $: losingTrades = filteredTrades.filter(t => (t.profit || 0) < 0).length;
  $: winRate = totalTrades > 0 ? (profitableTrades / totalTrades) * 100 : 0;
  $: totalProfit = filteredTrades.reduce((sum, trade) => sum + (trade.profit || 0), 0);
  $: totalPips = filteredTrades.reduce((sum, trade) => sum + (trade.pips || 0), 0);

  function selectYear(year: number) {
    selectedYear = year;
    selectedMonth = null; // Reset month when year changes
  }

  function selectMonth(month: number) {
    selectedMonth = month;
  }

  function clearFilters() {
    selectedYear = null;
    selectedMonth = null;
  }
</script>

<section class="min-h-screen bg-background p-6">
  <div class="max-w-4xl mx-auto space-y-8">
    <!-- Header -->
    <div class="flex items-center gap-4">
      <Button variant="outline" onclick={goBack}>
        ← Back to Simulation
      </Button>
      <div>
        <h1 class="text-3xl font-bold">Trader Details</h1>
        {#if trader}
          <p class="text-muted-foreground">{trader.name}</p>
        {/if}
      </div>
    </div>

    {#if isLoading}
      <Card>
        <CardContent class="p-8">
          <div class="text-center">
            <p class="text-muted-foreground">Loading trader details...</p>
          </div>
        </CardContent>
      </Card>
    {:else if error}
      <Card>
        <CardContent class="p-8">
          <div class="text-center">
            <p class="text-red-600">Error: {error}</p>
            <Button onclick={goBack} class="mt-4">Go Back</Button>
          </div>
        </CardContent>
      </Card>
    {:else if trader}
      <!-- Trader Information -->
      <Card>
        <CardHeader>
          <CardTitle>Trader Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="text-sm font-medium text-muted-foreground">Name</label>
              <p class="text-lg font-semibold">{trader.name}</p>
            </div>
            <div>
              <label class="text-sm font-medium text-muted-foreground">ID</label>
              <p class="text-lg">{trader.id}</p>
            </div>
            <div>
              <label class="text-sm font-medium text-muted-foreground">Added Date</label>
              <p class="text-lg">{new Date(trader.created_at).toLocaleDateString('id-ID', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                timeZone: 'Asia/Jakarta'
              })}</p>
            </div>
            <div>
              <label class="text-sm font-medium text-muted-foreground">Last Updated</label>
              <p class="text-lg">{new Date(trader.updated_at).toLocaleDateString('id-ID', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                timeZone: 'Asia/Jakarta'
              })}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Year Filter -->
      <Card>
        <CardHeader>
          <CardTitle class="flex items-center justify-between">
            Year Filter
            {#if selectedYear || selectedMonth !== null}
              <Button variant="outline" size="sm" onclick={clearFilters}>
                Clear Filters
              </Button>
            {/if}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div class="flex flex-wrap gap-2">
            {#each availableYears as year}
              <button
                onclick={() => selectYear(year)}
                class="px-4 py-2 rounded-lg border transition-colors {selectedYear === year 
                  ? 'bg-primary text-primary-foreground border-primary' 
                  : 'bg-background border-border hover:bg-muted'}"
              >
                {year}
              </button>
            {/each}
          </div>
        </CardContent>
      </Card>

      <!-- Month Filter -->
      {#if selectedYear}
        <Card>
          <CardHeader>
            <CardTitle>Month Filter for {selectedYear}</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="grid grid-cols-6 md:grid-cols-12 gap-2">
              {#each months as month}
                {@const hasData = availableMonths.includes(month.number)}
                <button
                  onclick={() => selectMonth(month.number)}
                  disabled={!hasData}
                  class="px-3 py-2 rounded-lg border text-sm transition-colors {selectedMonth === month.number 
                    ? 'bg-primary text-primary-foreground border-primary' 
                    : hasData 
                      ? 'bg-background border-border hover:bg-muted' 
                      : 'bg-muted border-muted text-muted-foreground cursor-not-allowed'}"
                >
                  {month.name}
                </button>
              {/each}
            </div>
          </CardContent>
        </Card>
      {/if}

      <!-- Trades Table -->
      {#if selectedYear}
        <Card>
          <CardHeader>
            <CardTitle>
              Trade History - {selectedYear}
              {#if selectedMonth !== null}
                {months[selectedMonth].name}
              {/if}
              ({totalTrades} trades)
            </CardTitle>
          </CardHeader>
          <CardContent>
            {#if tradesLoading}
              <div class="text-center py-8">
                <p class="text-muted-foreground">Loading trades...</p>
              </div>
            {:else if filteredTrades.length === 0}
              <div class="text-center py-12">
                <div class="text-muted-foreground space-y-2">
                  <p class="text-lg">No trades found</p>
                  <p class="text-sm">No trades found for selected period</p>
                </div>
              </div>
            {:else}
              <div class="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Symbol</TableHead>
                      <TableHead>Entry Price</TableHead>
                      <TableHead>SL</TableHead>
                      <TableHead>TP</TableHead>
                      <TableHead>Close Price</TableHead>
                      <TableHead>Created</TableHead>
                      <TableHead>Closed</TableHead>
                      <TableHead>Pips</TableHead>
                      <TableHead>Profit/Loss</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {#each filteredTrades as trade}
                      <TableRow>
                        <TableCell class="font-medium">{trade.symbol}</TableCell>
                        <TableCell>{formatPrice(trade.price)}</TableCell>
                        <TableCell class="text-red-500">{formatPrice(trade.sl)}</TableCell>
                        <TableCell class="text-green-500">{formatPrice(trade.tp)}</TableCell>
                        <TableCell>{formatPrice(trade.close_price)}</TableCell>
                        <TableCell class="text-xs">{formatDateTime(trade.created_at)}</TableCell>
                        <TableCell class="text-xs">{formatDateTime(trade.close_time)}</TableCell>
                        <TableCell class="{(trade.pips || 0) >= 0 ? 'text-green-600' : 'text-red-600'} font-medium">
                          {formatPips(trade.pips)}
                        </TableCell>
                        <TableCell class="{(trade.profit || 0) >= 0 ? 'text-green-600' : 'text-red-600'} font-medium">
                          {formatProfit(trade.profit)}
                        </TableCell>
                      </TableRow>
                    {/each}
                  </TableBody>
                </Table>
              </div>
            {/if}
          </CardContent>
        </Card>
      {:else}
        <Card>
          <CardHeader>
            <CardTitle>Trade History</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="text-center py-12">
              <div class="text-muted-foreground space-y-2">
                <p class="text-lg">Select a year to view trade history</p>
                <p class="text-sm">Choose a year from the filter above to see trades</p>
              </div>
            </div>
          </CardContent>
        </Card>
      {/if}
    {:else}
      <Card>
        <CardContent class="p-8">
          <div class="text-center">
            <p class="text-muted-foreground">Trader not found</p>
            <Button onclick={goBack} class="mt-4">Go Back</Button>
          </div>
        </CardContent>
      </Card>
    {/if}
  </div>
</section>
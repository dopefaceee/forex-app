<script lang="ts">
  import { page } from '$app/stores';
  import { Button } from "$lib/components/ui/button";
  import { Card, CardContent, CardHeader, CardTitle } from "$lib/components/ui/card";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
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
  import { AreaChart, Area } from 'layerchart';
  import { scaleLinear, scaleTime } from 'd3-scale';
  import { curveNatural } from 'd3-shape';
  import * as Chart from "$lib/components/ui/chart/index.js";
  import { Trash2 } from "@lucide/svelte";

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
        .eq('secure_id', traderId)
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
        .eq('secure_trader_id', traderId)
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

  function formatUSD(amount: number): string {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  }

  function formatIDR(amount: number): string {
    const idrAmount = amount * 10000; // Convert USD to IDR at 10,000 rate
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(idrAmount);
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

  // Simulation variables
  let simulationBalance = 5000; // Default $5000 USD
  let simulationLot = 0.01; // Default 0.01 lot
  let simulationMonth: number | null = null;
  let simulationYear: number | null = null;
  let simulationUseCustomRange = false;
  let simulationStartDate = '';
  let simulationEndDate = '';
  let simulationResults: any = null;
  let isSimulating = false;

  // Available months and years for simulation
  $: simulationAvailableMonths = [...new Set(trades.map(trade => {
    const date = new Date(trade.created_at);
    if (simulationYear && date.getFullYear() === simulationYear) {
      return date.getMonth();
    }
    return null;
  }).filter(month => month !== null))].sort((a, b) => a - b);

  function runSimulation() {
    // Validation based on selected mode
    if (simulationUseCustomRange) {
      if (!simulationStartDate && !simulationEndDate) {
        alert('Please select at least one date for simulation');
        return;
      }
    } else {
      if (!simulationYear || simulationMonth === null) {
        alert('Please select year and month for simulation');
        return;
      }
    }

    isSimulating = true;

    // Filter trades based on selected mode and sort by date ascending (earliest first)
    const simulationTrades = trades.filter(trade => {
      const date = new Date(trade.created_at);
      
      if (simulationUseCustomRange) {
        // Use custom date range
        if (simulationStartDate) {
          const start = new Date(simulationStartDate);
          if (date < start) return false;
        }
        if (simulationEndDate) {
          const end = new Date(simulationEndDate);
          end.setHours(23, 59, 59, 999); // Include the entire end date
          if (date > end) return false;
        }
        return true;
      } else {
        // Use year/month filter
        return date.getFullYear() === simulationYear && date.getMonth() === simulationMonth;
      }
    }).sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());

    if (simulationTrades.length === 0) {
      alert('No trades found for selected period');
      isSimulating = false;
      return;
    }

    // Calculate simulation results
    let currentBalance = simulationBalance;
    const tradeResults = simulationTrades.map(trade => {
      // Simple calculation: lot × pips (in USD)
      // If pips is positive = profit, if negative = loss
      const tradePnLUSD = simulationLot * (trade.pips || 0);
      
      currentBalance += tradePnLUSD;

      return {
        ...trade,
        simulatedPnL: tradePnLUSD,
        balanceAfter: currentBalance
      };
    });

    const totalPnL = currentBalance - simulationBalance;
    const winningTrades = tradeResults.filter(t => t.simulatedPnL > 0).length;
    const losingTrades = tradeResults.filter(t => t.simulatedPnL < 0).length;
    const winRate = tradeResults.length > 0 ? (winningTrades / tradeResults.length) * 100 : 0;

    // Prepare chart data for balance progression (accumulate by date)
    const chartData = generateChartData(tradeResults, simulationBalance);
    console.log('Generated chart data:', chartData);
    console.log('Chart data length:', chartData.length);

    simulationResults = {
      trades: tradeResults,
      startingBalance: simulationBalance,
      endingBalance: currentBalance,
      totalPnL: totalPnL,
      winningTrades,
      losingTrades,
      winRate,
      totalTrades: tradeResults.length,
      chartData: chartData
    };

    console.log('Simulation results:', simulationResults);

    isSimulating = false;
  }

  function generateChartData(tradeResults, startingBalance) {
    if (!tradeResults || tradeResults.length === 0) {
      return [];
    }

    // Sort trades by date first to ensure proper order
    const sortedTrades = [...tradeResults].sort((a, b) => {
      return new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
    });

    // Group trades by date (same day trades will be accumulated)
    const dailyTradesMap = new Map();
    
    sortedTrades.forEach((trade) => {
      if (!trade || !trade.created_at || typeof trade.balanceAfter !== 'number') {
        return;
      }

      try {
        const tradeDate = new Date(trade.created_at);
        if (isNaN(tradeDate.getTime())) {
          return;
        }
        
        // Use date only (no time) for grouping same-day trades
        const dateKey = tradeDate.toISOString().split('T')[0];
        
        if (!dailyTradesMap.has(dateKey)) {
          dailyTradesMap.set(dateKey, []);
        }
        dailyTradesMap.get(dateKey).push(trade);
        
      } catch (error) {
        console.warn('Skipping invalid trade data:', error);
      }
    });

    // Determine the full date range to display
    let startDate, endDate;
    
    if (simulationUseCustomRange) {
      startDate = simulationStartDate ? new Date(simulationStartDate) : new Date(sortedTrades[0].created_at);
      endDate = simulationEndDate ? new Date(simulationEndDate) : new Date(sortedTrades[sortedTrades.length - 1].created_at);
    } else {
      // Use year/month range
      startDate = new Date(simulationYear, simulationMonth, 1);
      endDate = new Date(simulationYear, simulationMonth + 1, 0); // Last day of the month
    }

    // Generate chart data for EVERY day in the range
    const chartData = [];
    let currentBalance = startingBalance;
    let totalTradeCount = 0;
    
    // Iterate through every day in the range
    const currentDate = new Date(startDate);
    
    while (currentDate <= endDate) {
      const dateKey = currentDate.toISOString().split('T')[0];
      const dayTrades = dailyTradesMap.get(dateKey) || [];
      
      if (dayTrades.length > 0) {
        // Day with trades - update balance and trade count
        const lastTradeOfDay = dayTrades[dayTrades.length - 1];
        currentBalance = lastTradeOfDay.balanceAfter;
        
        // Calculate total P&L for this day
        const dayPnL = dayTrades.reduce((sum, trade) => sum + (trade.simulatedPnL || 0), 0);
        
        // Update trade count
        totalTradeCount += dayTrades.length;
        
        chartData.push({
          date: new Date(currentDate),
          balance: currentBalance,
          trades: totalTradeCount,
          dailyTrades: dayTrades.length,
          simulatedPnL: dayPnL,
          details: dayTrades.length === 1 
            ? `${currentDate.toLocaleDateString('en-GB')}: ${dayPnL >= 0 ? '+' : ''}$${dayPnL.toFixed(2)}` 
            : `${currentDate.toLocaleDateString('en-GB')}: ${dayTrades.length} trades, ${dayPnL >= 0 ? '+' : ''}$${dayPnL.toFixed(2)}`,
          isProfit: dayPnL > 0,
          isLoss: dayPnL < 0,
          hasTrades: true
        });
      } else {
        // Day without trades - keep same balance
        chartData.push({
          date: new Date(currentDate),
          balance: currentBalance,
          trades: totalTradeCount,
          dailyTrades: 0,
          simulatedPnL: 0,
          details: `${currentDate.toLocaleDateString('en-GB')}: No trades`,
          isProfit: false,
          isLoss: false,
          hasTrades: false
        });
      }
      
      // Move to next day
      currentDate.setDate(currentDate.getDate() + 1);
    }
    
    return chartData;
  }

  function clearSimulation() {
    simulationResults = null;
    simulationMonth = null;
    simulationYear = null;
    simulationUseCustomRange = false;
    simulationStartDate = '';
    simulationEndDate = '';
  }

  function toggleSimulationMode() {
    simulationUseCustomRange = !simulationUseCustomRange;
    // Clear existing settings when switching modes
    if (simulationUseCustomRange) {
      simulationMonth = null;
      simulationYear = null;
    } else {
      simulationStartDate = '';
      simulationEndDate = '';
    }
  }

  // Helper function for clean date formatting
  function formatChartDate(date: Date): string {
    try {
      return date.toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
        timeZone: 'Asia/Jakarta'
      });
    } catch (e) {
      return 'Hari ini';
    }
  }

  // Delete trade functionality
  let deleteMessage = "";
  let deleteMessageType: "success" | "error" | "" = "";
  let deletingTradeId: number | null = null;

  async function deleteTrade(tradeId: number) {
    const confirmed = confirm("Are you sure you want to delete this trade? This action cannot be undone.");
    if (!confirmed) return;

    deletingTradeId = tradeId;
    deleteMessage = "";
    deleteMessageType = "";

    try {
      const { error } = await supabase
        .from('trades')
        .delete()
        .eq('id', tradeId);

      if (error) {
        console.error('Error deleting trade:', error);
        deleteMessage = `Error: ${error.message}`;
        deleteMessageType = "error";
        return;
      }

      deleteMessage = "Trade deleted successfully";
      deleteMessageType = "success";
      
      // Reload trades to update the list
      await loadTrades();
      
      // Clear simulation results if they exist (since trade data changed)
      if (simulationResults) {
        simulationResults = null;
      }

    } catch (error) {
      console.error('Error deleting trade:', error);
      deleteMessage = "An unexpected error occurred";
      deleteMessageType = "error";
    } finally {
      deletingTradeId = null;
      
      // Clear message after 3 seconds
      if (deleteMessage) {
        setTimeout(() => {
          deleteMessage = "";
          deleteMessageType = "";
        }, 3000);
      }
    }
  }

  // Chart configuration
  const chartConfig = {
    balance: {
      label: "Balance (USD)",
      color: "var(--chart-1)"
    }
  } satisfies Chart.Config;
</script>

<section class="min-h-screen bg-background">
  <!-- Back Navigation - Fixed at top -->
  <div class="sticky top-0 z-10 bg-background/80 backdrop-blur-sm border-b border-border/40 px-6 py-3">
    <div class="max-w-full mx-auto">
      <Button variant="ghost" onclick={goBack} class="text-muted-foreground hover:text-foreground -ml-2">
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Back to Simulation
      </Button>
    </div>
  </div>

  <div class="w-full px-6 py-8 space-y-8">
    <!-- Header -->
    <div class="text-center space-y-4">
      <h1 class="text-3xl font-bold">Trader Details</h1>
      {#if trader}
        <p class="text-xl text-muted-foreground">{trader.name}</p>
      {/if}
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
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <label class="text-sm font-medium text-muted-foreground">Name</label>
              <p class="text-lg font-semibold">{trader.name}</p>
            </div>
            <div>
              <label class="text-sm font-medium text-muted-foreground">ID</label>
              <p class="text-lg">{trader.secure_id}</p>
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

      <!-- Trading Simulation -->
      <Card>
        <CardHeader>
          <CardTitle>Trading Simulation</CardTitle>
        </CardHeader>
        <CardContent class="space-y-6">
          <!-- Simulation Form -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <Label for="sim-balance">Balance (USD)</Label>
              <Input
                id="sim-balance"
                type="number"
                bind:value={simulationBalance}
                placeholder="5000"
                step="100"
                min="100"
              />
              <p class="text-xs text-muted-foreground mt-1">
                ≈ {formatIDR(simulationBalance)} (Rate: 1 USD = 10,000 IDR)
              </p>
            </div>
            
            <div>
              <Label for="sim-lot">Lot Size</Label>
              <Input
                id="sim-lot"
                type="number"
                bind:value={simulationLot}
                placeholder="0.01"
                step="0.01"
                min="0.01"
                max="10"
              />
            </div>

            <!-- Period Selection Mode Toggle -->
            <div class="md:col-span-2">
              <Label>Period Selection</Label>
              <div class="flex items-center space-x-2 mt-2">
                <Button 
                  variant={!simulationUseCustomRange ? "default" : "outline"} 
                  size="sm" 
                  onclick={() => !simulationUseCustomRange || toggleSimulationMode()}
                  disabled={!simulationUseCustomRange}
                >
                  Year/Month
                </Button>
                <Button 
                  variant={simulationUseCustomRange ? "default" : "outline"} 
                  size="sm" 
                  onclick={() => simulationUseCustomRange || toggleSimulationMode()}
                  disabled={simulationUseCustomRange}
                >
                  Custom Range
                </Button>
              </div>
            </div>
          </div>

          <!-- Period Selection Fields -->
          {#if !simulationUseCustomRange}
            <!-- Year/Month Selection -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label for="sim-year">Year</Label>
                <select 
                  id="sim-year"
                  bind:value={simulationYear}
                  class="w-full px-3 py-2 border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring"
                >
                  <option value={null}>Select year...</option>
                  {#each availableYears as year}
                    <option value={year}>{year}</option>
                  {/each}
                </select>
              </div>
            
              <div>
                <Label for="sim-month">Month</Label>
                <select 
                  id="sim-month"
                  bind:value={simulationMonth}
                  disabled={!simulationYear}
                  class="w-full px-3 py-2 border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring disabled:opacity-50"
                >
                  <option value={null}>Select month...</option>
                  {#each simulationAvailableMonths as monthNum}
                    <option value={monthNum}>{months[monthNum].name}</option>
                  {/each}
                </select>
              </div>
            </div>
          {:else}
            <!-- Custom Date Range Selection -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label for="sim-start-date">Start Date</Label>
                <Input
                  id="sim-start-date"
                  type="date"
                  bind:value={simulationStartDate}
                  class="w-full"
                />
              </div>
              <div>
                <Label for="sim-end-date">End Date</Label>
                <Input
                  id="sim-end-date"
                  type="date"
                  bind:value={simulationEndDate}
                  class="w-full"
                />
              </div>
            </div>
          {/if}

          <!-- Simulation Actions -->
          <div class="flex gap-4">
            <Button 
              onclick={runSimulation}
              disabled={isSimulating || (simulationUseCustomRange ? (!simulationStartDate && !simulationEndDate) : (!simulationYear || simulationMonth === null))}
            >
              {isSimulating ? 'Simulating...' : 'Run Simulation'}
            </Button>
            
            {#if simulationResults}
              <Button variant="outline" onclick={clearSimulation}>
                Clear Results
              </Button>
            {/if}
          </div>

          <!-- Simulation Results -->
          {#if simulationResults}
            <div class="space-y-4 mt-6 pt-6 border-t">
              <h3 class="text-lg font-semibold">
                Simulation Results - 
                {#if simulationUseCustomRange}
                  {#if simulationStartDate && simulationEndDate}
                    {new Date(simulationStartDate).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })} 
                    to {new Date(simulationEndDate).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                  {:else if simulationStartDate}
                    From {new Date(simulationStartDate).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                  {:else if simulationEndDate}
                    Until {new Date(simulationEndDate).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                  {:else}
                    Custom Range
                  {/if}
                {:else}
                  {simulationYear} {months[simulationMonth].name}
                {/if}
              </h3>
              
              <!-- Results Summary -->
              <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-4 gap-4">
                <div class="text-center p-4 bg-muted rounded-lg">
                  <p class="text-sm text-muted-foreground">Starting Balance</p>
                  <p class="text-lg font-bold">{formatUSD(simulationResults.startingBalance)}</p>
                  <p class="text-xs text-muted-foreground">{formatIDR(simulationResults.startingBalance)}</p>
                </div>
                
                <div class="text-center p-4 bg-muted rounded-lg">
                  <p class="text-sm text-muted-foreground">Ending Balance</p>
                  <p class="text-lg font-bold {simulationResults.endingBalance > simulationResults.startingBalance ? 'text-green-600' : 'text-red-600'}">
                    {formatUSD(simulationResults.endingBalance)}
                  </p>
                  <p class="text-xs text-muted-foreground">{formatIDR(simulationResults.endingBalance)}</p>
                </div>
                
                <div class="text-center p-4 bg-muted rounded-lg">
                  <p class="text-sm text-muted-foreground">Total P&L</p>
                  <p class="text-lg font-bold {simulationResults.totalPnL >= 0 ? 'text-green-600' : 'text-red-600'}">
                    {simulationResults.totalPnL >= 0 ? '+' : ''}{formatUSD(simulationResults.totalPnL)}
                  </p>
                  <p class="text-xs text-muted-foreground">{simulationResults.totalPnL >= 0 ? '+' : ''}{formatIDR(simulationResults.totalPnL)}</p>
                  <p class="text-xs font-medium {simulationResults.totalPnL >= 0 ? 'text-green-600' : 'text-red-600'}">
                    {simulationResults.totalPnL >= 0 ? '+' : ''}{((simulationResults.totalPnL / simulationResults.startingBalance) * 100).toFixed(2)}%
                  </p>
                </div>
                
                <div class="text-center p-4 bg-muted rounded-lg">
                  <p class="text-sm text-muted-foreground">Win Rate</p>
                  <p class="text-lg font-bold">{simulationResults.winRate.toFixed(1)}%</p>
                  <p class="text-xs text-muted-foreground">{simulationResults.winningTrades}W / {simulationResults.losingTrades}L</p>
                </div>
              </div>

              <!-- Balance Progression Chart -->
              <div class="mt-6">
                <h4 class="text-md font-semibold mb-4">Balance Progression Chart</h4>
                {#if simulationResults.chartData && simulationResults.chartData.length > 1}
                  {@const validChartData = simulationResults.chartData.filter(d => d && d.date && typeof d.balance === 'number')}
                  {console.log('Chart data exists:', simulationResults.chartData.length, 'Valid chart data:', validChartData.length)}
                  {#if validChartData.length > 1}
                    <Chart.Container config={chartConfig} class="aspect-auto h-[400px] w-full">
                      <AreaChart
                        data={validChartData}
                        x="date"
                        xScale={scaleTime()}
                        y="balance"
                        series={[
                          {
                            key: "balance",
                            label: "Balance",
                            color: chartConfig.balance.color,
                          }
                        ]}
                        props={{
                          area: {
                            curve: curveNatural,
                            "fill-opacity": 0.3,
                            line: { class: "stroke-2" },
                          },
                          xAxis: {
                            tickFormat: (d) => {
                              try {
                                return d instanceof Date ? d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' }) : '';
                              } catch (e) {
                                return '';
                              }
                            }
                          },
                          yAxis: {
                            tickFormat: (d) => {
                              try {
                                return typeof d === 'number' ? (d >= 1000 ? `$${(d/1000).toFixed(0)}K` : `$${d.toFixed(0)}`) : '';
                              } catch (e) {
                                return '';
                              }
                            }
                          }
                        }}
                      >
                        {#snippet tooltip()}
                          <Chart.Tooltip hideLabel />
                        {/snippet}
                      </AreaChart>
                    </Chart.Container>
                  {:else}
                    <div class="h-[400px] flex items-center justify-center border rounded-lg bg-muted/10">
                      <div class="text-center text-muted-foreground">
                        <p class="text-lg">Insufficient valid chart data</p>
                        <p class="text-sm">Found {validChartData.length} valid points, need at least 2</p>
                        <p class="text-xs mt-2">Raw data: {simulationResults.chartData.length} points</p>
                      </div>
                    </div>
                  {/if}
                {:else}
                  <div class="h-[400px] flex items-center justify-center border rounded-lg bg-muted/10">
                    <div class="text-center text-muted-foreground">
                      <p class="text-lg">No chart data generated</p>
                      <p class="text-sm">
                        {#if simulationResults.chartData}
                          Chart data exists but has {simulationResults.chartData.length} points (need >1)
                        {:else}
                          No chart data in simulation results
                        {/if}
                      </p>
                    </div>
                  </div>
                {/if}
              </div>

              <!-- Simulation Trade Results Table -->
              <div class="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Symbol</TableHead>
                      <TableHead>Pips</TableHead>
                      <TableHead>Simulated P&L</TableHead>
                      <TableHead>Balance After</TableHead>
                      <TableHead class="w-12">Action</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {#each simulationResults.trades as trade}
                      <TableRow>
                        <TableCell class="text-xs">{formatDateTime(trade.created_at)}</TableCell>
                        <TableCell class="font-medium">{trade.symbol}</TableCell>
                        <TableCell class="{(trade.pips || 0) >= 0 ? 'text-green-600' : 'text-red-600'} font-medium">
                          {formatPips(trade.pips)}
                        </TableCell>
                        <TableCell class="{trade.simulatedPnL >= 0 ? 'text-green-600' : 'text-red-600'} font-medium">
                          <div>{trade.simulatedPnL >= 0 ? '+' : ''}{formatUSD(trade.simulatedPnL)}</div>
                          <div class="text-xs text-muted-foreground">{trade.simulatedPnL >= 0 ? '+' : ''}{formatIDR(trade.simulatedPnL)}</div>
                        </TableCell>
                        <TableCell class="font-medium">
                          <div>{formatUSD(trade.balanceAfter)}</div>
                          <div class="text-xs text-muted-foreground">{formatIDR(trade.balanceAfter)}</div>
                        </TableCell>
                        <TableCell>
                          <Button 
                            variant="ghost" 
                            size="sm" 
                            onclick={() => deleteTrade(trade.id)}
                            disabled={deletingTradeId === trade.id}
                            class="h-8 w-8 p-0 hover:bg-red-50 hover:text-red-600"
                          >
                            {#if deletingTradeId === trade.id}
                              <div class="h-4 w-4 animate-spin rounded-full border-2 border-red-600 border-t-transparent"></div>
                            {:else}
                              <Trash2 class="h-4 w-4" />
                            {/if}
                          </Button>
                        </TableCell>
                      </TableRow>
                    {/each}
                  </TableBody>
                </Table>
              </div>
            </div>
          {/if}
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
            <div class="grid grid-cols-6 md:grid-cols-12 lg:grid-cols-12 gap-2">
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
            
            <!-- Delete Message Display -->
            {#if deleteMessage}
              <div class="mt-2 text-sm {deleteMessageType === 'success' ? 'text-green-600' : 'text-red-600'}">
                {deleteMessage}
              </div>
            {/if}
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
                      <TableHead class="w-12">Action</TableHead>
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
                        <TableCell>
                          <Button 
                            variant="ghost" 
                            size="sm" 
                            onclick={() => deleteTrade(trade.id)}
                            disabled={deletingTradeId === trade.id}
                            class="h-8 w-8 p-0 hover:bg-red-50 hover:text-red-600"
                          >
                            {#if deletingTradeId === trade.id}
                              <div class="h-4 w-4 animate-spin rounded-full border-2 border-red-600 border-t-transparent"></div>
                            {:else}
                              <Trash2 class="h-4 w-4" />
                            {/if}
                          </Button>
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
          </div>
        </CardContent>
      </Card>
    {/if}
  </div>
</section>
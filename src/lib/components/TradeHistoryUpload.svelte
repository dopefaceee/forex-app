<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import { Card, CardContent, CardHeader, CardTitle } from "$lib/components/ui/card";

  export type TradeHistory = {
    id: string;
    traderAnalystName: string;
    symbol: string;
    dateCreated: string;
    dateClosed: string;
    typeBuy: "buy" | "sell";
    price: number;
    takeProfit: number;
    stopLoss: number;
    pips: number;
    profitLoss: number;
  };

  export let onTradeHistoryUploaded: (trades: TradeHistory[]) => void;

  let fileInput: HTMLInputElement;
  let isLoading = false;
  
  // Manual entry form
  let manualTrade: Omit<TradeHistory, 'id'> = {
    traderAnalystName: "",
    symbol: "XAUUSD",
    dateCreated: "",
    dateClosed: "",
    typeBuy: "buy",
    price: 0,
    takeProfit: 0,
    stopLoss: 0,
    pips: 0,
    profitLoss: 0
  };

  let trades: TradeHistory[] = [];

  function handleFileUpload(event: Event) {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];
    
    if (!file) return;
    
    isLoading = true;
    
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const text = e.target?.result as string;
        const lines = text.split('\n');
        const headers = lines[0].split(',').map(h => h.trim().toLowerCase());
        
        const parsedTrades: TradeHistory[] = [];
        
        for (let i = 1; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line) continue;
          
          const values = line.split(',').map(v => v.trim());
          
          const trade: TradeHistory = {
            id: crypto.randomUUID(),
            traderAnalystName: values[headers.indexOf('trader')] || values[headers.indexOf('analyst')] || '',
            symbol: values[headers.indexOf('symbol')] || 'XAUUSD',
            dateCreated: values[headers.indexOf('created')] || values[headers.indexOf('open')] || '',
            dateClosed: values[headers.indexOf('closed')] || values[headers.indexOf('close')] || '',
            typeBuy: (values[headers.indexOf('type')] || 'buy').toLowerCase() as "buy" | "sell",
            price: parseFloat(values[headers.indexOf('price')] || '0'),
            takeProfit: parseFloat(values[headers.indexOf('takeprofit')] || values[headers.indexOf('tp')] || '0'),
            stopLoss: parseFloat(values[headers.indexOf('stoploss')] || values[headers.indexOf('sl')] || '0'),
            pips: parseFloat(values[headers.indexOf('pips')] || '0'),
            profitLoss: parseFloat(values[headers.indexOf('profit')] || values[headers.indexOf('pl')] || '0')
          };
          
          parsedTrades.push(trade);
        }
        
        trades = [...trades, ...parsedTrades];
        onTradeHistoryUploaded(trades);
      } catch (error) {
        console.error('Error parsing CSV:', error);
        alert('Error parsing CSV file. Please check the format.');
      } finally {
        isLoading = false;
      }
    };
    
    reader.readAsText(file);
  }

  function addManualTrade() {
    if (!manualTrade.traderAnalystName || !manualTrade.dateCreated) {
      alert('Please fill in at least trader name and creation date');
      return;
    }
    
    const newTrade: TradeHistory = {
      ...manualTrade,
      id: crypto.randomUUID()
    };
    
    trades = [...trades, newTrade];
    onTradeHistoryUploaded(trades);
    
    // Reset form
    manualTrade = {
      traderAnalystName: "",
      symbol: "XAUUSD",
      dateCreated: "",
      dateClosed: "",
      typeBuy: "buy",
      price: 0,
      takeProfit: 0,
      stopLoss: 0,
      pips: 0,
      profitLoss: 0
    };
  }

  function clearTrades() {
    trades = [];
    onTradeHistoryUploaded(trades);
  }
</script>

<div class="space-y-6">
  <!-- File Upload Section -->
  <Card>
    <CardHeader>
      <CardTitle>Upload Trade History</CardTitle>
    </CardHeader>
    <CardContent class="space-y-4">
      <div>
        <Label for="file-upload">Upload CSV File</Label>
        <Input
          id="file-upload"
          type="file"
          accept=".csv"
          bind:this={fileInput}
          on:change={handleFileUpload}
          disabled={isLoading}
        />
        <p class="text-sm text-muted-foreground mt-1">
          Expected columns: Trader/Analyst, Symbol, Created/Open, Closed/Close, Type, Price, TakeProfit/TP, StopLoss/SL, Pips, Profit/PL
        </p>
      </div>
      
      {#if isLoading}
        <div class="text-center py-4">
          <p class="text-sm text-muted-foreground">Processing file...</p>
        </div>
      {/if}
    </CardContent>
  </Card>

  <!-- Manual Entry Section -->
  <Card>
    <CardHeader>
      <CardTitle>Add Trade Manually</CardTitle>
    </CardHeader>
    <CardContent class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div>
          <Label for="trader">Trader/Analyst Name</Label>
          <Input id="trader" bind:value={manualTrade.traderAnalystName} placeholder="e.g. John Doe" />
        </div>
        
        <div>
          <Label for="symbol">Symbol</Label>
          <Input id="symbol" bind:value={manualTrade.symbol} placeholder="e.g. XAUUSD" />
        </div>
        
        <div>
          <Label for="type">Trade Type</Label>
          <select bind:value={manualTrade.typeBuy} class="w-full px-3 py-2 border border-input bg-background rounded-md">
            <option value="buy">Buy</option>
            <option value="sell">Sell</option>
          </select>
        </div>
        
        <div>
          <Label for="created">Date Created</Label>
          <Input id="created" type="datetime-local" bind:value={manualTrade.dateCreated} />
        </div>
        
        <div>
          <Label for="closed">Date Closed</Label>
          <Input id="closed" type="datetime-local" bind:value={manualTrade.dateClosed} />
        </div>
        
        <div>
          <Label for="price">Price</Label>
          <Input id="price" type="number" step="0.00001" bind:value={manualTrade.price} />
        </div>
        
        <div>
          <Label for="tp">Take Profit</Label>
          <Input id="tp" type="number" step="0.00001" bind:value={manualTrade.takeProfit} />
        </div>
        
        <div>
          <Label for="sl">Stop Loss</Label>
          <Input id="sl" type="number" step="0.00001" bind:value={manualTrade.stopLoss} />
        </div>
        
        <div>
          <Label for="pips">Pips</Label>
          <Input id="pips" type="number" step="0.1" bind:value={manualTrade.pips} />
        </div>
        
        <div>
          <Label for="pl">Profit/Loss ($)</Label>
          <Input id="pl" type="number" step="0.01" bind:value={manualTrade.profitLoss} />
        </div>
      </div>
      
      <div class="flex gap-2">
        <Button on:click={addManualTrade}>Add Trade</Button>
        {#if trades.length > 0}
          <Button variant="outline" on:click={clearTrades}>Clear All ({trades.length})</Button>
        {/if}
      </div>
    </CardContent>
  </Card>

  <!-- Preview Section -->
  {#if trades.length > 0}
    <Card>
      <CardHeader>
        <CardTitle>Uploaded Trades ({trades.length})</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="max-h-64 overflow-y-auto">
          <div class="text-xs space-y-2">
            {#each trades.slice(-5) as trade}
              <div class="flex gap-2 p-2 bg-muted rounded">
                <span class="font-medium">{trade.traderAnalystName}</span>
                <span>{trade.symbol}</span>
                <span class="capitalize">{trade.typeBuy}</span>
                <span class="text-muted-foreground">{trade.pips} pips</span>
                <span class={trade.profitLoss > 0 ? 'text-green-600' : 'text-red-600'}>
                  ${trade.profitLoss.toFixed(2)}
                </span>
              </div>
            {/each}
            {#if trades.length > 5}
              <p class="text-muted-foreground text-center">... and {trades.length - 5} more</p>
            {/if}
          </div>
        </div>
      </CardContent>
    </Card>
  {/if}
</div>
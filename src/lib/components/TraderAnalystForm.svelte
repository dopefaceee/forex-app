<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import { Card, CardContent, CardHeader, CardTitle } from "$lib/components/ui/card";
  import { supabase } from "$lib/supabaseClient";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";

  export let onTraderAdded: (trader: any) => void = () => {};

  let traderName = "";
  let isLoading = false;
  let isLoadingTraders = true;
  let hasLoadedTraders = false;
  let message = "";
  let messageType: "success" | "error" | "" = "";
  let tradersList: any[] = [];

  onMount(async () => {
    console.log('Component mounted');
    console.log('Supabase client:', supabase);
    await testConnection();
    await loadTraders();
  });

  async function testConnection() {
    try {
      console.log('Testing Supabase connection...');
      const { data, error } = await supabase.from('trader_analysts').select('count', { count: 'exact', head: true });
      console.log('Connection test result:', { data, error });
      if (error) {
        setMessage(`Connection error: ${error.message}`, "error");
      } else {
        console.log('Supabase connection successful');
      }
    } catch (error) {
      console.error('Connection test failed:', error);
      setMessage("Failed to connect to database", "error");
    }
  }

  async function loadTraders() {
    console.log('loadTraders function called');
    isLoadingTraders = true;
    try {
      console.log('Calling supabase select...');
      const { data, error } = await supabase
        .from('trader_analysts')
        .select('*')
        .order('created_at', { ascending: false });

      console.log('Load traders response:', { data, error });

      if (error) {
        console.error('Error loading traders:', error);
        setMessage(`Error loading traders: ${error.message}`, "error");
        return;
      }

      tradersList = data || [];
      console.log('Loaded traders count:', tradersList.length);
    } catch (error) {
      console.error('Error loading traders:', error);
      setMessage("Error connecting to database", "error");
    } finally {
      isLoadingTraders = false;
      hasLoadedTraders = true;
    }
  }

  async function addTrader() {
    console.log('addTrader function called');
    console.log('traderName:', traderName);
    
    if (!traderName.trim()) {
      setMessage("Please enter a trader/analyst name", "error");
      return;
    }

    isLoading = true;
    setMessage("", "");
    console.log('Starting to add trader to Supabase...');

    try {
      console.log('Calling supabase insert...');
      
      // Generate a secure UUID for the new trader
      const secureId = crypto.randomUUID();
      console.log('Generated secure ID:', secureId);
      
      const { data, error } = await supabase
        .from('trader_analysts')
        .insert([
          {
            name: traderName.trim(),
            secure_id: secureId
          }
        ])
        .select()
        .single();

      console.log('Supabase response:', { data, error });

      if (error) {
        console.error('Error adding trader:', error);
        setMessage(`Error: ${error.message}`, "error");
        return;
      }

      setMessage(`Trader "${traderName}" added successfully!`, "success");
      onTraderAdded(data);
      
      // Reset form
      traderName = "";
      
      // Reload traders list
      await loadTraders();

    } catch (error) {
      console.error('Error adding trader:', error);
      setMessage("An unexpected error occurred", "error");
    } finally {
      isLoading = false;
    }
  }

  function setMessage(msg: string, type: "success" | "error" | "") {
    message = msg;
    messageType = type;
    if (msg) {
      setTimeout(() => {
        message = "";
        messageType = "";
      }, 5000);
    }
  }

  async function deleteTrader(id: number) {
    if (!confirm("Are you sure you want to delete this trader?")) return;

    try {
      const { error } = await supabase
        .from('trader_analysts')
        .delete()
        .eq('id', id);

      if (error) {
        console.error('Error deleting trader:', error);
        setMessage(`Error: ${error.message}`, "error");
        return;
      }

      setMessage("Trader deleted successfully", "success");
      await loadTraders();
    } catch (error) {
      console.error('Error deleting trader:', error);
      setMessage("An unexpected error occurred", "error");
    }
  }

  function goToTraderDetail(trader: any) {
    console.log('Navigating to trader detail:', trader);
    goto(`/simulation/trader/${trader.secure_id}`);
  }
</script>

<div class="space-y-6">
  <!-- Add Trader Form -->
  <Card>
    <CardHeader>
      <CardTitle>Add Trader/Analyst</CardTitle>
    </CardHeader>
    <CardContent class="space-y-4">
      <div>
        <Label for="trader-name">Trader/Analyst Name *</Label>
        <Input
          id="trader-name"
          bind:value={traderName}
          placeholder="e.g. John Doe"
          disabled={isLoading}
        />
      </div>

      <div class="flex gap-2 items-center">
        <Button onclick={addTrader} disabled={isLoading}>
          {isLoading ? "Adding..." : "Add Trader"}
        </Button>
        
        {#if message}
          <div class="text-sm {messageType === 'success' ? 'text-green-600' : 'text-red-600'}">
            {message}
          </div>
        {/if}
      </div>
    </CardContent>
  </Card>

  <!-- Traders List -->
  <Card>
    <CardHeader>
      <CardTitle>
        {#if isLoadingTraders}
          Loading Traders...
        {:else}
          Existing Traders/Analysts ({tradersList.length})
        {/if}
      </CardTitle>
    </CardHeader>
    <CardContent>
      {#if isLoadingTraders}
        <div class="flex items-center justify-center py-8">
          <div class="flex items-center space-x-2 text-muted-foreground">
            <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-600"></div>
            <span>Loading trader data...</span>
          </div>
        </div>
      {:else if tradersList.length > 0}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-96 overflow-y-auto">
          {#each tradersList as trader}
            <div class="flex justify-between items-center p-4 bg-muted rounded-lg">
              <div class="cursor-pointer flex-1" onclick={() => goToTraderDetail(trader)}>
                <div class="font-medium text-blue-600 hover:text-blue-800 hover:underline">{trader.name}</div>
                <div class="text-xs text-muted-foreground">
                  Added: {new Date(trader.created_at).toLocaleDateString('id-ID', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    timeZone: 'Asia/Jakarta'
                  })}
                </div>
              </div>
              <Button 
                variant="outline" 
                size="sm" 
                onclick={() => deleteTrader(trader.id)}
                class="ml-2"
              >
                Delete
              </Button>
            </div>
          {/each}
        </div>
      {:else if hasLoadedTraders}
        <div class="text-center py-8 text-muted-foreground">
          No traders found. Add a trader to get started.
        </div>
      {/if}
    </CardContent>
  </Card>
</div>
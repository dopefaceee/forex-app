<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "$lib/components/ui/card";
  import { Button } from "$lib/components/ui/button";
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

  type TradeType = "profit" | "loss";

  type Trade = {
    id: string;
    date: string;
    lot: number;
    pips: number; // nominal positive
    type: TradeType;
    note: string;
  };

  // =====================
  // SETTINGS
  // =====================
  let startingBalanceIdr = 50_000_000;

  // Nilai 1 pip / point untuk 1 lot (IDR)
  let valuePerPipPerLotIdr = 10_000;

  // P/L dikali 10 (sesuai request)
  const PL_MULTIPLIER = 10;

  // Initial trades (contoh)
  let trades: Trade[] = [
    { id: crypto.randomUUID(), date: new Date().toISOString().split('T')[0], lot: 0.16, pips: 300, type: "loss", note: "Example loss" },
    { id: crypto.randomUUID(), date: new Date().toISOString().split('T')[0], lot: 0.16, pips: 200, type: "profit", note: "Example win" }
  ];

  // =====================
  // HELPERS
  // =====================
  const clamp = (v: number, min: number, max: number) =>
    Number.isFinite(v) ? Math.min(Math.max(v, min), max) : min;

  const fmtIdr = (n: number) =>
    new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0
    }).format(isFinite(n) ? n : 0);

  const roundLot2 = (x: number) => Math.round(x * 100) / 100;

  function addTrade() {
    trades = [
      ...trades,
      { id: crypto.randomUUID(), date: new Date().toISOString().split('T')[0], lot: 0.01, pips: 0, type: "profit", note: "" }
    ];
  }

  function removeTrade(id: string) {
    trades = trades.filter((t) => t.id !== id);
  }

  function clearTrades() {
    trades = [];
  }

  function setTradeType(index: number, type: TradeType) {
    const copy = trades.slice();
    copy[index] = { ...copy[index], type };
    trades = copy;
  }

  // =====================
  // DERIVED CALCULATION
  // =====================
  $: startingSafe = clamp(startingBalanceIdr, 0, 9e15);
  $: pipValueSafe = clamp(valuePerPipPerLotIdr, 0, 9e12);

  $: rows = (() => {
    let running = startingSafe;

    return trades.map((t, index) => {
      const lot = clamp(t.lot, 0, 1000);
      const pipsAbs = clamp(Math.abs(t.pips), 0, 10_000_000);

      const signedPips = t.type === "loss" ? -pipsAbs : pipsAbs;

      const pl = signedPips * pipValueSafe * lot * PL_MULTIPLIER;

      running += pl;

      return {
        no: index + 1,
        ...t,
        lot,
        pipsAbs,
        pl,
        balanceAfter: running
      };
    });
  })();

  // =====================
  // SUMMARY
  // =====================
  $: totalPl = rows.reduce((acc, r) => acc + r.pl, 0);
  $: currentBalance = startingSafe + totalPl;

  $: totalTrades = rows.length;
  $: wins = rows.filter((r) => r.type === "profit" && r.pipsAbs > 0).length;
  $: losses = rows.filter((r) => r.type === "loss" && r.pipsAbs > 0).length;
  $: winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : 0;

  $: plPercent = startingSafe > 0 ? (totalPl / startingSafe) * 100 : 0;

  // Max drawdown (realized)
  $: maxDrawdownIdr = (() => {
    let peak = startingSafe;
    let maxDd = 0;

    for (const r of rows) {
      if (r.balanceAfter > peak) peak = r.balanceAfter;
      const dd = peak - r.balanceAfter;
      if (dd > maxDd) maxDd = dd;
    }
    return maxDd;
  })();

  $: maxDrawdownPercent = startingSafe > 0 ? (maxDrawdownIdr / startingSafe) * 100 : 0;
</script>

<section class="min-h-screen bg-background px-6 py-12">
  <div class="mx-auto max-w-6xl space-y-8">
    <header class="space-y-2">
      <h1 class="text-3xl font-bold tracking-tight">Trade Tracker (IDR)</h1>
      <p class="text-muted-foreground">
        Input <b>pips nominal</b>, pilih <b>Profit / Loss</b>, lalu saldo akan dihitung otomatis.
        P/L dikali <b>{PL_MULTIPLIER}</b>.
      </p>
    </header>

    <!-- SETTINGS -->
    <Card class="rounded-2xl">
      <CardHeader>
        <CardTitle>Settings</CardTitle>
        <CardDescription>Dipakai untuk semua perhitungan bulan ini.</CardDescription>
      </CardHeader>

      <CardContent class="grid gap-6 md:grid-cols-2">
        <div class="space-y-4">
          <div class="space-y-2">
            <Label>Saldo Awal (IDR)</Label>
            <Input type="number" min="0" step="1000" bind:value={startingBalanceIdr} />
          </div>

          <div class="space-y-2">
            <Label>Nilai 1 pip / point (1 lot)</Label>
            <Input type="number" min="0" step="100" bind:value={valuePerPipPerLotIdr} />
            <p class="text-xs text-muted-foreground">
              Default Rp10.000. Sesuaikan dengan broker kamu.
            </p>
          </div>
        </div>

        <div class="rounded-xl border p-4 space-y-2 text-sm">
          <div class="font-medium">Ringkasan</div>

          <div class="flex justify-between">
            <span>Saldo awal</span>
            <span class="font-medium">{fmtIdr(startingSafe)}</span>
          </div>

          <div class="flex justify-between">
            <span>Total P/L</span>
            <span class="font-medium">
              {fmtIdr(totalPl)} ({plPercent.toFixed(2)}%)
            </span>
          </div>

          <div class="flex justify-between">
            <span>Saldo sekarang</span>
            <span class="font-semibold">{fmtIdr(currentBalance)}</span>
          </div>

          <div class="flex justify-between">
            <span>Win rate</span>
            <span class="font-medium">{winRate.toFixed(1)}% ({wins}W / {losses}L)</span>
          </div>

          <div class="flex justify-between">
            <span>Max drawdown</span>
            <span class="font-medium">
              {fmtIdr(maxDrawdownIdr)} ({maxDrawdownPercent.toFixed(2)}%)
            </span>
          </div>
        </div>

        <div class="col-span-full flex gap-2">
          <Button onclick={addTrade}>Tambah Trade</Button>
          <Button variant="outline" onclick={clearTrades}>Reset</Button>
        </div>
      </CardContent>
    </Card>

    <!-- TABLE -->
    <Card class="rounded-2xl">
      <CardHeader>
        <CardTitle>Daftar Trade</CardTitle>
        <CardDescription>Saldo berjalan dihitung berdasarkan urutan baris.</CardDescription>
      </CardHeader>

      <CardContent>
        <div class="rounded-xl border overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>#</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Lot</TableHead>
                <TableHead>Profit / Loss</TableHead>
                <TableHead>Pips</TableHead>
                <TableHead>P/L (IDR)</TableHead>
                <TableHead>Saldo Setelah</TableHead>
                <TableHead>Catatan</TableHead>
                <TableHead>Aksi</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              {#if rows.length === 0}
                <TableRow>
                  <TableCell colspan="{9}" class="py-10 text-center text-muted-foreground">
                    Belum ada trade.
                  </TableCell>
                </TableRow>
              {:else}
                {#each rows as r (r.id)}
                  <TableRow>
                    <TableCell>{r.no}</TableCell>

                    <TableCell>
                      <Input
                        type="date"
                        bind:value={trades[r.no - 1].date}
                      />
                    </TableCell>

                    <TableCell>
                      <Input
                        type="number"
                        step="0.01"
                        min="0"
                        bind:value={trades[r.no - 1].lot}
                        onblur={() =>
                          (trades[r.no - 1].lot = roundLot2(trades[r.no - 1].lot))
                        }
                      />
                    </TableCell>

                    <TableCell>
                      <div class="flex gap-2">
                        <Button
                          size="sm"
                          variant={trades[r.no - 1].type === "profit" ? "default" : "outline"}
                          onclick={() => setTradeType(r.no - 1, "profit")}
                        >
                          Profit
                        </Button>
                        <Button
                          size="sm"
                          variant={trades[r.no - 1].type === "loss" ? "default" : "outline"}
                          onclick={() => setTradeType(r.no - 1, "loss")}
                        >
                          Loss
                        </Button>
                      </div>
                    </TableCell>

                    <TableCell>
                      <Input
                        type="number"
                        min="0"
                        step="1"
                        bind:value={trades[r.no - 1].pips}
                      />
                    </TableCell>

                    <TableCell
                      class={r.pl < 0
                        ? "text-destructive font-medium"
                        : r.pl > 0
                        ? "text-emerald-600 font-medium"
                        : ""}
                    >
                      {fmtIdr(r.pl)}
                    </TableCell>

                    <TableCell class="font-medium">
                      {fmtIdr(r.balanceAfter)}
                    </TableCell>

                    <TableCell>
                      <Input
                        type="text"
                        placeholder="mis: Trader A"
                        bind:value={trades[r.no - 1].note}
                      />
                    </TableCell>

                    <TableCell>
                      <Button size="sm" variant="outline" onclick={() => removeTrade(r.id)}>
                        Hapus
                      </Button>
                    </TableCell>
                  </TableRow>
                {/each}
              {/if}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  </div>
</section>

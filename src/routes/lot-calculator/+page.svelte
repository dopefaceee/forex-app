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

  // ----------------------------
  // Inputs
  // ----------------------------
  let balanceIdr = 50_000_000;

  // Mode
  let mode: "single" | "copytrade" = "single";

  // Single trade risk (%)
  let riskPercent = 1;

  // Copytrade total risk cap (% across concurrent positions)
  let totalRiskCapPercent = 2;

  // Copytrade overlap input method
  let overlapMethod: "manual" | "estimate" = "manual";

  // Manual overlap
  let maxConcurrentPositions = 4;

  // Estimate overlap (from signals/month + holding style)
  let signalsPerMonth = 120;
  let holdingStyle: "scalp" | "intraday" | "swing" = "intraday";

  // Averaging / multi-entry
  let entriesPerSignal = 1;

  // Stop loss
  let stopLossPips = 300;

  // ----------------------------
  // Fixed assumptions (Indonesia V1)
  // ----------------------------
  const USD_TO_IDR = 10_000;
  const PIP_VALUE_USD = 1; // XAUUSD typical: 1 lot ≈ $1/pip
  const PIP_VALUE_IDR = USD_TO_IDR * PIP_VALUE_USD;

  // ----------------------------
  // Helpers
  // ----------------------------
  const clamp = (v: number, min: number, max: number) =>
    Number.isFinite(v) ? Math.min(Math.max(v, min), max) : min;

  const fmtIdr = (n: number) =>
    new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      maximumFractionDigits: 0
    }).format(isFinite(n) ? n : 0);

  // Conservative rounding: floor to 0.01 lot
  const floorLot = (x: number) => Math.floor(x * 100) / 100;

  function setMode(m: "single" | "copytrade") {
    mode = m;
  }

  function setOverlapMethod(m: "manual" | "estimate") {
    overlapMethod = m;
  }

  function setHoldingStyle(s: "scalp" | "intraday" | "swing") {
    holdingStyle = s;
  }

  function setRisk(p: number) {
    riskPercent = p;
  }

  // ----------------------------
  // Safe values
  // ----------------------------
  $: balanceSafe = clamp(balanceIdr, 0, 9e15);
  $: stopLossSafe = clamp(stopLossPips, 0, 1_000_000);

  $: riskPercentSafe = clamp(riskPercent, 0, 100);
  $: totalRiskCapSafe = clamp(totalRiskCapPercent, 0, 100);

  $: maxConcurrentManualSafe = Math.floor(clamp(maxConcurrentPositions, 1, 1000));
  $: entriesPerSignalSafe = Math.floor(clamp(entriesPerSignal, 1, 1000));

  $: signalsPerMonthSafe = clamp(signalsPerMonth, 0, 1_000_000);

  // ----------------------------
  // Overlap estimation
  // ----------------------------
  // Simple "overlap factor" mapping (estimation only)
  // scalp: low overlap, intraday: medium, swing: high
  $: overlapFactor =
    holdingStyle === "scalp" ? 0.5 :
    holdingStyle === "intraday" ? 1.5 :
    3.0;

  // Convert signals/month -> signals/day
  $: signalsPerDay = signalsPerMonthSafe / 30;

  // Estimated max concurrent positions (minimum 1)
  $: estimatedMaxConcurrent = Math.max(1, Math.ceil(signalsPerDay * overlapFactor));

  // Choose max concurrent based on method
  $: maxConcurrentEffective =
    overlapMethod === "estimate" ? estimatedMaxConcurrent : maxConcurrentManualSafe;

  // ----------------------------
  // Core logic
  // ----------------------------
  // Risk per position (%)
  $: riskPerPositionPercent =
    mode === "single"
      ? riskPercentSafe
      : (maxConcurrentEffective > 0 ? totalRiskCapSafe / maxConcurrentEffective : 0);

  // Risk money per position (IDR)
  $: riskMoneyPerPositionIdr = balanceSafe * (riskPerPositionPercent / 100);

  // Lot per position
  $: rawLotPerPosition =
    stopLossSafe > 0
      ? riskMoneyPerPositionIdr / (stopLossSafe * PIP_VALUE_IDR)
      : 0;

  $: lotPerPosition = floorLot(rawLotPerPosition);

  // Lot per entry (averaging)
  $: rawLotPerEntry = entriesPerSignalSafe > 0 ? lotPerPosition / entriesPerSignalSafe : 0;
  $: lotPerEntry = floorLot(rawLotPerEntry);

  // Estimated total risk if max concurrent positions are active (based on rounded lot)
  $: estTotalRiskMoneyIdr =
    maxConcurrentEffective * (stopLossSafe * PIP_VALUE_IDR * lotPerPosition);

  $: estTotalRiskPercent =
    balanceSafe > 0 ? (estTotalRiskMoneyIdr / balanceSafe) * 100 : 0;

  // Warnings
  $: riskWarningSingle = mode === "single" && riskPercentSafe > 2;
  $: riskWarningCap = mode === "copytrade" && totalRiskCapSafe > 5;
</script>

<section class="min-h-screen bg-background px-6 py-12">
  <div class="mx-auto max-w-5xl space-y-8">
    <header class="space-y-2">
      <h1 class="text-3xl font-bold tracking-tight">Lot Calculator (Risk %)</h1>
      <p class="text-muted-foreground">
        Asumsi: <b>$1 = Rp10.000</b> dan XAUUSD standar <b>1 lot ≈ $1/pip</b>.
        Mode <b>Copytrade</b> bisa pakai <b>estimasi posisi aktif</b> dari <b>sinyal/bulan</b> + gaya holding.
      </p>
    </header>

    <div class="grid gap-6 lg:grid-cols-2">
      <!-- INPUT -->
      <Card class="rounded-2xl">
        <CardHeader>
          <CardTitle>Input</CardTitle>
          <CardDescription>Atur mode, saldo, risk, sinyal, dan stop loss.</CardDescription>
        </CardHeader>

        <CardContent class="space-y-6">
          <!-- Mode -->
          <div class="space-y-2">
            <Label>Mode</Label>
            <div class="flex gap-2">
              <Button
                type="button"
                size="sm"
                variant={mode === "single" ? "default" : "outline"}
                onclick={() => setMode("single")}
              >
                Single Trade
              </Button>

              <Button
                type="button"
                size="sm"
                variant={mode === "copytrade" ? "default" : "outline"}
                onclick={() => setMode("copytrade")}
              >
                Copytrade / Multi
              </Button>
            </div>
          </div>

          <!-- Balance -->
          <div class="space-y-2">
            <Label for="balance">Saldo Akun (IDR)</Label>
            <Input
              id="balance"
              type="number"
              inputmode="numeric"
              min="0"
              step="1000"
              bind:value={balanceIdr}
            />
          </div>

          <!-- Single mode risk -->
          {#if mode === "single"}
            <div class="space-y-2">
              <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                <Label for="risk">Risiko per Transaksi (%)</Label>

                <div class="flex gap-2">
                  <Button type="button" variant="outline" size="sm" onclick={() => setRisk(0.5)}>0.5%</Button>
                  <Button type="button" variant="outline" size="sm" onclick={() => setRisk(1)}>1%</Button>
                  <Button type="button" variant="outline" size="sm" onclick={() => setRisk(2)}>2%</Button>
                </div>
              </div>

              <Input id="risk" type="number" min="0" step="0.1" bind:value={riskPercent} />

              {#if riskWarningSingle}
                <p class="text-sm text-destructive">
                  Risiko di atas 2% termasuk agresif untuk 1 posisi.
                </p>
              {:else}
                <p class="text-xs text-muted-foreground">Umum dipakai: 0.5% – 2%</p>
              {/if}
            </div>
          {:else}
            <!-- Copytrade controls -->
            <div class="space-y-4">
              <div class="space-y-2">
                <Label for="cap">Total Risk Cap (%)</Label>
                <Input id="cap" type="number" min="0" step="0.1" bind:value={totalRiskCapPercent} />
                <p class="text-xs text-muted-foreground">Batas risiko total yang boleh aktif bersamaan.</p>
                {#if riskWarningCap}
                  <p class="text-sm text-destructive">
                    Total risk cap di atas 5% cukup agresif untuk copytrade.
                  </p>
                {/if}
              </div>

              <!-- Overlap method -->
              <div class="space-y-2">
                <Label>Metode Overlap (Posisi Aktif)</Label>
                <div class="flex gap-2">
                  <Button
                    type="button"
                    size="sm"
                    variant={overlapMethod === "manual" ? "default" : "outline"}
                    onclick={() => setOverlapMethod("manual")}
                  >
                    Manual
                  </Button>

                  <Button
                    type="button"
                    size="sm"
                    variant={overlapMethod === "estimate" ? "default" : "outline"}
                    onclick={() => setOverlapMethod("estimate")}
                  >
                    Estimasi dari Sinyal
                  </Button>
                </div>

                <p class="text-xs text-muted-foreground">
                  Manual kalau kamu sudah tahu biasanya berapa posisi overlap. Estimasi kalau cuma tahu sinyal/bulan.
                </p>
              </div>

              {#if overlapMethod === "manual"}
                <div class="space-y-2">
                  <Label for="concurrent">Max Posisi Aktif Bersamaan</Label>
                  <Input id="concurrent" type="number" min="1" step="1" bind:value={maxConcurrentPositions} />
                </div>
              {:else}
                <div class="space-y-4">
                  <div class="space-y-2">
                    <Label for="signals">Total Sinyal per Bulan</Label>
                    <Input id="signals" type="number" min="0" step="1" bind:value={signalsPerMonth} />
                  </div>

                  <div class="space-y-2">
                    <Label>Gaya Holding</Label>
                    <div class="flex gap-2 flex-wrap">
                      <Button
                        type="button"
                        size="sm"
                        variant={holdingStyle === "scalp" ? "default" : "outline"}
                        onclick={() => setHoldingStyle("scalp")}
                      >
                        Scalp
                      </Button>
                      <Button
                        type="button"
                        size="sm"
                        variant={holdingStyle === "intraday" ? "default" : "outline"}
                        onclick={() => setHoldingStyle("intraday")}
                      >
                        Intraday
                      </Button>
                      <Button
                        type="button"
                        size="sm"
                        variant={holdingStyle === "swing" ? "default" : "outline"}
                        onclick={() => setHoldingStyle("swing")}
                      >
                        Swing
                      </Button>
                    </div>
                    <p class="text-xs text-muted-foreground">
                      Ini hanya estimasi untuk menentukan posisi overlap. Scalping overlap rendah, swing overlap tinggi.
                    </p>
                    <p class="text-sm">
                      Estimasi max posisi aktif: <b>{estimatedMaxConcurrent}</b>
                    </p>
                  </div>
                </div>
              {/if}

              <!-- Averaging -->
              <div class="space-y-2">
                <Label for="entries">Maksimal Entry per Sinyal (Averaging)</Label>
                <Input id="entries" type="number" min="1" step="1" bind:value={entriesPerSignal} />
                <p class="text-xs text-muted-foreground">
                  Jika 2–3 entry per sinyal, lot per entry akan dibagi.
                </p>
              </div>
            </div>
          {/if}

          <!-- Stop loss -->
          <div class="space-y-2">
            <Label for="sl">Stop Loss (Pips)</Label>
            <Input id="sl" type="number" min="0" step="1" bind:value={stopLossPips} />
          </div>

          <div class="rounded-xl border p-4 space-y-2">
            <p class="text-sm font-medium">Asumsi Tetap</p>
            <div class="text-sm text-muted-foreground space-y-1">
              <div>1 USD = Rp10.000</div>
              <div>Nilai pip per 1.00 lot = {fmtIdr(PIP_VALUE_IDR)} / pip</div>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- OUTPUT -->
      <Card class="rounded-2xl">
        <CardHeader>
          <CardTitle>Hasil</CardTitle>
          <CardDescription>Rekomendasi lot + estimasi total risk aktif (khusus copytrade).</CardDescription>
        </CardHeader>

        <CardContent class="space-y-4">
          <div class="rounded-xl border overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead class="w-[45%]">Item</TableHead>
                  <TableHead>Value</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                <TableRow>
                  <TableCell class="font-medium">Mode</TableCell>
                  <TableCell>{mode === "single" ? "Single Trade" : "Copytrade / Multi"}</TableCell>
                </TableRow>

                <TableRow>
                  <TableCell class="font-medium">Saldo</TableCell>
                  <TableCell>{fmtIdr(balanceSafe)}</TableCell>
                </TableRow>

                <TableRow>
                  <TableCell class="font-medium">Stop Loss</TableCell>
                  <TableCell>{stopLossSafe.toFixed(0)} pips</TableCell>
                </TableRow>

                <TableRow>
                  <TableCell class="font-medium">Nilai pip (1 lot)</TableCell>
                  <TableCell>{fmtIdr(PIP_VALUE_IDR)} / pip</TableCell>
                </TableRow>

                {#if mode === "single"}
                  <TableRow>
                    <TableCell class="font-medium">Risk (%)</TableCell>
                    <TableCell>{riskPercentSafe.toFixed(2)}%</TableCell>
                  </TableRow>
                {:else}
                  <TableRow>
                    <TableCell class="font-medium">Total Risk Cap (%)</TableCell>
                    <TableCell>{totalRiskCapSafe.toFixed(2)}%</TableCell>
                  </TableRow>

                  <TableRow>
                    <TableCell class="font-medium">Max Posisi Aktif</TableCell>
                    <TableCell>
                      {maxConcurrentEffective}
                      {#if overlapMethod === "estimate"}
                        <span class="text-muted-foreground"> (estimasi)</span>
                      {/if}
                    </TableCell>
                  </TableRow>

                  <TableRow>
                    <TableCell class="font-medium">Risk per Posisi (%)</TableCell>
                    <TableCell>{riskPerPositionPercent.toFixed(2)}%</TableCell>
                  </TableRow>

                  <TableRow>
                    <TableCell class="font-medium">Entry per Sinyal</TableCell>
                    <TableCell>{entriesPerSignalSafe}</TableCell>
                  </TableRow>
                {/if}

                <TableRow>
                  <TableCell class="font-medium">Risk Uang (per posisi)</TableCell>
                  <TableCell>{fmtIdr(riskMoneyPerPositionIdr)}</TableCell>
                </TableRow>

                <TableRow>
                  <TableCell class="font-medium">Lot per Posisi</TableCell>
                  <TableCell class="text-lg font-semibold">{lotPerPosition.toFixed(2)} lot</TableCell>
                </TableRow>

                {#if mode === "copytrade"}
                  <TableRow>
                    <TableCell class="font-medium">Lot per Entry</TableCell>
                    <TableCell class="text-lg font-semibold">{lotPerEntry.toFixed(2)} lot</TableCell>
                  </TableRow>

                  <TableRow>
                    <TableCell class="font-medium">Estimasi Total Risk Aktif</TableCell>
                    <TableCell>
                      {fmtIdr(estTotalRiskMoneyIdr)} ({estTotalRiskPercent.toFixed(2)}%)
                    </TableCell>
                  </TableRow>
                {/if}
              </TableBody>
            </Table>
          </div>

          <div class="rounded-xl bg-muted p-4 text-sm text-muted-foreground space-y-1">
            <div class="font-medium text-foreground">Catatan</div>
            <div>
              Lot dibulatkan <b>turun</b> ke 0.01 agar tidak melewati risk. Mode estimasi overlap memakai asumsi gaya holding,
              jadi hasilnya bukan prediksi, tapi <b>kontrol risiko</b>.
            </div>
          </div>

          <div class="flex gap-3">
            <Button class="flex-1" size="lg" type="button" onclick={() => {}}>
              Simpan (coming soon)
            </Button>
            <Button class="flex-1" size="lg" variant="outline" type="button" onclick={() => {}}>
              Share (coming soon)
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</section>

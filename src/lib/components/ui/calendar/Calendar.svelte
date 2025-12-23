<script lang="ts">
  import { Button } from "../button/index.js";
  import { ChevronLeft, ChevronRight } from "@lucide/svelte";
  import * as Select from "../select/index.js";
  import { type DateValue, CalendarDate, getLocalTimeZone, today } from "@internationalized/date";

  type Props = {
    value?: DateValue;
    type?: "single";
    captionLayout?: "buttons" | "dropdown" | "dropdown-months" | "dropdown-years";
    maxValue?: DateValue;
    minValue?: DateValue;
    onValueChange?: (date: DateValue | undefined) => void;
    class?: string;
  };

  let { 
    value = $bindable(), 
    type = "single",
    captionLayout = "buttons",
    maxValue,
    minValue,
    onValueChange,
    class: className = ""
  }: Props = $props();

  let currentDate = $state(value || today(getLocalTimeZone()));
  let displayMonth = $state(currentDate.month);
  let displayYear = $state(currentDate.year);

  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  // Generate year options (current year ± 10 years)
  const currentYear = new Date().getFullYear();
  const yearOptions = Array.from({ length: 21 }, (_, i) => currentYear - 10 + i);

  const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  function getDaysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate();
  }

  function getFirstDayOfMonth(year: number, month: number): number {
    return new Date(year, month - 1, 1).getDay();
  }

  function selectDate(day: number) {
    const selected = new CalendarDate(displayYear, displayMonth, day);
    
    // Check if date is within bounds
    if (maxValue && selected.compare(maxValue) > 0) return;
    if (minValue && selected.compare(minValue) < 0) return;
    
    value = selected;
    onValueChange?.(selected);
  }

  function previousMonth() {
    if (displayMonth === 1) {
      displayMonth = 12;
      displayYear--;
    } else {
      displayMonth--;
    }
  }

  function nextMonth() {
    if (displayMonth === 12) {
      displayMonth = 1;
      displayYear++;
    } else {
      displayMonth++;
    }
  }

  function handleMonthChange(month: number) {
    displayMonth = month + 1; // months array is 0-indexed, but CalendarDate uses 1-indexed
  }

  function handleYearChange(year: number) {
    displayYear = year;
  }

  function isDateDisabled(day: number): boolean {
    const date = new CalendarDate(displayYear, displayMonth, day);
    if (maxValue && date.compare(maxValue) > 0) return true;
    if (minValue && date.compare(minValue) < 0) return true;
    return false;
  }

  const daysInMonth = $derived(getDaysInMonth(displayMonth, displayYear));
  const firstDayOfMonth = $derived(getFirstDayOfMonth(displayMonth, displayYear));
  const days = $derived(Array.from({ length: daysInMonth }, (_, i) => i + 1));
</script>

<div class="p-3 w-64 {className}">
  <!-- Caption Header -->
  {#if captionLayout === "buttons"}
    <div class="flex items-center justify-between mb-4">
      <Button variant="outline" size="sm" onclick={previousMonth}>
        <ChevronLeft class="h-4 w-4" />
      </Button>
      <h2 class="font-semibold text-sm">
        {months[displayMonth - 1]} {displayYear}
      </h2>
      <Button variant="outline" size="sm" onclick={nextMonth}>
        <ChevronRight class="h-4 w-4" />
      </Button>
    </div>
  {:else if captionLayout === "dropdown"}
    <div class="flex items-center justify-center gap-2 mb-4">
      <Select.Root type="single" value={displayMonth - 1} onValueChange={handleMonthChange}>
        <Select.Trigger class="w-32">
          {months[displayMonth - 1]}
        </Select.Trigger>
        <Select.Content>
          {#each months as month, index}
            <Select.Item value={index}>{month}</Select.Item>
          {/each}
        </Select.Content>
      </Select.Root>
      
      <Select.Root type="single" value={displayYear} onValueChange={handleYearChange}>
        <Select.Trigger class="w-20">
          {displayYear}
        </Select.Trigger>
        <Select.Content>
          {#each yearOptions as year}
            <Select.Item value={year}>{year}</Select.Item>
          {/each}
        </Select.Content>
      </Select.Root>
    </div>
  {:else if captionLayout === "dropdown-months"}
    <div class="flex items-center justify-center gap-2 mb-4">
      <Select.Root type="single" value={displayMonth - 1} onValueChange={handleMonthChange}>
        <Select.Trigger class="w-32">
          {months[displayMonth - 1]}
        </Select.Trigger>
        <Select.Content>
          {#each months as month, index}
            <Select.Item value={index}>{month}</Select.Item>
          {/each}
        </Select.Content>
      </Select.Root>
      <h2 class="font-semibold text-sm">{displayYear}</h2>
    </div>
  {:else if captionLayout === "dropdown-years"}
    <div class="flex items-center justify-center gap-2 mb-4">
      <h2 class="font-semibold text-sm">{months[displayMonth - 1]}</h2>
      <Select.Root type="single" value={displayYear} onValueChange={handleYearChange}>
        <Select.Trigger class="w-20">
          {displayYear}
        </Select.Trigger>
        <Select.Content>
          {#each yearOptions as year}
            <Select.Item value={year}>{year}</Select.Item>
          {/each}
        </Select.Content>
      </Select.Root>
    </div>
  {/if}

  <div class="grid grid-cols-7 gap-1 text-center text-xs font-medium text-muted-foreground mb-2">
    {#each weekdays as day}
      <div class="p-1">{day}</div>
    {/each}
  </div>

  <div class="grid grid-cols-7 gap-1">
    {#each Array(firstDayOfMonth).fill(null) as _}
      <div class="p-1"></div>
    {/each}
    
    {#each days as day}
      <Button 
        variant={value?.day === day && value?.month === displayMonth && value?.year === displayYear ? "default" : "ghost"}
        size="sm"
        class="h-8 w-8 p-0 font-normal text-xs"
        disabled={isDateDisabled(day)}
        onclick={() => selectDate(day)}
      >
        {day}
      </Button>
    {/each}
  </div>
</div>
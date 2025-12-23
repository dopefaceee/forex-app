<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { Sun, Moon } from "@lucide/svelte";
  import { theme, toggleTheme } from "$lib/stores/theme";

  let { size = "sm", variant = "ghost", class: className = "" }: {
    size?: "default" | "sm" | "lg" | "icon";
    variant?: "default" | "destructive" | "outline" | "secondary" | "ghost" | "link";
    class?: string;
  } = $props();
</script>

<Button
  {variant}
  {size}
  class="relative {className}"
  onclick={toggleTheme}
  aria-label="Toggle theme"
>
  <Sun class="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
  <Moon class="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
  <span class="sr-only">Toggle theme</span>
</Button>
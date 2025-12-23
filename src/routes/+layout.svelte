<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import ThemeToggle from '$lib/components/ThemeToggle.svelte';
	import '$lib/stores/theme'; // Initialize theme store

	let { children } = $props();
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

<div class="min-h-screen bg-background text-foreground">
	<!-- Theme Toggle - Fixed position in top right -->
	<div class="fixed top-4 right-4 z-50">
		<ThemeToggle size="icon" variant="outline" class="bg-background/80 backdrop-blur-sm border shadow-sm" />
	</div>
	
	{@render children()}
</div>

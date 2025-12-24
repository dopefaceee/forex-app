<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import ThemeToggle from '$lib/components/ThemeToggle.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import UserProfile from '$lib/components/UserProfile.svelte';
	import GoogleSignInButton from '$lib/components/GoogleSignInButton.svelte';
	import { authStore } from '$lib/stores/auth';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	import '$lib/stores/theme'; // Initialize theme store
	import { onMount } from 'svelte';

	let { children } = $props();

	// Initialize auth store on mount
	onMount(() => {
		authStore.initialize();
	});

	// Protected routes
	const protectedRoutes = ['/simulation'];

	// Check authentication for protected routes
	$effect(() => {
		if (browser && !$authStore.loading) {
			const currentPath = $page.url.pathname;
			const isProtectedRoute = protectedRoutes.some(route => currentPath.startsWith(route));
			
			if (isProtectedRoute && !$authStore.user) {
				console.log('User not authenticated, redirecting to landing page');
				goto('/');
			}
		}
	});
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

<div class="min-h-screen bg-background text-foreground flex flex-col">
	<!-- Header with Auth -->
	<header class="sticky top-0 z-50 bg-background/80 backdrop-blur-sm border-b border-border/40">
		<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
			<div class="flex justify-between items-center h-16">
				<!-- Logo/Brand -->
				<div class="flex items-center">
					<a href="/" class="text-xl font-bold">Trading Simulation</a>
				</div>
				
				<!-- Auth Section -->
				<div class="flex items-center space-x-4">
					{#if $authStore.user}
						<UserProfile />
					{/if}
					<ThemeToggle size="icon" variant="outline" class="bg-background/80 backdrop-blur-sm border shadow-sm" />
				</div>
			</div>
		</div>
	</header>
	
	<!-- Main content -->
	<main class="flex-1">
		{@render children()}
	</main>
	
	<!-- Footer -->
	<Footer />
</div>

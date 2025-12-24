<script lang="ts">
  import { Github, Mail, ExternalLink, TrendingUp } from "@lucide/svelte";
</script>

<footer class="bg-muted/30 border-t border-border mt-auto">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
      <!-- Brand Section -->
      <div class="md:col-span-2">
        <div class="flex items-center space-x-2 mb-4">
          <TrendingUp class="h-6 w-6 text-green-600 dark:text-green-400" />
          <h3 class="text-lg font-bold">Trading Simulation</h3>
        </div>
        <p class="text-sm text-muted-foreground mb-4 max-w-md">
          Platform simulasi trading profesional menggunakan data analyst dari TradersFamily. 
          Bantu investor memahami strategi trading dan mengelola risiko dengan lebih baik.
        </p>
        <div class="flex space-x-4">
          <a
            href="https://tradersfamily.id/"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center space-x-1 text-sm text-green-600 dark:text-green-400 hover:text-green-500 dark:hover:text-green-300 transition-colors"
          >
            <span>TradersFamily</span>
            <ExternalLink class="h-3 w-3" />
          </a>
        </div>
      </div>

      <!-- Navigation Links -->
      <div>
        <h4 class="text-sm font-semibold text-foreground mb-4">Platform</h4>
        <div class="space-y-3">
          <a href="/" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Beranda
          </a>
          <a href="/simulation" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Trading Simulation
          </a>
          <a href="/about" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Tentang
          </a>
        </div>
      </div>

      <!-- Resources -->
      <div>
        <h4 class="text-sm font-semibold text-foreground mb-4">Resources</h4>
        <div class="space-y-3">
          <a href="/help" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Bantuan
          </a>
          <a href="/privacy" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Privacy Policy
          </a>
          <a href="/terms" class="block text-sm text-muted-foreground hover:text-foreground transition-colors">
            Terms of Service
          </a>
        </div>
      </div>
    </div>

    <!-- Bottom Section -->
    <div class="mt-8 pt-8 border-t border-border">
      <div class="flex flex-col sm:flex-row justify-between items-center">
        <div class="text-sm text-muted-foreground">
          © {new Date().getFullYear()} Trading Simulation. All rights reserved.
        </div>
        <div class="flex space-x-4 mt-4 sm:mt-0">
          <a
            href="mailto:info@tradingsimulation.com"
            class="text-muted-foreground hover:text-foreground transition-colors"
            title="Contact Us"
          >
            <Mail class="h-4 w-4" />
          </a>
          <a
            href="https://github.com"
            target="_blank"
            rel="noopener noreferrer"
            class="text-muted-foreground hover:text-foreground transition-colors"
            title="GitHub"
          >
            <Github class="h-4 w-4" />
          </a>
        </div>
      </div>
    </div>
  </div>
</footer>
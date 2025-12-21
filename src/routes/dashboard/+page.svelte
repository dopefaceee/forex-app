<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "$lib/components/ui/card";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import { Plus, Folder, Calendar, TrendingUp } from "@lucide/svelte";
  
  let projectName = "";
  let projects: Array<{id: string, name: string, created: string, trades: number}> = [];
  
  function createProject() {
    if (projectName.trim()) {
      const newProject = {
        id: Date.now().toString(),
        name: projectName,
        created: new Date().toLocaleDateString(),
        trades: 0
      };
      projects = [...projects, newProject];
      projectName = "";
    }
  }
</script>

<section class="min-h-screen bg-background px-6 py-12">
  <div class="mx-auto max-w-6xl space-y-8">
    <div class="space-y-2">
      <h1 class="text-3xl font-bold tracking-tight">Dashboard</h1>
      <p class="text-muted-foreground">
        Create and manage your trading projects
      </p>
    </div>

    <!-- Create New Project -->
    <Card class="rounded-2xl">
      <CardHeader>
        <CardTitle>Create New Project</CardTitle>
        <CardDescription>Start tracking a new trading strategy or account</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex gap-4">
          <div class="flex-1 space-y-2">
            <Label for="project-name">Project Name</Label>
            <Input
              id="project-name"
              type="text"
              placeholder="e.g., XAUUSD Scalping Strategy"
              bind:value={projectName}
              on:keydown={(e) => e.key === 'Enter' && createProject()}
            />
          </div>
          <div class="flex items-end">
            <Button onclick={createProject} disabled={!projectName.trim()}>
              <Plus class="w-4 h-4 mr-2" />
              Create Project
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- Projects List -->
    <div class="space-y-4">
      <h2 class="text-2xl font-semibold">Your Projects</h2>
      
      {#if projects.length === 0}
        <Card class="rounded-2xl border-dashed">
          <CardContent class="flex flex-col items-center justify-center py-16 text-center">
            <Folder class="w-12 h-12 text-muted-foreground mb-4" />
            <p class="text-muted-foreground">No projects yet. Create your first project to start tracking trades.</p>
          </CardContent>
        </Card>
      {:else}
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {#each projects as project}
            <a href="/trade-tracker?project={project.id}">
              <Card class="rounded-xl hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader>
                  <CardTitle class="text-lg">{project.name}</CardTitle>
                  <CardDescription class="flex items-center gap-2 text-sm">
                    <Calendar class="w-3 h-3" />
                    Created {project.created}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <TrendingUp class="w-4 h-4 text-muted-foreground" />
                      <span class="text-sm text-muted-foreground">{project.trades} trades</span>
                    </div>
                    <Button variant="ghost" size="sm">
                      Open →
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </a>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</section>
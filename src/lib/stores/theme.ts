import { writable } from 'svelte/store';
import { browser } from '$app/environment';

type Theme = 'light' | 'dark';

// Get initial theme from localStorage or default to 'light'
function getInitialTheme(): Theme {
  if (!browser) return 'light';
  
  const stored = localStorage.getItem('theme') as Theme;
  if (stored) return stored;
  
  // Check system preference
  if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    return 'dark';
  }
  
  return 'light';
}

export const theme = writable<Theme>(getInitialTheme());

// Subscribe to theme changes and update DOM and localStorage
if (browser) {
  theme.subscribe((value) => {
    localStorage.setItem('theme', value);
    
    if (value === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  });
  
  // Apply initial theme
  const initialTheme = getInitialTheme();
  if (initialTheme === 'dark') {
    document.documentElement.classList.add('dark');
  } else {
    document.documentElement.classList.remove('dark');
  }
}

export function toggleTheme() {
  theme.update(currentTheme => currentTheme === 'light' ? 'dark' : 'light');
}
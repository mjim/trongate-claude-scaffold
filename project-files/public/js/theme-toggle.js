/**
 * theme-toggle.js - Dark mode toggle with localStorage persistence
 *
 * Strategy: respects system preference on first visit, then remembers
 * the user's manual choice in localStorage.
 *
 * Usage:
 *   <button class="theme-toggle" onclick="toggleTheme()">
 *     <span class="theme-icon-light">&#9788;</span>
 *     <span class="theme-icon-dark">&#9789;</span>
 *   </button>
 *
 * Or call setTheme('dark') / setTheme('light') programmatically.
 */

(function() {
    // Apply theme as early as possible to avoid flash of wrong theme
    const stored = localStorage.getItem('theme');
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const theme = stored || (systemPrefersDark ? 'dark' : 'light');

    if (theme === 'dark') {
        document.documentElement.classList.add('dark');
    }
})();

function setTheme(theme) {
    if (theme === 'dark') {
        document.documentElement.classList.add('dark');
    } else {
        document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('theme', theme);
}

function toggleTheme() {
    const isDark = document.documentElement.classList.contains('dark');
    setTheme(isDark ? 'light' : 'dark');
}

function getTheme() {
    return document.documentElement.classList.contains('dark') ? 'dark' : 'light';
}

// Listen for system preference changes if user hasn't made a manual choice
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
    if (!localStorage.getItem('theme')) {
        setTheme(e.matches ? 'dark' : 'light');
        localStorage.removeItem('theme'); // Keep it as system-following
    }
});

// Theme mode toggle for Sphinx Book Theme
document.addEventListener('DOMContentLoaded', function() {
    // Get the current theme preference from local storage or default to light
    let currentTheme = localStorage.getItem('theme') || 'light';
    
    // Check if we have theme toggle in navbar
    const themeToggleExists = document.querySelector('#theme-toggle') !== null;
    
    // Only add the toggle if it doesn't exist already
    if (!themeToggleExists) {
        // Create theme toggle button
        const toggleButton = document.createElement('button');
        toggleButton.id = 'theme-toggle';
        toggleButton.className = 'theme-toggle-button';
        toggleButton.setAttribute('aria-label', 'Toggle dark mode');
        
        // Create the icons for light/dark mode
        const lightIcon = document.createElement('span');
        lightIcon.innerHTML = '☀️';
        lightIcon.className = 'theme-icon light-icon';
        
        const darkIcon = document.createElement('span');
        darkIcon.innerHTML = '🌙';
        darkIcon.className = 'theme-icon dark-icon';
        
        // Append icons to button
        toggleButton.appendChild(lightIcon);
        toggleButton.appendChild(darkIcon);
        
        // Add styles for the button
        const style = document.createElement('style');
        style.textContent = `
            .theme-toggle-button {
                background: transparent;
                border: none;
                cursor: pointer;
                padding: 8px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                margin-left: 10px;
                transition: background-color 0.3s;
            }
            
            .theme-toggle-button:hover {
                background-color: rgba(0, 0, 0, 0.1);
            }
            
            html[data-theme="dark"] .theme-toggle-button:hover {
                background-color: rgba(255, 255, 255, 0.1);
            }
            
            .theme-icon {
                display: none;
            }
            
            html[data-theme="light"] .light-icon {
                display: block;
            }
            
            html[data-theme="dark"] .dark-icon {
                display: block;
            }
        `;
        document.head.appendChild(style);
        
        // Find navbar right items
        const navbarRight = document.querySelector('.navbar-nav-right') || 
                          document.querySelector('.bd-navbar-elements');
        
        if (navbarRight) {
            // Create a container for the toggle
            const toggleContainer = document.createElement('div');
            toggleContainer.className = 'theme-toggle-container';
            toggleContainer.appendChild(toggleButton);
            
            // Add the toggle to the navbar
            navbarRight.appendChild(toggleContainer);
        }
        
        // Add click event to toggle theme
        toggleButton.addEventListener('click', function() {
            // Toggle theme
            const theme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
            
            // Update HTML attribute
            document.documentElement.setAttribute('data-theme', theme);
            
            // Save preference
            localStorage.setItem('theme', theme);
        });
    }
    
    // Apply the theme from preferences
    if (currentTheme) {
        document.documentElement.setAttribute('data-theme', currentTheme);
    }
}); 
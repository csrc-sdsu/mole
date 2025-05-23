// JavaScript to show the announcement banner only on the main documentation index page
document.addEventListener('DOMContentLoaded', function() {
    // Get the announcement container
    const announcementBanner = document.querySelector('.bd-header-announcement');
    
    if (announcementBanner) {
        // Get the current path
        const path = window.location.pathname;
        
        // Check if this is the main index page
        // We need to handle various path patterns including the local build pattern
        const isMainIndexPage = 
            // General cases
            path === '/' || 
            path === '/index.html' ||
            // Local build pattern matching
            path.endsWith('/build/html/index.html') ||
            path.endsWith('/mole/doc/sphinx/build/html/index.html') ||
            // Direct access patterns
            path === '/mole/' ||
            path === '/mole/index.html';
        
        // Show only on main index page and hide everywhere else
        if (!isMainIndexPage) {
            announcementBanner.style.display = 'none';
        }
    }
}); 
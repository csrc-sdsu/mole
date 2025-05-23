// Add an announcement banner only on the index page
document.addEventListener('DOMContentLoaded', function() {
    // Check if we're on the index page
    const isIndexPage = document.location.pathname.endsWith('/index.html') || 
                        document.location.pathname.endsWith('/') || 
                        document.location.pathname === '';
    
    // Get the theme-announcement meta tag value if it exists
    const announcementMeta = document.querySelector('meta[name="theme-announcement"]');
    
    if (isIndexPage && announcementMeta) {
        const announcementText = announcementMeta.getAttribute('content');
        if (announcementText) {
            // Create announcement banner
            const announcementBanner = document.createElement('div');
            announcementBanner.id = 'announcement-banner';
            announcementBanner.className = 'bd-header-announcement';
            
            const container = document.createElement('div');
            container.className = 'container-xl';
            container.textContent = announcementText;
            
            announcementBanner.appendChild(container);
            
            // Insert at the top of the page
            const body = document.body;
            body.insertBefore(announcementBanner, body.firstChild);
        }
    }
}); 
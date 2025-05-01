// Custom JavaScript for enhancing sphinx-book-theme

document.addEventListener('DOMContentLoaded', function() {
    // ===== Enable smooth scrolling for anchor links =====
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                window.scrollTo({
                    top: target.offsetTop - 70, // Account for fixed header
                    behavior: 'smooth'
                });
                // Update URL without page jump
                history.pushState(null, null, this.getAttribute('href'));
            }
        });
    });

    // ===== Add copy button to code blocks =====
    const codeBlocks = document.querySelectorAll('div.highlight pre');
    codeBlocks.forEach((codeBlock, index) => {
        // Create copy button
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-button';
        copyButton.type = 'button';
        copyButton.setAttribute('aria-label', 'Copy code to clipboard');
        copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M4 1.5H3a2 2 0 0 0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3.5a2 2 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1v-1z"/><path d="M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-3a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5h3zm-3-1A1.5 1.5 0 0 0 5 1.5v1A1.5 1.5 0 0 0 6.5 4h3A1.5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3z"/></svg>';
        
        // Set up copy functionality
        copyButton.addEventListener('click', () => {
            const code = codeBlock.textContent;
            navigator.clipboard.writeText(code).then(() => {
                copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M12.736 3.97a.733.733 0 0 1 1.047 0c.286.289.29.756.01 1.05L7.88 12.01a.733.733 0 0 1-1.065.02L3.217 8.384a.757.757 0 0 1 0-1.06.733.733 0 0 1 1.047 0l3.052 3.093 5.4-6.425a.247.247 0 0 1 .02-.022Z"/></svg>';
                setTimeout(() => {
                    copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M4 1.5H3a2 2 0 0 0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3.5a2 2 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1v-1z"/><path d="M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-3a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5h3zm-3-1A1.5 1.5 0 0 0 5 1.5v1A1.5 1.5 0 0 0 6.5 4h3A1.5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3z"/></svg>';
                }, 2000);
            });
        });
        
        // Add button to parent container for better positioning
        const container = codeBlock.parentElement;
        container.style.position = 'relative';
        container.appendChild(copyButton);
    });

    // ===== Enhance table visibility =====
    document.querySelectorAll('table').forEach(table => {
        // Add a container for horizontal scrolling on small screens
        const wrapper = document.createElement('div');
        wrapper.className = 'table-responsive';
        wrapper.style.overflowX = 'auto';
        table.parentNode.insertBefore(wrapper, table);
        wrapper.appendChild(table);
        
        // Add zebra striping (backup in case CSS doesn't handle it)
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach((row, index) => {
            if (index % 2 !== 0) {
                row.classList.add('row-alt');
            }
        });
    });

    // ===== Add collapsible sections =====
    document.querySelectorAll('.toggle-section-button').forEach(button => {
        button.addEventListener('click', function() {
            const content = this.nextElementSibling;
            if (content.style.maxHeight) {
                content.style.maxHeight = null;
                this.setAttribute('aria-expanded', 'false');
                this.querySelector('.toggle-icon').textContent = '+';
            } else {
                content.style.maxHeight = content.scrollHeight + 'px';
                this.setAttribute('aria-expanded', 'true');
                this.querySelector('.toggle-icon').textContent = '-';
            }
        });
    });

    // ===== Add card hover effects =====
    document.querySelectorAll('.sd-card').forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px)';
            this.style.boxShadow = '0 8px 16px rgba(0, 0, 0, 0.1)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';
        });
    });

    // ===== Back to top button =====
    const backToTopButton = document.createElement('button');
    backToTopButton.id = 'back-to-top';
    backToTopButton.innerHTML = '↑';
    backToTopButton.setAttribute('aria-label', 'Back to top');
    backToTopButton.setAttribute('title', 'Back to top');
    document.body.appendChild(backToTopButton);
    
    // Show/hide back to top button based on scroll position
    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            backToTopButton.classList.add('visible');
        } else {
            backToTopButton.classList.remove('visible');
        }
    });
    
    // Add click event to back to top button
    backToTopButton.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

    // ===== Add styles for JS enhancements =====
    const style = document.createElement('style');
    style.textContent = `
        /* Copy button styles */
        .copy-button {
            position: absolute;
            top: 5px;
            right: 5px;
            padding: 4px 8px;
            background-color: rgba(255, 255, 255, 0.8);
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
            opacity: 0;
        }
        
        .highlight:hover .copy-button {
            opacity: 1;
        }
        
        .copy-button:hover {
            background-color: #f0f0f0;
        }
        
        /* Table responsive styles */
        .table-responsive {
            margin-bottom: 1rem;
        }
        
        /* Back to top button */
        #back-to-top {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            font-size: 20px;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s, transform 0.3s;
            transform: translateY(20px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            z-index: 1000;
        }
        
        #back-to-top.visible {
            opacity: 0.7;
            transform: translateY(0);
        }
        
        #back-to-top:hover {
            opacity: 1;
        }
        
        /* Toggle section styles */
        .toggle-section-button {
            display: block;
            width: 100%;
            text-align: left;
            padding: 10px 15px;
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            margin-bottom: 0;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .toggle-section-button:hover {
            background-color: #e9ecef;
        }
        
        .toggle-icon {
            float: right;
            font-weight: bold;
        }
        
        .toggle-section-content {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
            border: 1px solid #e9ecef;
            border-top: none;
            border-radius: 0 0 4px 4px;
            padding: 0 15px;
        }
    `;
    document.head.appendChild(style);
}); 
---
title: Read Me
---

```{include} ../../../../README.md
```

```{raw} html
<script>
// Fix image paths after the page loads
document.addEventListener('DOMContentLoaded', function() {
    // Get all images on the page
    const images = document.querySelectorAll('img[src^="api/doc/assets/img/"]');
    
    // Update each image source
    images.forEach(img => {
        // Extract the filename from the path
        const filename = img.src.split('/').pop();
        // Set the new source
        img.src = '../_static/img/' + filename;
    });

    // Also check for images with the path doc/assets/img/
    const images2 = document.querySelectorAll('img[src^="doc/assets/img/"]');
    images2.forEach(img => {
        const filename = img.src.split('/').pop();
        img.src = '../_static/img/' + filename;
    });
});
</script>
```
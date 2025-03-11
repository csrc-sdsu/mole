---
title: MATLAB API Reference
---

# MATLAB API Reference

This page provides complete reference documentation for all MATLAB functions in the MOLE library.

```{admonition} Navigation Tip
:class: tip
The documentation below uses frames for navigation. Use the left panel to browse functions by category, and the right panel will display the selected function documentation.
```

```{eval-rst}
.. raw:: html

   <script>
   // Define the base path to MATLAB documentation - change this in one place if needed
   const MATLAB_DOC_PATH = "../../../../../doxygen/matlab/";
   </script>

   <div class="buttons-container" style="display: flex; justify-content: space-between; margin-bottom: 20px;">
      <a href="../../../../../doxygen/matlab/index.html" class="btn btn-primary" style="background-color: #2980b9; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;" target="_blank" rel="noopener noreferrer">Open in New Window</a>
      <a href="javascript:void(0);" onclick="expandView()" class="btn btn-secondary" style="background-color: #34495e; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;">Expand View</a>
   </div>
   
   <div style="position: relative; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; max-width: 100%; margin-top: 10px; background-color: white;">
     <div style="background-color: #f8f9fa; padding: 10px; border-bottom: 1px solid #ddd; font-weight: bold;">MOLE MATLAB API Reference</div>
     <iframe id="matlab-api-frame" src="../../../../../doxygen/matlab/index.html" frameborder="0" style="width: 100%; height: 600px; border: none;"></iframe>
   </div>
   
   <script>
   // Function to expand the iframe view
   function expandView() {
     const iframe = document.getElementById('matlab-api-frame');
     if (iframe) {
       iframe.style.height = '90vh';
       iframe.style.maxHeight = 'none';
     }
   }
   
   document.addEventListener('DOMContentLoaded', function() {
     // Adjust iframe height based on content
     try {
       const iframe = document.getElementById('matlab-api-frame');
       iframe.onload = function() {
         iframe.style.height = Math.min(iframe.contentWindow.document.body.scrollHeight + 50, 700) + 'px';
       };
     } catch(e) {
       console.log('Cannot adjust iframe height: ', e);
     }
     
     });
     
     document.querySelector('.buttons-container').insertAdjacentElement('afterend', quickLinksDiv);
   </script>
```

## Function Categories

<div class="grid-container" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
  <div class="component-box">
    <h3>Core Operators</h3>
    <ul>
      <li><strong>1D Operators</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/grad.html" target="matlab-api-frame">grad</a> - Gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/div.html" target="matlab-api-frame">div</a> - Divergence</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/lap.html" target="matlab-api-frame">lap</a> - Laplacian</li>
        </ul>
      </li>
      <li><strong>2D Operators</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/grad2D.html" target="matlab-api-frame">grad2D</a> - 2D Gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/div2D.html" target="matlab-api-frame">div2D</a> - 2D Divergence</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/lap2D.html" target="matlab-api-frame">lap2D</a> - 2D Laplacian</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/curl2D.html" target="matlab-api-frame">curl2D</a> - 2D Curl</li>
        </ul>
      </li>
      <li><strong>3D Operators</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/grad3D.html" target="matlab-api-frame">grad3D</a> - 3D Gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/div3D.html" target="matlab-api-frame">div3D</a> - 3D Divergence</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/lap3D.html" target="matlab-api-frame">lap3D</a> - 3D Laplacian</li>
        </ul>
      </li>
    </ul>
  </div>
  
  <div class="component-box">
    <h3>Advanced Operators</h3>
    <ul>
      <li><strong>Non-Uniform Grids</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/gradNonUniform.html" target="matlab-api-frame">gradNonUniform</a> - Non-uniform gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/divNonUniform.html" target="matlab-api-frame">divNonUniform</a> - Non-uniform divergence</li>
        </ul>
      </li>
      <li><strong>Curvilinear Grids</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/grad2DCurv.html" target="matlab-api-frame">grad2DCurv</a> - Curvilinear 2D gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/div2DCurv.html" target="matlab-api-frame">div2DCurv</a> - Curvilinear 2D divergence</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/grad3DCurv.html" target="matlab-api-frame">grad3DCurv</a> - Curvilinear 3D gradient</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/div3DCurv.html" target="matlab-api-frame">div3DCurv</a> - Curvilinear 3D divergence</li>
        </ul>
      </li>
    </ul>
  </div>

  <div class="component-box">
    <h3>Boundary Conditions</h3>
    <ul>
      <li><strong>Mixed BC</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/mimeticB.html" target="matlab-api-frame">mimeticB</a> - Mimetic boundary operator</li>
        </ul>
      </li>
      <li><strong>Robin BC</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/robinBC.html" target="matlab-api-frame">robinBC</a> - 1D Robin BC</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/robinBC2D.html" target="matlab-api-frame">robinBC2D</a> - 2D Robin BC</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/robinBC3D.html" target="matlab-api-frame">robinBC3D</a> - 3D Robin BC</li>
        </ul>
      </li>
    </ul>
  </div>
  
  <div class="component-box">
    <h3>Utilities</h3>
    <ul>
      <li><strong>Interpolation</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/interpol.html" target="matlab-api-frame">interpol</a> - 1D interpolation</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/interpol2D.html" target="matlab-api-frame">interpol2D</a> - 2D interpolation</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/interpol3D.html" target="matlab-api-frame">interpol3D</a> - 3D interpolation</li>
        </ul>
      </li>
      <li><strong>Grid Utilities</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/gridGen.html" target="matlab-api-frame">gridGen</a> - Grid generation</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/tfi.html" target="matlab-api-frame">tfi</a> - Transfinite interpolation</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/nodal.html" target="matlab-api-frame">nodal</a> - Nodal operator</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/jacobian2D.html" target="matlab-api-frame">jacobian2D</a> - 2D Jacobian</li>
        </ul>
      </li>
      <li><strong>Weights</strong>
        <ul>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/weightsP.html" target="matlab-api-frame">weightsP</a> - Weights for P</li>
          <li><a href="../../../../../doxygen/matlab/mole_MATLAB/weightsQ.html" target="matlab-api-frame">weightsQ</a> - Weights for Q</li>
        </ul>
      </li>
    </ul>
  </div>
</div>

<script>
// If the path ever needs to be changed, just edit the MATLAB_DOC_PATH variable at the top of this file
// and run the following function to update all links programmatically if needed in future:
function updateAllMatlabLinks(newPath) {
  // Get all links
  const links = document.querySelectorAll('a[href*="doxygen/matlab/"]');
  
  // Update each link
  links.forEach(link => {
    link.href = link.href.replace(/^(.*?)doxygen\/matlab\//, newPath);
  });
  
  // Update the iframe
  const iframe = document.getElementById('matlab-api-frame');
  if (iframe) {
    iframe.src = iframe.src.replace(/^(.*?)doxygen\/matlab\//, newPath);
  }
  
  console.log('All MATLAB documentation links updated to use path: ' + newPath);
}

// Example usage:
// updateAllMatlabLinks('https://example.com/new/path/to/matlab/docs/');
</script>

```{admonition} Function Documentation
:class: note
Each function is documented with proper headers that explain inputs, outputs, and usage examples. Click on a function name above to view its detailed documentation.
```
``` 
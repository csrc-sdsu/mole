# Advanced Features Demo

This page demonstrates the advanced features available in our documentation with sphinx-book-theme.

## Dark Mode Support

Our documentation now supports dark mode! Look for the theme toggle button in the top navbar.

## Interactive Elements

### Tabs

````{tab-set}
```{tab-item} MATLAB
```matlab
% MATLAB example
function result = addTwoNumbers(a, b)
    result = a + b;
end
```
```{tab-item} C++
```cpp
// C++ example
double addTwoNumbers(double a, double b) {
    return a + b;
}
```
```{tab-item} Python
```python
# Python example
def add_two_numbers(a, b):
    return a + b
```
````

### Admonitions (Callouts)

```{note}
This is a note admonition - useful for providing additional information.
```

```{warning}
This is a warning admonition - use this to warn users about potential issues.
```

```{tip}
This is a tip admonition - use this to provide helpful tips to users.
```

```{important}
This is an important admonition - use this to highlight critical information.
```

## Expandable Sections

```{dropdown} Click to expand this section
This is a hidden section that can be expanded and collapsed by clicking on it.

You can include:
- Lists
- Code blocks
- And other content

```{dropdown} Nested dropdown
This is a nested dropdown inside another dropdown!
```
```

## Cards

```{card} Feature Card Title
:link: https://sphinx-book-theme.readthedocs.io/
:link-type: url
:img-top: _static/logo.png
:img-alt: MOLE Logo

Card content featuring the MOLE logo and a link to sphinx-book-theme docs.
```

````{grid} 2
```{grid-item-card} Card 1
:link: api/index
:img-top: _static/logo.png
:img-alt: MOLE Logo

View the API documentation
```
```{grid-item-card} Card 2
:link: examples/index
:img-top: _static/logo.png
:img-alt: MOLE Logo

Explore examples
```
````

## Code with Copy Button

All code blocks now have a copy button that appears when you hover over them:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    int sum = 0;
    
    for (int num : numbers) {
        sum += num;
    }
    
    std::cout << "Sum: " << sum << std::endl;
    return 0;
}
```

## Badges and Labels

:bdg-primary:`Primary`
:bdg-secondary:`Secondary`
:bdg-success:`Success`
:bdg-warning:`Warning`
:bdg-danger:`Danger`
:bdg-info:`Info`

## Buttons

```{button-link} https://github.com/csrc-sdsu/mole
:color: primary
:outline:
GitHub Repository
```

```{button-link} examples/index
:color: info
Examples
```

## Interactive Mermaid Diagrams

```{mermaid}
flowchart LR
    A[Input] --> B{Process}
    B --> C[Output 1]
    B --> D[Output 2]
``` 
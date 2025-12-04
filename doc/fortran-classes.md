MOLE Fortran Class Diagram
--------------------------
```mermaid
classDiagram

class tensor_1D_t
class scalar_1D_t
class vector_1D_t
class divergence_1D_t
class laplacian_1D_t
class gradient_operator_1D_t
class divergence_operator_1D_t
class mimetic_matrix_1D_t

tensor_1D_t <|-- scalar_1D_t
tensor_1D_t <|-- vector_1D_t
tensor_1D_t <|-- divergence_1D_t
divergence_1D_t <|-- laplacian_1D_t
mimetic_matrix_1D_t <|-- gradient_operator_1D_t
mimetic_matrix_1D_t <|-- divergence_operator_1D_t

scalar_1D_t  o-- gradient_operator_1D_t 
vector_1D_t  o-- divergence_1D_t

class scalar_1D_t{
    + operator(.grad.) vector_1D_t
    + operator(.laplacian.) scalar_1D_t
}

class vector_1D_t{
    + operator(.div.) divergence_1D_t
    + operator(.laplacian.) laplacian_1D_t
}

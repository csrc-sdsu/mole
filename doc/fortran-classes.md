MOLE Fortran Class Diagram
--------------------------

```mermaid

%%{init: { 'theme':'neo',  "class" : {"hideEmptyMembersBox": true} } }%%

classDiagram

class tensor_1D_t
class scalar_1D_t
class vector_1D_t
class divergence_1D_t
class laplacian_1D_t
class gradient_operator_1D_t
class divergence_operator_1D_t
class mimetic_matrix_1D_t

tensor_1D_t <|-- scalar_1D_t : is a
tensor_1D_t <|-- vector_1D_t : is a
tensor_1D_t <|-- divergence_1D_t : is a
divergence_1D_t <|-- laplacian_1D_t : is a
mimetic_matrix_1D_t <|-- gradient_operator_1D_t : is a
mimetic_matrix_1D_t <|-- divergence_operator_1D_t : is a

class scalar_1D_t{
    - gradient_operator_1D_ : gradient_operator_1D_t
    + operator(.grad.) vector_1D_t
    + operator(.laplacian.) scalar_1D_t
}

class vector_1D_t{
    - divergence_operator_1D_ : divergence_operator_1D_t
    + operator(.div.) divergence_1D_t
}

class mimetic_matrix_1D_t{
 - upper_ :: double precision
 - inner_ :: double precision
 - lower_ :: double precision
}

class gradient_operator_1D_t{
 + operator(.x.) double precision[]
 + assemble() double precision[] "2D array"
}

class divergence_operator_1D_t{
 + operator(.x.) double precision[]
 + assemble() double precision[] "2D array"
}

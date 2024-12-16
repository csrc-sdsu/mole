#include <iostream>
#include <math.h> 
#include "mole.h"
/**
 * This example uses MOLE to solve the heat equation u_t-alpha*u_xx=0[with alpha=1] over [0,1]^2,
 * u(x,0)=0 for x in (-1,1), u(1,t)=u(-1,t)=100 for t in [0,1]. 
 */
int main() { 
    int k=2;// Operators' order of accuracy
    double t0=0; //initial time
    double tf=1; //final time
    double a=0; //left boundary
    double b=1; //right boundary
    int m=2*k+1; //num of cells
    double dx=(b-a)/m;
    double dt=tf/(ceil((3*tf)/(dx*dx))); //Von Neumann stability criterion for explicit scheme, if k > 2 then dt/dx^2<0.5.  
    /*Note that unlike the matlab example, dt isn't dx^2/3 because if a and b are changed or the final time is changed
    *the final time tf may not be a multiple of dt. This value of dt guarantees that the final time will be a mutiple of dt.
    * while still satisfying Von Neumann stablity criterion
    *Note that in this example dt=dx^2/3 like it is in the matlab example. 
    */
    Laplacian L(k,m,dx); 
    vec solution(m + 2); 
    solution(0)=100;
    solution(m+1)=100;
    vec k1(m+2); 
    double t=t0;
    while (t <= tf) { //time integration with euler method. 
      k1=L*(solution);
      solution=solution+dt*k1;
      t=t+dt;
    }

    std::cout << solution;


    return 0;
}
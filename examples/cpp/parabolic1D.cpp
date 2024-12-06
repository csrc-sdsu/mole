#include <iostream>
#include <math.h> 
#include "mole.h"
/**
 * This example uses MOLE to solve the heat equation u_t-u_xx=0,u(x,0)=100x^2,u(-1,t)=100,u(1,t)=100
 *the true solution should be approximately all 100s at cout;

 */
int main() { 
int k=4;// Operators' order of accuracy
double t0=0; //initial time
double tf=1; //final time
double a=-1; //left boundary
double b=1; //right boundary
int m=2*k+1; //num of cells
double dx=(b-a)/m;
double dt=1.0/(ceil(3/(dx*dx)));

Laplacian L(k,m,dx); //mimetic operator is m+2 by m+2. it gives the laplacian at at a,a+0.5dx,a+1.5dx,..,a+(m-0.5)dx,b,
vec solution(m + 2); //solution at a,a+dx,...,a+(m-1)dx,b
solution(0)=100;
solution(m+1)=100;
int i; 
for (i=1;i<=m;i++){  
    solution(i)=100*(a+dx*(i-0.5))*(a+dx*(i-0.5));
}

vec k1(m+2); 
vec k2(m+2);
vec k3(m+2);
vec k4(m+2);
double t=t0;
while (t<=tf){
k1=L*(solution);
k2=L*(solution+dt/2*k1);
k3=L*(solution+dt/2*k2);
k4=L*(solution+dt*k3);
solution=solution+dt/6*k1;
solution=solution+dt/3*k2;
solution=solution+dt/3*k3;
solution=solution+dt/6*k4;
t=t+dt;
}

//time integration with rk4

cout << solution;


return 0;

}
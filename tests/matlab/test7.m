% Correctness test of divergence

addpath('../../src/matlab')

tol = 1e-4;

testfun=@ (x) (x-x^2)^2;
deriv=@ (x) (2*(1-2*x)*(x-x^2));
points=10;
for i=10:2:(10+(2*points))
    faces=linspace(0,1,2*i+2)';
    B=div(i,2*i+1,1/(2*i+1));
    centers=[0; linspace(0.5/(2*i+1),1-0.5/(2*i+1),2*i+1)' ;1];
    testoutput=arrayfun(deriv,centers);
    d=B*(arrayfun(testfun,faces));
    if (norm(d-testoutput,inf) > tol)
        fprintf("Test FAILED!\n");
        fprintf("error between numerical and actual result is\n");
        norm(d-testoutput,inf)     
        i
    end  
end


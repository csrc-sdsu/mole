% Correctness test of gradient

addpath('../../src/matlab')

tol = 1e-4;

testfun=@ (x) (x-x^2)^2;
deriv=@ (x) (2*(1-2*x)*(x-x^2));
points=10;
for i=10:2:(10+(2*points))
    faces=linspace(0,1,2*i+1)';
    B=grad(i,2*i,1/(2*i));
    centers=[0; linspace(0.5/(2*i),1-0.5/(2*i),2*i)' ;1];
    testoutput=arrayfun(deriv,faces);
    d=B*(arrayfun(testfun,centers));
    if (norm(d-testoutput,inf) > tol)
        fprintf("Test FAILED!\n");
        fprintf("error between numerical and actual result is\n");
        norm(d-testoutput,inf)     
        i;
    end  
end
fprintf("Test PASSED!\n");
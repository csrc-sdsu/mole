classdef testGradient < matlab.unittest.TestCase
    methods(Test)
        function testNullityofGradient(testCase)
            addpath ('../../src/matlab_octave')
            
            ks=[2,4,6,8];
            tol = 1e-10;
            for k = ks
            	m = 2*k+1;
            	dx=1/m;
            	
            	G= grad(k,m,dx);
            	field = ones(m+2,1);
            	sol = G* field;
            	
            	testCase.verifyLessThan(norm(sol),tol, ...
            		sprintf("Nullity test failed for k = %d", k));
             end
        end
    end
end


classdef testCurl2D < matlab.unittest.TestCase
    methods(Test)
        function testCurl2DErrors(testCase)
            % 2D Curl test
            % The purpose is to check the 2D curl component and not the whole 2D curl
            %
            % So, it is intended to test this:
            % F = (P(x,y),Q(x,y),0) and curl(F) = (-dQ/dz,dP/dz,dQ/dx-dP/dy)=(0,0,dQ/dx-dP/dy)
            % 
            % However, to make this test more realistic we assume
            % F = (P(x,y),Q(x,y),R(x,y)) and
            % curl(F) = (dR/dy-dQ/dz,dP/dz-dR/dx,dQ/dx-dP/dy)=(dR/dy,-dR/dx,dQ/dx-dP/dy)
            % 
            % P and Q are chosen such the last component of the curl is zero
            % The example does not check the first two components of the 2D curl which
            % involves R that was added just to make the test more general
            %
            addpath('../../src/matlab_octave');

            m = 17; n = 17;
            
            west = 0; east = 1; south = 0; north = 1;
            
            dx = (east-west)/m; dy = (north-south)/n;
            
            P = @(x,y) (6*(x.^5).*(y.^6));
            Q = @(x,y) (6*(x.^6).*(y.^5));
            R = @(x,y) ((x.^6).*(y.^6));
            Py = @(x,y) (36*(x.^5).*(y.^5));
            Qx = @(x,y) (36*(x.^5).*(y.^5));
            Rx = @(x,y) (6*(x.^5).*(y.^6));
            Ry = @(x,y) (6*(x.^6).*(y.^5));
            
            xc = (west+dx/2:dx:east-dx/2)'; yc = (south+dy/2:dy:north-dy/2)';
            xn = (west:dx:east)'; yn = (south:dy:north)';
            
            [Yc,Xn] = meshgrid(yc,xn); [Yn,Xc] = meshgrid(yn,xc);
            [Y,X]   = meshgrid(yc,xc); [Yp,Xp] = meshgrid(yn,xn);
            
            % exact curl
            Pa =  Ry(Xn,Yc); % first exact component of the 2D curl (at horizontal faces)
            Qa = -Rx(Xc,Yn); % second exact component of the 2D curl (at vertical faces)
            Ra = Qx(X,Y)-Py(X,Y); % third exact component of the 2D curl (at centers)
            Pac = reshape(Pa,[],1); 
            Qac = reshape(Qa,[],1); 
            Rac = reshape(Ra,[],1); 
            vac = [Pac; Qac; Rac]; 
            
            % analytics of 2D curl input data
            Rp = R(Xp,Yp); % R at cell nodes
            Pv = P(Xc,Yn); % P at the middle of the horizontal edges
            Qh = Q(Xn,Yc); % Q at the middle of the vertical edges
            Rpc = reshape(Rp,[],1);
            Pvc = reshape(Pv,[],1);
            Qhc = reshape(Qh,[],1);
            vp = [Pvc; Qhc; Rpc]; 

            ks=[2,4,6,8];
            tolcomp12 = [5e-2,5e-4,5e-14,5e-14];
            tolcomp3  = [6e-2,3e-3,6e-14,6e-14];
            tolglob   = [e-1,4e-3,8e-14,8e-14];

            for k = ks
                % tolerances
                tolc12 = tolcomp12(k);
                tolc3 = tolcomp3(k);
                tolg = tolglob(k);

                % 2D curl operator                
                C = curl2D(k, m, dx, n, dy); % need to modify the last component of 2D curl
                
                C0  = C*vp; % approximated 2D curl
                CC1 = C0(1:(m+1)*n); % first component of approximated 2D curl
                CC2 = C0((m+1)*n+1:(n+1)*m+n*(m+1)); % second component of approximated 2D curl
                Cc  = C0(n*(m+1)+(n+1)*m+1:end); % third component of the approximated 2D curl
                CC1 = reshape(CC1,m+1,n);
                CC2 = reshape(CC2,m,n+1);
                Cc  = reshape(Cc,m,n);
                
                % differences
                d1 = CC1-Pa; % first component
                d2 = CC2-Qa; % second component
                d  = Cc-Ra;  % third component
                d0 = C0-vac; % all components
            	
            	testCase.verifyLessThan(norm(d1),tolc12,...
                    sprintf("Nullity test failed for error 1st component, k = %d ", k));
            	testCase.verifyLessThan(norm(d2),tolc12,...
                    sprintf("Nullity test failed for error 2nd component, k = %d ", k));
            	testCase.verifyLessThan(norm(d),tolc3,...
                    sprintf("Nullity test failed for error 3rd component, k = %d ", k));
            	testCase.verifyLessThan(norm(d0),tolg,...
                    sprintf("Nullity test failed for global error, k = %d ", k));
            end
        end
    end
end
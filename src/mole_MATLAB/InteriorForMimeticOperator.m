% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

function [derivitive]=InteriorForMimeticOperator(k) %calculates the interior row of the mimetic operator of order 2k
%this formula is based off of 
derivitive=[-1/2,1/2];
nextTerm=[-1/8,3/8,-3/8,1/8];%represents (h/2*delta)^(2k+3), or [(-1)^(i+1)binom(2k+3,i)for i=0:2k+3]

NextTermCopy=nextTerm;
scalefactor=1;
edgevalue=1/8; %represents 1/(2^(2i+3)), what the value of 
for i=1:(k-1)
scalefactor=scalefactor*-(2*i-1)^2/(2*i*(2*i+1));
derivitive=[0 derivitive 0];
derivitive=derivitive+scalefactor*nextTerm; %size delta is 2i+2, we're about to make it 2i+4
edgevalue=edgevalue/4;
NextTermCopy=[-edgevalue NextTermCopy edgevalue];
NextTermCopy(3:(2*i+2))=(nextTerm(3:(2*i+2))-2*nextTerm(2:(2*i+1))+nextTerm(1:(2*i)))/4;
NextTermCopy(2)=(2*i+3)*edgevalue;
NextTermCopy(2*i+3)=-(2*i+3)*edgevalue;
nextTerm=NextTermCopy;


end
derivitive=2*derivitive;
end
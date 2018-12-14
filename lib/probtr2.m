function prob = probtr2(ntr, nt, nz)

%   MOST Paper Simulations
%   Copyright (c) 2014-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

if nargin <3
  nz = 1;
end

prob = ones(ntr, nt, nz)/ntr;
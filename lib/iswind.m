function Wind = iswind(gen, iwind)
%ISWIND  Checks for wind units.
%   WIND = ISWIND(GEN, IWIND) returns a column vector of 1's and 0's. The
%   1's correspond to rows of the GEN matrix which represent wind units.
%   The current test uses iwind (indexes of wind units) to generate the
%   logical array.

%   MOST Paper Simulations
%   Copyright (c) 2015-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

Wind = zeros(size(gen,1),1);

Wind(iwind) = 1;

Wind = logical(Wind);

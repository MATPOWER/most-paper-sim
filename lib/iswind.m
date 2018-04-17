function Wind = iswind(gen, iwind)
%ISWIND  Checks for wind units.
%   WIND = ISWIND(GEN, IWIND) returns a column vector of 1's and 0's. The
%   1's correspond to rows of the GEN matrix which represent wind units.
%   The current test uses iwind (indexes of wind units) to generate the
%   logical array.


Wind = zeros(size(gen,1),1);

Wind(iwind) = 1;

Wind = logical(Wind);


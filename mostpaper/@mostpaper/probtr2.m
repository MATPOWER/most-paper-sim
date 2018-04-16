function prob = probtr2(ntr, nt, nz)

if nargin <3
  nz = 1;
end

prob = ones(ntr, nt, nz)/ntr;
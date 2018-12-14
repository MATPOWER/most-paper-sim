function [blid, lampbus, lampcbus] = npricesmpf(mpsd)
% Function to extract nodal prices
% Inputs:
%   MPSD      :     Multi-period sopf structure
%
% Outputs
%   BLID      :     [nb x 1] Bus ID
%   LAMPBUS   :     [nb x nt] matrix of expected nodal prices (absolute)
%   LAMPCBUS  :     [nb x nt] matrix of expected nodal prices (conditional)
%
% Dependencies:
% - define_constants
% 
% Related functions:
% npriceshp.m :     prices in the system, probability weighted
% npricesf.m  :     function to filter prices in certain areas
%   
% 2014.02.24
% Alberto J. Lamadrid

%   MOST Paper Simulations
%   Copyright (c) 2014-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

define_constants;
nb = size(mpsd.mpc.bus, 1);
nt = size(mpsd.tstep, 2);

lampbus = zeros(nb, nt);
lampcbus = zeros(nb, nt);
for t = 1:nt
  pp = zeros(nb, 1);
  if isempty(mpsd.idx.nj)
    njt = 1;
  else
    njt = mpsd.idx.nj(t);
  end
  for j = 1:njt
    if isempty(mpsd.idx.nc)
      ncjt = 1;
    else
      ncjt = mpsd.idx.nc(t,j);
    end
    for k = 1:ncjt+1
      pp = pp + mpsd.flow(t,j,k).mpc.bus(:, LAM_P);
    end
  end
  lampbus(:, t) = pp; 
  lampcbus(:, t) = pp / mpsd.StepProb(t);
end

blid = mpsd.mpc.bus(:, BUS_I);
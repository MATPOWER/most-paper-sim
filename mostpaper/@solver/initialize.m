function x_ps = initialize(ps, x, sim_inputdir)
%INITIALIZE @solver/initialize

%   MP-Sim
%   Copyright (c) 2016, 2017 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MP-Sim.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

%mpc2 = cell(mpsd.idx.nt, 1);
mpc2 = {[]};
%r2.results = cell(mpsd.idx.nt, 1);
r2.results = {[]};
r2.xgd = {};
%r2.f = zeros(mpsd.idx.nt, 1);
r2.f = [];
%r2.success = zeros(mpsd.idx.nt, 1);  
r2.success = [];
x_ps = struct('mpc2', mpc2, 'r2', r2);

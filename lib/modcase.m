function mpco = modcase(mpci);
% Make modifications to base file
% - pmin for all generators (0)
% - ramp rates for generators (base on pmax-pmin range)
% - reactive demand for loads
% - ramp rates for loads (infinity)
% - scaling of load
% - line changes
% Alberto J. Lamadrid
% 2013.07.24

%   MOST Paper Simulations
%   Copyright (c) 2013-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

define_constants;

if ~isfield(mpci, 'iess')
  mpci.iess = [];
end
if ~isfield(mpci, 'iwind')
  mpci.iwind = [];
end

inp.rampf = 1.3;                    % factor for ramps
%inp.peak_load = 1.95;               % factor for peak load
%inp.peak_load = 2.1;                % factor for peak load
inp.line_increase = [];             % lines to be upgraded

mpco = mpci;

% find all gens excluding wind and ESS units
il = isload(mpci.gen);
ig = setdiff(find(~isload(mpci.gen)), union(mpci.iwind, mpci.iess));

mpco.gen(ig, PMIN) = 0;             % set to 0 PMIN for all gens
range = mpci.gen(ig, PMAX) - mpci.gen(ig, PMIN);
%mpco.gen(ig, RAMP_10) = inp.rampf * range;
%mpco.gen(ig, RAMP_30) = inp.rampf * range;
%mpco.gen(ig, RAMP_AGC) = inp.rampf * range;
%mpco.gen(il, QG) = 0;               % set Qg for all loads, ramps not binding
%mpco.gen(il, [RAMP_10, RAMP_30, RAMP_AGC]) = inf;

% Peak Load
if isfield(inp, 'peak_load')
    if inp.peak_load ~=1
        [mpco.bus, mpco.gen] = scale_load(inp.peak_load, mpci.bus, mpci.gen);
    end
end

if isfield(inp, 'line_increase')    % line improvements
    for k = 1:size(inp.line_increase, 1)
        ib = inp.line_increase(k, 1);
        if inp.line_increase(k, 2)      %% do it
            mpco.branch(ib, [BR_B RATE_A RATE_B RATE_C]) = mpci.branch(ib, [BR_B RATE_A RATE_B RATE_C]) * inp.line_increase(k, 3);
            mpco.branch(ib, [BR_R BR_X]) = mpci.branch(ib, [BR_R BR_X]) / inp.line_increase(k, 3);
        end
    end
end
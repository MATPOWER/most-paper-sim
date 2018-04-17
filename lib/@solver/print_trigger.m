function print_trigger(ps, x, y, r, t, idx)
%PRINT_TRIGGER @solver/print_trigger

%   MP-Sim
%   Copyright (c) 2016, 2017 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MP-Sim.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

fprintf('%d : trigger %s\n', t, ps.name);
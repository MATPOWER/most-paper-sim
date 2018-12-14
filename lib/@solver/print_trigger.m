function print_trigger(ps, x, y, r, t, idx)
%PRINT_TRIGGER @solver/print_trigger

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

fprintf('%d : trigger %s\n', t, ps.name);
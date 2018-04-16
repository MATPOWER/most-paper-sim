classdef solver < mpsim_process
%solver process is subclass of @MPSIM_PROCESS

%   MP-Sim
%   Copyright (c) 2016, 2017 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MP-Sim.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

    properties
    end
    methods
        function obj = solver(s)
            obj@mpsim_process(s);
        end
    end
end

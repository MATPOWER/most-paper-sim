classdef mostpaper < mpsim
%Subclass of MPSIM.  Specify all simulation definitions here.

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

    properties
    end
    methods
        function initialize(sim)
            %% set default values for simulator properties
            sim.l = 1;              %% l, length of simulation time step
            sim.units = 'periods';  %% units of l, length of time step
            sim.T = 24;             %% T, number of simulation periods per run
            sim.R = [2, 4, 2];   %% R, dimension(s) of simulation runs
            
            %% create and register process objects
            sim.register_process(solver(...
                struct( 'name', 'solver', ...
                        'f', 1, ...
                        't0', 1, ...
                        'tau', 0) ));
        end
    end
end

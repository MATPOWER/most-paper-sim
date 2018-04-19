function post_run(sim, y, sim_outputdir)
%POST_RUN @mostpaper/post_run

%   MP-Sim
%   Copyright (c) 2016, 2017 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MP-Sim.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

simname = sim.name;
config.outputs = sprintf('%s/../../', sim_outputdir);
config.workdir = sprintf('%s/../../', sim_outputdir);
config.inputs = sprintf('%s/../../', sim_outputdir);

group = 1;
runs2compare = cell(1);
runs2compare{group}.GroupType  = 'stc';
runs2compare{group}.GroupName  = [];
runs2compare{group}.GroupParam = [];
group = group + 1;

theta_len = sim.R(2);
theta_min = 0.6;
theta_max = 1.2;
theta_info{1} = theta_len;
theta_info{2} = theta_min;
theta_info{3} = theta_max;
theta = linspace(theta_min,theta_max,theta_len);
res_criteria_param = {theta, theta, theta, theta};

% The following defines the set of runs of each reserve criterion as a single group of runs
runs2compare{group}.GroupType  = 'det';
runs2compare{group}.GroupName  = 'default2';
runs2compare{group}.GroupParam = res_criteria_param{1};
group = group + 1;

compfxst2va_replicate(simname, config, runs2compare);
windinpaper(simname, config, theta);
varexpcompareares_replicate(simname, config, theta_info);
resplot1_replicate(simname, config, theta);
respgplots_replicate(simname, config, theta_info)
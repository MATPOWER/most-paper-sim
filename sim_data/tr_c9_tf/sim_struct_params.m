function sp = c9_simstruct
%C9_SIMSTRUCT
% % Outputs:
%   SP      :     Simulation Parameters
%
% Assumptions:
% Following structure in: 
% sopf3_sim_params.m
%
% Questions:
% - what is a horizon in stage 2?
% - field t0 taken from ray-notes row 25
% - added field T in s1, denoting number of stage 1 runs - for which information is available
% 
% 2014.06.21
% Ray Zimmerman
% Alberto J. Lamadrid

% absolute periods are indexed both by single index t = 1:T, as in trajectories,
% and by pairs (t1, t2), where t1 is "stage 1 period" index and t2 is a
% "stage 2 period" index within the corresponding "stage 1 period"

sp = struct(...
    'start_date', 0302, ... %% date MMDD of beginning of trajectory
    'start_hour', 00, ...   %% hour HH of beginning of trajectory
    't0', struct(...
        'N', 13, ...        %% number of trajectories
        'P', 24 ...         %% length of trajectory in stage 2 periods
        ), ... 
    's1', struct(...
        'l', 60, ...        %% length of period in minutes
        'P', 24, ...        %% length of horizon in periods
        'T', 1, ...         %% number of stage 1 runs
        'f', 1, ...         %% frequency of runs in periods
        'tau_in', 210, ...  %% computation begins tau_in minutes before 1st period in planning horizon
        'tau_out', 180 ...  %% results are available tau_out minutes before 1st period in planning horizon
        ), ...              
    's2', struct(...
        'l', 30, ...        %% length of period in minutes
        'P', 6, ...         %% length of horizon in periods
        'f', 1, ...         %% frequency of runs in periods
        'tau_in', 10, ...   %% computation begins tau_in minutes before 1st period in planning horizon
        'tau_out', 2 ...    %% results are available tau_out minutes before 1st period in planning horizon
        ) ...
);
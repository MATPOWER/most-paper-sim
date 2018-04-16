function compfxst2va_replicate(simname, configf, runs2compare, normGroup, normRun)
% Inputs:
%   SIMNAME     :   Name of the directory where the run for the simulation is stored
%   CONFIGF     :   Configuration file of stochastic runs.
%                   Three potential directories (default in parenthesis):
%     'inputs'      
%     'workdir'     All three set in @mostpaper/post_run
%     'outputs'     
%                   if empty, all info inside configf.inputs/simname folder 
%   RUNS2COMPARE :  Array of structs where each struct contains info of the runs to be
%                   compared.
%               {}.GroupType   Type of group of runs: 'det' for deterministic (fix reserves)  or 'stc' for stochastic runs  
%               {}.GroupName   Name of group of runs. For fixed reserves, this indicates name of reserve criteria: {'default', 'default2', etc.}  
%               {}.GroupParam  Matrix of parameters of group of runs, where each column contains the parameters for a single run 
%   NORMGROUP    : Number of group containing the run used to plot normalized costs. (default: first stochastic group)   
%   NORMRUN      : Number of run within group normGroup used to plot normalized costs. (default: first run of selected group) .
%
% Creates plot of average costs (x axis) against costs standard deviation (y axis) and corresponding table.
%
% 04.07.2015
% 2018.03.09
% Daniel Munoz-Alvarez
% Alberto J. Lamadrid

%**************************** ASSUMPTION **********************************
% Assumption of location of groups of fixed reserve runs:
% compfxst2va_replicate assumes the folder specified by configf.output (or the default,
% if empty) not only IS the 'output' folder of the stochastic run(s)
% but it also CONTAINS the 'output' folders of all the deterministic runs.
%**************************************************************************

if nargin < 5
    normRun = [];
    if nargin < 4
        normGroup = [];
    end
end

% Default working and output folders
if isempty(configf.outputs)
  configf.outputs = configf.inputs;
end
if isempty(configf.workdir)
  configf.workdir = configf.inputs;
end

% Number of group runs
Ngroups = numel(runs2compare);


define_constants;
savetr = 0;                         % simulation counter
s1cont = 0;                         % stage 1 counter
s2cont = 0;                         % stage 2 counter
s1datan = 's1-data';                % name of mat file with s1 data
s2datan = 's2-data';                % name of mat file with s2 data
s1plots = 's1_plots';               % name of mat file with s1 data for plots
s1fdatan = 's1f-data';              % name of mat file with s1 fixed data
s2fdatan = 's2f-data';              % name of mat file with s2 fixed data
s1fplots = 's1f_plots';             % name of mat file with s1 fixed data for plots
res2name = 'traj';                  % short name for results of second stage (to save)
res2namef = 'trajf';                % short name for results of second stage (to save)
 

savecompdir = sprintf('%s%s/outputs/comp/', ...
  configf.outputs, simname);% file for comparison results

if ~exist(savecompdir, 'dir')
    mkdir(savecompdir);
end

prfxn = simname;                    % add at beginning of file names for plots
prfix = sprintf('%s%s', savecompdir, simname);
my_xlabel = 'Hours';

Ecost  = 1;                          % energy cost
Rcost  = 2;                          % reserve cost
Lcost  = 3;                          % load not served (lns) cost
R2cost = 4;                          % second stage (real-time) reserve cost
UCcost = 5;                          % unit commitment cost
Tcost  = 6;                          % total cost

vars = [Ecost; Rcost; Lcost; R2cost; UCcost; Tcost];


energyCost     = cell(Ngroups,1);
lnsCost        = cell(Ngroups,1);
reserveCost    = cell(Ngroups,1);
reserveCost2   = cell(Ngroups,1);
commitmentCost = cell(Ngroups,1);
totalCost      = cell(Ngroups,1);
data           = cell(Ngroups,1);
labels         = cell(1,Ngroups);

AllDataS1 = cell(Ngroups,1);
AllDataS2 = cell(Ngroups,1);

done = 0; % Selecting run to normalize plots by default

for group = 1:Ngroups
    
    if strcmp('stc', runs2compare{group}.GroupType)
        GroupSize = 1;
        StcGroup = 1;
        
        labels{group} = 'stochastic';
        
        if ~done
            normGroup = group;
            normRun = 1;
            done = 1;
        end
        
    elseif strcmp('det', runs2compare{group}.GroupType)
        GroupSize = size(runs2compare{group}.GroupParam,2);
%        GroupSize = 1;             % changed 2018.03.11, match compfxst2
        StcGroup = 0;
        
        labels{group} = [runs2compare{group}.GroupName];
%        labels{group} = 'deterministic'; % % changed 2018.03.11, match compfxst2
        
    else
        error('GroupType must be either stc or det.')
    end
    
    % Initialize data table
    energyCost{group}    = zeros(GroupSize,1);
    reserveCost{group}   = zeros(GroupSize,1);
    lnsCost{group}       = zeros(GroupSize,1);
    reserveCost2{group}  = zeros(GroupSize,1);
    commitmentCost{group}= zeros(GroupSize,1);
    totalCost{group}     = zeros(GroupSize,1);
    data{group}.average  = zeros(GroupSize,length(vars));
    data{group}.stddev   = zeros(GroupSize,length(vars));
    
    % Names of variables to load for computations (to avoid loading too many unnecessary variables)
    varnamesST1 = {'r0','r1','r2'};    % So far, no variables from stage 1 are being used, only loaded for debugging/checking purposes
    varnamesST2 = {'ntr','cstP2','ig','genRrp','genRrm','genRup','genRdn','shcstP2','ucstcost','ucsdcost','genRup2','genRdn2', 'cstP2f'};
    varnamesFX  = {'ntr','cstP2','ig','genRrp','genRrm','genRup','genRdn','shcstP2','ucstcost','ucsdcost','rescost2'};

    for run = 1:GroupSize
        
        % Determine names of result files of first and second stages
        % Names are different for stochastic and deterministic simulations
        if StcGroup
            savefiles1 = sprintf('%s%s/work/stage1/%3.3i/results_%3.3i', ...
                configf.workdir, simname, savetr, s1cont);% file for stage 1 results
            savefileress2 = sprintf('%s%s/outputs/stage2/%3.3i/%s', ...
                configf.outputs, simname, savetr, s2datan);% directory for processed outputs, s2
            
            resultsS1 = savefiles1;
            resultsS2 = savefileress2;
            
            % Load first stage results
%             load(resultsS1, varnamesST1{:});
%             AllDataS1{group}(run) = load(resultsS2);   % Saving all for debbuging
            % Load second stage results for stochastic run
            load(resultsS2, varnamesST2{:});
%             AllDataS2{group}(run) = load(resultsS2);   % Saving all for debbuging
            
            warning('Ad hoc temporary fix being used: Should make accounting variables in fix and stochastic cases the same.')
            rescost2 = zeros(ntr,1);
            
        else
            
            % file for processed s2 outputs of fixed reserves, (stored in s1)
%            resultsS2 = [  sprintf('%s%s',configf.outputs, simname) filesep...
%                                sprintf('outputs/stage1/%3.3i/%s',savetr, s1fdatan)...
            resultsS2 = [  sprintf('%s%s',configf.outputs, simname) filesep...
                                [simname '_' runs2compare{group}.GroupName '_' sprintf('%0.3i',run) filesep simname]...
                                sprintf('/outputs/stage1/%3.3i/%s',savetr, s1fdatan)...
                              ];
            
            % Load second stage results
            
            load(resultsS2, varnamesFX{:});
            AllDataS2{group}(run) = load(resultsS2); % Saving all for debbuging
            
            genRup2 = zeros(1,1,ntr);
            genRdn2 = zeros(1,1,ntr);
        end
        
        % Generation costs only (not consumption utility)
        energyCost{group}(run,1:ntr) = permute( sum( sum( cstP2(ig,:,1:ntr,1), 2), 1), [1 3 2])...  % dimensions of cstP2: ng x nt x ntr x (nc0 + 1)
                                     + permute( sum( sum( cstP2f(ig,:,1:ntr,1), 2), 1), [1 3 2]); % dimensions of cstP2f: ng x nt x ntr x (nc0 + 1)
        % Stage 1 reserve costs
        reserveCost{group}(run,1:ntr) =... 
                 ...  sum( sum( genRrp ) )...   % Positive ramping reserve cost: dimensions ng x (nt - 1)
                 ...+ sum( sum( genRrm ) )...   % Negative ramping reserve cost: dimensions ng x (nt - 1)
                + sum( sum( genRup ) )...       % Positive contingency reserve cost: dimensions ng x nt
                + sum( sum( genRdn ) );         % Negative contingency reserve cost: dimensions ng x nt
        
        % Load shed cost: recall that the cost of lost load is actually -schstP2 because it is stored as a benefit rather than as a cost   
        lnsCost{group}(run,1:ntr) = permute(sum( sum( -shcstP2(:,:,:,1), 2), 1), [1 3 2]);   % dimensions of cstP2: ng x nt x ntr x (nc0 + 1)
        
        % Stage 2 contingency reserve costs
        reserveCost2{group}(run,1:ntr) =...
                + reshape(sum( sum( genRup2(:,:,1:ntr), 1), 2),1,[])...   % Contingency up reserve cost: dimensions ng x nt x ntr
                + reshape(sum( sum( genRdn2(:,:,1:ntr), 1), 2),1,[])...   % Contingency down reserve cost: dimensions ng x nt x ntr
                + reshape(sum( rescost2(1:ntr,:),2 ),1,[]);               % Fixed contingency reserve cost: dimensions ntr x nt
        
        % Unit Commitment costs (start-up and shut-down costs)
        commitmentCost{group}(run,1:ntr) =...
                + sum( sum( ucstcost ) )...               % Start-up costs: dimensions ng x nt
                + sum( sum( ucsdcost ) );                 % Shut-down costs: dimensions ng x nt
            
        % Total cost
        totalCost{group}(run,1:ntr) =...
                                  energyCost{group}(run,1:ntr)...
                                + reserveCost{group}(run,1:ntr)...
                                + lnsCost{group}(run,1:ntr)...
                                + reserveCost2{group}(run,1:ntr)...
                                + commitmentCost{group}(run,1:ntr);
        
        % Store average and std dev of costs in table: avg energy, avg
        % reserve, avg load not served, avg total cost, std dev total cost
        data{group}.average(run, Ecost)  = mean( energyCost{group}(run,1:ntr), 2);
        data{group}.average(run, Rcost)  = mean( reserveCost{group}(run,1:ntr), 2);
        data{group}.average(run, Lcost)  = mean( lnsCost{group}(run,1:ntr), 2);
        data{group}.average(run, R2cost) = mean( reserveCost2{group}(run,1:ntr), 2);
        data{group}.average(run, UCcost) = mean( commitmentCost{group}(run,1:ntr), 2);
        data{group}.average(run, Tcost)  = mean( totalCost{group}(run,1:ntr), 2);
        
        data{group}.stddev(run, Ecost)  = std( energyCost{group}(run,1:ntr), [], 2);
        data{group}.stddev(run, Rcost)  = std( reserveCost{group}(run,1:ntr), [], 2);
        data{group}.stddev(run, Lcost)  = std( lnsCost{group}(run,1:ntr), [], 2);
        data{group}.stddev(run, R2cost) = std( reserveCost2{group}(run,1:ntr), [], 2);
        data{group}.stddev(run, UCcost) = std( commitmentCost{group}(run,1:ntr), [], 2);
        data{group}.stddev(run, Tcost)  = std( totalCost{group}(run,1:ntr), [], 2);
    end
end

if isempty(normGroup)
    normGroup = 1;
end
if isempty(normRun)
    normRun = 1;
end

save([prfix '_compfxst2va_replicate'], 'energyCost', 'reserveCost', 'reserveCost2', ...
  'commitmentCost', 'totalCost', 'data');
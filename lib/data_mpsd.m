function varargout = data_mpsd(mpsd, optd, ntraj, prob2)
% 
% This file has two functions included:
% data_mpsd   : Creates information for post-processing extraction
% print_dmpsd : Prints txt files with main results
%
% Information includes
% - Revenue and financial calculations
% - System management data
%
% Based on previous files:
% - hp_revenuedc
% - hp_revenuedcs2
% - hpf_revenuedcs2
% - hp_revenuedc_wy
% - doplots_hpdc
% - revenuenpcc
% - rampnpcc
% 
% Inputs:
%   MPSD      :     Data structure with all fields after running the multi-period 
%                   SuperOPF problem (mpsopfl)
%   OPTD      :     Options for data extraction, including the following. The default is 
%                   shown in parenthesis:
%     'runtype'     (first stage) select stage ('1', '2', 'f')
%     'saveit'      (true) flag to indicate whether to create .mat file
%     'savepath'    ('') path to directory to save files in
%     'savename'    ('data-cx_fs') name of .MAT file
%     'tframe'      (24)  number of time periods considered
%     'fuelinfo'    (true) flag to indicate whether there is fuel information (ng x 1)
%     'rtoinfo'     (true) flag to indicate whether there is rto information (ng x 1)
%     'shed_threshold' (1e-3) used for load shedding calculation
%     'var_threshold' (0) variance threshold for generators, defines which variables are plotted
%     'opttable'    (1) create a table with detailed information per period
%     'verbose'     (0) displays to user
%     'optp'        ([]) printing options for text files
% If runtype == 2 (second stage), the following field should be added to optd
%     'basedir2'    ('c9_fs-res2') directory with second stage results 
%     'res2name'    ('traj#') name of the trajectories in the second stage
%
%   NTRAJ     :     () Number of trajectories for second stage, default empty
%   PROB2     :     () Probability for each trajectory (ntr x nt), default empty
%
% Outputs:
%     VARARGOUT :     Variables for creating plots (80 if first run, 104 if second run)

% doplots_hpdc: 
% missing variables (not included in optd):
% - savefilei has to be used instead of savefile to avoid confussions (this to be replaced)
% - nti;
% - tframe = nti;
% - basedir (using savefilei and nti)
% - ld
% - fact
% - fn_prefix
%
% Variables defined but not used
% flow_threshold
% 
% maxgencap:
% missing variables
% - Markers
% 
% Assumptions:
% - mpsd.mpc has information on the location of ess and wind units (mpsd.mpc.iwind, mpsd.mpc.iess)
% - if fields mpsd.mpc.iwind, mpsd.mpc.ies do not exist, assume there are no wind/ess units
% - loads do not include ess units (il index)
% - igi index includes active generators and ess units
% - ig index excludes igi and wind generators
% - there was a correction for zero probabilities (older version of code). This is assumed not necessary
% - in case of a second stage, file provided (mpsd) is the first stage results. This mpsd has info on the trajectories
%
% Implementation plan:
% 1- start with data created in doplots_hpdc, revenuenpcc
% 2- construct back data from different versions of hp*_revenue (stochastic runs)
% 3- saving info for plots - not large dataset.
% 4- Ray is of the opinion that calculations should be made and no data saved - to avoid large files
%   - compromise: only save info strictly necessary for plots into a .mat file 
% (testing creates a file of around 111kb, 898 if including mpsd)
% 5- 2015.05.23: the new stage 2 uses a a version of mpsoplf. For references to sopf, check data_mpsdv0
%
% Pendings (to be done by first implementation):
% - Replace OstrDCC by mpsd (DONE)
% - Replace all occurrences of ref.ess by ie, ref.wind by iw (DONE)
% - Replace Ostr2 by tri.r2 (re-evaluate if the prefix r2 is appropriate?)
% - LNScst2 is not used (delete?)
%
% Additonal functions used:
% - print_dmpsd (also part of this file)
%
% Future Enhancements:
% - move the following variables to plotting function
%   var_threshold = 0;                % variance threshold for generators
%   loadplots = 0;                    % set to 0 if not interested in load plots
% - add variables for:
%   - cost of reserves
%   - cost of ramp
%   - cost of load follow
% - Define how are the fuel types information going to be treated
% - calculate ramping costs (RampWearCostCoeff) in this file
%
% 2015.05.23
% Alberto J. Lamadrid

%   MOST Paper Simulations
%   Copyright (c) 2015-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

if nargin < 2
  optd.runtype = '1';
  optd.saveit = 1;
  optd.savepath = [];
  optd.savename = 'data-cx_fs';
  optd.tframe = 24;
  optd.fuelinfo = 1;
  optd.rtoinfo = 1;
  optd.shed_threshold = 1e-3;
  optd.var_threshold = 0;
  optd.opttable = 1;
  optd.verbose = 0;
  optd.optp = [];
  optd.basedir2 = 'c9_fs-res2';
  optd.res2name = 'traj';
else
  if nargin < 3
    ntraj = [];
  else
    if nargin < 4
      prob2 = [];
    end
  end
  if ~isfield(optd, 'runtype')
    optd.runtype = '1';
  elseif optd.runtype == '2'
    if ~isfield(optd, 'basedir2')
      optd.basedir2 = 'c9_fs-res2';
    end
    if ~isfield(optd, 'res2name')
      optd.res2name = 'traj';
    end
  end
  if ~isfield(optd, 'saveit')
    optd.saveit = 1;
  end
  if ~isfield(optd, 'savepath')
    optd.savepath = [];
  end
  if ~isfield(optd, 'savename')
    optd.savename = 'data-cx_fs';
  end
  if ~isfield(optd, 'tframe')
    optd.tframe = 24;
  end
  if ~isfield(optd, 'fuelinfo')
    optd.fuelinfo = 1;
  end
  if ~isfield(optd, 'rtoinfo')
    optd.rtoinfo = 1;
  end
  if ~isfield(optd, 'shed_threshold')
    optd.shed_threshold = 1e-3;
  end
  if ~isfield(optd, 'var_threshold')
    optd.var_threshold = 0;
  end
  if ~isfield(optd, 'opttable')
    optd.opttable = 1;
  end
  if ~isfield(optd, 'verbose')
    optd.verbose = 0;
  end
  if ~isfield(optd, 'optp')
    optd.optp = [];
  end
end

%% define named indices into bus, gen, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;
[CRPPOS, QRPPOS, CRPNEG, QRPNEG, DCPPOS, DCPNEG] = idx_rof;

OstrDCC = mpsd;                     % ? delete

%%----- Basic Information setup  -----
ntt = mpsd.idx.nt;                  % number of time periods
if optd.tframe <=0
    tframe = ntt;                   % assign total number if periods if user does not specify frame
end
nt = optd.tframe;                   % time frame of analysis
startnt = ntt - nt;                 % place to start time analysis
ng = size(mpsd.mpc.gen, 1);         % number of generators (includes dispatchable loads)
nb = size(mpsd.mpc.bus, 1);         % number of buses
ns = size(mpsd.mpc.iess, 1);        % number of storage units

if ~isfield(mpsd.mpc, 'iwind')
  iw = [];
else
  iw = mpsd.mpc.iwind;
end
if ~isfield(mpsd.mpc, 'iess')
  ie = [];
else
  ie = mpsd.mpc.iess;
end

if size(mpsd.Storage.UnitIdx, 1) < size(ie, 1)
    ne = size(ie, 1);
else                                % number of ESS units  
    ne = size(mpsd.Storage.UnitIdx, 1);
end
nj = max(mpsd.idx.nj);              % number of scenarios
nc = max(max(mpsd.idx.nc));         % number of contingencies (not including base)
if nc ==0
    nc0 = 1;
else
    nc0 = nc;
end
il = setdiff((find(isload(mpsd.mpc.gen) & mpsd.mpc.gen(:, GEN_STATUS) > 0)), ...
    ie);                            % determine loads different to ESS units
igi = setdiff((find(~isload(mpsd.mpc.gen) & mpsd.mpc.gen(:, GEN_STATUS) > 0)), ...
    ie);                            % determine gens different to ESS units
ig = setdiff(igi, iw);              % determine gens different to wind units
prob = mpsd.CostWeights;            % probabilities of contingencies in each time period. nc x nj x nt

% correct zero probabilities (check hp_revenuedc, around prob assignment)

prs = sum(prob(:, :, :), 1);
if nj>1 && size(prs, 3) >1
  prs = reshape(prs, nj, nt);       % probabilities of each state
else
  prs = squeeze(prs)';              % case of single scenarios   
end
cprobk = ones(size(prob));          % conditional probabilities of contingency, on scenario and time period 
cprobsc = ones(nj, nt);             % conditional probabilities of each scenario with its contingencies, on time period
cprobt = sum(prs, 1);               % probabilities of each time period, (nt x 1)

%%----- Creation of New Variables to be saved -----
Pg = NaN * ones(ng, nt, nj, nc0 + 1);       % Active Power
%Qg = NaN * ones(ng, nt, nj, nc0 + 1);        % Reactive Power
lamP = NaN * ones(ng, nt);                  % Active power Nodal prices
%lamQ = Nan * ones(ng, nt, nj, nc0 + 1);      % Reactive power nodal prices
cstP = NaN * ones(ng, nt, nj, nc0 + 1);     % Cost
cstPf = zeros(ng, nt, nj, nc0 + 1);         % no-load costs
revP = NaN * ones(ng, nt, nj, nc0 + 1);     % Revenue for P
shedP = zeros(ng, nt, nj, nc0 + 1);         % shed load
shcstP = zeros(ng, nt, nj, nc0 + 1);        % cost of load shed
revP2 = zeros(ng, nt, nj, nc0 + 1);         % revenue for loads shed
eshed = zeros(nt, nj);                      % expected load shed over contingencies
ePg = zeros(ng, nt, nj);                    % expected power generated over contingencies
ecstP = zeros(ng, nt, nj);                  % expected cost over contingencies
ecstPf = zeros(ng, nt, nj);                 % expected no load cost over contingencies
erevP = zeros(ng, nt, nj);                  % expected revenue for gens over contingencies
erevP2 = zeros(ng, nt, nj);                 % expected revenue from load shed over contingencies
eshcstP = zeros(ng, nt, nj);                % expected demand shed
e2shed = zeros(1, nt);                      % expected shed over scenarios/contingencies
e2Pg = zeros(ng, nt);                       % expected power dispatched over scenarios/contingencies
e2cstP = zeros(ng, nt);                     % expected cost over scenarios/contingencies
e2cstPa = zeros(ng, nt);                    % expected cost over scenarios/contingencies using adjusted weights, conventional gens
e2cstPf= zeros(ng, nt);                     % expected no load cost over scenarios/contingencies
e2cstPaf = zeros(ng, nt);                   % expected no load cost over scenarios/contingencies using adjusted weights, conventional gens
e2shcstP = zeros(ng, nt);                   % expected shed power over scenarios/contingencies
e2revP = zeros(ng, nt);                     % expected revenue over scenarios/contingencies
e2revP2 = zeros(ng, nt);                    % expected revenue from load shed
genPcst = NaN * ones(1, nt);                % Cost of generation
genP = NaN * ones(1, nt);                   % expected cost of power generated
genE = NaN * ones(1, nt);                   % expected cost payed to ESS
loadP = NaN * ones(1, nt);                  % expected payments from loads
LNScst = NaN * ones(1, nt);                 % cost of load not served
Pc = NaN * ones(ng, nt);                    % contracted amounts
Rpp = NaN * ones(ng, nt);                   % Positive reserves 
Rpm = NaN * ones(ng, nt);                   % Negative Reserves (contingency)
Rrp = NaN * ones(ng, nt-1);                 % Positive ramp reserve
Rrm = NaN * ones(ng, nt-1);                 % Negative Ramp reserve
Sp = NaN * ones(ne, nt);                    % Upper storage bound
Sm = NaN * ones(ne, nt);                    % lower storage bound
Rpplam = NaN * ones(ng, nt);
Rpmlam = NaN * ones(ng, nt);
genRup = NaN * ones(ng, nt);                % Cost of contingency up reserves
genRdn = NaN * ones(ng, nt);                % Cost of contingency down reserves
Gmaxlim = NaN * ones(ng, nt, nj, nc0 + 1);  % upper limits on units
Gminlim = NaN * ones(ng, nt, nj, nc0 + 1);  % lower limits on units
Gmaxe = zeros(ng, nt, nj);                  % expected available (pmax) over contingencies
Gmaxe2 = zeros(ng, nt);                     % expected available (pmax) over scenarios/contingencies
genRrp = NaN * ones(ng, nt - 1);            % cost of positive ramping
genRrm = NaN * ones(ng, nt - 1);            % cost of negative ramping
Rrplam = NaN * ones(ng, nt-1);              % prices for ramp, positive
Rrmlam = NaN * ones(ng, nt-1);              % prices for ramp, negative
eStorSt = NaN * ones(ne, nt);               % expected storage state
eStorPg = NaN * ones(ne, nt);               % expected storage dispatch
mstorl = NaN * ones(ne, nt);                % min storage level
Mstorl = NaN * ones(ne, nt);                % Max storage level
Rrpoffer = NaN * ones(ng, nt);              % Positive ramp offers
Rrmoffer = NaN * ones(ng, nt);              % Negative ramp offers
erpCost = NaN * ones(ng, nt);               % Expected ramp cost
tloadp = NaN * ones(nb, nt);                % load per period, active
tloadq = NaN * ones(nb, nt);                % load per period, reactive
eshedP = zeros(ng, nt, nj);                 % expected load shed over contingencies
e2shedP = zeros(ng, nt);                    % expected load shed (over contingencies/scenarios)
Lim = NaN * ones(ng, nt);                   % upper limits (gmax) generated per time period
lim = NaN * ones(ng, nt);                   % lower limits (gmin) generated per time period
GG = NaN * ones(ng, nt);                    % upper generation dispatched (Pg)
GGm = NaN * ones(ng, nt);                   % lower generation dispatched (Pg)
ucstcost = NaN * ones(ng, nt);              % Cost of startup of gens
ucsdcost = NaN * ones(ng, nt);              % Cost of shutdown of gens
if optd.runtype == 2                        % second stage run
  ntr = ntraj;                              % number of trajectories used
  Pg2 = NaN * ones(ng, nt, ntr, nc0 + 1);   % Active Power, s2
  lamP2 = NaN * ones(ng, nt, ntr);          % Active power Nodal prices, s2
  lamP2b = NaN * ones(nb, nt, ntr);         % Active power Nodal prices, s2, buses
  cstP2 = NaN * ones(ng, nt, ntr, nc0 + 1); % Cost, stage 2
  cstP2f = zeros(ng, nt, ntr, nc0 + 1);     % no-load cost, stage 2
  revPs2 = NaN * ones(ng, nt, ntr, nc0 + 1);% Revenue for P, s2
  shedP2 = zeros(ng, nt, ntr, nc0 + 1);     % shed load, s2
  shcstP2 = zeros(ng, nt, ntr, nc0 + 1);    % cost of load shed, s2
  eshed2 = zeros(nt, ntr);                  % expected load shed over contingencies, s2
  ePg2 = zeros(ng, nt, ntr);                % expected power generated over contingencies, s2
  ecstP2 = zeros(ng, nt, ntr);              % expected cost over contingencies, s2
  ecstP2f = zeros(ng, nt, ntr);             % expected no-load cost over contingencies, s2
  erevPs2 = zeros(ng, nt, ntr);             % expected revenue for gens over contingencies, s2
  eshcstP2 = zeros(ng, nt, ntr);            % expected cost demand shed, s2
  e2shed2 = zeros(1, nt);                   % expected shed over scenarios/contingencies, s2
  e2Pg2 = zeros(ng, nt);                    % expected power dispatched over scenarios/contingencies, s2
  e2cstP2 = zeros(ng, nt);                  % expected cost over scenarios/contingencies, s2
  e2cstP2f = zeros(ng, nt);                 % expected no-load cost over scenarios/contingencies, s2
  e2shcstP2 = zeros(ng, nt);                % expected shed power over scenarios/contingencies, s2
  e2revPs2 = zeros(ng, nt);                 % expected revenue over scenarios/contingencies, s2
  LNScst2 = NaN * ones(1, nt);              % cost of load not served, 2s
  eshedP2 = zeros(ng, nt, ntr);             % expected load shed over contingencies, s2
  e2shedP2 = zeros(ng, nt);                 % expected load shed (over contingencies/scenarios), s2
  eopcstP2 = zeros(ng, nt);                 % average operation cost over trajectories on intact case, s2
  Rpp2 = NaN * ones(ng, nt, ntr);           % Positive reserves 
  Rpm2 = NaN * ones(ng, nt, ntr);           % Negative Reserves (contingency)
  Rpplam2 = NaN * ones(ng, nt, ntr);
  Rpmlam2 = NaN * ones(ng, nt, ntr);
  genRup2 = NaN * ones(ng, nt, ntr);        % Cost of contingency up reserves
  genRdn2 = NaN * ones(ng, nt, ntr);        % Cost of contingency down reserves
  Gmaxlim2 = NaN * ones(ng, nt, ntr, nc0 + 1); % upper limits on units, s2
  Gminlim2 = NaN * ones(ng, nt, ntr, nc0 + 1); % lower limits on units, s2
end

lamP(:, :) = mpsd.results.GenPrices(:, startnt + 1:end) ./ (ones(ng, 1) * cprobt);

for t = 1:nt                        % cycle over time periods
  if optd.verbose
    fprintf('Time period considered: %d\n', t);
  end
  for sc = 1:nj                     % cycle over scenarios
    if optd.verbose
      fprintf('Scenario considered: %d\n', sc);
    end
    cidvc = zeros(nc, 1);           % vector of contingencies first settlement
    for c = 1:nc+1                  % cycle over contingencies
      mpc = mpsd.flow(startnt + t, sc, c).mpc;
      gen = mpc.gen;
      bus = mpc.bus;
%% RDZ - 6/10/15
%% per-flow gencosts have been modified from original to remove
%% fixed cost portion and include it in separate objective function cost
%% term multiplied by commitment variable, so the following does
%% NOT include the fixed costs and we need to include them explicitly ...
      gencost = mpc.gencost;
      Pg(:, t, sc, c) = gen(:, PG) .* (gen(:, GEN_STATUS) > 0);
      % Qg(:, t, sc, c) = gen(:, QG) .* (gen(:, GEN_STATUS) > 0);
      Gmaxlim(:, t, sc, c) = gen(:, PMAX) .* (gen(:, GEN_STATUS) > 0);
      Gminlim(:, t, sc, c) = gen(:, PMIN) .* (gen(:, GEN_STATUS) > 0);
      cstP(:, t, sc, c) = totcost(gencost, Pg(:, t, sc, c)) .* (gen(:, GEN_STATUS) > 0);
%% ... which we do here ...
      % check for UC
      if ~isempty(mpsd.UC.CommitKey) &&  isfield(mpc, 'fixed_gencost')
        % explicitly add no-load cost from flow-specific mpc.fixed_gencost
        cstPf(:, t, sc, c) = mpc.fixed_gencost .* (gen(:, GEN_STATUS) > 0);% have variable tracking only no-load costs
        cstP(:, t, sc, c) = cstP(:, t, sc, c) + cstPf(:, t, sc, c);
      end
      e2cstPa(:, t) = e2cstPa(:, t) + cstP(:, t, sc, c) * mpsd.CostWeightsAdj(c,sc,t);
      e2cstPaf(:, t) = e2cstPaf(:, t) + cstPf(:, t, sc, c) * mpsd.CostWeightsAdj(c,sc,t);
%      cstP(:, t, sc, c) = totcost(gencost, Pg(:, t));
      revP(:, t, sc, c) = Pg(:, t, sc, c) .* lamP(:, t);
                                    % load shed
      s = find(gen(il, PG)- gen(il, PMIN) > optd.shed_threshold);
      if ~isempty(s)
          shedP(il(s), t, sc, c) = gen(il(s), PG)- gen(il(s), PMIN);
          shcstP(il(s), t, sc, c) = totcost(gencost(il(s), :), gen(il(s), PMIN)) .* (gen(il(s), GEN_STATUS) > 0) -...
              cstP(il(s), t, sc, c);
%% ... and here, check for UC
          if ~isempty(mpsd.UC.CommitKey) &&  isfield(mpc, 'fixed_gencost')
            shcstP(il(s), t, sc, c) = shcstP(il(s), t, sc, c) + ...
              mpc.fixed_gencost(il(s)) .* (gen(il(s), GEN_STATUS) > 0);
          end
          revP2(il(s), t, sc, c) = Pg(il(s), t, sc, c) .* lamP(il(s), t);
          eshed(t, sc) = eshed(t, sc) + prob(c, sc, t);
      end
      cprobk(c, sc, t) = prob(c, sc, t) / prs(sc, t);
      if prs(sc,t) == 0
        cprobk(:, sc, t) = 0;
      end
      ePg(:, t, sc) = ePg(:, t, sc) + cprobk(c, sc, t) * Pg(:, t, sc, c);
      Gmaxe(:, t, sc) = Gmaxe(:, t, sc) + cprobk(c, sc, t) * Gmaxlim(:, t, sc, c);
      ecstP(:, t, sc) = ecstP(:, t, sc) + cprobk(c, sc, t) * cstP(:, t, sc, c);
      ecstPf(:, t, sc) = ecstPf(:, t, sc) + cprobk(c, sc, t) * cstPf(:, t, sc, c);
      erevP(:, t, sc) = erevP(:, t, sc) + cprobk(c, sc, t) * revP(:, t, sc, c);
      erevP2(:, t, sc) = erevP2(:, t, sc) + cprobk(c, sc, t) * revP2(:, t, sc, c);
      eshcstP(:, t, sc) = eshcstP(:, t, sc) + cprobk(c, sc, t) * shcstP(:, t, sc, c);
      eshedP(:, t, sc) = eshedP(:, t, sc) + cprobk(c, sc, t) * shedP(:, t, sc, c);
    end
    cprobsc(sc, t) = prs(sc, t) / cprobt(1, t);
    if cprobt(1, t) == 0
      cprobsc(sc, t)=0;
    end
    e2shed(1, t) = e2shed(1, t) + cprobsc(sc, t) * eshed(t, sc);
    e2Pg(:, t) = e2Pg(:, t) + cprobsc(sc, t) * ePg(:, t, sc);
    Gmaxe2(:, t) = Gmaxe2(:, t) + cprobsc(sc, t) * Gmaxe(:, t, sc);
    e2cstP(:, t) = e2cstP(:, t) + cprobsc(sc, t) * ecstP(:, t, sc);
    e2cstPf(:, t) = e2cstPf(:, t) + cprobsc(sc, t) * ecstPf(:, t, sc);
    e2shcstP(:, t) = e2shcstP(:, t) + cprobsc(sc, t) * eshcstP(:, t, sc);
    e2revP(:, t) = e2revP(:, t) + cprobsc(sc, t) * erevP(:, t, sc);
    e2revP2(:, t) = e2revP2(:, t) + cprobsc(sc, t) * erevP2(:, t, sc);
    e2shedP(:, t) = e2shedP(:, t) + cprobsc(sc, t) * eshedP(:, t, sc);
  end
  Rrpoffer(:, t) = mpsd.offer(t).PositiveLoadFollowReservePrice;
  Rrmoffer(:, t) = mpsd.offer(t).NegativeLoadFollowReservePrice;
  [tloadp(:, t), tloadq(:, t)] = total_load(bus, gen, (1:nb)');
                                    % make a call to calculate that portion
  if optd.runtype == 2
    for tr = 1:ntr                  % cycle for second stage results over trajectories
%      tri = load(sprintf('%s%sresults_s2_traj%3.3i', optd.basedir2, filesep, tr));
      tri = load(sprintf('%s%s%3.3i', optd.basedir2, optd.res2name, tr));
%      lamP2b(:, t, tr) = tri.r2.results{t}.results.GenPrices(tri.r2.results{t}.flow(t, tr, 1).mpc.bus(:, BUS_I))
      [blid2, lamP2b(:, t, tr), lamP2bc(:, t, tr)] = npricesmpf(tri.r2.results{t});
      gen2 = tri.r2.results{t}.flow(1, 1, 1).mpc.gen;% set to first available set of results
      lamP2(:, t, tr) = tri.r2.results{t}.results.GenPrices;
      Rpp2(:, t, tr) = tri.r2.results{t}.results.Rpp(:, 1:end);
      Rpm2(:, t, tr) = tri.r2.results{t}.results.Rpm(:, 1:end);
      Rpplam2(:, t, tr) = tri.r2.results{t}.results.RppPrices(:, 1:end);
      Rpmlam2(:, t, tr) = tri.r2.results{t}.results.RpmPrices(:, 1:end);
      nc2 = size(tri.r2.results{t}.cont.contab, 1);% 2015.06.12, AJL, contingencies in second stage may be different to first stage if units decommitted are part of contingency table
      for ct2= 1:nc2+1              % cycle over contingencies (warning, modify this eventually)
        mpc2 = tri.r2.results{t}.flow(1, 1, ct2).mpc;
        gen2 = mpc2.gen;% only one period, one state
        bus2 = mpc2.bus;
        gencost2 = mpc2.gencost;
        % 2015.06.18, add gmax lims for trajectories
        Gmaxlim2(:, t, tr, c) = gen2(:, PMAX) .* (gen2(:, GEN_STATUS) > 0);
        Gminlim2(:, t, tr, c) = gen2(:, PMIN) .* (gen2(:, GEN_STATUS) > 0);
        c =ct2;                     % counter for contingencies in first stage
        if ct2>1
          flct = 0;                 % flag for loop
          while flct ==0            % loop till we find the correspondent contingency, assumes nc>=nc2 (due to possible decommitted units)
            if min(tri.r2.results{t}.cont.contab(ct2-1, :) == mpsd.cont(startnt + t, 1).contab(c-1, :), [], 1) % all fields match in contab
              flct =1;
              cidvc(c, 1) = 1;      % contingency in both first and second settlement 
            else
              c = c+1;
            end
          end
        end
        Pg2(:, t, tr, c) = gen2(:, PG) .* (gen2(:, GEN_STATUS) > 0);
%% RDZ - 6/10/15
%% The following line includes fixed costs even for units that are decommitted.
%        cstP2(:, t, tr, c) = totcost(gencost2, Pg2(:, t, tr, c));
%% Need to explicitly zero them out.
        cstP2(:, t, tr, c) = totcost(gencost2, Pg2(:, t, tr, c)) .* (gen2(:, GEN_STATUS) > 0);
        % check for UC
        if ~isempty(tri.r2.results{t}.UC.CommitKey) && isfield(mpc2, 'fixed_gencost')
          cstP2f(:, t, tr, c) = mpc2.fixed_gencost .* (gen2(:, GEN_STATUS) > 0);% have variable tracking only no-load costs
          cstP2(:, t, tr, c) = cstP2(:, t, tr, c) + cstP2f(:, t, tr, c);
        end
        revP2(:, t, tr, c) = Pg2(:, t, tr, c) .* lamP2(:, t, tr);
        s2 = find(gen2(il, PG)- gen2(il, PMIN) > optd.shed_threshold);
        if ~isempty(s2)
          shedP2(il(s2), t, tr, c) = gen2(il(s2), PG)- gen2(il(s2), PMIN);
          shcstP2(il(s2), t, tr, c) = totcost(gencost2(il(s2), :), gen2(il(s2), PMIN)) .* (gen2(il(s2), GEN_STATUS) > 0) -...
              cstP2(il(s2), t, tr, c);
%% correct shedcost
          if ~isempty(tri.r2.results{t}.UC.CommitKey) && isfield(mpc2, 'fixed_gencost')
            shcstP2(il(s2), t, tr, c) = shcstP2(il(s2), t, tr, c) + ...
              mpc2.fixed_gencost(il(s2)) .* (gen2(il(s2), GEN_STATUS) > 0);
          end
          revPs2(il(s2), t, tr, c) = Pg2(il(s2), t, tr, c) .* lamP2(il(s2), t);
%          eshed2(t, tr) = eshed2(t, tr) + prob2(c, tr, t);
        end
%        cprobk = ones(nc+1, ntr, nt); % warning, only one contingency
        cprobk2(:, tr, t) = cprobk(:, 1, t);
        ePg2(:, t, tr) = ePg2(:, t, tr) + cprobk2(c, tr, t) * Pg2(:, t, tr, c);
        ecstP2(:, t, tr) = ecstP2(:, t, tr) + cprobk2(c, tr, t) * cstP2(:, t, tr, c);   %here
        ecstP2f(:, t, tr) = ecstP2f(:, t, tr) + cprobk2(c, tr, t) * cstP2f(:, t, tr, c);
        erevPs2(:, t, tr) = erevPs2(:, t, tr) + cprobk2(c, tr, t) * revPs2(:, t, tr, c);
        eshcstP2(:, t, tr) = eshcstP2(:, t, tr) + cprobk2(c, tr, t) * shcstP2(:, t, tr, c);
        eshedP2(:, t, tr) = eshedP2(:, t, tr) + cprobk2(c, tr, t) * shedP2(:, t, tr, c);
      end
      cprobtr(tr, t) = prob2(tr, t);% warning, cprobtr here refers to trajectories
%      e2shed2(1, t) = e2shed2(1, t) + cprobtr(tr, t) * eshed2(t, tr);
      e2Pg2(:, t) = e2Pg2(:, t) + cprobtr(tr, t) * ePg2(:, t, tr);
      e2cstP2(:, t) = e2cstP2(:, t) + cprobtr(tr, t) * ecstP2(:, t, tr);
      e2cstP2f(:, t) = e2cstP2f(:, t) + cprobtr(tr, t) * ecstP2f(:, t, tr);
      e2shcstP2(:, t) = e2shcstP2(:, t) + cprobtr(tr, t) * eshcstP2(:, t, tr);
%      e2revPs2(:, t) = e2revPs2(:, t) + cprobtr(tr, t) * erevPs2(:, t, tr);
      e2shedP2(:, t) = e2shedP2(:, t) + cprobtr(tr, t) * eshedP2(:, t, tr);
      eopcstP2(:,t) = eopcstP2(:,t) + cprobtr(tr, t) * cstP2(:, t, tr, 1);  % This assumes c=1 is intact case (no contingency case)
    end
  end
  if mpsd.UC.CommitKey
    vv = get_idx(mpsd.om);
    v = mpsd.QP.x(vv.i1.v(t):vv.iN.v(t));
    w = mpsd.QP.x(vv.i1.w(t):vv.iN.w(t));
    ucstcost(:, t)  = mpsd.StepProb(t)*mpsd.flow(t,1,1).mpc.gencost(:, STARTUP ) .* v;
    ucsdcost(:, t) = mpsd.StepProb(t)*mpsd.flow(t,1,1).mpc.gencost(:, SHUTDOWN) .* w;
  end
end
Rrpoffer = Rrpoffer(:, 1:end-1);    % remove last period, as no ramping is needed then
Rrmoffer = Rrmoffer(:, 1:end-1);
genPcst(:, :) = sum(e2cstP(ig, :));
genP(:, :) = sum(e2revP(ig, :));
genE(:, :) = sum(e2revP(ie, :), 1);
loadP(:, :) = sum(e2revP(il, :));
LNScst(:, :) = sum(e2shcstP(il, :));
Pc(:, :) = mpsd.results.Pc(:, startnt + 1:end);
Rpp(:, :) = mpsd.results.Rpp(:, startnt + 1:end);
Rpm(:, :) = mpsd.results.Rpm(:, startnt + 1:end);
if nt >1
  Rrp(:, :) = mpsd.results.Rrp(:, startnt + 1:end);
  Rrm(:, :) = mpsd.results.Rrm(:, startnt + 1:end);
  Rrplam = mpsd.results.RrpPrices(:, startnt + 1:end);
  Rrmlam = mpsd.results.RrmPrices(:, startnt + 1:end);
  genRrp(:, :) = Rrp .* Rrplam;
  genRrm(:, :) = Rrm .* Rrmlam;
else
  Rrp = mpsd.results.Rrp;
  Rrm = mpsd.results.Rrm;
  Rrplam = mpsd.results.RrpPrices;
  Rrmlam = mpsd.results.RrmPrices;
  genRrp = [];
  genRrm = [];
end
Rpplam(:, :) = mpsd.results.RppPrices(:, startnt + 1:end);
Rpmlam(:, :) = mpsd.results.RpmPrices(:, startnt + 1:end);
genRup(:, :) = Rpp .* Rpplam;
genRdn(:, :) = Rpm .* Rpmlam;
if optd.runtype == 2
  genRup2 = Rpp2 .* Rpplam2;
  genRdn2 = Rpm2 .* Rpmlam2;
end
if min(ie)>0
  Sp(:, :) = mpsd.results.Sp(:, startnt + 1:end);
  Sm(:, :) = mpsd.results.Sm(:, startnt + 1:end);
  eStorSt(:, :) = mpsd.Storage.ExpectedStorageState(:, startnt + 1:end);
  MinStorageLevel = mpsd.Storage.MinStorageLevel;
  MaxStorageLevel = mpsd.Storage.MaxStorageLevel;
  if size(MinStorageLevel, 1) == 1 && ns > 1% expand rows
    MinStorageLevel = ones(ns, 1) * MinStorageLevel;
  end
  if size(MinStorageLevel, 2) == 1 && nt > 1% expand cols
    MinStorageLevel = MinStorageLevel * ones(1, nt);
  end
  if size(MaxStorageLevel, 1) == 1 && ns > 1% expand rows
    MaxStorageLevel = ones(ns, 1) * MaxStorageLevel;
  end
  if size(MaxStorageLevel, 2) == 1 && nt > 1% expand cols
    MaxStorageLevel = MaxStorageLevel * ones(1, nt);
  end
  if mpsd.Storage.ForceCyclicStorage %opt.ForceCyclicStorage
    if size(mpsd.Storage.ExpectedStorageDispatch>0)
      eStorPg(:, :) = mpsd.Storage.ExpectedStorageDispatch(:, startnt + 1:end);
    else
      eStorPg = mpsd.Storage.ExpectedStorageDispatch;
    end
  else
    eStorPg(:, :) = mpsd.Storage.ExpectedStorageDispatch(:, startnt + 1:end);
  end
  mstorl(:, :) = MinStorageLevel;
  Mstorl(:, :) = MaxStorageLevel;
else
  if isfield(mpsd.Storage, 'ExpectedStorageDispatch')
    eStorPg = ...                     % Dimensions are [] for this case
      mpsd.Storage.ExpectedStorageDispatch;
  else
    eStorPg = [];
  end
  if isfield(mpsd.Storage, 'MinStorageLevel') && isfield(mpsd.Storage, 'MaxStorageLevel')
    if (~isempty(mpsd.Storage.MinStorageLevel) ||...
      ~isempty(mpsd.Storage.MaxStorageLevel))
      mstorl(:, :) = mpsd.Storage.MinStorageLevel(:, startnt + 1:end - 1);
      Mstorl(:, :) = mpsd.Storage.MaxStorageLevel(:, startnt + 1:end - 1);
    else
      mstorl = mpsd.Storage.MinStorageLevel;
      Mstorl = mpsd.Storage.MaxStorageLevel;
    end
  end
end
erpCost(:, :) = mpsd.results.ExpectedRampCost;
[blid, lampbus, lampcbus] = npricesmpf(mpsd);
Lim = squeeze(max(max(Gmaxlim, [], 4), [], 3));     % gen limits up
lim = squeeze(min(min(Gminlim, [], 4), [], 3));     % gen limits down
GG = squeeze(max(max(Pg, [], 4), [], 3));           % max generated
GGm = squeeze(min(min(Pg, [], 4), [], 3));          % min generated
mGGt = min(min(min(Pg, [], 4), [], 3), [], 2);
MGGt = max(max(max(Pg, [], 4), [], 3), [], 2);
MGGp = max(max(Pg, [], 4), [], 3);

llmp = e2Pg .* lamP;                % load-weighted prices ([1 x nt])
lwlmp=sum(llmp(il, :))./sum(e2Pg(il, :));

glmp = e2Pg .* lamP;                % conv.generation-weighted prices ([1 x nt])
gwlmp=sum(llmp(ig, :))./sum(e2Pg(ig, :));

print_dmpsd(genPcst, genP, genE, genRup, genRdn, ...
  genRrp, genRrm, loadP, e2revP, LNScst, e2shed, erpCost, ...
  tloadp, e2Pg, Pg, e2shedP, ig, il, ie, iw, nt, ...
  optd.optp, optd);
  
%col = 1;
%oil = 2;
%ngi = 3;
%hyd = 4;
%nuk = 5;
%win = 6;
%reu = 7;
%ess = 8;
%naf = 9;
%es2 = 7;                            % id for capcost table
%
%fuel = mpsd.mpc.genfuel;
%idn = zeros(ng, size(mpc.fuelname, 1)+1);
%for i = 1:ng
%    idn(i, 1) = strcmp(fuel(i, :), 'coal   ');
%    idn(i, 2) = strcmp(fuel(i, :), 'oil    ');
%    idn(i, 3) = strcmp(fuel(i, :), 'ng     ');
%    idn(i, 4) = strcmp(fuel(i, :), 'hydro  ');
%    idn(i, 5) = strcmp(fuel(i, :), 'nuclear');
%    idn(i, 6) = strcmp(fuel(i, :), 'wind   ');
%    idn(i, 7) = strcmp(fuel(i, :), 'refuse ');
%    idn(i, 8) = or(strcmp(fuel(i, :), 'ESS    '), strcmp(fuel(i, :), 'Flex ld'));
%    idn(i, 9) = strcmp(fuel(i, :), 'na     ');
%end

avoutv = {'Pg', 'lamP', 'cstP', ...
  'revP', 'shedP', 'shcstP', ...
  'revP2', 'eshed', 'ePg', ...
  'ecstP', 'erevP', 'erevP2', ...
  'eshcstP', 'e2shed', 'e2Pg', ...
  'e2cstP', 'e2shcstP', 'e2revP', ...
  'e2revP2', 'genPcst', 'genP', ...
  'genE', 'loadP', 'LNScst', ...
  'Pc', 'Rpp', 'Rpm', ...
  'Rrp', 'Rrm', 'Sp', ...
  'Sm', 'Rpplam', 'Rpmlam', ...
  'genRup', 'genRdn', 'Gmaxlim', ...
  'Gminlim', 'Gmaxe', 'Gmaxe2', ...
  'genRrp', 'genRrm', 'Rrplam', ...
  'Rrmlam', 'eStorSt', 'eStorPg', ...
  'mstorl', 'Mstorl', 'Rrpoffer', ...
  'Rrmoffer', 'erpCost', 'tloadp', ...
  'tloadq', 'eshedP', 'e2shedP', ...
  'Lim', 'lim', 'GG', ...
  'GGm', 'mGGt', 'MGGt'...          
  'MGGp', 'ucstcost', 'ucsdcost'... 
  'cstPf', 'ecstPf', 'e2cstPf', ...
  'e2cstPaf', ...                   % 67 original variables
  'ntt', 'nt', 'ng', ...            % 68 variables from here on, additional variables out vector, modify as necessary
  'startnt', 'ng', 'nb', ...
  'iw', 'ie', 'ne', ...
  'nj', 'nc', 'nc0', ...
  'il', 'igi', 'ig', ...
  'prob', 'prs', 'cprobk', ...
  'cprobsc', 'cprobt', 'e2cstPa'... % standard set of variables, 88
  'ntr', 'prob2', 'Pg2', ...        % 89, variables for second run
  'lamP2', 'lamP2b', 'cstP2', ...
  'revPs2', 'shedP2', 'shcstP2', ...
  'eshed2', 'ePg2', 'ecstP2', ...
  'erevPs2', 'eshcstP2', 'e2shed2', ...
  'e2Pg2', 'e2cstP2', 'e2shcstP2'...
  'e2revPs2', 'LNScst2', 'eshedP2'...
  'e2shedP2', 'cprobtr', 'lampbus',...
  'lampcbus','eopcstP2', 'Rpp2', ....
  'Rpm2', 'Rpplam2', 'Rpmlam2', ...
  'genRup2', 'genRdn2', 'cidvc'...
  'cstP2f', 'ecstP2f', 'e2cstP2f', ...
  'Gmaxlim2', 'Gminlim2'
%  '', '', '', ...
%  '', '', '', ...
%  '', '', '', ...  
  };

if optd.runtype == '1'
  avoutv0 = avoutv;                 % save original information
  offs = 38;                        % additional variables for second run
  avoutv = avoutv0(1:end-offs);     % variables for first run
end

for st = 1:size(avoutv, 2)
  varargout{st} = eval(avoutv{st});
end;

%[varargout{1:nargout}] = varout;
%[varargout{1:nargout}] = [avoutv(:)];

if optd.saveit
  save(sprintf('%s%s%s.mat', optd.savepath, filesep, optd.savename), avoutv{:})
end

function print_dmpsd(genPcst, genP, genE, genRup, genRdn, ...
  genRrp, genRrm, loadP, e2revP, LNScst, e2shed, erpCost, ...
  tloadp, e2Pg, Pg, e2shedP, ig, il, ie, iw, nt, ...
  optp, optd)
% 
% Prints txt files with main results 
% Included as part of the same file to avoid file proliferation, and keep data creation clean
% 
% Inputs:
%     VARARGIN    :   Financial and physical information (genPcst, genP, genE, genRup, genRdn, ...
%                     genRrp, genRrm, loadP, e2revP, LNScst, e2shed, erpCost, ...
%                     tloadp, e2Pg, Pg, e2shedP
%     IG          :   Indicator for conventional generators (excludes ess, excludes wind)
%     IL          :   Indicator for loads
%     IE          :   Indicator for ESS units
%     IW          :   Indicator for wind units
%     NT          :   Number of time periods
%     OPTP        :   options for printing, including the following. The default is 
%                     shown in parenthesis:
%       'af'      (1) accounting factor, data in hourly steps
%       'af2'     (365) accounting factor, run for a day converted to days in year (for LOLE, EALS)
%     OPTD        :   Options for data extraction, refer to help of data_mpsd
%     
%
% Alberto J. Lamadrid

if ~isfield(optp, 'af')
  optp.af = 1;                      % accounting factor, data in hourly steps
end
if ~isfield(optp, 'af2')
  optp.af2 = 365;                   % accounting factor, run for a day converted to days in year
end

if optd.saveit
  fid = fopen(sprintf('%s%s%s.txt', optd.savepath, filesep, optd.savename), 'w');
  af = optp.af;
  af2 = optp.af2;

  if optd.opttable
    fprintf(fid, '1\tConventional gen. c                            =');
    fprintf(fid, '\t%15.2f', af*genPcst);
    fprintf(fid, '\t=\t%15.2f\n', af*sum(genPcst));

    fprintf(fid, '2\tpmt to conv.gens for Pg                        =');
    fprintf(fid, '\t%15.2f', af*genP);
    fprintf(fid, '\t=\t%15.2f\n', af*sum(genP));

    fprintf(fid, '3\tpmt to ESS for Pg                              =');
    fprintf(fid, '\t%15.2f', af*(genE.*(genE>=0)) );
    fprintf(fid, '\t=\t%15.2f\n', af*sum(genE(:, genE>=0)));

    fprintf(fid, '4\tpmt to conv.gens for pos reserves, Rpp         =');
    fprintf(fid, '\t%15.2f', af*( sum(genRup(ig, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRup(ig, :))) ));

    fprintf(fid, '5\tpmt to conv.gens for neg reserves, Rpm         =');
    fprintf(fid, '\t%15.2f', af*( sum(genRdn(ig, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRdn(ig, :))) ));
    if nt > 1
      fprintf(fid, '6\tpmt to conv.gens for pos ramp, Rrp             =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrp(ig, :)), 0]));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrp(ig, :))) ));

      fprintf(fid, '7\tpmt to conv.gens for neg ramp, Rrm             =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrm(ig, :)), 0] ));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrm(ig, :))) ));
    end
    fprintf(fid, '8\tpmt to gens for energy and reserves, 2+4+5     =');
    fprintf(fid, '\t%15.2f', af*(genP + sum(genRup(ig, :)) + sum(genRdn(ig, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) ));
    if nt > 1
      fprintf(fid, '9\tpmt to gens for energy, res, ramp, 2+4+5+6+7   =');
      fprintf(fid, '\t%15.2f', af*(genP + sum(genRup(ig, :)) + sum(genRdn(ig, :)) + [sum(genRrp(ig, :)), 0] + [sum(genRrm(ig, :)), 0] ));
      fprintf(fid, '\t=\t%15.2f\n', af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) +sum(sum(genRrp(ig, :))) + sum(sum(genRrm(ig, :))) ));
    end
    fprintf(fid, '10\tpmt from loads for Pd                          =');
    fprintf(fid, '\t%15.2f', af*(-loadP ));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(loadP) ));

    fprintf(fid, '11\tpmt from loads for pos reserves, Rpp           =');
    fprintf(fid, '\t%15.2f', af*(-sum(genRup(il, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(sum(genRup(il, :))) ));

    fprintf(fid, '12\tpmt from loads for neg reserves, Rpm           =');
    fprintf(fid, '\t%15.2f', af*(-sum(genRdn(il, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(sum(genRdn(il, :))) ));

    fprintf(fid, '13\tpmt from loads for energy and res., 10+11+12   =');
    fprintf(fid, '\t%15.2f', af*(-loadP - sum(genRup(il, :)) - sum(genRdn(il, :)) ));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(loadP) - sum(sum(genRup(il, :))) - sum(sum(genRdn(il, :))) ));

    fprintf(fid, '14\tpmt from ESS units                             =');
    fprintf(fid, '\t%15.2f', af*(-genE.*(genE<0)) );
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(genE(:, genE<0))));

    fprintf(fid, '15\tNet pmt to ESS units                           =');
    fprintf(fid, '\t%15.2f', af*(genE));
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(genE)));
  
    fprintf(fid, '16\tpmt to ESS units for pos reserves, Rpp         =');
    fprintf(fid, '\t%15.2f', af*( sum(genRup(ie, :), 1) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRup(ie, :))) ));

    fprintf(fid, '17\tpmt to ESS units for neg reserves, Rpm         =');
    fprintf(fid, '\t%15.2f', af*( sum(genRdn(ie, :), 1) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRdn(ie, :))) ));
    if nt > 1
      fprintf(fid, '18\tpmt to ESS units for pos ramp, Rrp             =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrp(ie, :), 1), 0]));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrp(ie, :))) ));

      fprintf(fid, '19\tpmt to ESS units for neg ramp, Rrm             =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrm(ie, :), 1), 0] ));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrm(ie, :))) ));
    end
    fprintf(fid, '20\tpmt to Wind units for Pg                       =');
    fprintf(fid, '\t%15.2f', af*sum(e2revP(iw, :), 1));
    fprintf(fid, '\t=\t%15.2f\n', af*sum(sum(e2revP(iw, :))));

    fprintf(fid, '21\tpmt to Wind units for pos reserves, Rpp        =');
    fprintf(fid, '\t%15.2f', af*( sum(genRup(iw, :), 1) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRup(iw, :))) ));

    fprintf(fid, '22\tpmt to Wind units for neg reserves, Rpm        =');
    fprintf(fid, '\t%15.2f', af*( sum(genRdn(iw, :), 1) ));
    fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRdn(iw, :))) ));
    if nt > 1
      fprintf(fid, '23\tpmt to Wind units for pos ramp, Rrp            =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrp(iw, :), 1), 0]));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrp(iw, :))) ));

      fprintf(fid, '24\tpmt to Wind units for neg ramp, Rrm            =');
      fprintf(fid, '\t%15.2f', af*( [sum(genRrm(iw, :), 1), 0] ));
      fprintf(fid, '\t=\t%15.2f\n', af*( sum(sum(genRrm(iw, :))) ));
    end
    fprintf(fid, '25\tcost of LNS                                    =');
    fprintf(fid, '\t%15.2f', af*(-LNScst));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(LNScst)));

    fprintf(fid, '26\tpmt to transmission                            =');
    fprintf(fid, '\t%15.2f', af*(-loadP -genP ));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(loadP) -sum(genP) ));

    fprintf(fid, '27\thrs of load shedding                           =');
    fprintf(fid, '\t%15.2f', af*(e2shed));
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(e2shed)));
  
    fprintf(fid, '28\tExpected ramping cost                          =');
    fprintf(fid, '\t%15.2f', af*(sum(erpCost(ig, :))));
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(sum(erpCost(ig, :)))));
  
    fprintf(fid, '29\tTotal Active Load                              =');
    fprintf(fid, '\t%15.2f', af*(sum(tloadp)));
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(sum(tloadp))));
  
    fprintf(fid, '30\tpmt to transmission, with reserves, 13-8       =');
    fprintf(fid, '\t%15.2f', af*(-loadP - sum(genRup(il, :)) - sum(genRdn(il, :)) ) - (af*(genP + sum(genRup(ig, :)) + sum(genRdn(ig, :)) )));
    fprintf(fid, '\t=\t%15.2f\n', af*(-sum(loadP) - sum(sum(genRup(il, :))) - sum(sum(genRdn(il, :))) ) - (af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) )));

    fprintf(fid, '31\tExpected wind dispatched                       =');
    fprintf(fid, '\t%15.2f', sum(e2Pg(iw, :), 1) );
    fprintf(fid, '\t=\t%15.2f\n', sum(sum(e2Pg(iw, :), 1), 2) );
  
    fprintf(fid, '32\tCapacity Needed                                =');
    MGGt = max(max(max(Pg, [], 4), [], 3), [], 2);
    MGGp = max(max(Pg, [], 4), [], 3);
    fprintf(fid, '\t%15.2f',  sum(MGGp(ig, :), 1) );
    fprintf(fid, '\t=\t%15.2f\n', sum(MGGt(ig, :), 1) );
  
    fprintf(fid, '33\tExpected Amount of Load Shed                   =');
    fprintf(fid, '\t%15.2f', af*(sum(e2shedP(il, :), 1)) );
    fprintf(fid, '\t=\t%15.2f\n', af*(sum(sum(e2shedP))) );
  
    fprintf(fid, '34\tExpected Amount of Load Shed, annual basis     =');
    fprintf(fid, '\t%15.2f', af2*(sum(e2shedP, 1)) );
    fprintf(fid, '\t=\t%15.2f\n', af2*(sum(sum(e2shedP))) );

    fprintf(fid, '35\tLOLE, annual basis                             =');
    fprintf(fid, '\t%15.2f', af2*(e2shed) );
    fprintf(fid, '\t=\t%15.2f\n', af2*(sum(e2shed)) );        
  else
    fprintf(fid, '1\tgen cost                                       =\t%15.2f\n', af*sum(genPcst));
    fprintf(fid, '2\tpmt to gens for Pg                             =\t%15.2f\n', af*sum(genP));
    fprintf(fid, '3\tpmt to ESS for Pg                              =\t%15.2f\n', af*sum(genE(:, genE>=0)));
    fprintf(fid, '4\tpmt to conv.gens for pos reserves, Rpp         =\t%15.2f\n', af*( sum(sum(genRup(ig, :))) ));
    fprintf(fid, '5\tpmt to conv.gens for neg reserves, Rpm         =\t%15.2f\n', af*( sum(sum(genRdn(ig, :))) ));
    if nt > 1    
      fprintf(fid, '6\tpmt to conv.gens for pos ramp, Rrp             =\t%15.2f\n', af*( sum(sum(genRrp(ig, :))) ));
      fprintf(fid, '7\tpmt to conv.gens for neg ramp, Rrm             =\t%15.2f\n', af*( sum(sum(genRrm(ig, :))) ));
    end    
    fprintf(fid, '8\tpmt to c.gens for energy and reserves, 2+4+5   =\t%15.2f\n', af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) ));
    if nt > 1
      fprintf(fid, '9\tpmt to c.gens for energy, res, ramp, 2+4+5+6+7 =\t%15.2f\n', af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) +sum(sum(genRrp(ig, :))) + sum(sum(genRrm(ig, :))) ));
    end    
    fprintf(fid, '10\tpmt from loads for Pd                          =\t%15.2f\n', af*(-sum(loadP) ));
    fprintf(fid, '11\tpmt from loads for pos reserves, Rpp           =\t%15.2f\n', af*(-sum(sum(genRup(il, :))) ));
    fprintf(fid, '12\tpmt from loads for neg reserves, Rpm           =\t%15.2f\n', af*(-sum(sum(genRdn(il, :))) ));
    fprintf(fid, '13\tpmt from loads for energy and res., 10+11+12   =\t%15.2f\n', af*(-sum(loadP) - sum(sum(genRup(il, :))) - sum(sum(genRdn(il, :))) ));
  
    fprintf(fid, '14\tpmt from ESS units                             =\t%15.2f\n', af*(-sum(genE(:, genE<0))));
    fprintf(fid, '15\tNet pmt to ESS units                           =\t%15.2f\n', af*(sum(genE)));
    fprintf(fid, '16\tpmt to ESS for pos reserves, Rpp               =\t%15.2f\n', af*( sum(sum(genRup(ie, :))) ));
    fprintf(fid, '17\tpmt to ESS for neg reserves, Rpm               =\t%15.2f\n', af*( sum(sum(genRdn(ie, :))) ));
    if nt > 1    
      fprintf(fid, '18\tpmt to ESS for pos ramp, Rrp                   =\t%15.2f\n', af*( sum(sum(genRrp(ie, :))) ));
      fprintf(fid, '19\tpmt to ESS for neg ramp, Rrm                   =\t%15.2f\n', af*( sum(sum(genRrm(ie, :))) ));
    end
    fprintf(fid, '20\tpmt to Wind units for Pg                       =\t%15.2f\n', af*sum(sum(e2revP(iw, :))));
    fprintf(fid, '21\tpmt to Wind units for pos reserves, Rpp        =\t%15.2f\n', af*( sum(sum(genRup(iw, :))) ));
    fprintf(fid, '22\tpmt to Wind units for neg reserves, Rpm        =\t%15.2f\n', af*( sum(sum(genRdn(iw, :))) ));
    if nt > 1
      fprintf(fid, '23\tpmt to Wind units for pos ramp, Rrp            =\t%15.2f\n', af*( sum(sum(genRrp(iw, :))) ));
      fprintf(fid, '24\tpmt to Wind units for neg ramp, Rrm            =\t%15.2f\n', af*( sum(sum(genRrm(iw, :))) ));
    end
    fprintf(fid, '25\tcost of LNS                                    =\t%15.2f\n', af*(-sum(LNScst)));
    fprintf(fid, '26\tpmt to transmission (no reserves)              =\t%15.2f\n', af*(-sum(loadP) -sum(genP) ));
    fprintf(fid, '27\thrs of load shedding                           =\t%15.2f\n', af*(sum(e2shed)));
    fprintf(fid, '28\tExpected ramping cost                          =\t%15.2f\n', af*(sum(sum(erpCost(ig, :)))));
    fprintf(fid, '29\tTotal Active Load                              =\t%15.2f\n', af*(sum(sum(tloadp))));
    fprintf(fid, '30\tpmt to transmission, with reserves, 13-8       =\t%15.2f\n', af*(-sum(loadP) - sum(sum(genRup(il, :))) - sum(sum(genRdn(il, :))) ) - (af*(sum(genP) + sum(sum(genRup(ig, :))) + sum(sum(genRdn(ig, :))) )));
    fprintf(fid, '31\tExpected wind dispatched                       =\t%15.2f\n', sum(sum(e2Pg(iw, :), 1), 2) );
    MGGt = max(max(max(Pg, [], 4), [], 3), [], 2);
    fprintf(fid, '32\tCapacity Needed                                =\t%15.2f\n', sum(MGGt(ig, :), 1) );
    fprintf(fid, '33\tExpected Amount of Load Shed                   =\t%15.2f\n', af*(sum(sum(e2shedP))) );
    fprintf(fid, '34\tExpected Amount of Load Shed, annual basis     =\t%15.2f\n', af2*(sum(sum(e2shedP))) );
    fprintf(fid, '35\tLOLE, annual basis                             =\t%15.2f\n', af2*(sum(e2shed)) );
  end

  fprintf(fid, '\n\n');
  fclose(fid);
else
  if optd.verbose
    fprintf('No text file generated')
  end
end
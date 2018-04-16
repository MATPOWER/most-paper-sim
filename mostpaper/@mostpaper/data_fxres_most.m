function varargout = data_fxres_most(mpfix, optd, ntraj, prob2)
% CALCULATES REVENUE FROM HORIZON PLANNING PROBLEM
% Fixed reserves case
% Inputs
%   MPFIX     :   results from the first stage run
%   OPTD      :     Options for data extraction, including the following. The default is 
%                   shown in parenthesis:
%     'saveit'      (true) flag to indicate whether to create .mat file
%     'savepath'    ('') path to directory to save files in
%     'savename'    ('data-cx_fs') name of .MAT file
%     'tframe'      (24)  number of time periods considered
%     'fuelinfo'    (true) flag to indicate whether there is fuel information (ng x 1)
%     'rtoinfo'     (true) flag to indicate whether there is rto information (ng x 1)
%     'shed_threshold' (1e-3) used for load shedding calculation
%     'var_threshold' (0) variance threshold for generators, defines which variables are plotted
%     'reszi'       ([1]) zones to include for fixed reserves requirements (e.g. excluding one can be because the first one is a total system req)
%     'opttable'    (1) create a table with detailed information per period
%     'verbose'     (0) displays to user
%     'optp'        ([]) printing options for text files
% If runtype == 2 (second stage), the following fields should be added to optd
%     'basedir2'    ('c9_fs-res2') directory with second stage results 
%     'res2name'    ('trajf#') name of the trajectories in the second stage
%
%   NTRAJ     :     () Number of trajectories for second stage, default empty
%   PROB2     :     () Probability for each trajectory (ntr x nt), default empty
%
% Outputs:
%     VARARGOUT :     Variables for creating plots (80 if first run, 104 if second run)
%
% Pending
% - change name of txt file with results
% - change OstrDCC for mpfix
% - check ptdfile
% Mostly replaced hpf_revenuedcs2
%
% 2014.09.11
% Alberto J. Lamadrid
% 
% Modifications (Daniel, 04/14/2015)
% - Modified assignation of a subset of the variables Rpp, Rpm, Rrp, Rrm,
% Rpplam, Rpmlam, Rrplam, Rrmlam, genRup, genRdn, genRrp, genRrm
% - Created variables revRup, revRdn, revRrp, revRrm to account for the
% revenues from reserves. The genXxx variables contain the reserve costs as
% opposed to the revenues obtained by participants.

if nargin < 2
  optd.saveit = 1;
  optd.savepath = [];
  optd.savename = 'data-cx_fs';
  optd.tframe = 24;
  optd.fuelinfo = 1;
  optd.rtoinfo = 1;
  optd.shed_threshold = 1e-3;
  optd.var_threshold = 0;
  optd.reszi = [1];
  optd.opttable = 1;
  optd.verbose = 0;
  optd.optp = [];
  optd.basedir2 = 'c9_fs-res2f';
  optd.res2name = 'trajf';
else
  if nargin < 3
    ntraj = [];
  else
    if nargin < 4
      prob2 = [];
    end
  end
  if ~isfield(optd, 'saveit')
    optd.saveit = 1;
  end
  if ~isfield(optd, 'savepath')
    optd.savepath = [];
  end
  if ~isfield(optd, 'savename')
    optd.savename = 'data-cx_fr';
  end
  if ~isfield(optd, 'tframe')
    optd.tframe = 24;
  end
  if ~isfield(optd, 'shed_threshold')
    optd.shed_threshold = 1e-3;
  end
  if ~isfield(optd, 'var_threshold')
    optd.var_threshold = 0;
  end
  if ~isfield(optd, 'reszi')
    optd.reszi = [1];
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
  if ~isfield(optd, 'basedir2')
    optd.basedir2 = 'c9_fs-res2f';
  end
  if ~isfield(optd, 'res2name')
    optd.res2name = 'trajf';
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

% Get basic dimensions, first stage
% Load results from second stage
r2b = load(sprintf('%s%s%3.3i', optd.basedir2, optd.res2name, 1));
ntt = mpfix.idx.nt;                 % number of time periods
nt = optd.tframe;                   % time frame of analysis
if optd.tframe <=0
    tframe = ntt;                   % assign total number if periods if user does not specify frame
end
startnt = ntt - nt;                 % place to start time analysis
ng = size(mpfix.mpc.gen, 1);        % number of generators (includes dispatchable loads)
nb = size(mpfix.mpc.bus, 1);        % number of buses

if ~isfield(mpfix.mpc, 'iwind')
  iw = [];
else
  iw = mpfix.mpc.iwind;
end
if ~isfield(mpfix.mpc, 'iess')
  ie = [];
else
  ie = mpfix.mpc.iess;
end
if size(mpfix.Storage.UnitIdx, 1) < size(ie)
    ne = size(ie);
else
    ne = size(mpfix.Storage.UnitIdx, 1);% number of ESS units
end
nj = max(mpfix.idx.nj);             % number of scenarios
nc = max(max(mpfix.idx.nc));        % number of contingencies (not including base)
ntr = ntraj;                        % number of trajectories used
nz = size(...
    mpfix.FixedReserves(1, 1).zones, 1);% number of reserve zones
if nc ==0
    nc0 = 1;
else
    nc0 = nc;
end
il = setdiff((find(isload(mpfix.mpc.gen) & mpfix.mpc.gen(:, GEN_STATUS) > 0)), ...
    ie);                            % determine loads different to ESS units
igi = setdiff((find(~isload(mpfix.mpc.gen) & mpfix.mpc.gen(:, GEN_STATUS) > 0)), ...
    ie);                            % determine gens different to ESS units
ig = setdiff(igi, iw);              % determine gens different to wind units
prob = mpfix.CostWeights;           % probabilities of contingencies in each time period. nc x nj x nt
% correct zero probabilities
%prob(:, 1, [14]) = prob(:, 1, [13]);     %% CORRECTION ON ZERO PROBABILITIES
%prob(:, 1, [15]) = prob(:, 1, [13]);
prs = sum(prob(:, :, :), 1);                % probabilities of each state
if nj>1
  prs = reshape(prs, nj, nt);               % final shape must be nj x nt
else 
  prs = squeeze(prs)';                      % 1 x nt
end
cprobk = ones(size(prob));                  % conditional probabilities of contingency, on scenario and time period 
cprobsc = ones(nj, nt);                     % conditional probabilities of each scenario with its contingencies, on time period
cprobt = sum(prs, 1);                       % probabilities of each time period, (1 x nt)
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
ecstPf = zeros(ng, nt, nj);                 % expected no-load cost over contingencies
erevP = zeros(ng, nt, nj);                  % expected revenue for gens over contingencies
erevP2 = zeros(ng, nt, nj);                 % expected revenue from load shed over contingencies
eshcstP = zeros(ng, nt, nj);                % expected cost demand shed
e2shed = zeros(1, nt);                      % expected shed over scenarios/contingencies
e2Pg = zeros(ng, nt);                       % expected power dispatched over scenarios/contingencies
e2cstP = zeros(ng, nt);                     % expected cost over scenarios/contingencies
e2cstPa = 0;                                % expected cost over scenarios/contingencies using adjusted weights, conventional gens
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
revRup = NaN * ones(ng, nt);                % Revenue from contingency up reserves
revRdn = NaN * ones(ng, nt);                % Revenue from contingency down reserves
Gmaxlim = NaN * ones(ng, nt, nj, nc0 + 1);  % upper limits on units
Gminlim = NaN * ones(ng, nt, nj, nc0 + 1);  % lower limits on units
Gmaxe = zeros(ng, nt, nj);                  % expected available (pmax) over contingencies
Gmaxe2 = zeros(ng, nt);                     % expected available (pmax) over scenarios/contingencies
genRrp = NaN * ones(ng, nt - 1);            % cost of positive ramping
genRrm = NaN * ones(ng, nt - 1);            % cost of negative ramping
revRrp = NaN * ones(ng, nt - 1);            % revenue from positive ramping
revRrm = NaN * ones(ng, nt - 1);            % revenue from negative ramping
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
ucstcost = NaN * ones(ng, nt);              % Cost of startup of gens
ucsdcost = NaN * ones(ng, nt);              % Cost of shutdown of gens
resreq1 = zeros(nz, nt);                    % reserve requirements per zone
resreq2 = zeros(nz, nj, nt);                % reserve requirements per scenario/trajectory
resCost = zeros(1, nt);                     % cost of reserves, s1
resreqt = zeros(1, nt);                     % total reserve requirements
rescost2 = zeros(ntr, nt);                  % cost of reserves, s2
erescost2 = zeros (1, nt);                  % expected cost of reserves, s2
% second stage variables
  ntr = ntraj;                              % number of trajectories used
  Pg2 = NaN * ones(ng, nt, ntr, nc0 + 1);   % Active Power, s2
  lamP2 = NaN * ones(ng, nt, ntr);          % Active power Nodal prices, s2
  lamP2b = NaN * ones(nb, nt, ntr);         % Active power Nodal prices, s2, buses
  cstP2 = NaN * ones(ng, nt, ntr, nc0 + 1); % Cost, stage 2
  cstP2f = zeros(ng, nt, ntr, nc0 + 1);     % no-load Cost, stage 2
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
  Gmaxlim2 = NaN * ones(ng, nt, nj, nc0 + 1);% upper limits on units, s2
  Gminlim2 = NaN * ones(ng, nt, nj, nc0 + 1);% lower limits on units, s2


lamP(:, :) = mpfix.results.GenPrices(:, startnt + 1:end) ./ (ones(ng, 1) * cprobt);

for t = 1:nt                        % cycle over time periods
  if optd.verbose
    fprintf(fid, 'Time period considered: %d\n', t);
  end
  for sc = 1:nj                     % cycle over scenarios
    if optd.verbose
      fprintf(fid, 'Scenario considered: %d\n', sc);
    end
    cidvc = zeros(nc, 1);           % vector of contingencies first settlement
    for c = 1:nc+1                  % cycle over contingencies
      mpc = mpfix.flow(startnt + t, sc, c).mpc;
      gen = mpc.gen;
      bus = mpc.bus;
%% RDZ - 6/16/15
%% per-flow gencosts have been modified from original to remove
%% fixed cost portion and include it in separate objective function cost
%% term multiplied by commitment variable, so the following does
%% NOT include the fixed costs and we need to include them explicitly ...
      gencost = mpc.gencost;
      Pg(:, t, sc, c) = gen(:, PG) .* (gen(:, GEN_STATUS) > 0);
      % Qg(:, t, sc, c) = gen(:, QG) .* (gen(:, GEN_STATUS) > 0);
      Gmaxlim(:, t, sc, c) = gen(:, PMAX) .* (gen(:, GEN_STATUS) > 0);
      Gminlim(:, t, sc, c) = gen(:, PMIN) .* (gen(:, GEN_STATUS) > 0);
      cstP(:, t, sc, c) = totcost(gencost, Pg(:, t, sc, c)).* (gen(:, GEN_STATUS) > 0);
%% ... which we do here ...
      if ~isempty(mpfix.UC.CommitKey) &&  isfield(mpc, 'fixed_gencost')
        cstPf(:, t, sc, c) = mpc.fixed_gencost .* (gen(:, GEN_STATUS) > 0);% have variable tracking only no-load costs
        cstP(:, t, sc, c) = cstP(:, t, sc, c) + cstPf(:, t, sc, c);
      end
      e2cstPa = e2cstPa + sum(cstP(ig, t, sc, c), 1) * mpfix.CostWeightsAdj(c,sc,t);
      e2cstPaf(:, t) = e2cstPaf(:, t) + cstPf(:, t, sc, c) * mpfix.CostWeightsAdj(c,sc,t);
      revP(:, t, sc, c) = Pg(:, t, sc, c) .* lamP(:, t);
      % load shed
      s = find(gen(il, PG)- gen(il, PMIN) > optd.shed_threshold);
      if ~isempty(s)
        shedP(il(s), t, sc, c) = gen(il(s), PG)- gen(il(s), PMIN);
        shcstP(il(s), t, sc, c) = totcost(gencost(il(s), :), gen(il(s), PMIN)) .* (gen(il(s), GEN_STATUS) > 0) -...
            cstP(il(s), t, sc, c);
%% ... and here, check for UC
        if ~isempty(mpfix.UC.CommitKey) &&  isfield(mpc, 'fixed_gencost')
          shcstP(il(s), t, sc, c) = shcstP(il(s), t, sc, c) + ...
            mpc.fixed_gencost(il(s)) .* (gen(il(s), GEN_STATUS) > 0);
        end
        revP2(il(s), t, sc, c) = Pg(il(s), t, sc, c) .* lamP(il(s), t);
        eshed(t, sc) = eshed(t, sc) + prob(c, sc, t);
      end
      cprobk(c, sc, t) = prob(c, sc, t) / prs(sc, t);
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
  resreq1(:, t) = mpfix.FixedReserves(t, 1).req(:, 1);%R, prc, mu and totalcost
  Rrpoffer(:, t) = mpfix.offer(t).PositiveLoadFollowReservePrice;
  Rrmoffer(:, t) = mpfix.offer(t).NegativeLoadFollowReservePrice;
  %resCost(:, t) = mpfix.FixedReserves(t).totalcost;
  resCost(:, t) = mpfix.flow(t).mpc.reserves.totalcost;
  [tloadp(:, t), tloadq(:, t)] = total_load(bus, gen, (1:nb)');
  %Rpp(:, t) = mpfix.FixedReserves(startnt + t).R;
  Rpp(:, t) = mpfix.flow(startnt + t).mpc.reserves.R;
  Rpm(:, t) = zeros(ng,1);                                          % no negative contingency reserves 
  %Rpplam(:, t) = mpfix.FixedReserves(startnt + t).prc;
  Rpplam(:, t) = mpfix.flow(startnt + t).mpc.reserves.prc;              % contingency reserve prices are used only for settlement calculations (e.g. revenue)
  Rpmlam(:, t) = zeros(ng,1);                                       % no negative contingency reserve prices
  genRup(:, t) = Rpp(:,startnt + t) .* mpfix.FixedReserves(startnt + t).cost;      % Second coefficient should be consistent with mpfix.offer(startnt + t).PositiveActiveReservePrice and 
  genRdn(:, t) = Rpm(:,startnt + t) .* zeros(ng,1);                                % Second coefficient should equal mpfix.offer(startnt + t).NegativeActiveReservePrice
  for tr = 1:ntr                          % cycle for second stage results over trajectories
    tri = load(sprintf('%s%s%3.3i', optd.basedir2, optd.res2name, tr));
    lamP2b(:, t, tr) = tri.r2f.results{t}.bus(:, LAM_P);
    lamP2(:, t, tr) = tri.r2f.results{t}.bus(tri.r2f.results{t}.gen(:, GEN_BUS), LAM_P);
    for c= 1:nc+1                       % cycle over contingencies (warning, modify this eventually)
      mpc2 = tri.r2f.results{t};
      gen2 = mpc2.gen;
      bus2 = mpc2.bus;
      gencost2 = mpc2.gencost;
      Gmaxlim2(:, t, tr, c) = gen2(:, PMAX) .* (gen2(:, GEN_STATUS) > 0);
      Gminlim2(:, t, tr, c) = gen2(:, PMIN) .* (gen2(:, GEN_STATUS) > 0);
      Pg2(:, t, tr, c) = gen2(:, PG) .* (gen2(:, GEN_STATUS) > 0);
%% RDZ - 6/16/15
%% The following line includes fixed costs even for units that are decommitted.
%      cstP2(:, t, tr, c) = totcost(gencost2, Pg2(:, t, tr, c));
%% Need to explicitly zero them out.
      cstP2(:, t, tr, c) = totcost(gencost2, Pg2(:, t, tr, c)) .* (gen2(:, GEN_STATUS) > 0);
      if isfield(mpc2, 'fixed_gencost')% maybe not necessary given current setup...
        cstP2f(:, t, tr, c) = mpc2.fixed_gencost .* (gen2(:, GEN_STATUS) > 0);% have variable tracking only no-load costs
        cstP2(:, t, tr, c) = cstP2(:, t, tr, c) + cstP2f(:, t, tr, c);
      end
      revP2(:, t, tr, c) = Pg2(:, t, tr, c) .* lamP2(:, t, tr);
      s2 = find(gen2(il, PG)- gen2(il, PMIN) > optd.shed_threshold);
      if ~isempty(s2)
        shedP2(il(s2), t, tr, c) = gen2(il(s2), PG)- gen2(il(s2), PMIN);
        shcstP2(il(s2), t, tr, c) = totcost(gencost2(il(s2), :), gen2(il(s2), PMIN)) -...
          cstP2(il(s2), t, tr, c);
        revPs2(il(s2), t, tr, c) = Pg2(il(s2), t, tr, c) .* lamP2(il(s2), t);
%                eshed2(t, tr) = eshed2(t, tr) + prob2(c, tr, t);
      end
      cprobk = ones(nc+1, ntr, nt);   % warning, only one contingency
      ePg2(:, t, tr) = ePg2(:, t, tr) + cprobk(c, tr, t) * Pg2(:, t, tr, c);
      ecstP2(:, t, tr) = ecstP2(:, t, tr) + cprobk(c, tr, t) * cstP2(:, t, tr, c);
      ecstP2f(:, t, tr) = ecstP2f(:, t, tr) + cprobk(c, tr, t) * cstP2f(:, t, tr, c);
      erevPs2(:, t, tr) = erevPs2(:, t, tr) + cprobk(c, tr, t) * revPs2(:, t, tr, c);
      eshcstP2(:, t, tr) = eshcstP2(:, t, tr) + cprobk(c, tr, t) * shcstP2(:, t, tr, c);
      eshedP2(:, t, tr) = eshedP2(:, t, tr) + cprobk(c, tr, t) * shedP2(:, t, tr, c);
    end
    cprobsc(tr, t) = prob2(tr, t);      % warning, cprobsc here refers to trajectories
%        e2shed2(1, t) = e2shed2(1, t) + cprobsc(tr, t) * eshed2(t, tr);
    e2Pg2(:, t) = e2Pg2(:, t) + cprobsc(tr, t) * ePg2(:, t, tr);
    e2cstP2(:, t) = e2cstP2(:, t) + cprobsc(tr, t) * ecstP2(:, t, tr);
    e2cstP2f(:, t) = e2cstP2f(:, t) + cprobsc(tr, t) * ecstP2f(:, t, tr);
    e2shcstP2(:, t) = e2shcstP2(:, t) + cprobsc(tr, t) * eshcstP2(:, t, tr);
%        e2revPs2(:, t) = e2revPs2(:, t) + cprobsc(tr, t) * erevPs2(:, t, tr);
    e2shedP2(:, t) = e2shedP2(:, t) + cprobsc(tr, t) * eshedP2(:, t, tr);
    resreq2(:, sc, t) = tri.r2f.results{t}.reserves.req(:, 1);
    rescost2(tr, t) = tri.r2f.results{t}.reserves.totalcost;
  end
  erescost2(:, t) = mean(rescost2(:, t), 1);
  if mpfix.UC.CommitKey
    vv = get_idx(mpfix.om);
    v = mpfix.QP.x(vv.i1.v(t):vv.iN.v(t));
    w = mpfix.QP.x(vv.i1.w(t):vv.iN.w(t));
    ucstcost(:, t)  = mpfix.StepProb(t)*mpfix.flow(t,1,1).mpc.gencost(:, STARTUP ) .* v;
    ucsdcost(:, t) = mpfix.StepProb(t)*mpfix.flow(t,1,1).mpc.gencost(:, SHUTDOWN) .* w;
  end
end
Rrpoffer = Rrpoffer(:, 1:end-1);            % remove last period, as no ramping is needed then
Rrmoffer = Rrmoffer(:, 1:end-1);
genPcst(:, :) = sum(e2cstP(ig, :));         % expected cost
genP(:, :) = sum(e2revP(ig, :));            % generators expected revenue
genE(:, :) = sum(e2revP(ie, :), 1);         % ess expected revenue
loadP(:, :) = sum(e2revP(il, :));           % loads expected payments
LNScst(:, :) = sum(e2shcstP(il, :));        % cost of lns
LNScst2(:, :) = sum(e2shcstP2(il, :));      % cost of lns, 2s
Pc(:, :) = e2Pg;
% Rpp(:, :) = mpfix.results.Rpp(:, startnt + 1:end);
% Rpm(:, :) = mpfix.results.Rpm(:, startnt + 1:end);
resreqt(:, :) = sum(resreq1(optd.reszi, :), 1);  % fixed reserves needed
if nt >1
  Rrp(:, :) = 0;
  Rrm(:, :) = 0;
  Rrplam(:, :) = mpfix.results.RrpPrices(:, startnt + 1:end);
  Rrmlam(:, :) = mpfix.results.RrmPrices(:, startnt + 1:end);
  genRrp(:, :) = Rrp .* Rrpoffer;
  genRrm(:, :) = Rrm .* Rrmoffer;
  revRrp(:, :) = Rrp .* Rrplam;
  revRrm(:, :) = Rrm .* Rrmlam;
else
  Rrp(:, :) = 0;
  Rrm(:, :) = 0;
  Rrplam(:, :) = mpfix.results.RrpPrices;
  Rrmlam(:, :) = mpfix.results.RrmPrices;
  genRrp = [];
  genRrm = [];
  revRrp = [];
  revRrm = [];
end
% Rpplam(:, :) = mpfix.results.RppPrices(:, startnt + 1:end);
% Rpmlam(:, :) = mpfix.results.RpmPrices(:, startnt + 1:end);
% genRup(:, :) = Rpp .* Rpplam;
% genRdn(:, :) = Rpm .* Rpmlam;
revRup(:, :) = Rpp .* Rpplam; 
revRdn(:, :) = Rpm .* Rpmlam; 
if min(ie)>0
  Sp(:, :) = mpfix.results.Sp(:, startnt + 1:end);
  Sm(:, :) = mpfix.results.Sm(:, startnt + 1:end);
  eStorSt(:, :) = mpfix.Storage.ExpectedStorageState(:, startnt + 1:end);
  if Istr.Storage.ForceCyclicStorage %opt.ForceCyclicStorage
    eStorPg(:, :) = mpfix.Storage.ExpectedStorageDispatch(:, startnt + 1:end);
    mstorl(:, :) = mpfix.Storage.MinStorageLevel(:, startnt + 1:end - 1);
    Mstorl(:, :) = mpfix.Storage.MaxStorageLevel(:, startnt + 1:end - 1);        
  else
    eStorPg(:, :) = mpfix.Storage.ExpectedStorageDispatch(:, startnt + 1:end);
    mstorl(:, :) = mpfix.Storage.MinStorageLevel(:, startnt + 1:end);
    Mstorl(:, :) = mpfix.Storage.MaxStorageLevel(:, startnt + 1:end);    
  end
else
  %eStorPg = ...                     % Dimensions are [] for this case
  %  mpfix.Storage.ExpectedStorageDispatch;
  eStorPg = [];
  mstorl(:, :) = [];
%   mpfix.Storage.MinStorageLevel(:, startnt + 1:end - 1);      % Modified by Daniel 3/6/2015   
  Mstorl(:, :) = [];
%   mpfix.Storage.MaxStorageLevel(:, startnt + 1:end - 1);      % Modified by Daniel 3/6/2015   
end
erpCost(:, :) = mpfix.results.ExpectedRampCost;
Lim = squeeze(max(max(Gmaxlim, [], 4), [], 3));     % gen limits up
lim = squeeze(min(min(Gminlim, [], 4), [], 3));     % gen limits down
GG = squeeze(max(max(Pg, [], 4), [], 3));           % max generated
GGm = squeeze(min(min(Pg, [], 4), [], 3));          % min generated
mGGt = min(min(min(Pg, [], 4), [], 3), [], 2);
MGGt = max(max(max(Pg, [], 4), [], 3), [], 2);
MGGp = max(max(Pg, [], 4), [], 3);

optp = [];
print_dmpsd(genPcst, genP, genE, genRup, genRdn, ...
  genRrp, genRrm, loadP, e2revP, LNScst, e2shed, erpCost, ...
  tloadp, e2Pg, Pg, e2shedP, ig, il, ie, iw, nt, ...
  optp, optd);

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
  'e2shedP2', 'resCost', 'resreqt'...
  'rescost2', 'erescost2', 'revRrm',...
  'revRrp', 'revRup', 'revRdn',...
  'cstP2f', 'ecstP2f', 'e2cstP2f', ...
  'Gmaxlim2', 'Gminlim2', ...
  };

for st = 1:size(avoutv, 2)
  varargout{st} = eval(avoutv{st});
end;

if optd.saveit
%   save(sprintf('%s%s%s.mat', optd.savepath, filesep, optd.savename), avoutv{:});
  save(sprintf('%s%s.mat', optd.savepath, optd.savename), avoutv{:});
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
%   fid = fopen(sprintf('%s%s%s.txt', optd.savepath, filesep, optd.savename), 'w');
  fid = fopen(sprintf('%s%s.txt', optd.savepath, optd.savename), 'w');
  
  af = optp.af;
  af2 = optp.af2;

  fprintf(fid, 'Expected Period Values ...\n');

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

% pending:
% add cost of reserves
% cost of ramp
% cost of load follow
function [thisrun, byidx] = preload_run_inputs(ps, sim_name, sim_inputdir, R, nidx, r)
%PRELOAD_RUN_INPUTS @solver/preload_run_inputs
%

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).


%% First stage setup
% (1.2) Initialize counters and data files
name_setup.savetr = 0;                         % simulation counter
name_setup.s1cont = 0;                         % stage 1 counter
name_setup.s2cont = 0;                         % stage 2 counter
name_setup.s1datan = 's1-data';                % name of mat file with s1 data
name_setup.s2datan = 's2-data';                % name of mat file with s2 data
name_setup.res2name = 'traj';                  % short name for results of second stage (to save)
name_setup.s1plots = 's1_plots';               % name of mat file with s1 data for plots

name_setup.s1fdatan = 's1f-data';              % name of mat file with s1 fixed data
name_setup.s2fdatan = 's2f-data';              % name of mat file with s2 fixed data
name_setup.s1fplots = 's1f_plots';             % name of mat file with s1 fixed data for plots

ropt = struct();
ropt.UC.flag = 1;
ropt.verbose = 2;
ropt.first = 1;
ropt.second = 1;
ropt.UC.CyclicCommitment = 1;
mpopt1 = [];
mpopt2 = [];

roptf = ropt;
mpopt1f = [];
mpopt2f = [];


fixed_outputs_dir = [];
fixed_work_dir = [];
second_stage = [];
mpsd = [];
mpsdf = []; 
trajdatai = [];
xgd  = [];
contabtf = [];
profiles = [];
req0 = [];

num_threads = 6;  %laptop, raptor

if r{1} == 1 && r{2} == 1

	mpopt1 = mpoption('verbose', 2, 'out.all', 1);
	mpopt1 = mpoption(mpopt1, 'opf.violation', 5e-7);
	mpopt1 = mpoption(mpopt1, 'most.solver', 'GUROBI');

	mpopt1 = mpoption(mpopt1, 'gurobi.opts.Method', 2);
	mpopt1 = mpoption(mpopt1, 'gurobi.opts.PreDual', 1);

	mpopt1 = mpoption(mpopt1, 'gurobi.opts.Threads', num_threads);
	mpopt1 = mpoption(mpopt1, 'gurobi.opts.ConcurrentMIP', 4);
	%--------------------------------------------------------------------
	mpopt2 = mpoption('verbose', 0, 'out.all', 0);
	mpopt2 = mpoption(mpopt2, 'opf.violation', 5e-7);
	mpopt2 = mpoption(mpopt2, 'most.solver', 'GUROBI');
    mpopt2 = mpoption(mpopt2, 'opf.dc.solver', 'GUROBI');
    
	%mpopt2 = mpoption(mpopt2, 'cplex.opts.threads', num_threads);
	%mpopt2 = mpoption(mpopt2, 'cplex.opts.lpmethod', 4);
	%mpopt2 = mpoption(mpopt2, 'cplex.opts.qpmethod', 3);

	mpopt2 = mpoption(mpopt2, 'gurobi.opts.PreDual', 1);
	mpopt2 = mpoption(mpopt2, 'gurobi.opts.Method', 1);
	mpopt2 = mpoption(mpopt2, 'gurobi.opts.Threads', num_threads);

elseif r{1} == 2
	res_criteria_list = {'default2'};
	theta_len = R(2);
	theta_min = 0.6;
	theta_max = 1.2;
	theta = linspace(theta_min,theta_max,theta_len);
	res_criteria_param = {theta, theta, theta, theta};

	% additional parameter that indicates lines with flows to be checked in reserves 42(30:17); 43(8:30); 64, 65 (30:38); 129(70:71) 13 (5:11); 121 (65:68)
	roptf.linec = [42, 43, 64, 65, 13, 121, 129];
	% additional parameter that reserve criterion may require

	roptf.rescrit = 'default2';
	roptf.rescritParam = res_criteria_param{length(res_criteria_list)}(r{2});
	% going to have to go up one level
	fixed_outputs_dir = ['../' sim_name '_' roptf.rescrit '_' num2str(r{2}, '%0.3d')];
	fixed_work_dir = ['../' sim_name '_' roptf.rescrit '_' num2str(r{2}, '%0.3d')];

	% additional parameter that indicates zones in a cell
	roptf.zones = {[3], [4], [2, 3, 4]};
	roptf.verbose = 1;
	roptf.UC.flag = 1;

	roptf.resinfo = 'resfixp';
	roptf.s2ResReductionFactor = 0.9;
	ropt.algs.s2base = {'GUROBI', 'CPLEX', 'MIPS'};
	% set to 1 if reserves change over the periods of the horizon
	roptf.fixtimediff = 1;
	% name of function to create reserves requirements
	roptf.rescf = 'res_criteria';
	roptf.UC.CyclicCommitment = 1;
	%--------------------------------------------------------------------
	mpopt1f = mpoption('most.security_constraints', 0);
	%mpopt1f = mpoption(mpopt1f, 'most.solver', 700);
	mpopt1f = mpoption(mpopt1f, 'most.fixed_res', 1);
	mpopt1f = mpoption(mpopt1f, 'most.solver', 'GUROBI');
	%mpopt1f = mpoption(mpopt1f, 'cplex.opts.lpmethod', 4);
	mpopt1f = mpoption(mpopt1f, 'gurobi.opts.Method', 2);
	mpopt1f = mpoption(mpopt1f, 'gurobi.opts.PreDual', 1);
	%mpopt1f = mpoption(mpopt1f, 'cplex.opts.threads', num_threads);
	mpopt1f = mpoption(mpopt1f, 'gurobi.opts.Threads', 2);
	mpopt1f = mpoption(mpopt1f, 'verbose', 1);
	%--------------------------------------------------------------------
	mpopt2f = mpoption('opf.dc.solver', 'GUROBI', 'verbose', 0, 'out.all', 0);
	mpopt2f = mpoption(mpopt2f, 'model', 'DC');
	mpopt2f = mpoption(mpopt2f, 'opf.violation', 5e-7);
	mpopt2f = mpoption(mpopt2f, 'sopf.force_Pc_eq_P0', 0);   %% constrain contracted == base case dispatch
	%mpopt2f = mpoption(mpopt2f, 'cplex.lpmethod', 3);% network simplex
	%mpopt2f = mpoption(mpopt2f, 'cplex.qpmethod', 3);% network simplex
	mpopt2f = mpoption(mpopt2f, 'gurobi.method', 1);% dual simplex
	mpopt2f = mpoption(mpopt2f, 'gurobi.threads', num_threads);

	grb_opt.PreDual = 1;
	mpopt2f = mpoption(mpopt2f, 'gurobi.opts', grb_opt);
	%mpopt2f = mpoption(mpopt2f, 'cplex.opts', cplex_opt);

	
	if roptf.verbose, fprintf('==================================\n');end
end

if (r{1} == 1 && r{2} == 1) || r{1} == 2
	% (4.1) Load base case: mpcData
	% see question modify loadcase to understand function handles?
	current_path = pwd;
	casef_path = sprintf('%s/stage1/%3.3i/%3.3i/s1', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	mpcr = feval_w_path_mpsim(casef_path, 'mpcase');
	mpc = loadcase(mpcr);
	mpc = idx_fuel(mpc);
	mpc0 = mpc;

	% (4.2) Perform changes to base case
	%mpc = modcase(mpc);                 % perform modifications to case

	% (4.3) Modify contingency table
	contabf_path = sprintf('%s/stage1/%3.3i/%3.3i/s1', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	contabi = feval_w_path_mpsim(contabf_path, 'contab', mpc);

	% (4.4) Modify additional gen data: xGenData
	xgendf_path = sprintf('%s/stage1/%3.3i/%3.3i/s1', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	xgd = loadxgendata(feval_w_path_mpsim(xgendf_path, 'xGenData', mpc), mpc);

	% (4.5) Modify wind gen data: WindData
	windf_path = sprintf('%s/stage1/%3.3i/%3.3i/s1', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	inpw = feval_w_path_mpsim(windf_path, 'winddata');
	if ~isempty(inpw.busgw)
	  windi = createwind(mpc, inpw);      % create wind inputs
	  [iwind, mpc, xgd] = addwind(windi, mpc, xgd); 
	else 
	  iwind = mpc.iwind; 
	end
	ldidx = 1; % index for wind

	% (4.6) Modify storage gen data: StorageData
	%inpe = essf(mpc);
	%essi = createess(mpc, inpe);        % create ess inputs
	%[iess, mpc, xgd, sd] = addstorage(essi, mpc, xgd);
	sd = [];

	% (4.7) Modify profiles data: profiles
	profw_path = sprintf('%s/stage1/%3.3i/%3.3i', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	profiles = getprofiles(feval_w_path_mpsim(profw_path, 'profile_wind_s1'), iwind);
	profiles = getprofiles(feval_w_path_mpsim(profw_path, 'profile_load_s1'), profiles);

	% (4.8) Modify transition probability matrices: transmat
	trmat_path = sprintf('%s/stage1/%3.3i/%3.3i', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	transmat = feval_w_path_mpsim(trmat_path, 'transmat_s1');

	% (6.2) Stage 1: First run
	% This is a one time initialization
	if ropt.first
	  mpsd = loadmd(mpc, transmat, xgd, sd, contabi, profiles);
	  
	  if ropt.UC.flag
	    %mpsd.UC.CyclicCommitment = ropt.UC.CyclicCommitment;
        if r{1} == 1 && r{2} == 1
            mpopt1 = mpoption(mpopt1, 'most.uc.cyclic', ropt.UC.CyclicCommitment);
        end
	  else
	    mpsd.UC.CommitKey = [];           % this allows to use the same inputs, but do not run commitment. Future change may have a specialized flag
	  end
	  
	  if isfield(ropt, 'filtered') && ropt.filtered > 0
	    mpsd = filter_ramp_transitions(mpsd, ropt.filtered);
	  end

	  mpsd_dir = sprintf('%s/mpsd_data/%3.3i/', ...
	  	sim_inputdir, name_setup.savetr);

	  if ~exist(mpsd_dir, 'dir')
		  mkdir([mpsd_dir]);
	 	  warning('directory for storing output results created, First run');
	 	  mpc1 = mpc;
		  modct = mpsd.tstep(1, 1).OpCondSched(1, 1).tab;
		  mpc0m = apply_changes(0, mpc1, modct);
		  define_constants;
		  mpc0m.gen(mpc0m.gen(:, PMIN) > 0, PMIN) = 0;
		  %r0 =rundcopf(mpc0m);
		  r0_input = loadmd(mpc0m);
		  r0_temp = most(r0_input);
		  r0 = r0_temp.flow.mpc;
		  mpsd.InitialPg = r0.gen(:, 2);
		  save(sprintf('%s%s.mat', mpsd_dir, 'first_run'), 'mpsd');
	  else
	  	saved_mpsd = load(sprintf('%s%s', mpsd_dir, 'first_run'));
	    mpsd.InitialPg = saved_mpsd.mpsd.InitialPg;
	  end

	  %mpsd.Storage.ForceCyclicStorage = 1;
      if r{1} == 1 && r{2} == 2
        mpopt1 = mpoption(mpopt1, 'most.storage.cyclic', 1);
      end
   end


	% Determinstic--------------------------------------------------------
	% (4.9) Update changes in extended casefile: mpsd with options
	
	if r{1} == 2
	  contabi = [];
	  ewindp = eprofile(transmat, profiles(1), contabi);
	  eloadp = eprofile(transmat, profiles(2), contabi);
	  profilesf = ewindp;
	  profilesf = getprofiles(eloadp, profilesf);

	  for t = 1:nidx
	    transmatf{1, t} = 1;              % create transition probability matrix
      end

      mpc = idx_fuel(mpc);
	  mpsdf = loadmd(mpc, transmatf, xgd, sd, contabi, profilesf);
      
      if roptf.UC.flag
          if r{1} == 2
              mpopt1f = mpoption(mpopt1f, 'most.uc.cyclic', roptf.UC.CyclicCommitment);
          end
      else
          mpsdf.UC.CommitKey = [];
      end
      
	  inputdir = sprintf('%s/stage1/%3.3i/%3.3i/s1/', ...
	      sim_inputdir, name_setup.savetr, name_setup.s1cont);   % directory where inputs are placed
	    
	  % -- define zones --
	  [zone, bus_zone] = feval_w_path_mpsim(inputdir, 'zonesdef');
	  zone = logical(zone);
	  bus_zone = logical(bus_zone);
	  [reserves.zones,  reserves.req, reserves.cost, reserves.qty, reserves.bus_zones] = ...
	          deal(zone, zeros(size(zone,1),1), xgd.PositiveActiveReservePrice, xgd.PositiveActiveReserveQuantity, bus_zone);
	  reserves.qty(mpc.iwind) = 0;
	  mpc.reserves = reserves;

	  [reqi_f, reqi0_f] = feval_w_path_mpsim(inputdir, 'req');
	  reqi = reqi_f * roptf.rescritParam;
	  reqi0 = reqi0_f * roptf.rescritParam;

	  %% XX-----  create info for fixed reserves -----
	  if roptf.first
	    res2f = cell(mpsdf.idx.nt, 1);      % fixed reserves vector
	    mpcint = cell(mpsdf.idx.nt, 1);     % initial runs with fixed reserves
	    for t = 1:nidx
	      if roptf.fixtimediff              % create requirements for each time period
	        modct = cell(mpsdf.idx.nt, 1);  % contab tables for operating conditions, nt x 1
	        for m = 1:size(profiles, 1)
	          modct = apply_profile(profilesf(m), modct);
	        end
	        mpcint{t} = apply_changes(0, mpc, modct{t});
	        mpcint{t}.reserves = reserves;  % add info of reserves
	        req(:, t) = reqi(:, t);
	        req0(:, t) = reqi0(:, t);      % original reserve requirement
	      else
	        req = reqi0(:, t)*ones(1, nidx); % replicated same requirements over all hours
	      end
	      cost = xgd.PositiveActiveReservePrice;
	      qty = xgd.PositiveActiveReserveQuantity;
	      [reserves.zones,  reserves.req, reserves.cost, reserves.qty, reserves.bus_zones] = ...
	          deal(zone, req(:, t), cost, qty, bus_zone);
	      reserves.qty(mpcint{t}.iwind) = 0;
	      mpcint{t}.reserves = reserves;    %
	      mpsdf.FixedReserves(t, 1, 1) = reserves;
	    end
	  end

	  if roptf.first
	  	saved_mpsd = load(sprintf('%s%s', mpsd_dir, 'first_run'));
	    mpsdf.InitialPg = saved_mpsd.mpsd.InitialPg;
	  end
    end
    %save(sprintf('%s/%s', sim_inputdir, 'mpsdf2.mat'), 'mpsdf', 'mpopt1f');
	% END Determinstic--------------------------------------------------------

	% xx-----  Stage 2 -----
	% initially taken from results of multiperiod sopf
	% -- traj data --
	%windf_path = sprintf('%s/stage1/%3.3i/%3.3i/s1', sim_inputdir, name_setup.savetr, name_setup.s1cont);
	%inpw = feval_w_path_mpsim(windf_path, 'winddata');
	%if ~isempty(inpw.busgw)
	%  windi = createwind(mpc0, inpw);      % create wind inputs
	%  [iwind, mpc, xgd] = addwind(windi, mpc0, xgd);
	%else
	%  iwind = mpc.iwind; 
	%end

	% (5.1) Load data for trajectories of random parameters: traj data
	trjw_path = sprintf('%s/trajectory', sim_inputdir);
	trajdata = getprofiles(feval_w_path_mpsim(trjw_path, 'profile_wind'), iwind);
	trajdata = getprofiles(feval_w_path_mpsim(trjw_path, 'profile_load'), trajdata);
	%ntraj = size(trajdata(1).values, 2);% determine number of trajectories from data
	%nt2 = size(trajdata(1).values, 1);  % determine number of time periods in s2 from data

	% -- extract trajectories data  -----
	trajdatai = [];                 % initialize trajectory information
	trajdatai = trajdata;           % cycle over all trajectories information, leave info only for current trajectory
	contabtf = cell(nidx, 1);
	for m = 1:size(trajdata, 1)
	  trajdatai(m, 1).values = trajdata(m).values(:, r{3}, :);
	  if r{1} == 2
	  	contabtf = apply_profile(trajdatai(m, 1), contabtf);
	  end
	end
	second_stage = struct('mpsd', mpsd, 'mpsdf', mpsdf, 'trajdatai', trajdatai, 'xgd', xgd, 'contabtf', struct('vals', contabtf));
end

thisrun = struct('name_setup', name_setup, 'fixed_outputs_dir', fixed_outputs_dir, 'fixed_work_dir', fixed_work_dir, ...
	'sim_ropt', ropt, 'sim_mpopt1', mpopt1, 'sim_mpopt2', mpopt2, 'sim_roptf', roptf, 'sim_mpopt1f', mpopt1f, 'sim_mpopt2f', mpopt2f, ...
	'second_stage', second_stage, 'profiles', profiles, 'req0', req0);
byidx = [];

% -- run each one of the cases  -----
if ropt.verbose || roptf.verbose
    fprintf(' /\\    /\\    /\\    /\\                      /\\    /\\    /\\    /\\\n');
    fprintf('/  \\  /  \\  /  \\  /  \\  /  stg.2 SOPF  \\  /  \\  /  \\  /  \\  /  \\\n');
    fprintf('    \\/    \\/    \\/    \\/                \\/    \\/    \\/    \\/\n');
end
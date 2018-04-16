function [x_ps, sx_updates, out_args] = update(ps, x, u, sim_name, sim_workdir, r, idx)
%UPDATE @solver/update

%   MP-Sim
%   Copyright (c) 2016, 2017 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MP-Sim.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

 if idx == 1
  	x.(ps.name).mpc2 = cell(u.time_periods, 1);
  	x.(ps.name).r2.results = cell(u.time_periods, 1);
  	x.(ps.name).r2.xgd = cell(u.time_periods, 1);
  	x.(ps.name).r2.f = zeros(u.time_periods, 1);
  	x.(ps.name).r2.success = zeros(u.time_periods, 1);
end

ropt = u.sim_ropt;
mpopt1 = u.sim_mpopt1;
mpopt2 = u.sim_mpopt2;
second_stage = u.second_stage;

roptf = u.sim_roptf;
mpopt1f = u.sim_mpopt1f;
mpopt2f = u.sim_mpopt2f;

if r{1} == 1 && r{2} == 1
	savefiledirs1 = sprintf('%s/stage1/%3.3i/', ...
	  sim_workdir, u.name_setup.savetr); % directory for stage 1 results
	savefiles1 = sprintf('%s/stage1/%3.3i/results_%3.3i', ...
	  sim_workdir, u.name_setup.savetr, u.name_setup.s1cont); % file for stage 1 results
	savefiledirs2 = sprintf('%s/stage2/%3.3i/', ...
	  sim_workdir, u.name_setup.savetr); % directory for stage 2 results
	savefiles2 = sprintf('%s/stage2/%3.3i/results_%3.3i', ...
	  sim_workdir, u.name_setup.savetr, u.name_setup.s2cont);% file for stage 2 resultsa
  
  if ~exist(savefiledirs1, 'dir')
    mkdir([savefiledirs1]);
    warning('directory for storing output results created, stage 1');
  end
  if ~exist(savefiledirs2, 'dir')
    mkdir([savefiledirs2]);
    warning('directory for storing raw output results created, stage 2');
  end
end

if r{1} == 2
	fixed_work_dir = u.fixed_work_dir;
	savefiledirs1h = sprintf('%s/%s/%s/workdir/stage1/%3.3i/', ...
	     sim_workdir, fixed_work_dir, sim_name, u.name_setup.savetr);% directory for stage 1 results hack
	savefiles1 = sprintf('%s/stage1/%3.3i/results_%3.3i', ...
        sim_workdir, u.name_setup.savetr, u.name_setup.s1cont); % file for stage 1 results
    if ~exist(savefiledirs1h, 'dir')
		mkdir(savefiledirs1h);
		copyfile([savefiles1 '.mat'], savefiledirs1h);
	end
    savefiledirs1 = sprintf('%s/%s/%s/workdir/stage1/%3.3i/', ...
		sim_workdir, fixed_work_dir, sim_name, u.name_setup.savetr);% directory for stage 1 results
	savefiledirs2 = sprintf('%s/%s/%s/workdir/stage2/%3.3i/', ...
		sim_workdir, fixed_work_dir, sim_name, u.name_setup.savetr);% directory for stage 2 results
	savefiles1f = sprintf('%s/%s/%s/workdir/stage1/%3.3i/results_fr_%3.3i', ...
		sim_workdir, fixed_work_dir, sim_name, u.name_setup.savetr, u.name_setup.s1cont); % file for stage 1 results, fixed
	savefiles2f = sprintf('%s/%s/%s/workdir/stage2/%3.3i/results_fr_%3.3i', ...
		sim_workdir, fixed_work_dir, sim_name, u.name_setup.savetr, u.name_setup.s2cont);% file for stage 2 results, fixed
    
    if ~exist(savefiledirs1, 'dir')
        mkdir([savefiledirs1]);
        warning('directory for storing output results created, stage 1');
    end
    if ~exist(savefiledirs2, 'dir')
        mkdir([savefiledirs2]);
        warning('directory for storing raw output results created, stage 2');
    end
end
	
r1 = [];
r1f = [];
if r{3} == 1 && idx == 1
	if ~ropt.first
		try
			if r{1} == 1 && r{2} == 1
          		s1r = load(savefiles1);
          		r1 = s1r.r1;
          	elseif r{1} == 2
          		s1r = load(savefiles1f);
          		r1f = s1r.r1f;
          		u.req0 = s1r.req0;
          	end
        catch errorl
          if strcmp('MATLAB:load:couldNotReadFile', errorl.identifier)
            error('tr_st: No results for first stage available!');
          elseif strcmp('MATLAB:nonExistentField', errorl.identifier)
            error('tr_st: Results do not have first stage information, change option to run first stage');
          else
            rethrow(errorl)
          end
        end
    else
    	if r{1} == 1 && r{2} == 1
	        warning('Results do not have first stage information, calling run, verify program');
	        if ropt.verbose
	          fprintf('\n');
	          fprintf(' /\\    /\\    /\\    /\\                      /\\    /\\    /\\    /\\\n');
	          fprintf('/  \\  /  \\  /  \\  /  \\  /  DC MP SOPF  \\  /  \\  /  \\  /  \\  /  \\\n');
	          fprintf('    \\/    \\/    \\/    \\/                \\/    \\/    \\/    \\/\n');
	          fprintf('==================================\n');
	        end
	        r1 = most(second_stage.mpsd, mpopt1);
         %   saved_r1 = load(sprintf('%s.mat', savefiles1));
		%r1 = saved_r1.r1;
	        save(sprintf('%s.mat', savefiles1));% save first stage results
	    elseif r{1} == 2
	        if roptf.verbose
	          fprintf('\n');
	          fprintf(' /\\    /\\    /\\    /\\                      /\\    /\\    /\\    /\\\n');
	          fprintf('/  \\  /  \\  /  \\  /  \\  /  FX RES OPF  \\  /  \\  /  \\  /  \\  /  \\\n');
	          fprintf('    \\/    \\/    \\/    \\/                \\/    \\/    \\/    \\/\n');
	          fprintf('==================================\n');
	        end
	        %r1f = mpsopfl_fixed_res(mpsdf);% call the first stage
	        r1f = most(second_stage.mpsdf, mpopt1f);
            %saved_r1 = load(sprintf('%s.mat', savefiles1f));
		%r1f = saved_r1.r1f;
	        save(sprintf('%s', savefiles1f));% save first stage results
	    end
    end
else
	if r{1} == 1 && r{2} == 1
		saved_r1 = load(sprintf('%s.mat', savefiles1));
		r1 = saved_r1.r1;
	elseif r{1} == 2
		saved_r1 = load(sprintf('%s.mat', savefiles1f));
		r1f = saved_r1.r1f;
    end
end
if ropt.verbose
	if r{1} == 1 && r{2} == 1
	  fprintf('==================================\n');
	  fprintf('  S2, MPSOPFL : Trajectory %i, Period %i\n',r{3}, idx);
	  fprintf('==================================\n');
	elseif r{1} == 2
		fprintf('==================================\n');
        fprintf('  SOPF2F : Trajectory %i, Period %i\n', r{3}, idx);
        fprintf('==================================\n');
	end
end

r2 = x.(ps.name).r2;
%mpc2_val = [];
%results_val = [];
%xgd_val = [];
%f_val = [];
%success_val = [];
if r{1} == 1 && r{2} == 1
  [mpc2_val, xgd_val] = mpsets2(second_stage.mpsd, r1, r2, idx, second_stage.trajdatai, second_stage.xgd);
  %r2.results{t} = mpsopfl_fixed_res(mpc2{t});
  results_val = most(mpc2_val, mpopt2);
  f_val = results_val.results.f;
  %r2.success(t) = r2.results{t}.Solve;
  success_val = 1;
  
  x.(ps.name).mpc2{idx, 1} = mpc2_val;
  x.(ps.name).r2.results{idx, 1} = results_val;
  x.(ps.name).r2.xgd{idx, 1} = xgd_val;
  x.(ps.name).r2.f(idx, 1) = f_val;
  x.(ps.name).r2.success(idx, 1) = success_val;

elseif r{1} == 2
  r1fa = r1f;
  r1fa.FixedReserves(idx, 1, 1).req = u.req0(:, idx);% adjust reserves requirements to lower value
  mpc2_val = mpsetfs2(second_stage.mpsdf, r1fa, r2, idx, second_stage.contabtf(idx).vals);
  [results_val, success_val] = runopf_w_res(mpc2_val, mpopt2f);
  xgd_val = [];
  f_val = 0;
  
  x.(ps.name).mpc2{idx, 1} = mpc2_val;
  x.(ps.name).r2.results{idx, 1} = results_val;
  x.(ps.name).r2.xgd{idx, 1} = xgd_val;
  x.(ps.name).r2.f(idx, 1) = f_val;
  x.(ps.name).r2.success(idx, 1) = success_val;
end

  x_ps = x.(ps.name);

  out_args = [];
  if idx == u.time_periods
  	if r{1} == 1 && r{2} == 1
  		fn_prefix2 = sprintf('%s', savefiledirs2);
  		mpc2 = x.(ps.name).mpc2;
  		r2 = x.(ps.name).r2;
  		if ropt.verbose,fprintf('==================================\n');end
  		save(sprintf('%s%s%3.3i.mat', fn_prefix2, 'traj', r{3}), 'mpc2', 'r2');
  		out_args = {r1, savefiledirs2};
  	elseif r{1} == 2
  		fn_prefix2f = sprintf('%s', savefiledirs2);
  		mpc2f = x.(ps.name).mpc2;
  		r2f = x.(ps.name).r2;
  		if roptf.verbose,fprintf('==================================\n');end
    	save(sprintf('%s%s%3.3i.mat', fn_prefix2f, 'trajf', r{3}), 'mpc2f', 'r2f');
    	out_args = {r1f, savefiledirs2};
    end
  end


sx_updates = [];

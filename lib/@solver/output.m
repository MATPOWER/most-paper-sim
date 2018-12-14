function y_ps = output(ps, x, u, sim_name, sim_outputdir, r, idx, out_args)
%OUTPUT solver/output

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

if nargin == 1
    y_ps = [];
else
	if r{1} == 1 && r{2} == 1 && r{3} == u.runs(3) && idx == u.time_periods
        u.runs(3)
		savefileresds1 = sprintf('%s/stage1/%3.3i/', ...
		  sim_outputdir, u.name_setup.savetr);% directory for processed outputs, s1
		savefileress1 = sprintf('%s/stage1/%3.3i/%s', ...
		  sim_outputdir, u.name_setup.savetr, u.name_setup.s1datan);% file for processed outputs, s1
		savefileresds2 = sprintf('%s/stage2/%3.3i/', ...
		  sim_outputdir, u.name_setup.savetr);% directory for processed outputs, s2
		savefileress2 = sprintf('%s/stage2/%3.3i/%s', ...
		  sim_outputdir, u.name_setup.savetr, u.name_setup.s2datan);% directory for processed outputs, s2

		if ~exist(savefileresds1, 'dir')
		  mkdir([savefileresds1]);
		  warning('directory for storing processed output results created, stage 1');
		end
		if ~exist(savefileresds2, 'dir')
		  mkdir([savefileresds2]);
		  warning('directory for storing processed output results created, stage 2');
		end

    	r1 = out_args{1};

    	% (7.1) first stage runs data-----
    	optd.savepath = savefileresds1;
		optd.savename = u.name_setup.s1datan;
		nOut = 88;
		[outArgs{1:nOut}] = data_mpsd(r1, optd);

		% (7.2) diagnosis plots -----
		savedvars = savefileress1;
		optp.savepath = savefileresds1;
		optp.savefile = sprintf('%s', u.name_setup.s1plots);
		optp.profiles = u.profiles;
		doplots_hpdcf(r1, savedvars, optp);

		% (7.3) second stage calculations -----
		%optd2.basedir2 = savefileresds2; % directory of second stage results
		optd2.basedir2 = out_args{2};   % directory of second stage results
		out_args{2}
		optd2.res2name = u.name_setup.res2name;        % name of files for second stage
		optd2.savefile = savefileress2;
		optd2.runtype = 2;
		optd2.savepath = savefileresds2;
		optd2.savename = u.name_setup.s2datan;
		if u.sim_ropt.second
		  nOut = 126;
		  [outArgs2{1:nOut}] = data_mpsd(r1, optd2, u.runs(3), probtr2(u.runs(3), u.time_periods));
		%  hp_revenuedcs2(savefiles1, 1, nt, optd2, ntraj, probtr2(ntraj, nt));
		end
    elseif r{1} == 2 && r{3} == u.runs(3) && idx == u.time_periods
    	savefileresds1 = sprintf('%s/%s/%s/outputs/stage1/%3.3i/', ...
		  sim_outputdir, u.fixed_outputs_dir, sim_name, u.name_setup.savetr);% directory for processed outputs, s1
		savefileress1f = sprintf('%s/%s/%s/outputs/stage1/%3.3i/%s', ...
		  sim_outputdir, u.fixed_outputs_dir, sim_name, u.name_setup.savetr, u.name_setup.s1fdatan);% file for processed outputs, s1
		savefileresds2 = sprintf('%s/%s/%s/outputs/stage2/%3.3i/', ...
		  sim_outputdir, u.fixed_outputs_dir, sim_name, u.name_setup.savetr);% directory for processed outputs, s2
		savefileress2 = sprintf('%s/%s/%s/outputs/stage2/%3.3i/%s', ...
		  sim_outputdir, u.fixed_outputs_dir, sim_name, u.name_setup.savetr, u.name_setup.s2fdatan);% directory for processed outputs, s2

		if ~exist(savefileresds1, 'dir')
		  mkdir([savefileresds1]);
		  warning('directory for storing processed output results created, stage 1');
		end
		if ~exist(savefileresds2, 'dir')
		  mkdir([savefileresds2]);
		  warning('directory for storing processed output results created, stage 2');
		end

		r1f = out_args{1};
		optd.savepath = savefileresds1;
		optd.savename = u.name_setup.s1fdatan;
		optd.basedir2 = out_args{2};
		optd.res2name = 'trajf';
		optd.saveit = 1;
		nOut = 123;
		[outArgs{1:nOut}] = data_fxres_most(r1f, optd, u.runs(3), probtr2(u.runs(3), u.time_periods));

	end
    y_ps = [];
end

function t_test9(quiet)
% T_TEST9 tests equality of certain mat files from the test9 case

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Haeyong Shin, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

if nargin < 1
  quiet = 0;
end
num_tests = 17;
t_begin(num_tests, quiet);
sim_name = 'testsim9';
test9_config = mpsim_config();
mpsd_data = load(sprintf('%s/%s/inputs/mpsd_data/000/first_run', ...
    test9_config.inputdir, sim_name));

t_is(mpsd_data.mpsd.mpc.bus(:,1), [1;2;3;4;5;6;7;8;9], 12, 'mpsd data value in bus');
t_is(mpsd_data.mpsd.mpc.bus(:,10), ones(9,1)*345, 12, 'mpsd data value bus 2');
t_is(mpsd_data.mpsd.idx.nt, 24, 12, 'mpsd data value idx');
t_is(round(mpsd_data.mpsd.InitialPg,4), [82.0914;0;0;-47.5604;-52.8449;-66.0561;84.3699], 12, 'mpsd data value InitialPg');

s1data = load(sprintf('%s/%s/outputs/stage1/000/s1-data.mat', ...
    test9_config.inputdir, sim_name));
t_is(s1data.ng, 7, 12, 's1data nt value');
t_is(s1data.iw, 7, 12, 's1data iw value');
t_is(round(s1data.loadP(1,1:3)), [-3829, -3056, -2946], 12,'hi')

s2data = load(sprintf('%s/%s/outputs/stage2/000/s2-data.mat', ...
    test9_config.inputdir, sim_name));
t_is(s2data.ntr, 2, 12, 's2data ntr value');
t_is(s2data.prob2(1,1:5), ones(1,5)*0.5, 12, 's2data prob2 value');
t_is(round(s2data.e2Pg2(1,1:5),4), [81.6888, 68.3895, 63.6266, 61.4002, 62.7252], 12, 's2data e2Pg2 value');

s1fdata = load(sprintf('%s/%s/testsim9_default2_001/%s/outputs/stage1/000/s1f-data.mat', ...
    test9_config.inputdir, sim_name, sim_name));
t_is(round(s1fdata.resCost(1,1:5),4), [264.5663, 262.8730, 261.1292, 258.6795, 255.4365], 12, 's1fdata resCost value');
t_is(s1fdata.lamP(1,1:5), [23.0010, 20, 20, 13.9990, 20], 12, 's1fdata lamP value');
t_is(round(s1fdata.genP(1,1:5)), [1877, 1365, 1264, 850, 1238], 12, 's1fdata genP value');

results0 = load(sprintf('%s/%s/work/stage1/000/results_000.mat', test9_config.inputdir, sim_name));
t_is(round(results0.r1.results.f), -45720693, 12, 'results0 r1 results f value');
t_is(round(results0.r1.InitialPg,4), [82.0914;0;0;-47.5604;-52.8449;-66.0561;84.3699], 12, 'results0 r1 InitialPg value');

resultsfr0 = load(sprintf('%s/%s/testsim9_default2_001/%s/workdir/stage1/000/results_fr_000.mat', ...
    test9_config.inputdir, sim_name, sim_name));
t_is(round(resultsfr0.r1f.results.f), -45712167, 12, 'resultsfr0 r1f results f value');
t_is(round(resultsfr0.r1f.flow(1).mpc.reserves.totalcost,4), 264.5663, 12, ...
    'resultsfr0 r1f flow mpc reserves totalcost value');

t_end;
function mpc = case9d4
%CASE9    Power flow data for 9 bus, 3 generator case.
%   Please see CASEFORMAT for details on the case file format.
%
%   Based on data from Joe H. Chow's book, p. 70.

%   MATPOWER
%   $Id: case9.m,v 1.11 2010/03/10 18:08:14 ray Exp $
% Alberto J. Lamadrid 12/10/3
% - Added dummy fuel types for testing
% - All loads dispatchable
% - Changed cost function to be linear due to problem
% AJL, 14/07/25
% - decreased line capacity of branch 5 from 150 to 100
% Tried the following changes
% - increased line capacity of branch 4 from 300 to 500
% - increased line capacity of branch 2 from 250 to 350
% - increased line capacity of branch 3 from 150 to 200
% - increased line capacity of branch 6 from 550 to 450
% - increased line capacity of branch 9 from 250 to 450
% - increased line capacity of branch 1 from 250 to 350
% - decreased line capacity of branch 8 from 250 to 50
% - decreased line capacity of branch 6 from 450 to 50
  

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1	0	345	1	1.1	0.9;
	2	2	0	0	0	0	1	1	0	345	1	1.1	0.9;
	3	2	0	0	0	0	1	1	0	345	1	1.1	0.9;
	4	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
	5	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
	6	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
	7	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
	8	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
	9	1	0	0	0	0	1	1	0	345	1	1.1	0.9;
];

%% generator data
%	bus	Pg      Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0       0	300     -300	1	100     1       200     10      0	0	0       0       0       0       Inf         Inf     Inf     Inf       0;
	2	163     0	300     -300	1	100     1       300     10      0	0	0       0       0       0       Inf         Inf     Inf     Inf       0;
	3	85      0	300     -300	1	100     1       120     10      0	0	0       0       0       0       Inf         Inf     Inf     Inf       0;
	5	-90     -30	0       -30     1	100     1       0       -90     0	0	0       0       0       0       Inf         Inf     Inf     Inf     0;
	7	-100	-35	0       -35     1	100     1       0       -100	0	0	0       0       0       0       Inf         Inf     Inf     Inf     0;
	9	-125	-50	0       -50     1	100     1       0       -125	0	0	0       0       0       0       Inf         Inf     Inf     Inf     0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	4	0	0.0576	0	250	250	250	0	0	1	-360	360;
	4	5	0.017	0.092	0.158	250	250	250	0	0	1	-360	360;
	5	6	0.039	0.17	0.358	150	150	150	0	0	1	-360	360;
	3	6	0	0.0586	0	300	300	300	0	0	1	-360	360;
	6	7	0.0119	0.1008	0.209	100	100	100	0	0	1	-360	360;
	7	8	0.0085	0.072	0.149	250	250	250	0	0	1	-360	360;
	8	2	0	0.0625	0	250	250	250	0	0	1	-360	360;
	8	9	0.032	0.161	0.306	250	250	250	0	0	1	-360	360;
	9	4	0.01	0.085	0.176	250	250	250	0	0	1	-360	360;
];

%%-----  OPF Data  -----%%
%% area data
%	area	refbus
mpc.areas = [
	1	5;
];

%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
  2 0 0 2 25 0;
  2 0 0 2 30 0;
  2 0 0 2 27 0;
	2	0	0	2	10000	0;
	2	0	0	2	10000	0;
	2	0	0	2	10000	0;
];

define_constants;
mpc.gen(1:3, PMIN) = 0;
mpc.gencost(1:3, NCOST+1) = [20 60 40]';
mpc.branch(1, RATE_A:RATE_C) = 150;
mpc.branch(4, RATE_A:RATE_C) = 100;
% [mpc.bus, mpc.gen] = scale_load(0.9, mpc.bus, mpc.gen);

mpc.ihydro = 1;
mpc.inuke = [];
mpc.icoal = 2;
mpc.ing = 3;
mpc.ioil = [];
mpc.ilo = find(isload(mpc.gen));

mpc.genfuel(mpc.ihydro, 1) = {'hydro'};
mpc.genfuel(mpc.inuke, 1) = {'nuclear'};
mpc.genfuel(mpc.icoal, 1) = {'coal'};
mpc.genfuel(mpc.ing, 1) = {'ng'};
mpc.genfuel(mpc.ioil, 1) = {'oil'};
mpc.genfuel(mpc.ilo, 1) = {'na'};

mpc.fuelname={
    'coal'
    'hydro'
    'na'
    'ng'
    'ngcc'
    'syncgen'
    'nuke'
    'wind'
    'oil'
    'ess'
};
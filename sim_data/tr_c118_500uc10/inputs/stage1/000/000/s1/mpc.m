function mpc = c118et9
%C118ET8    Power flow data for IEEE 118 bus test case.
%   Please see CASEFORMAT for details on the case file format.
%   This data was converted from IEEE Common Data Format
%   (ieee118cdf.txt) on 20-Sep-2004 by cdf2matp, rev. 1.11
%   See end of file for warnings generated during conversion.
%
%   Converted from IEEE CDF file from:
%       http://www.ee.washington.edu/research/pstca/
%   With baseKV data take from the PSAP format file from the same site,
%   added manually on 10-Mar-2006.
% 
%  08/25/93 UW ARCHIVE           100.0  1961 W IEEE 118 Bus Test Case
%
% Updates: Sep 15'2010 by CM and CZ. Buses grouped on four areas;
%        Branch thermal limits incorporated based on: KV level, same 
%        cable, and safe security factor (assuming bundled config on 345KV
%        and double circuit on 161 and 138KV lines). 
%        Transformer capacity for 9 units also set.
%        Split data for parallel lines that initially had aggregated params
%        RAMP_AGC,RAMP_10 & RAMP_30 set to 20% of PMAX for each generator
%        function change of name to c118
% Aug 13'2012 by CM and DM.
%         The 118-bus test system was modified in order to allow the
%         loading factor to be considerably increased without compromising
%         the feasibility of the system. The procedure followed is
%         described here.
% 
%         First, all the synchronous capacitors were removed from the
%         system in order to decrease the size of the model. Those were
%         initially 22 generators. Two of them were added again (generators
%         at buses 110 and 104) because there are currently hydro
%         generators close to the geographic locations where the
%         synchronous capacitors were located originally. This overall
%         retirement yielded a base case consisting of 34 generators, that
%         is the original 54 generators minus 20 synchronous generators
%         retired.
% 
%         Second, the set of relevant contingencies was chosen from all
%         possible contingencies. The generator contingencies selected were
%         those of generators located at buses 10, 80, and 89. The branch
%         contingencies selected were those of branches located between
%         buses 17-30, 30-38, and 5-11. Those contingencies showed to have
%         important impact over the system when using a dispatch deviation
%         criterion. The criterion was applied using both DC and AC
%         versions of the OPF.
% 
%         Third, the loading factor range  was obtained for the set of
%         contingencies for both the DC and AC versions of the model. For
%         the DC case, all the loading factors of the base case (no
%         contingencies) and all the contingencies were above 1.6. For the
%         AC case, however, the loading factor of the base case was around
%         1.3, and even worse, the loading factor of the worst contingency
%         was around 1.1. Since similar loading factor conditions were
%         desired for both DC and AC cases, some changes or upgrades were
%         required.
% 
%         In the AC base case there were voltage problems in buses 70
%         and 76, and that was causing the system to become infeasible when
%         exceeding a loading factor of 1.3. Apparently, there was not
%         enough reactive power to be dispatched in that zone since all the
%         synchronous capacitors were removed. Hence, two synchronous
%         capacitors were added in that particular zone, namely generators
%         at buses 76 and 77. Additionally, the reactive power limits of the
%         generator at bus 77 were increased from [-20, 70] MVar to [-50,
%         330] MVar in order to obtain a loading factor above 1.6 for the
%         base case.
% 
%         Furthermore, in the case under the contingency of the generator at
%         bus 10, again with the AC case, the loading factor was the one
%         close to 1.1. To improve that factor, the synchronous capacitor
%         at bus 6 was added and its reactive power limits increased from
%         [-13, 50] MVar to [-50, 250] MVar. With these changes, the
%         voltage level deficiencies at bus 6 were solved, at least for
%         loading factors up to 1.5. Beyond this loading factor it gets
%         more difficult to improve it without resorting to the addition of
%         more synchronous generators. Therefore, the maximum loading
%         factor for the AC case was defined to be 1.5 whereas for the DC
%         case it was defined to be 1.6.
% 2014.10.29, Alberto J. Lamadrid:
% Start from file c118swf available in /mpsopf-dev/mpsopf/. 
% Changes Documented in c118changev1.m
% ~/Dropbox/albertoj/mfilesn/c118changev1.m
%
% - make all loads dispatchable
% - maintain consistency in additional fields
% - maintain comments from original file
% - load is scaled to 1.6 the original value
% - Wind is scaled to cover 33% of the scaled load (10\% taking into account a 30% capacity factor)
% - ESS units removed
% - Change generators 14 (bus 59) and 15 (bus 61) from coal to ngcc. 
%   These are the only candidates in the [54:56, 59:64] area (PA, eastern part of the system)
% - Changed generator 4 (bus 10) from coal to nuke. Large coal plant no longer in operation
% - Make the backbone double circuits:
%     - double resistance (BR_R)
%     - double reactance (BR_X)
%     - half susceptance (BR_B)
%     - half rate (RATE_A, RATE_B, RATE_C)
%   - line 8-30 (branch 43)
%   - line 26-30 (branch 44)
%   - line 30-38 (branch 62)
%   - line 38-65 (branch 107) (it was marked with H)
%   - line 63-64 (branch 105) (it was marked with H)
%   - line 64-65 (branch 108) (it was marked with H)
% - Ramps and Capacities (mail 2014.10.31, 4.20PM, Carlos, Re: case118, questions)
%     - calculation had an incorrect sign in ramps for coal, refer to c118et2 for historical trail
% - Added wind farm in bus 44 not in original data.
%   - 12 wind turbines, 2319.5MW (original 11 turbines, 2262.4MW)
%   - Info copied from wind gen in bus 43, PMAX 57.18. 
%   - Though Carlos identified the NREL site as 6390 (lat 40.390788, long -82.488453), with a capacity of 361MW, the capacity of site 6947 (bus 43) shows as 665MW. Therefore, kept with a low PMAX
%   - http://www.nrel.gov/gis/data_wind.html
%   - http://www.nrel.gov/electricity/transmission/eastern_wind_dataset.html
%   - www.greenenergyohio.org/page.cfm?pageID=2212
%   Bus	Name	NREL Sites
%   1	RIVERSIDE	6849
%   6	KANKAKEE	4734, 5538, 4102, 3579, 4024, 4136, 5098, 4248
%   9	BEQUINE	4604, 4208, 4366, 3978, 4247, 4181, 4094, 4468, 4476, 4607
%   18	MCKINLEY	4555, 4943, 4469, 4475
%   19	LINCOLN	4876
%   41	S. TIFFIN	6428,  6139, 5784, 5820, 5470, 5383, 5211
%   43	S. KENTON	6947
%   44	W MOUNT VERNON	6390
%   62	NATRIUM	5966, 6163, 6161, 5340, 2252, 671, 4857, 5020, 4749, 3984
%   63	TIDD	7402, 6813, 6665, 6567, 5512, 4329
%   72	HILLSBORO	7176
%   80	CABIN CREEK	5261, 5709, 3288, 3068
% 2015.03.24, Alberto J. Lamadrid
% - Zones changed according to congestion patterns, see c118changev1
%   - New areas are manually defined, refer to
%   - 118bus new zones color.pdf
%   - c118buszones0.pdf
%   - in /Dropbox/SuperOPF-Group/c118buszones0.pdf
%
% 2015.03.31, Alberto J. Lamadrid
% - Lines from 65-69 doubled (as per c118swf)
% - gen in buses 49, 65, 66, 69, 89 halved (for fixed reserves, initial capacities 304, 491, 492, 707 respectively)
%
% 2015.04.23, Alberto J. Lamadrid
% See c118changev1
% - split generator in bus 69
% - increase ramp capacity of hydro generators to 100%
%     old	new
%     20	100
%     28	140
%     20	100
%     20	100
%     20	100
% 2014.05.20
% - recompute ramps for all generators according to the following formulae
% \cite{ferc2012}, Figures 2 and 4
% - change generators in buses 65, 66, 69 and 89 to gas turbines (ng) from coal, change cost function
%   - cost is assigned based on average cost of existing ng gens 
%   - intercept around 533 plus random factor
%   - slope around 31 plus random factor
%   - For coal units with PMAX less than 500MW:
%     (a) RAMP_AGC: (0.006038 - 3.840e-6*PMAX)*PMAX
%     (b) RAMP_10: (0.006038 - 3.840e-6*PMAX)*PMAX*10, Ranges from 5.65 to 18.4
%     (c) RAMP_30: (0.006038 - 3.840e-6*PMAX)*PMAX*30, Ranges from 16 to 55, around 15-16% of PMAX       
%   - For coal units with PMAX more than 500MW (only one unit in bus 80, 577MW PMAX)
%     (a) RAMP_AGC: (0.004573 - 9.099e-7*PMAX)*PMAX
%     (b) RAMP_10: (0.004573 - 9.099e-7*PMAX)*PMAX*10, 24MW (PMAX 577)
%     (c) RAMP_30: (0.004573 - 9.099e-7*PMAX)*PMAX*30
%    The PMIN for coal units was not modified. RDZ: should we put all to 0
%   - For gas units (turbines), 'ng'
%     (a) RAMP_AGC: 0.03*PMAX, 0.03(combustion turbines)
%     (b) RAMP_10: 0.03*PMAX*10, 0.03(combustion turbines)
%     (c) RAMP_30: 0.03*PMAX*30, 0.03(combustion turbines)
%     RAMP 30 ends up with values close to PMAX
%     (d) PMIN: 0.44*PMAX, (combustion turbines)
% 
% 2015.05.20, Alberto J. Lamadrid
% - Split original ng generators into 
%   If mc$>35$, treat as ng, if mc$<35$, treat as ngcc
% - ngcc is a new fuel, most units will be ngcc. Relatively inflexible
%   - ng corresponds to only one original gen at bus 54, cost = 200 + 53.21Pg
%   - the units at buses 65, 66, 69 and 89 are changed to ng, to make them more flexible (min up and down times)
%   - all cost wil have intercept in [200.14 200.95] , slope in [53.4 54.12]  
%   - The mc<35 does not apply in these cases (these units originally had costs below 35)
%   - For gas units (cc gas) 'ngcc'
%     (a) RAMP_AGC: 0.018*PMAX, (combined cycle)
%     (b) RAMP_10: 0.018*PMAX*10, (combined cycle)
%     (c) RAMP_30: 0.018*PMAX*30, (combined cycle)
%     RAMP 30 ends up with values close to PMAX
%     (d) PMIN: 0.24*PMAX, 0.24 (cc gas);
%   - In summary, at the end there are
%     - 3 ngcc units, cheap fuel (~30), not very flexible minup and down and ramp
%     - 9 ng units, expensive fuel (~54), very flexible minup and down and ramp
% - Startup cost from Carlos (mail 2015.05.18, 10.47AM), procedure used is as follows (quotes from Carlos)
%   - First, I assumed that the startup cost would be roughly proportional to PMAX*MARGCOST
%   - Second, I found the value of PMAX*MARGCOST for each unit using colombian fuel costs, the heatrates in Cullen's paper, and the capacity of the plants.
%   - Then, I fit an affine function to STARTUPCOST/(PMAX*MARGCOST) hoping to find a small linear dependency
%   - Came up with the coefficients in (4.378 - 0.0023*PMAX) * PMAX * MARGCOST, which more or less works and predicts the values that Cullen derived.  Finally, to account for the difference in the observed values vs.  "engineering estimates" that Cullen provides, I used a 0.50 factor on the overall value.  It is somewhat contrived, but it is the best that I could do at the time.  
%   - Formula boils down to:
%       mpc.gencost(itherm, STARTUP) = 0.5 * (4.378 - 0.0023*mpc.gen(itherm,PMAX)) .* mpc.gen(itherm, PMAX) .* mpc.gencost(itherm, COST);
%   - with this the startup costs are more or less doubled from the original values
%   - the original values were around ten times the constant term of the cost
% 2015.06.04, Alberto J. Lamadrid
%   - Startup costs for ng units are too high. Divided the startup cost by 20 for ng units only
% 2015.06.07
% - manually changed the costs for the nuclear generator, increased the fixed cost, decreased the marginal one
% 2015.06.11
% - changed syncgens to ngcc, modified 
%   -ramps (ngcc FERC formula) 
%   - pmin (.44), 
%   - costs original 20, 1.29 and 30.45. newmc ~54, fc ~200
%   - startup cost according to Carlos' formula. 
%   - Original 2000, 20, 3200. New startup ends up being ~ 11000 using raw formula
%   - Startup costs are divided by 3 after talking to Carlos. Final startup cost ends up being ~ 3700
% 2015.08.18, 2015.08.24
% - initilaly eliminated the limit on line 150, now put a limit of 300 (original 200)


%   MATPOWER
%   $Id: c118swf.m,v 1.1 2012/08/29 19:22:55 cvs Exp $

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	2	0	0	0	0	1	0.955	10.67	138	1	1.06	0.94;
	2	1	0	0	0	0	1	0.971	11.22	138	1	1.06	0.94;
	3	1	0	0	0	0	1	0.968	11.56	138	1	1.06	0.94;
	4	2	0	0	0	0	1	0.998	15.28	138	1	1.06	0.94;
	5	1	0	0	0	-40	1	1.002	15.73	138	1	1.06	0.94;
	6	2	0	0	0	0	1	0.99	13	138	1	1.06	0.94;
	7	1	0	0	0	0	1	0.989	12.56	138	1	1.06	0.94;
	8	2	0	0	0	0	1	1.015	20.77	345	1	1.06	0.94;
	9	1	0	0	0	0	1	1.043	28.02	345	1	1.06	0.94;
	10	2	0	0	0	0	1	1.05	35.61	345	1	1.06	0.94;
	11	1	0	0	0	0	1	0.985	12.72	138	1	1.06	0.94;
	12	2	0	0	0	0	1	0.99	12.2	138	1	1.06	0.94;
	13	1	0	0	0	0	1	0.968	11.35	138	1	1.06	0.94;
	14	1	0	0	0	0	1	0.984	11.5	138	1	1.06	0.94;
	15	2	0	0	0	0	2	0.97	11.23	138	1	1.06	0.94;
	16	1	0	0	0	0	1	0.984	11.91	138	1	1.06	0.94;
	17	1	0	0	0	0	2	0.995	13.74	138	1	1.06	0.94;
	18	2	0	0	0	0	2	0.973	11.53	138	1	1.06	0.94;
	19	2	0	0	0	0	2	0.963	11.05	138	1	1.06	0.94;
	20	1	0	0	0	0	2	0.958	11.93	138	1	1.06	0.94;
	21	1	0	0	0	0	2	0.959	13.52	138	1	1.06	0.94;
	22	1	0	0	0	0	2	0.97	16.08	138	1	1.06	0.94;
	23	1	0	0	0	0	2	1	21	138	1	1.06	0.94;
	24	2	0	0	0	0	2	0.992	20.89	138	1	1.06	0.94;
	25	2	0	0	0	0	2	1.05	27.93	138	1	1.06	0.94;
	26	2	0	0	0	0	2	1.015	29.71	345	1	1.06	0.94;
	27	2	0	0	0	0	2	0.968	15.35	138	1	1.06	0.94;
	28	1	0	0	0	0	2	0.962	13.62	138	1	1.06	0.94;
	29	1	0	0	0	0	2	0.963	12.63	138	1	1.06	0.94;
	30	1	0	0	0	0	2	0.968	18.79	345	1	1.06	0.94;
	31	2	0	0	0	0	2	0.967	12.75	138	1	1.06	0.94;
	32	2	0	0	0	0	2	0.964	14.8	138	1	1.06	0.94;
	33	1	0	0	0	0	2	0.972	10.63	138	1	1.06	0.94;
	34	2	0	0	0	14	3	0.986	11.3	138	1	1.06	0.94;
	35	1	0	0	0	0	3	0.981	10.87	138	1	1.06	0.94;
	36	2	0	0	0	0	3	0.98	10.87	138	1	1.06	0.94;
	37	1	0	0	0	-25	3	0.992	11.77	138	1	1.06	0.94;
	38	1	0	0	0	0	3	0.962	16.91	345	1	1.06	0.94;
	39	1	0	0	0	0	3	0.97	8.41	138	1	1.06	0.94;
	40	2	0	0	0	0	3	0.97	7.35	138	1	1.06	0.94;
	41	1	0	0	0	0	3	0.967	6.92	138	1	1.06	0.94;
	42	2	0	0	0	0	3	0.985	8.53	138	1	1.06	0.94;
	43	1	0	0	0	0	3	0.978	11.28	138	1	1.06	0.94;
	44	1	0	0	0	10	3	0.985	13.82	138	1	1.06	0.94;
	45	1	0	0	0	10	3	0.987	15.67	138	1	1.06	0.94;
	46	2	0	0	0	10	3	1.005	18.49	138	1	1.06	0.94;
	47	1	0	0	0	0	3	1.017	20.73	138	1	1.06	0.94;
	48	1	0	0	0	15	3	1.021	19.93	138	1	1.06	0.94;
	49	2	0	0	0	0	3	1.025	20.94	138	1	1.06	0.94;
	50	1	0	0	0	0	3	1.001	18.9	138	1	1.06	0.94;
	51	1	0	0	0	0	3	0.967	16.28	138	1	1.06	0.94;
	52	1	0	0	0	0	3	0.957	15.32	138	1	1.06	0.94;
	53	1	0	0	0	0	3	0.946	14.35	138	1	1.06	0.94;
	54	2	0	0	0	0	3	0.955	15.26	138	1	1.06	0.94;
	55	2	0	0	0	0	3	0.952	14.97	138	1	1.06	0.94;
	56	2	0	0	0	0	3	0.954	15.16	138	1	1.06	0.94;
	57	1	0	0	0	0	3	0.971	16.36	138	1	1.06	0.94;
	58	1	0	0	0	0	3	0.959	15.51	138	1	1.06	0.94;
	59	2	0	0	0	0	3	0.985	19.37	138	1	1.06	0.94;
	60	1	0	0	0	0	3	0.993	23.15	138	1	1.06	0.94;
	61	2	0	0	0	0	3	0.995	24.04	138	1	1.06	0.94;
	62	2	0	0	0	0	3	0.998	23.43	138	1	1.06	0.94;
	63	1	0	0	0	0	3	0.969	22.75	345	1	1.06	0.94;
	64	1	0	0	0	0	3	0.984	24.52	345	1	1.06	0.94;
	65	2	0	0	0	0	3	1.005	27.65	345	1	1.06	0.94;
	66	2	0	0	0	0	3	1.05	27.48	138	1	1.06	0.94;
	67	1	0	0	0	0	3	1.02	24.84	138	1	1.06	0.94;
	68	1	0	0	0	0	4	1.003	27.55	345	1	1.06	0.94;
	69	3	0	0	0	0	4	1.035	30	138	1	1.06	0.94;
	70	2	0	0	0	0	4	0.984	22.58	138	1	1.06	0.94;
	71	1	0	0	0	0	2	0.987	22.15	138	1	1.06	0.94;
	72	2	0	0	0	0	2	0.98	20.98	138	1	1.06	0.94;
	73	2	0	0	0	0	3	0.991	21.94	138	1	1.06	0.94;
	74	2	0	0	0	12	4	0.958	21.64	138	1	1.06	0.94;
	75	1	0	0	0	0	4	0.967	22.91	138	1	1.06	0.94;
	76	2	0	0	0	0	4	0.943	21.77	138	1	1.06	0.94;
	77	2	0	0	0	0	4	1.006	26.72	138	1	1.06	0.94;
	78	1	0	0	0	0	4	1.003	26.42	138	1	1.06	0.94;
	79	1	0	0	0	20	4	1.009	26.72	138	1	1.06	0.94;
	80	2	0	0	0	0	4	1.04	28.96	138	1	1.06	0.94;
	81	1	0	0	0	0	4	0.997	28.1	345	1	1.06	0.94;
	82	1	0	0	0	20	4	0.989	27.24	138	1	1.06	0.94;
	83	1	0	0	0	10	4	0.985	28.42	138	1	1.06	0.94;
	84	1	0	0	0	0	4	0.98	30.95	138	1	1.06	0.94;
	85	2	0	0	0	0	4	0.985	32.51	138	1	1.06	0.94;
	86	1	0	0	0	0	4	0.987	31.14	138	1	1.06	0.94;
	87	2	0	0	0	0	4	1.015	31.4	161	1	1.06	0.94;
	88	1	0	0	0	0	4	0.987	35.64	138	1	1.06	0.94;
	89	2	0	0	0	0	4	1.005	39.69	138	1	1.06	0.94;
	90	2	0	0	0	0	4	0.985	33.29	138	1	1.06	0.94;
	91	2	0	0	0	0	4	0.98	33.31	138	1	1.06	0.94;
	92	2	0	0	0	0	4	0.993	33.8	138	1	1.06	0.94;
	93	1	0	0	0	0	4	0.987	30.79	138	1	1.06	0.94;
	94	1	0	0	0	0	4	0.991	28.64	138	1	1.06	0.94;
	95	1	0	0	0	0	4	0.981	27.67	138	1	1.06	0.94;
	96	1	0	0	0	0	4	0.993	27.51	138	1	1.06	0.94;
	97	1	0	0	0	0	4	1.011	27.88	138	1	1.06	0.94;
	98	1	0	0	0	0	4	1.024	27.4	138	1	1.06	0.94;
	99	2	0	0	0	0	4	1.01	27.04	138	1	1.06	0.94;
	100	2	0	0	0	0	4	1.017	28.03	138	1	1.06	0.94;
	101	1	0	0	0	0	4	0.993	29.61	138	1	1.06	0.94;
	102	1	0	0	0	0	4	0.991	32.3	138	1	1.06	0.94;
	103	2	0	0	0	0	4	1.001	24.44	138	1	1.06	0.94;
	104	2	0	0	0	0	4	0.971	21.69	138	1	1.06	0.94;
	105	2	0	0	0	20	4	0.965	20.57	138	1	1.06	0.94;
	106	1	0	0	0	0	4	0.962	20.32	138	1	1.06	0.94;
	107	2	0	0	0	6	4	0.952	17.53	138	1	1.06	0.94;
	108	1	0	0	0	0	4	0.967	19.38	138	1	1.06	0.94;
	109	1	0	0	0	0	4	0.967	18.93	138	1	1.06	0.94;
	110	2	0	0	0	6	4	0.973	18.09	138	1	1.06	0.94;
	111	2	0	0	0	0	4	0.98	19.74	138	1	1.06	0.94;
	112	2	0	0	0	0	4	0.975	14.99	138	1	1.06	0.94;
	113	2	0	0	0	0	2	0.993	13.74	138	1	1.06	0.94;
	114	1	0	0	0	0	2	0.96	14.46	138	1	1.06	0.94;
	115	1	0	0	0	0	2	0.96	14.46	138	1	1.06	0.94;
	116	2	0	0	0	0	4	1.005	27.12	138	1	1.06	0.94;
	117	1	0	0	0	0	1	0.974	10.67	138	1	1.06	0.94;
	118	1	0	0	0	0	4	0.949	21.92	138	1	1.06	0.94;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
% 	1	0	0	15	-5	0.955	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	4	0	0	300	-300 0.998	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	6	0	0	250	-50	0.99	100	1	100	44	0	0	0	0	0	0	3	30	90	0	0;      % Generator critical for voltage support on bus 6
	8	0	0	300	-300	1.015	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;    % in higher load conditions
	10	450	0	200	-147	1.05	100	1	550	55	0	0	0	0	0	0	110	110	110	0	0;
	12	85	0	120	-35	0.99	100	1	185	20	0	0	0	0	0	0	0.985606	9.85606	29.56818	0	0;
% 	15	0	0	30	-10	 0.97	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	18	0	0	50	-16	 0.973	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	19	0	0	24	-8	 0.962	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	24	0	0	300	-300	0.992	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	25	220	0	140	-47	1.05	100	1	320	30	0	0	0	0	0	0	1.538944	15.38944	46.16832	0	0;
	26	314	0	1000	-1000	1.015	100	1	414	40	0	0	0	0	0	0	1.84157136	18.4157136	55.2471408	0	0;
	27	0	0	300	-300	0.968	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
% 	31	7	0	300	-300 0.967	100	1 107	0	0	0	0	0	0	0       21	21	21	0	0;
% 	32	0	0	42	-14	 0.963	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	34	0	0	24	-8	 0.984	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	36	0	0	24	-8	 0.98	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	40	0	0	300	-300	0.97	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	42	0	0	300	-300	0.985	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	46	19	0	100	-100	1.005	100	1	119	12	0	0	0	0	0	0	0.66414376	6.6414376	19.9243128	0	0;
  49	102	0	105	-42.5	1.025	100	1	152	15	0	0	0	0	0	0	0.82905664	8.2905664	24.8716992	0	0;
	49	102	0	105	-42.5	1.025	100	1	152	15	0	0	0	0	0	0	0.82905664	8.2905664	24.8716992	0	0;
	54	48	0	300	-300	0.955	100	1	148	65.12	0	0	0	0	0	0	4.44	44.4	133.2	0	0;
% 	55	0	0	23	-8	 0.952	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
% 	56	0	0	15	-8	 0.954	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	59	155	0	180	-60	0.985	100	1	255	61.2	0	0	0	0	0	0	4.59	45.9	137.7	0	0;
	61	160	0	300	-100	0.995	100	1	260	62.4	0	0	0	0	0	0	4.68	46.8	140.4	0	0;
	62	0	0	20	-20	0.998	100	1	100	24	0	0	0	0	0	0	1.8	18	54	0	0;
	65	195.5	0	100	-33.5	1.005	100	1	245.5	108.02	0	0	0	0	0	0	7.365	73.65	220.95	0	0;% halved
	65	195.5	0	100	-33.5	1.005	100	1	245.5	108.02	0	0	0	0	0	0	7.365	73.65	220.95	0	0;
  66	196	0	100	-33.5	1.05	100	1	246	108.24	0	0	0	0	0	0	7.38	73.8	221.4	0	0;% halved
  66	196	0	100	-33.5	1.05	100	1	246	108.24	0	0	0	0	0	0	7.38	73.8	221.4	0	0;
	69	258.2	0	150	-150	1.035	100	1	402.6	177.144	0	0	0	0	0	0	12.078	120.78	362.34	0	0;
	69	258.2	0	150	-150	1.035	100	1	402.6	177.144	0	0	0	0	0	0	12.078	120.78	362.34	0	0;
% 	70	0	0	32	-10	 0.984	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	72	0	0	100	-100	0.98	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	73	0	0	100	-100	0.991	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
% 	74	0	0	9	-6	 0.958	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	76	0	0	23	-8	0.943	100	1	100	44	0	0	0	0	0	0	3	30	90	0	0;  % These two critical for voltage support of bus 76
	77	0	0	330	-50	1.006	100	1	100	44	0	0	0	0	0	0	3	30	90	0	0;  % in higher load conditions
	80	477	0	280	-165	1.04	100	1	577	60	0	0	0	0	0	0	2.3356889	23.356889	70.0706671	0	0;
% 	85	0	0	23	-8	 0.985	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	87	4	0	1000	-100	1.015	100	1	104	10	0	0	0	0	0	0	0.58641856	5.8641856	17.5925568	0	0;
  89	303.5	0	150	-105	1.005	100	1	353.5	155.54	0	0	0	0	0	0	10.605	106.05	318.15	0	0;
	89	303.5	0	150	-105	1.005	100	1	353.5	155.54	0	0	0	0	0	0	10.605	106.05	318.15	0	0;
	90	0	0	300	-300	0.985	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	91	0	0	100	-100	0.98	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
% 	92	0	0	9	-3	 0.99	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	99	0	0	100	-100	1.01	100	1	100	0	0	0	0	0	0	0	20	100	100	0	0;
	100	252	0	155	-50	1.017	100	1	352	35	0	0	0	0	0	0	1.64958464	16.4958464	49.4875392	0	0;
	103	40	0	40	-15	1.01	100	1	140	0	0	0	0	0	0	0	28	140	140	0	0;
	104	0	0	23	-8	0.971	100	1	100	0	0	0	0	0	0	0	20	100	100	0	0;
% 	105	0	0	23	-8	 0.965	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	107	0	0	200	-200	0.952	100	1	100	0	0	0	0	0	0	0	20	100	100	0	0;
	110	0	0	23	-8	0.973	100	1	100	0	0	0	0	0	0	0	20	100	100	0	0;
	111	36	0	1000	-100	0.98	100	1	136	14	0	0	0	0	0	0	0.75014336	7.5014336	22.5043008	0	0;
% 	112	0	0	1000 -100 0.975	100	1 100	0	0	0	0	0	0	0       20	20	20	0	0;
	113	0	0	200	-100	0.993	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
	116	0	0	1000	-1000	1.005	100	1	100	10	0	0	0	0	0	0	0.5654	5.654	16.962	0	0;
  % from here on, wind units
	1	0	0	200	-100	1	100	1	56.3217158	0	0	0	0	0	0	0	65	65	65	0	0; % TIFFIN
	6	0	0	2000	-1000	1.035	100	1	542.421446	0	0	0	0	0	0	0	626	626	626	0	0;
	9	0	0	2000	-1000	1.035	100	1	642.934049	0	0	0	0	0	0	0	742	742	742	0	0;
	18	0	0	200	-100	1.035	100	1	183.695442	0	0	0	0	0	0	0	212	212	212	0	0;
	19	0	0	200	-100	1.035	100	1	54.5887398	0	0	0	0	0	0	0	63	63	63	0	0;
	41	0	0	2000	-1000	1.035	100	1	443.641823	0	0	0	0	0	0	0	512	512	512	0	0;
	43	0	0	200	-100	1.035	100	1	57.1882038	0	0	0	0	0	0	0	66	66	66	0	0;
	44	0	0	200	-100	1.035	100	1	57.1882038	0	0	0	0	0	0	0	66	66	66	0	0;
	62	0	0	500	-300	1.035	100	1	132.572655	0	0	0	0	0	0	0	153	153	153	0	0;
	63	0	0	600	-300	1.035	100	1	75.3844508	0	0	0	0	0	0	0	87	87	87	0	0;
	72	0	0	200	-100	1.035	100	1	38.9919572	0	0	0	0	0	0	0	45	45	45	0	0;
	80	0	0	200	-100	1.035	100	1	34.6595175	0	0	0	0	0	0	0	40	40	40	0	0;
  % From here on, storage units
%	59	0	0	10	-10	1	100	1	400	-400	0	0	0	0	0	0	20	50	100	0	0;  % TIDD
%	116	0	0	10	-10	1.035	100	1	400	-400	0	0	0	0	0	0	20	50	100	0	0;  % KYGER CREEK
%	90	0	0	10	-10	1.035	100	1	400	-400	0	0	0	0	0	0	20	50	100	0	0;  % HOLSTON
%	80	0	0	10	-10	1.035	100	1	400	-400	0	0	0	0	0	0	20	50	100	0	0;  % CABIN CREEK
	% From here on, dispatchable units
	1	-81.6	-43.2	0	-43.2	0.955	100	1	0	-81.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	2	-32	-14.4	0	-14.4	0.971	100	1	0	-32	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	3	-62.4	-16	0	-16	0.968	100	1	0	-62.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	4	-62.4	-19.2	0	-19.2	0.998	100	1	0	-62.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	6	-83.2	-35.2	0	-35.2	0.99	100	1	0	-83.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	7	-30.4	-3.2	0	-3.2	0.989	100	1	0	-30.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	8	-44.8	-0	0	0	1.015	100	1	0	-44.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	11	-112	-36.8	0	-36.8	0.985	100	1	0	-112	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	12	-75.2	-16	0	-16	0.99	100	1	0	-75.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	13	-54.4	-25.6	0	-25.6	0.968	100	1	0	-54.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	14	-22.4	-1.6	0	-1.6	0.984	100	1	0	-22.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	15	-144	-48	0	-48	0.97	100	1	0	-144	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	16	-40	-16	0	-16	0.984	100	1	0	-40	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	17	-17.6	-4.8	0	-4.8	0.995	100	1	0	-17.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	18	-96	-54.4	0	-54.4	0.973	100	1	0	-96	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	19	-72	-40	0	-40	0.963	100	1	0	-72	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	20	-28.8	-4.8	0	-4.8	0.958	100	1	0	-28.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	21	-22.4	-12.8	0	-12.8	0.959	100	1	0	-22.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	22	-16	-8	0	-8	0.97	100	1	0	-16	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	23	-11.2	-4.8	0	-4.8	1	100	1	0	-11.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	24	-20.8	-0	0	0	0.992	100	1	0	-20.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	27	-113.6	-20.8	0	-20.8	0.968	100	1	0	-113.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	28	-27.2	-11.2	0	-11.2	0.962	100	1	0	-27.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	29	-38.4	-6.4	0	-6.4	0.963	100	1	0	-38.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	31	-68.8	-43.2	0	-43.2	0.967	100	1	0	-68.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	32	-94.4	-36.8	0	-36.8	0.964	100	1	0	-94.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	33	-36.8	-14.4	0	-14.4	0.972	100	1	0	-36.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	34	-94.4	-41.6	0	-41.6	0.986	100	1	0	-94.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	35	-52.8	-14.4	0	-14.4	0.981	100	1	0	-52.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	36	-49.6	-27.2	0	-27.2	0.98	100	1	0	-49.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	39	-43.2	-17.6	0	-17.6	0.97	100	1	0	-43.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	40	-105.6	-36.8	0	-36.8	0.97	100	1	0	-105.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	41	-59.2	-16	0	-16	0.967	100	1	0	-59.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	42	-153.6	-36.8	0	-36.8	0.985	100	1	0	-153.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	43	-28.8	-11.2	0	-11.2	0.978	100	1	0	-28.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	44	-25.6	-12.8	0	-12.8	0.985	100	1	0	-25.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	45	-84.8	-35.2	0	-35.2	0.987	100	1	0	-84.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	46	-44.8	-16	0	-16	1.005	100	1	0	-44.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	47	-54.4	-0	0	0	1.017	100	1	0	-54.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	48	-32	-17.6	0	-17.6	1.021	100	1	0	-32	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	49	-139.2	-48	0	-48	1.025	100	1	0	-139.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	50	-27.2	-6.4	0	-6.4	1.001	100	1	0	-27.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	51	-27.2	-12.8	0	-12.8	0.967	100	1	0	-27.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	52	-28.8	-8	0	-8	0.957	100	1	0	-28.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	53	-36.8	-17.6	0	-17.6	0.946	100	1	0	-36.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	54	-180.8	-51.2	0	-51.2	0.955	100	1	0	-180.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	55	-100.8	-35.2	0	-35.2	0.952	100	1	0	-100.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	56	-134.4	-28.8	0	-28.8	0.954	100	1	0	-134.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	57	-19.2	-4.8	0	-4.8	0.971	100	1	0	-19.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	58	-19.2	-4.8	0	-4.8	0.959	100	1	0	-19.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	59	-443.2	-180.8	0	-180.8	0.985	100	1	0	-443.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	60	-124.8	-4.8	0	-4.8	0.993	100	1	0	-124.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	62	-123.2	-22.4	0	-22.4	0.998	100	1	0	-123.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	66	-62.4	-28.8	0	-28.8	1.05	100	1	0	-62.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	67	-44.8	-11.2	0	-11.2	1.02	100	1	0	-44.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	70	-105.6	-32	0	-32	0.984	100	1	0	-105.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	72	-19.2	-0	0	0	0.98	100	1	0	-19.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	73	-9.6	-0	0	0	0.991	100	1	0	-9.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	74	-108.8	-43.2	0	-43.2	0.958	100	1	0	-108.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	75	-75.2	-17.6	0	-17.6	0.967	100	1	0	-75.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	76	-108.8	-57.6	0	-57.6	0.943	100	1	0	-108.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	77	-97.6	-44.8	0	-44.8	1.006	100	1	0	-97.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	78	-113.6	-41.6	0	-41.6	1.003	100	1	0	-113.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	79	-62.4	-51.2	0	-51.2	1.009	100	1	0	-62.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	80	-208	-41.6	0	-41.6	1.04	100	1	0	-208	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	82	-86.4	-43.2	0	-43.2	0.989	100	1	0	-86.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	83	-32	-16	0	-16	0.985	100	1	0	-32	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	84	-17.6	-11.2	0	-11.2	0.98	100	1	0	-17.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	85	-38.4	-24	0	-24	0.985	100	1	0	-38.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	86	-33.6	-16	0	-16	0.987	100	1	0	-33.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	88	-76.8	-16	0	-16	0.987	100	1	0	-76.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	90	-260.8	-67.2	0	-67.2	0.985	100	1	0	-260.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	91	-16	-0	0	0	0.98	100	1	0	-16	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	92	-104	-16	0	-16	0.993	100	1	0	-104	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	93	-19.2	-11.2	0	-11.2	0.987	100	1	0	-19.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	94	-48	-25.6	0	-25.6	0.991	100	1	0	-48	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	95	-67.2	-49.6	0	-49.6	0.981	100	1	0	-67.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	96	-60.8	-24	0	-24	0.993	100	1	0	-60.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	97	-24	-14.4	0	-14.4	1.011	100	1	0	-24	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	98	-54.4	-12.8	0	-12.8	1.024	100	1	0	-54.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	99	-67.2	-0	0	0	1.01	100	1	0	-67.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	100	-59.2	-28.8	0	-28.8	1.017	100	1	0	-59.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	101	-35.2	-24	0	-24	0.993	100	1	0	-35.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	102	-8	-4.8	0	-4.8	0.991	100	1	0	-8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	103	-36.8	-25.6	0	-25.6	1.001	100	1	0	-36.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	104	-60.8	-40	0	-40	0.971	100	1	0	-60.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	105	-49.6	-41.6	0	-41.6	0.965	100	1	0	-49.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	106	-68.8	-25.6	0	-25.6	0.962	100	1	0	-68.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	107	-80	-19.2	0	-19.2	0.952	100	1	0	-80	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	108	-3.2	-1.6	0	-1.6	0.967	100	1	0	-3.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	109	-12.8	-4.8	0	-4.8	0.967	100	1	0	-12.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	110	-62.4	-48	0	-48	0.973	100	1	0	-62.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	112	-108.8	-20.8	0	-20.8	0.975	100	1	0	-108.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	113	-9.6	-0	0	0	0.993	100	1	0	-9.6	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	114	-12.8	-4.8	0	-4.8	0.96	100	1	0	-12.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	115	-35.2	-11.2	0	-11.2	0.96	100	1	0	-35.2	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	116	-294.4	-0	0	0	1.005	100	1	0	-294.4	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	117	-32	-12.8	0	-12.8	0.974	100	1	0	-32	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
	118	-52.8	-24	0	-24	0.949	100	1	0	-52.8	0	0	0	0	0	0	Inf	Inf	Inf	Inf	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.0303	0.0999	0.0254	175	0	0	0	0	1	-360	360;
	1	3	0.0129	0.0424	0.01082	175	0	0	0	0	1	-360	360;
	4	5	0.00176	0.00798	0.0021	175	0	0	0	0	1	-360	360;
	3	5	0.0241	0.108	0.0284	175	0	0	0	0	1	-360	360;
	5	6	0.0119	0.054	0.01426	175	0	0	0	0	1	-360	360;
	6	7	0.00459	0.0208	0.0055	175	0	0	0	0	1	-360	360;
	8	9	0.0049	0.061	0.581	440	0	0	0	0	1	-360	360;%HD
	8	9	0.0049	0.061	0.581	440	0	0	0	0	1	-360	360;%HD
	8	5	0	0.0267	0	550	0	0	0.985	0	1	-360	360;%trafo
	9	10	0.0052	0.0644	0.615	440	0	0	0	0	1	-360	360;%HD
	9	10	0.0052	0.0644	0.615	440	0	0	0	0	1	-360	360;%HD
	4	11	0.0209	0.0688	0.01748	175	0	0	0	0	1	-360	360;
	5	11	0.0203	0.0682	0.01738	175	0	0	0	0	1	-360	360;
	11	12	0.00595	0.0196	0.00502	175	0	0	0	0	1	-360	360;
	2	12	0.0187	0.0616	0.01572	175	0	0	0	0	1	-360	360;
	3	12	0.0484	0.16	0.0406	175	0	0	0	0	1	-360	360;
	7	12	0.00862	0.034	0.00874	175	0	0	0	0	1	-360	360;
	11	13	0.02225	0.0731	0.01876	175	0	0	0	0	1	-360	360;
	12	14	0.0215	0.0707	0.01816	175	0	0	0	0	1	-360	360;
	13	15	0.0744	0.2444	0.06268	175	0	0	0	0	1	-360	360;
	14	15	0.0595	0.195	0.0502	175	0	0	0	0	1	-360	360;
	12	16	0.0212	0.0834	0.0214	175	0	0	0	0	1	-360	360;
	15	17	0.0264	0.0874	0.0222	175	0	0	0	0	1	-360	360;%Doub C
	15	17	0.0264	0.0874	0.0222	175	0	0	0	0	1	-360	360;%Doub C
	16	17	0.0454	0.1801	0.0466	175	0	0	0	0	1	-360	360;
	17	18	0.0123	0.0505	0.01298	175	0	0	0	0	1	-360	360;
	18	19	0.01119	0.0493	0.01142	175	0	0	0	0	1	-360	360;
	19	20	0.0252	0.117	0.0298	175	0	0	0	0	1	-360	360;
	15	19	0.012	0.0394	0.0101	175	0	0	0	0	1	-360	360;
	20	21	0.0183	0.0849	0.0216	175	0	0	0	0	1	-360	360;
	21	22	0.0209	0.097	0.0246	175	0	0	0	0	1	-360	360;
	22	23	0.0342	0.159	0.0404	175	0	0	0	0	1	-360	360;
	23	24	0.027	0.0984	0.0249	175	0	0	0	0	1	-360	360;%D circ
	23	24	0.027	0.0984	0.0249	175	0	0	0	0	1	-360	360;%D circ
	23	25	0.0312	0.16	0.0432	175	0	0	0	0	1	-360	360;%D circ
	23	25	0.0312	0.16	0.0432	175	0	0	0	0	1	-360	360;%D circ
	26	25	0	0.0382	0	200	0	0	0.96	0	1	-360	360;%trafo
	25	27	0.0636	0.326	0.0882	175	0	0	0	0	1	-360	360;%D circ
	25	27	0.0636	0.326	0.0882	175	0	0	0	0	1	-360	360;%D circ
	27	28	0.01913	0.0855	0.0216	175	0	0	0	0	1	-360	360;
	28	29	0.0237	0.0943	0.0238	175	0	0	0	0	1	-360	360;
	30	17	0	0.0388	0	300	0	0	0.96	0	1	-360	360;%trafo
	8	30	0.0086	0.1008	0.257	220	0	0	0	0	1	-360	360;%D circ
	8	30	0.0086	0.1008	0.257	220	0	0	0	0	1	-360	360;%D circ
	26	30	0.0160	0.172	0.454	220	0	0	0	0	1	-360	360;%D circ
	26	30	0.0160	0.172	0.454	220	0	0	0	0	1	-360	360;%D circ
	17	31	0.0474	0.1563	0.0399	175	0	0	0	0	1	-360	360;
	29	31	0.0108	0.0331	0.0083	175	0	0	0	0	1	-360	360;
	23	32	0.0634	0.2306	0.0587	175	0	0	0	0	1	-360	360;%D circ
	23	32	0.0634	0.2306	0.0587	175	0	0	0	0	1	-360	360;%D circ
	31	32	0.0298	0.0985	0.0251	175	0	0	0	0	1	-360	360;
	27	32	0.0229	0.0755	0.01926	175	0	0	0	0	1	-360	360;
	15	33	0.038	0.1244	0.03194	175	0	0	0	0	1	-360	360;
	19	34	0.0752	0.247	0.0632	175	0	0	0	0	1	-360	360;
	35	36	0.00224	0.0102	0.00268	175	0	0	0	0	1	-360	360;
	35	37	0.011	0.0497	0.01318	175	0	0	0	0	1	-360	360;
	33	37	0.0415	0.142	0.0366	175	0	0	0	0	1	-360	360;
	34	36	0.00871	0.0268	0.00568	175	0	0	0	0	1	-360	360;
	34	37	0.0051	0.0188	0.0049	175	0	0	0	0	1	-360	360;%D circ
	34	37	0.0051	0.0188	0.0049	175	0	0	0	0	1	-360	360;%D circ
	38	37	0	0.0375	0	350	0	0	0.935	0	1	-360	360;%trafo
	37	39	0.0321	0.106	0.027	175	0	0	0	0	1	-360	360;
	37	40	0.0593	0.168	0.042	175	0	0	0	0	1	-360	360;
	30	38	0.0093	0.108	0.211	220	0	0	0	0	1	-360	360;%D circ
	30	38	0.0093	0.108	0.211	220	0	0	0	0	1	-360	360;%D circ
	39	40	0.0184	0.0605	0.01552	175	0	0	0	0	1	-360	360;
	40	41	0.0145	0.0487	0.01222	175	0	0	0	0	1	-360	360;
	40	42	0.0555	0.183	0.0466	175	0	0	0	0	1	-360	360;
	41	42	0.041	0.135	0.0344	175	0	0	0	0	1	-360	360;
	43	44	0.0608	0.2454	0.06068	175	0	0	0	0	1	-360	360;
	34	43	0.0413	0.1681	0.04226	175	0	0	0	0	1	-360	360;
	44	45	0.0224	0.0901	0.0224	175	0	0	0	0	1	-360	360;
	45	46	0.04	0.1356	0.0332	175	0	0	0	0	1	-360	360;
	46	47	0.076	0.254	0.0158	175	0	0	0	0	1	-360	360;%D circ
	46	47	0.076	0.254	0.0158	175	0	0	0	0	1	-360	360;%D circ
	46	48	0.0601	0.189	0.0472	175	0	0	0	0	1	-360	360;
	47	49	0.0191	0.0625	0.01604	175	0	0	0	0	1	-360	360;
	42	49	0.0715	0.323	0.086	175	0	0	0	0	1	-360	360;
	42	49	0.0715	0.323	0.086	175	0	0	0	0	1	-360	360;
	45	49	0.0684	0.186	0.0444	175	0	0	0	0	1	-360	360;
	48	49	0.0179	0.0505	0.01258	175	0	0	0	0	1	-360	360;
	49	50	0.0267	0.0752	0.01874	175	0	0	0	0	1	-360	360;
	49	51	0.0486	0.137	0.0342	175	0	0	0	0	1	-360	360;
	51	52	0.0203	0.0588	0.01396	175	0	0	0	0	1	-360	360;
	52	53	0.0405	0.1635	0.04058	175	0	0	0	0	1	-360	360;
	53	54	0.0263	0.122	0.031	175	0	0	0	0	1	-360	360;
	49	54	0.073	0.289	0.0738	175	0	0	0	0	1	-360	360;
	49	54	0.0869	0.291	0.073	175	0	0	0	0	1	-360	360;
	54	55	0.0169	0.0707	0.0202	175	0	0	0	0	1	-360	360;
	54	56	0.0055	0.0191	0.0037	175	0	0	0	0	1	-360	360;%D circ
	54	56	0.0055	0.0191	0.0037	175	0	0	0	0	1	-360	360;%D circ
	55	56	0.00488	0.0151	0.00374	175	0	0	0	0	1	-360	360;
	56	57	0.0343	0.0966	0.0242	175	0	0	0	0	1	-360	360;
	50	57	0.0474	0.134	0.0332	175	0	0	0	0	1	-360	360;
	56	58	0.0343	0.0966	0.0242	175	0	0	0	0	1	-360	360;
	51	58	0.0255	0.0719	0.01788	175	0	0	0	0	1	-360	360;
	54	59	0.0503	0.2293	0.0598	175	0	0	0	0	1	-360	360;
	56	59	0.0825	0.251	0.0569	175	0	0	0	0	1	-360	360;
	56	59	0.0803	0.239	0.0536	175	0	0	0	0	1	-360	360;
	55	59	0.04739	0.2158	0.05646	175	0	0	0	0	1	-360	360;
	59	60	0.0317	0.145	0.0376	175	0	0	0	0	1	-360	360;
	59	61	0.0328	0.15	0.0388	175	0	0	0	0	1	-360	360;
	60	61	0.0053	0.027	0.0073	175	0	0	0	0	1	-360	360;%D circ
	60	61	0.0053	0.027	0.0073	175	0	0	0	0	1	-360	360;%D circ
	60	62	0.0123	0.0561	0.01468	175	0	0	0	0	1	-360	360;
	61	62	0.00824	0.0376	0.0098	175	0	0	0	0	1	-360	360;
	63	59	0	0.0386	0	400	0	0	0.96	0	1	-360	360;%trafo
	63	64	0.00344	0.04	0.108	220	0	0	0	0	1	-360	360;%H D circ
	63	64	0.00344	0.04	0.108	220	0	0	0	0	1	-360	360;%H D circ
	64	61	0	0.0268	0	200	0	0	0.985	0	1	-360	360;%trafo
	38	65	0.01802	0.1972	0.523	220	0	0	0	0	1	-360	360;%H D circ
	38	65	0.01802	0.1972	0.523	220	0	0	0	0	1	-360	360;%H D circ
	64	65	0.00538	0.0604	0.19	220	0	0	0	0	1	-360	360;%H D circ
	64	65	0.00538	0.0604	0.19	220	0	0	0	0	1	-360	360;%H D circ
	49	66	0.018	0.0919	0.0248	175	0	0	0	0	1	-360	360;
	49	66	0.018	0.0919	0.0248	175	0	0	0	0	1	-360	360;
	62	66	0.0482	0.218	0.0578	175	0	0	0	0	1	-360	360;
	62	67	0.0258	0.117	0.031	175	0	0	0	0	1	-360	360;
	65	66	0	0.037	0	200	0	0	0.935	0	1	-360	360;%trafo
	66	67	0.0224	0.1015	0.02682	175	0	0	0	0	1	-360	360;
	65	68	0.0028	0.032	0.319	440	0	0	0	0	1	-360	360;%HD
	65	68	0.0028	0.032	0.319	440	0	0	0	0	1	-360	360;%HD
	47	69	0.0844	0.2778	0.07092	175	0	0	0	0	1	-360	360;
	49	69	0.0985	0.324	0.0828	175	0	0	0	0	1	-360	360;
	68	69	0	0.037	0	350	0	0	0.935	0	1	-360	360;%trafo
	69	70	0.06	0.254	0.061	175	0	0	0	0	1	-360	360;%D circ
	69	70	0.06	0.254	0.061	175	0	0	0	0	1	-360	360;%D circ
	24	70	0.00221	0.4115	0.10198	175	0	0	0	0	1	-360	360;
	70	71	0.00882	0.0355	0.00878	175	0	0	0	0	1	-360	360;
	24	72	0.0488	0.196	0.0488	175	0	0	0	0	1	-360	360;
	71	72	0.0446	0.18	0.04444	175	0	0	0	0	1	-360	360;
	71	73	0.00866	0.0454	0.01178	175	0	0	0	0	1	-360	360;
	70	74	0.0401	0.1323	0.03368	175	0	0	0	0	1	-360	360;
	70	75	0.0428	0.141	0.036	175	0	0	0	0	1	-360	360;
	69	75	0.081	0.244	0.062	175	0	0	0	0	1	-360	360;%D circ
	69	75	0.081	0.244	0.062	175	0	0	0	0	1	-360	360;%D circ
	74	75	0.0123	0.0406	0.01034	175	0	0	0	0	1	-360	360;
	76	77	0.0444	0.148	0.0368	175	0	0	0	0	1	-360	360;
	69	77	0.0618	0.202	0.0519	175	0	0	0	0	1	-360	360;%D circ
	69	77	0.0618	0.202	0.0519	175	0	0	0	0	1	-360	360;%D circ
	75	77	0.0601	0.1999	0.04978	175	0	0	0	0	1	-360	360;
	77	78	0.0075	0.0248	0.0063	175	0	0	0	0	1	-360	360;%D circ
	77	78	0.0075	0.0248	0.0063	175	0	0	0	0	1	-360	360;%D circ
	78	79	0.00546	0.0244	0.00648	175	0	0	0	0	1	-360	360;
	77	80	0.017	0.0485	0.0472	175	0	0	0	0	1	-360	360;
	77	80	0.0294	0.105	0.0228	175	0	0	0	0	1	-360	360;
	79	80	0.0156	0.0704	0.0187	175	0	0	0	0	1	-360	360;
	68	81	0.0035	0.0404	0.404	440	0	0	0	0	1	-360	360;%HD
	68	81	0.0035	0.0404	0.404	440	0	0	0	0	1	-360	360;%HD
	81	80	0	0.037	0	300	0	0	0.935	0	1	-360	360;%Trafo
	77	82	0.0596	0.1706	0.0409	175	0	0	0	0	1	-360	360;%D circ
	77	82	0.0596	0.1706	0.0409	175	0	0	0	0	1	-360	360;%D circ
	82	83	0.0224	0.0733	0.019	175	0	0	0	0	1	-360	360;%D circ
	82	83	0.0224	0.0733	0.019	175	0	0	0	0	1	-360	360;%D circ
	83	84	0.0625	0.132	0.0258	175	0	0	0	0	1	-360	360;
	83	85	0.043	0.148	0.0348	175	0	0	0	0	1	-360	360;
	84	85	0.0302	0.0641	0.01234	175	0	0	0	0	1	-360	360;
	85	86	0.035	0.123	0.0276	175	0	0	0	0	1	-360	360;
	86	87	0.02828	0.2074	0.0445	200	0	0	0	0	1	-360	360;%161Kv
	85	88	0.02	0.102	0.0276	175	0	0	0	0	1	-360	360;
	85	89	0.0239	0.173	0.047	175	0	0	0	0	1	-360	360;
	88	89	0.0139	0.0712	0.01934	175	0	0	0	0	1	-360	360;
	89	90	0.0518	0.188	0.0528	175	0	0	0	0	1	-360	360;
	89	90	0.0238	0.0997	0.106	175	0	0	0	0	1	-360	360;
	90	91	0.0254	0.0836	0.0214	175	0	0	0	0	1	-360	360;
	89	92	0.0099	0.0505	0.0548	175	0	0	0	0	1	-360	360;
	89	92	0.0393	0.1581	0.0414	175	0	0	0	0	1	-360	360;
	91	92	0.0387	0.1272	0.03268	175	0	0	0	0	1	-360	360;
	92	93	0.0258	0.0848	0.0218	175	0	0	0	0	1	-360	360;
	92	94	0.0481	0.158	0.0406	175	0	0	0	0	1	-360	360;
	93	94	0.0223	0.0732	0.01876	175	0	0	0	0	1	-360	360;
	94	95	0.0132	0.0434	0.0111	175	0	0	0	0	1	-360	360;
	80	96	0.0356	0.182	0.0494	175	0	0	0	0	1	-360	360;
	82	96	0.0324	0.106	0.0272	175	0	0	0	0	1	-360	360;%D circ
	82	96	0.0324	0.106	0.0272	175	0	0	0	0	1	-360	360;%D circ
	94	96	0.0269	0.0869	0.023	175	0	0	0	0	1	-360	360;
	80	97	0.0183	0.0934	0.0254	175	0	0	0	0	1	-360	360;
	80	98	0.0238	0.108	0.0286	175	0	0	0	0	1	-360	360;
	80	99	0.0454	0.206	0.0546	175	0	0	0	0	1	-360	360;
	92	100	0.0648	0.295	0.0472	175	0	0	0	0	1	-360	360;
	94	100	0.0356	0.116	0.0302	175	0	0	0	0	1	-360	360;%D circ
	94	100	0.0356	0.116	0.0302	175	0	0	0	0	1	-360	360;%D circ
	95	96	0.0171	0.0547	0.01474	175	0	0	0	0	1	-360	360;
	96	97	0.0173	0.0885	0.024	175	0	0	0	0	1	-360	360;
	98	100	0.0397	0.179	0.0476	175	0	0	0	0	1	-360	360;
	99	100	0.018	0.0813	0.0216	175	0	0	0	0	1	-360	360;
	100	101	0.0277	0.1262	0.0328	175	0	0	0	0	1	-360	360;
	92	102	0.0123	0.0559	0.01464	175	0	0	0	0	1	-360	360;
	101	102	0.0246	0.112	0.0294	175	0	0	0	0	1	-360	360;
	100	103	0.032	0.105	0.0268	175	0	0	0	0	1	-360	360;%D circ
	100	103	0.032	0.105	0.0268	175	0	0	0	0	1	-360	360;%D circ
	100	104	0.0451	0.204	0.0541	175	0	0	0	0	1	-360	360;
	103	104	0.0466	0.1584	0.0407	175	0	0	0	0	1	-360	360;
	103	105	0.0535	0.1625	0.0408	175	0	0	0	0	1	-360	360;
	100	106	0.0605	0.229	0.062	175	0	0	0	0	1	-360	360;
	104	105	0.00994	0.0378	0.00986	175	0	0	0	0	1	-360	360;
	105	106	0.014	0.0547	0.01434	175	0	0	0	0	1	-360	360;
	105	107	0.053	0.183	0.0472	175	0	0	0	0	1	-360	360;
	105	108	0.0261	0.0703	0.01844	175	0	0	0	0	1	-360	360;
	106	107	0.053	0.183	0.0472	175	0	0	0	0	1	-360	360;
	108	109	0.0105	0.0288	0.0076	175	0	0	0	0	1	-360	360;
	103	110	0.03906	0.1813	0.0461	175	0	0	0	0	1	-360	360;
	109	110	0.0278	0.0762	0.0202	175	0	0	0	0	1	-360	360;
	110	111	0.022	0.0755	0.02	175	0	0	0	0	1	-360	360;
	110	112	0.0494	0.128	0.031	175	0	0	0	0	1	-360	360;%D circ
	110	112	0.0494	0.128	0.031	175	0	0	0	0	1	-360	360;%D circ
	17	113	0.00913	0.0301	0.00768	175	0	0	0	0	1	-360	360;
	32	113	0.0615	0.203	0.0518	175	0	0	0	0	1	-360	360;
	32	114	0.0135	0.0612	0.01628	175	0	0	0	0	1	-360	360;
	27	115	0.0164	0.0741	0.01972	175	0	0	0	0	1	-360	360;
	114	115	0.0023	0.0104	0.00276	175	0	0	0	0	1	-360	360;
	68	116	0.0007	0.0081	0.082	440	0	0	0	0	1	-360	360;%HD
	68	116	0.0007	0.0081	0.082	440	0	0	0	0	1	-360	360;%HD
	12	117	0.0329	0.14	0.0358	175	0	0	0	0	1	-360	360;
	75	118	0.0145	0.0481	0.01198	175	0	0	0	0	1	-360	360;
	76	118	0.0164	0.0544	0.01356	175	0	0	0	0	1	-360	360;
];

%%-----  OPF Data  -----%%
%% area data
%	area	refbus
mpc.areas = [%load
	1	15; %90+j30
	2	27; %71+j13
	3	59; %277+j 113
	4	116;% 184+j0
];

%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
% 	2	0	0	2	 35.39 	0	0	0	0	0;	%
% 	2	0	0	2	 31.45 	0	0	0	0	0;	%
	2	3768.0637	0	2	54.5042968	201.517299 ;
	2	5890.16	0	2	28.4	300	;
	2	16000	0	2	5.36	10600	;
	2	13472.5903	0	2	36.85	70	;
% 	2	0	0	2	 45.58 	0	0	0	0	0;	%
% 	2	0	0	2	 213.32 	0	0	0	0	0;	%
% 	2	0	0	2	 62.15 	0	0	0	0	0;	%
	2	5525.136	0	2	26.64	300	;
	2	15523.6608	0	2	26.64	800	;
	2	18891.5056	0	2	26.64	1100	;
	2	9453.292	0	2	45.58	500	;
% 	2	0	0	2	 31.77 	0	0	0	0	0;	%
% 	2	0	0	2	 37.34 	0	0	0	0	0;	%
% 	2	0	0	2	 212.03 	0	0	0	0	0;	%
% 	2	0	0	2	 329.73 	0	0	0	0	0;	%
	2	7744.316	0	2	37.34	400	;
	2	6925.086	0	2	33.39	300	;
	2	8154.03333	0	2	33.39	400	;
	2	7920.31781	0	2	25.87	800	;
	2	7920.31781	0	2	25.87	800	;
	2	794.910575	0	2	53.21	200	;
% 	2	0	0	2	 2.00 	0	0	0	0	0;	%
% 	2	0	0	2	 612.62 	0	0	0	0	0;	%
	2	12844.3698	0	2	26.57	700	;
	2	15611.778	0	2	31.77	800	;
	2	7176.04	0	2	34.6	100	;
	2	1264.41817	0	2	54.0247237	200.957507;
	2	1266.54957	0	2	54.1157919	200.964889;
	2	1250.48726	0	2	53.3369868	200.157613;
	2	1268.92417	0	2	54.1233759	200.970593;
	2	1870.73023	0	2	53.8423592	200.957167;
	2	1852.14817	0	2	53.3075404	200.485376;
% 	2	0	0	2	 1.29 	0	0	0	0	0;	%
	2	5068.856	0	2	24.44	250	;
	2	4979.674	0	2	24.01	250	;
% 	2	0	0	2	 25.87 	0	0	0	0	0;	%
	2	3774.35956	0	2	54.595365	201.236283 ;
	2	3720.51816	0	2	53.8165599	200.701464 ;
	2	40189.2311	0	2	45.66	300	;
% 	2	0	0	2	 66.19 	0	0	0	0	0;	%
	2	6501.7237	0	2	30.21	320	;
	2	1685.16827	0	2	53.4884982	200.80028;
	2	1693.62376	0	2	53.7568815	200.141886;
	2	6240.666	0	2	30.09	300	;
	2	6012.526	0	2	28.99	1000	;
% 	2	0	0	2	 215.89 	0	0	0	0	0;	%
	2	0	0	2	1.29	0	;
	2	18206.8332	0	2	28.99	1000	;
	2	0	0	2	2	0	;
	2	0	0	2	2	0	;
% 	2	0	0	2	 1.29 	0	0	0	0	0;	%
	2	0	0	2	1.29	0	;
	2	0	0	2	1.29	0	;
	2	9230.1179	0	2	33.39	500	;
% 	2	0	0	2	 59.82 	0	0	0	0	0;	%
	2	6402.438	0	2	30.87	300	;
	2	5525.136	0	2	26.64	300	;
  % wind units
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
	2	0	0	2	0	0	;
  % storage units
  %1   0   0   3   -200   2    0    0    200    2;
  %1   0   0   3   -200   2    0    0    200    2;
	%2	0	0	2	0.0	 0.0	0    0      0    0;
	%2	0	0	2	0.0	 0.0	0    0      0    0;
%	2	0	0	2	0	0	;
%	2	0	0	2	0	0	;
%	2	0	0	2	0	0	;
%	2	0	0	2	0	0	;
	% dispatchable loads
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
	2	0	0	2	10000	0	;
];

%% generator fuel type
mpc.genfuel = {
% 	    'syncgen'	;
% 	    'syncgen'	;
	'ng';% changed from syncgen
	'coal';
	'nuke'; % from coal
	'coal';
% 	    'syncgen'	;
% 	    'oil'	;
% 	    'syncgen'	;
	'coal';
	'coal';
	'coal';
	'coal';
% 	    'syncgen'	;
% 	    'syncgen'	;
% 	    'syncgen'	;
% 	    'syncgen'	;
	'coal';
	'coal';
	'coal';
	'coal';
	'coal';
	'ng';
% 	    'syncgen'	;
% 	    'syncgen'	;
	'ngcc';% changed from coal
	'ngcc';% changed from coal
	'ngcc';
	'ng';% changed from coal
	'ng';% changed from coal
	'ng';% changed from coal
	'ng';% changed from coal
	'ng';% changed from coal
	'ng';% changed from coal
% 	    'syncgen'	;
	'coal';
	'coal';
% 	    'syncgen'	;
	'ng';% changed from syncgen
	'ng';% changed from syncgen
	'coal';
% 	    'syncgen'	;
	'coal';
	'ng';% changed from coal
	'ng';% changed from coal
	'coal';
	'coal';
% 	    'oil'	;
	'hydro';
	'coal';
	'hydro';
	'hydro';
% 	    'syncgen'	;
	'hydro';
	'hydro';
	'coal';
% 	    'syncgen'	;
	'coal';
	'coal';
  % from here on, wind units
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
	'wind';
%	'ess';
%	'ess';
%	'ess';
%	'ess';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
  'na';
};

%% bus names
mpc.bus_name = {
	'RIVERSIDE';
	'POKAGON';
	'HICKORY CREEK';
	'NEW CARLISLE';
	'OLIVE';
	'KANKAKEE';
	'JACKSON RD';
	'OLIVE';
	'BEQUINE';
	'BREEDER';
	'BEND';
	'TWIN BRANCH';
	'CONCORD';
	'GOSHEN JT';
	'FORT WAYNE';
	'NORTH END';
	'SORENSON SUB FORT WAYNE';
	'MCKINLEY AVE FORT WAYNE';
	'LINCOLN';
	'ADAMS';
	'JAY';
	'RANDOLPH';
	'COLLEGE CORNER';
	'TRENTON';
	'TANNERS CREEK';
	'TANNERS CREEK';
	'MADISON';
	'MULLIN';
	'GRANT';
	'SORENSON SUB FORT WAYNE';
	'DEER CREEK';
	'DELAWARE';
	'HAVILAND';
	'ROCK HILL';
	'WEST LIMA';
	'STERLING';
	'EAST LIMA';
	'EAST LIMA';
	'NEW LIBERTY';
	'WEST END';
	'SOUTH TIFFIN';
	'HOWARD';
	'SOUTH KENTON';
	'WEST MOUNT VERNON';
	'NORTH NEWARK';
	'WEST LANCASTER';
	'CROOKSVILLE';
	'ZANESVILLE';
	'PHILO';
	'WEST CAMBRIDGE';
	'NEW COMERSTOWN';
	'SOUTH COSHOCTON';
	'WOOSTER';
	'TORREY';
	'WAGENHALS';
	'SUNNYSIDE';
	'WEST NEW PHILADELPHIA';
	'WEST NEW PHILADELPHIA 2';
	'TIDD';
	'SOUTH WEST KAMMER';
	'KAMMER';
	'NATRIUM';
	'TIDD';
	'KAMMER';
	'MUSKINGUM';
	'MUSKINGUM';
	'SUMMERFIELD';
	'PHILIP SPORN';
	'PHILIP SPORN';
	'PORTSMOUTH';
	'NORTH PORTSMOUTH';
	'HILLSBORO';
	'SARGENTS';
	'BELLEFONTE';
	'SOUTH POINT';
	'DARRAH';
	'TURNER';
	'CHEMICAL';
	'CAPITOL HILL';
	'CABIN CREEK';
	'KANAWHA';
	'LOGAN';
	'SPRIGG';
	'BETSY LAYNE';
	'BEAVER CREEK';
	'HAZZARD';
	'PINEVILLE';
	'FREMONT';
	'CLINCH RIVER';
	'HOLSTON';
	'HOLSTON T';
	'SALTVILLE';
	'TAZEWELL';
	'SWITCHBACK';
	'CALDWELL';
	'BAILEYSVILLE';
	'SUNDIAL';
	'BRADLEY';
	'HINTON';
	'GLEN LYN';
	'WYTHE';
	'SMYTHE';
	'CLAYTOR';
	'HANCOCK';
	'ROANOKE';
	'CLOVERDALE';
	'REUSENS';
	'BLAINE';
	'FRANKLIN';
	'FIELDALE';
	'DAN RIVER';
	'DANVILLE';
	'DEER CREEK';
	'WEST MEDFORD';
	'MEDFORD';
	'KYGER CREEK';
	'COREY';
	'WEST HUNTINGTON';
};

icoal = [];
ioil = [];
ing = [];
ingcc = [];
ihydro = [];
inuke = [];
iwind = [];
iess = [];
isyncgen = [];
ilo = [];
for i = 1:length(mpc.genfuel)
  if strcmp('coal', mpc.genfuel{i})
    icoal = [ icoal; i];
  elseif strcmp('oil', mpc.genfuel{i})
    ioil = [ ioil; i];
  elseif strcmp('hydro', mpc.genfuel{i})
    ihydro = [ ihydro; i];
  elseif strcmp('ng', mpc.genfuel{i})
    ing = [ ing; i];
  elseif strcmp('ngcc', mpc.genfuel{i})
    ingcc = [ ingcc; i];
  elseif strcmp('nuke', mpc.genfuel{i})
    inuke = [ inuke; i];
  elseif strcmp('wind', mpc.genfuel{i})
    iwind = [ iwind; i];
  elseif strcmp('ess', mpc.genfuel{i})
    iess = [ iess; i];
  elseif strcmp('syncgen', mpc.genfuel{i})
    isyncgen = [ isyncgen; i];
  elseif strcmp('na', mpc.genfuel{i})
    ilo = [ilo; i];    
  else
    error('unrecognized fuel type')
  end
end
mpc.icoal = icoal;
mpc.ioil = ioil;
mpc.ing = ing;
mpc.ingcc = ingcc;
mpc.ihydro = ihydro;
mpc.inuke = inuke;
mpc.iwind = iwind;
mpc.iess = iess;
mpc.isyncgen = isyncgen;
mpc.ilo = ilo;

define_constants;
mpc.NamePlateWind = mpc.gen(iwind, PMAX);

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

% Warnings from cdf2matp conversion:
%
% ***** area data conversion not yet implemented (creating dummy area data)
% ***** negative Pg at bus 4 treated as Pd
% ***** negative Pg at bus 8 treated as Pd
% ***** negative Pg at bus 24 treated as Pd
% ***** negative Pg at bus 27 treated as Pd
% ***** negative Pg at bus 40 treated as Pd
% ***** negative Pg at bus 42 treated as Pd
% ***** negative Pg at bus 72 treated as Pd
% ***** negative Pg at bus 73 treated as Pd
% ***** negative Pg at bus 90 treated as Pd
% ***** negative Pg at bus 91 treated as Pd
% ***** negative Pg at bus 99 treated as Pd
% ***** negative Pg at bus 107 treated as Pd
% ***** negative Pg at bus 112 treated as Pd
% ***** negative Pg at bus 113 treated as Pd
% ***** negative Pg at bus 116 treated as Pd
% ***** Insufficient generation, setting Pmax at slack bus (bus 69) to 805.2
% ***** MVA limit of branch 1 - 2 not given, set to 9900
% ***** MVA limit of branch 1 - 3 not given, set to 9900
% ***** MVA limit of branch 4 - 5 not given, set to 9900
% ***** MVA limit of branch 3 - 5 not given, set to 9900
% ***** MVA limit of branch 5 - 6 not given, set to 9900
% ***** MVA limit of branch 6 - 7 not given, set to 9900
% ***** MVA limit of branch 8 - 9 not given, set to 9900
% ***** MVA limit of branch 8 - 5 not given, set to 9900
% ***** MVA limit of branch 9 - 10 not given, set to 9900
% ***** MVA limit of branch 4 - 11 not given, set to 9900
% ***** MVA limit of branch 5 - 11 not given, set to 9900
% ***** MVA limit of branch 11 - 12 not given, set to 9900
% ***** MVA limit of branch 2 - 12 not given, set to 9900
% ***** MVA limit of branch 3 - 12 not given, set to 9900
% ***** MVA limit of branch 7 - 12 not given, set to 9900
% ***** MVA limit of branch 11 - 13 not given, set to 9900
% ***** MVA limit of branch 12 - 14 not given, set to 9900
% ***** MVA limit of branch 13 - 15 not given, set to 9900
% ***** MVA limit of branch 14 - 15 not given, set to 9900
% ***** MVA limit of branch 12 - 16 not given, set to 9900
% ***** MVA limit of branch 15 - 17 not given, set to 9900
% ***** MVA limit of branch 16 - 17 not given, set to 9900
% ***** MVA limit of branch 17 - 18 not given, set to 9900
% ***** MVA limit of branch 18 - 19 not given, set to 9900
% ***** MVA limit of branch 19 - 20 not given, set to 9900
% ***** MVA limit of branch 15 - 19 not given, set to 9900
% ***** MVA limit of branch 20 - 21 not given, set to 9900
% ***** MVA limit of branch 21 - 22 not given, set to 9900
% ***** MVA limit of branch 22 - 23 not given, set to 9900
% ***** MVA limit of branch 23 - 24 not given, set to 9900
% ***** MVA limit of branch 23 - 25 not given, set to 9900
% ***** MVA limit of branch 26 - 25 not given, set to 9900
% ***** MVA limit of branch 25 - 27 not given, set to 9900
% ***** MVA limit of branch 27 - 28 not given, set to 9900
% ***** MVA limit of branch 28 - 29 not given, set to 9900
% ***** MVA limit of branch 30 - 17 not given, set to 9900
% ***** MVA limit of branch 8 - 30 not given, set to 9900
% ***** MVA limit of branch 26 - 30 not given, set to 9900
% ***** MVA limit of branch 17 - 31 not given, set to 9900
% ***** MVA limit of branch 29 - 31 not given, set to 9900
% ***** MVA limit of branch 23 - 32 not given, set to 9900
% ***** MVA limit of branch 31 - 32 not given, set to 9900
% ***** MVA limit of branch 27 - 32 not given, set to 9900
% ***** MVA limit of branch 15 - 33 not given, set to 9900
% ***** MVA limit of branch 19 - 34 not given, set to 9900
% ***** MVA limit of branch 35 - 36 not given, set to 9900
% ***** MVA limit of branch 35 - 37 not given, set to 9900
% ***** MVA limit of branch 33 - 37 not given, set to 9900
% ***** MVA limit of branch 34 - 36 not given, set to 9900
% ***** MVA limit of branch 34 - 37 not given, set to 9900
% ***** MVA limit of branch 38 - 37 not given, set to 9900
% ***** MVA limit of branch 37 - 39 not given, set to 9900
% ***** MVA limit of branch 37 - 40 not given, set to 9900
% ***** MVA limit of branch 30 - 38 not given, set to 9900
% ***** MVA limit of branch 39 - 40 not given, set to 9900
% ***** MVA limit of branch 40 - 41 not given, set to 9900
% ***** MVA limit of branch 40 - 42 not given, set to 9900
% ***** MVA limit of branch 41 - 42 not given, set to 9900
% ***** MVA limit of branch 43 - 44 not given, set to 9900
% ***** MVA limit of branch 34 - 43 not given, set to 9900
% ***** MVA limit of branch 44 - 45 not given, set to 9900
% ***** MVA limit of branch 45 - 46 not given, set to 9900
% ***** MVA limit of branch 46 - 47 not given, set to 9900
% ***** MVA limit of branch 46 - 48 not given, set to 9900
% ***** MVA limit of branch 47 - 49 not given, set to 9900
% ***** MVA limit of branch 42 - 49 not given, set to 9900
% ***** MVA limit of branch 42 - 49 not given, set to 9900
% ***** MVA limit of branch 45 - 49 not given, set to 9900
% ***** MVA limit of branch 48 - 49 not given, set to 9900
% ***** MVA limit of branch 49 - 50 not given, set to 9900
% ***** MVA limit of branch 49 - 51 not given, set to 9900
% ***** MVA limit of branch 51 - 52 not given, set to 9900
% ***** MVA limit of branch 52 - 53 not given, set to 9900
% ***** MVA limit of branch 53 - 54 not given, set to 9900
% ***** MVA limit of branch 49 - 54 not given, set to 9900
% ***** MVA limit of branch 49 - 54 not given, set to 9900
% ***** MVA limit of branch 54 - 55 not given, set to 9900
% ***** MVA limit of branch 54 - 56 not given, set to 9900
% ***** MVA limit of branch 55 - 56 not given, set to 9900
% ***** MVA limit of branch 56 - 57 not given, set to 9900
% ***** MVA limit of branch 50 - 57 not given, set to 9900
% ***** MVA limit of branch 56 - 58 not given, set to 9900
% ***** MVA limit of branch 51 - 58 not given, set to 9900
% ***** MVA limit of branch 54 - 59 not given, set to 9900
% ***** MVA limit of branch 56 - 59 not given, set to 9900
% ***** MVA limit of branch 56 - 59 not given, set to 9900
% ***** MVA limit of branch 55 - 59 not given, set to 9900
% ***** MVA limit of branch 59 - 60 not given, set to 9900
% ***** MVA limit of branch 59 - 61 not given, set to 9900
% ***** MVA limit of branch 60 - 61 not given, set to 9900
% ***** MVA limit of branch 60 - 62 not given, set to 9900
% ***** MVA limit of branch 61 - 62 not given, set to 9900
% ***** MVA limit of branch 63 - 59 not given, set to 9900
% ***** MVA limit of branch 63 - 64 not given, set to 9900
% ***** MVA limit of branch 64 - 61 not given, set to 9900
% ***** MVA limit of branch 38 - 65 not given, set to 9900
% ***** MVA limit of branch 64 - 65 not given, set to 9900
% ***** MVA limit of branch 49 - 66 not given, set to 9900
% ***** MVA limit of branch 49 - 66 not given, set to 9900
% ***** MVA limit of branch 62 - 66 not given, set to 9900
% ***** MVA limit of branch 62 - 67 not given, set to 9900
% ***** MVA limit of branch 65 - 66 not given, set to 9900
% ***** MVA limit of branch 66 - 67 not given, set to 9900
% ***** MVA limit of branch 65 - 68 not given, set to 9900
% ***** MVA limit of branch 47 - 69 not given, set to 9900
% ***** MVA limit of branch 49 - 69 not given, set to 9900
% ***** MVA limit of branch 68 - 69 not given, set to 9900
% ***** MVA limit of branch 69 - 70 not given, set to 9900
% ***** MVA limit of branch 24 - 70 not given, set to 9900
% ***** MVA limit of branch 70 - 71 not given, set to 9900
% ***** MVA limit of branch 24 - 72 not given, set to 9900
% ***** MVA limit of branch 71 - 72 not given, set to 9900
% ***** MVA limit of branch 71 - 73 not given, set to 9900
% ***** MVA limit of branch 70 - 74 not given, set to 9900
% ***** MVA limit of branch 70 - 75 not given, set to 9900
% ***** MVA limit of branch 69 - 75 not given, set to 9900
% ***** MVA limit of branch 74 - 75 not given, set to 9900
% ***** MVA limit of branch 76 - 77 not given, set to 9900
% ***** MVA limit of branch 69 - 77 not given, set to 9900
% ***** MVA limit of branch 75 - 77 not given, set to 9900
% ***** MVA limit of branch 77 - 78 not given, set to 9900
% ***** MVA limit of branch 78 - 79 not given, set to 9900
% ***** MVA limit of branch 77 - 80 not given, set to 9900
% ***** MVA limit of branch 77 - 80 not given, set to 9900
% ***** MVA limit of branch 79 - 80 not given, set to 9900
% ***** MVA limit of branch 68 - 81 not given, set to 9900
% ***** MVA limit of branch 81 - 80 not given, set to 9900
% ***** MVA limit of branch 77 - 82 not given, set to 9900
% ***** MVA limit of branch 82 - 83 not given, set to 9900
% ***** MVA limit of branch 83 - 84 not given, set to 9900
% ***** MVA limit of branch 83 - 85 not given, set to 9900
% ***** MVA limit of branch 84 - 85 not given, set to 9900
% ***** MVA limit of branch 85 - 86 not given, set to 9900
% ***** MVA limit of branch 86 - 87 not given, set to 9900
% ***** MVA limit of branch 85 - 88 not given, set to 9900
% ***** MVA limit of branch 85 - 89 not given, set to 9900
% ***** MVA limit of branch 88 - 89 not given, set to 9900
% ***** MVA limit of branch 89 - 90 not given, set to 9900
% ***** MVA limit of branch 89 - 90 not given, set to 9900
% ***** MVA limit of branch 90 - 91 not given, set to 9900
% ***** MVA limit of branch 89 - 92 not given, set to 9900
% ***** MVA limit of branch 89 - 92 not given, set to 9900
% ***** MVA limit of branch 91 - 92 not given, set to 9900
% ***** MVA limit of branch 92 - 93 not given, set to 9900
% ***** MVA limit of branch 92 - 94 not given, set to 9900
% ***** MVA limit of branch 93 - 94 not given, set to 9900
% ***** MVA limit of branch 94 - 95 not given, set to 9900
% ***** MVA limit of branch 80 - 96 not given, set to 9900
% ***** MVA limit of branch 82 - 96 not given, set to 9900
% ***** MVA limit of branch 94 - 96 not given, set to 9900
% ***** MVA limit of branch 80 - 97 not given, set to 9900
% ***** MVA limit of branch 80 - 98 not given, set to 9900
% ***** MVA limit of branch 80 - 99 not given, set to 9900
% ***** MVA limit of branch 92 - 100 not given, set to 9900
% ***** MVA limit of branch 94 - 100 not given, set to 9900
% ***** MVA limit of branch 95 - 96 not given, set to 9900
% ***** MVA limit of branch 96 - 97 not given, set to 9900
% ***** MVA limit of branch 98 - 100 not given, set to 9900
% ***** MVA limit of branch 99 - 100 not given, set to 9900
% ***** MVA limit of branch 100 - 101 not given, set to 9900
% ***** MVA limit of branch 92 - 102 not given, set to 9900
% ***** MVA limit of branch 101 - 102 not given, set to 9900
% ***** MVA limit of branch 100 - 103 not given, set to 9900
% ***** MVA limit of branch 100 - 104 not given, set to 9900
% ***** MVA limit of branch 103 - 104 not given, set to 9900
% ***** MVA limit of branch 103 - 105 not given, set to 9900
% ***** MVA limit of branch 100 - 106 not given, set to 9900
% ***** MVA limit of branch 104 - 105 not given, set to 9900
% ***** MVA limit of branch 105 - 106 not given, set to 9900
% ***** MVA limit of branch 105 - 107 not given, set to 9900
% ***** MVA limit of branch 105 - 108 not given, set to 9900
% ***** MVA limit of branch 106 - 107 not given, set to 9900
% ***** MVA limit of branch 108 - 109 not given, set to 9900
% ***** MVA limit of branch 103 - 110 not given, set to 9900
% ***** MVA limit of branch 109 - 110 not given, set to 9900
% ***** MVA limit of branch 110 - 111 not given, set to 9900
% ***** MVA limit of branch 110 - 112 not given, set to 9900
% ***** MVA limit of branch 17 - 113 not given, set to 9900
% ***** MVA limit of branch 32 - 113 not given, set to 9900
% ***** MVA limit of branch 32 - 114 not given, set to 9900
% ***** MVA limit of branch 27 - 115 not given, set to 9900
% ***** MVA limit of branch 114 - 115 not given, set to 9900
% ***** MVA limit of branch 68 - 116 not given, set to 9900
% ***** MVA limit of branch 12 - 117 not given, set to 9900
% ***** MVA limit of branch 75 - 118 not given, set to 9900
% ***** MVA limit of branch 76 - 118 not given, set to 9900
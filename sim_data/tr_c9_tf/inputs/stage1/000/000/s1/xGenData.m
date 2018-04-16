function xgd_table = xgendatagr0(gen, inp)
%MYXGENDATA Data file for extra per-generator data for MPSOPF.
%   XGD_TABLE = MYXGENDATA
%   XGD_TABLE = MYXGENDATA(GEN)
%   XGD_TABLE = MYXGENDATA(MPC)
%     INP       :     Specification of parameters for offers
%       .res    :     scalar, determining the proportion of pmax available for reserves
%
%   This file returns extra generator data in the standard
%   xGenData table format described in LOADXGENDATA. May optionally
%   require a corresponding GEN matrix or MATPOWER case struct (MPC)
%   as input.
%   Assumptions:
%   - Initial Pg extracted from mpc
%   - Loads are not reserve constrained
%   - no wear-and-tear costs
%   - contingency prices differentiated for generators and non-gens
%   - inc and dec prices differentiated for generators and non-gens
%   - PositiveLoadFollowReserveQuantity and negative for gens proportinal to PMAX.
%   - PositiveActiveReservePrice, negative set to a low number close to  0
%   - load follow reserve prices determined by fuel type
%   - load follow reserve quantities determined by fuel type
%
% 2015.04.15
% Alberto J. Lamadrid

%%-----  SET THESE FLAGS IF YOUR DATA USES GEN or GENCOST  -----
needs_gen       = 1;
needs_gencost   = 0;
epsfact = 1e-3;                     % factor to differentiate positive and negative reserves

%%-----  initialization and arg checking (DO NOT CHANGE)  -----
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;
if nargin > 0
    if isstruct(gen)
      mpc     = gen;
      gen     = mpc.gen;
      gencost = mpc.gencost;
    end
    if nargin<2
      inp.res = 2;                  % pmax available for reserves
    end
end
if needs_gen && nargin == 0
    error('Construction of this XGENDATA requires GEN or MPC as input.');
end
if needs_gencost && (nargin == 0 || ~exist('gencost', 'var'))
    error('Construction of this XGENDATA requires MPC (with GENCOST) as input.');
end

%%----- constants (values and indices) -----
pcap = gen(:, PMAX);                % capacity installed
idxpg = 1;                          % index for InitialPg
idxwtcol = 2;                       % index for wear-and-tear (ramping) costs
idxresp = 3;                        % index for PositiveActiveReservePrice
idxresn = 5;                        % index for NegativeActiveReservePrice
idxrescol = [4, 10];                % index for reserve quantities to be set proportional to capacity, positive
idxrescoln = [6, 12];               % index for reserve quantities to be set proportional to capacity, negative
idxrdp = 7;                         % index for PositiveActiveDeltaPrice
idxrdn = 8;                         % index for NegativeActiveDeltaPrice
idxlfp = 9;                         % index for PositiveLoadFollowReservePrice 
idxlfn = 11;                        % index for NegativeLoadFollowReservePrice

%%-----  determination of fuel types -----
bl = [mpc.ihydro;                   % slow ramping units (baseload)
    mpc.inuke;];
sl = [mpc.icoal];                   % mid ramping units (shoulder)
pl = [mpc.ing];                     % fast ramping units (peaking)

%%-----  wear-and-tear (ramping) costs -----
rpraw = zeros(size(mpc.gen, 1), 1); % no wear-and-tear (ramp) costs

%%-----  contingency reserve prices -----
crespf = 5;                         % price for PositiveActiveReservePrice, NegativeActiveReservePrice, gens
cresp = 0.001;                      % price for PositiveActiveReservePrice, NegativeActiveReservePrice, not gens
crpr = ones(size(mpc.gen, 1), 1)*cresp;
crpr([pl], 1) = crespf;             % price for positive reserves
crpr([sl], 1) = crespf;             % price for positive reserves
crpr([bl], 1) = crespf;             % price for positive reserves
crnr = crpr + epsfact;              % price for negative reserves

%%-----  inc and dec prices -----
pdpg = 0.001;                       % price for PositiveActiveDeltaPrice, NegativeActiveDeltaPrice, gens
pdpa = 0.001;                       % price for PositiveActiveReservePrice, NegativeActiveReservePrice, not gens
pdpr = ones(size(mpc.gen, 1), 1)*pdpa;
pdpr([bl; sl; pl], 1) = pdpg;       % price for positive delta
pdnr = pdpr + epsfact;              % price for negative delta

%%-----  load follow reserve prices  -----
plfpg = 0.001;
lfraw = ones(size(mpc.gen, 1), 1)*plfpg;
lfraw(bl, 1) = 3;
lfraw(sl, 1) = 2;
lfraw(pl, 1) = 1;

%%-----  THE DATA  -----
xgd_table.colnames = {
	'InitialPg', ...
		'RampWearCostCoeff', ...
			'PositiveActiveReservePrice', ...
				'PositiveActiveReserveQuantity', ...
					'NegativeActiveReservePrice', ...
						'NegativeActiveReserveQuantity', ...
							'PositiveActiveDeltaPrice', ...
								'NegativeActiveDeltaPrice', ...
									'PositiveLoadFollowReservePrice', ...
										'PositiveLoadFollowReserveQuantity', ...
											'NegativeLoadFollowReservePrice', ...
												'NegativeLoadFollowReserveQuantity', ...
};

xgd_table.data = ones(size(gen, 1), 1)*[
  %0	0	0.001	100	0.002	100	0.001	0.002	0.001	100	0.002	100;
	0	0	cresp	100	cresp+epsfact	100	pdpg	pdpg+epsfact	cresp	100	cresp+epsfact	100;
];

%%-----  initialPg  -----
xgd_table.data(:, idxpg) = gen(:, PG);

%%-----  wear-and-tear (ramping) costs  -----
xgd_table.data(:, idxwtcol) = rpraw;

%%-----  contingency prices  -----
xgd_table.data(:, idxresp) = crpr;
xgd_table.data(:, idxresn) = crnr;

%%-----  inc and dec prices  -----
xgd_table.data(:, idxrdp) = pdpg;
xgd_table.data(:, idxrdn) = pdnr;

%%-----  load follow reserve prices  -----
xgd_table.data(:, idxlfp) = lfraw;
xgd_table.data(:, idxlfn) = lfraw + epsfact;

%%-----  contingency and load follow reserve quantities  -----
xgd_table.data(:, idxrescol)...       % assign reserves proportional to capacity installed
  = max(0, pcap*inp.res*ones(1, size(idxrescol, 2)));
xgd_table.data(:, idxrescoln)...      % add small noise to negative variables
  = max(0, pcap*inp.res*ones(1, size(idxrescol, 2))) + epsfact;
il = isload(gen);                     % determine loads
xgd_table.data(il, [idxrescol, ...
  idxrescoln]) = Inf;                 % set reserves to Inf for loads
function wind = createwind(mpci, inp)
%WIND = CREATEWIND(MPCI, INP)
% Creates structure for new wind units, based on location provided and installed capacity (PMAX)
%
% Inputs
%   MPCI      :     Initial casefile in general form (could be name, structure, or the file)
%   INP       :     Specification of placement of wind units, capacities
%     .busgw  :     [nw x 1] vector with bus locations
%     .wp_max :     [nw x 1] vector wiht PMAX, consistent with .busgw
%     .ramp   :     scalar, determining the proportion of pmax available for ramp
%     .res    :     scalar, determining the proportion of pmax available for reserves
%     .wfn    :     flag, indicates if cost will be nasty
%     .npcc   :     flag, indicates whether the input struct has the fields from npcc
% Outputs
%   WIND      :     WindUnitData structure with the following fields
%     .gen    :     rows to be appended to the GEN matrix from MPC
%     .gencost:     rows to be added to the GENCOST matrix
%                   from MPC, default is zero cost
%     .xgd_table
%              :    xGenData table struct or filename providing data for
%                   the wind units being added. See LOADXGENDATA for
%                   more information on the xGenData table format.
%                   The default information and fields are as follows
%          1	 'InitialPg', ...	0
%          2	'RampWearCostCoeff', ...	0
%          3	'PositiveActiveReservePrice', ...	0.0001
%          4	'PositiveActiveReserveQuantity', ... 	inp.wp_max * inp.res
%          5	'NegativeActiveReservePrice', ...	0.0002
%          6	 'NegativeActiveReserveQuantity', ...	inp.wp_max * inp.res
%          7	'PositiveActiveDeltaPrice', ...	0
%          8	'NegativeActiveDeltaPrice', ...	0
%          9	'PositiveLoadFollowReservePrice', ...	0
%          10	'PositiveLoadFollowReserveQuantity', ...	inp.wp_max * inp.ramp
%          11	'NegativeLoadFollowReservePrice', ...	0
%          12	 'NegativeLoadFollowReserveQuantity', ...	inp.wp_max * inp.ramp
%       .genfuel
%               : optional, add info on genfuels (verify)
%
% Assumptions:
% 1- If input is not provided, return error messages
% 2- The new wind generators created do not have a capability curve
% 3- If the input provied for wind is empty, return empty wind struct
%
% Changes in creation of generators: (vs. hist. runs 2011-2012)
% 1- Instead of copying from an existing generator, all wind generators are created from scratch
% 2- Ramping capability is set to a multiple of the maximum power capacity (default, 5 x pmax)
% 3- The cost of generation is set to zero, unless inp.wfn is set to 1. 
%     In such case, the cost of generation is set to -1,500
% 4- Reserves (Contingency and load follow) quantities are set to a multiple of 
%     the maximum power capacity (default, 2 x pmax) 
%
% Future enhancements: 
% 1- create canned output if input is not provided
% 2- revise the npcc output assignment
%
% Ray's comments
% x pass two vectors
% x load generic data (use loadcase, delete upper parts)
% x document wind gen info and reserves.
% x Set reserves according to pmax
%
% 2013.05.03
% Alberto J. Lamadrid

%   MOST Paper Simulations
%   Copyright (c) 2013-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

mpc0 = loadcase(mpci);

if nargin<2
  error('Parameter information missing');
  if nargin <1
    error('Case information missing');  
  end  
end

if ~isfield(inp, 'ramp')
  inp.ramp = 4;
end
if ~isfield(inp, 'res')
  inp.res = 2;
end
if size(inp.busgw, 1)<1             % no creation of inputs
  wind = [];
  return
end

idxrescol = [4, 6];                 % index of reserve variables to be set proportional to capacity
idxrpcol = [10, 12];                % index of load follow variables to be set proportional to capacity

[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, ...
        PMAX, PMIN, MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, ...
        PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, ...
        RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;

ng0 = size(mpc0.gen, 1);            % original number of generators
nw0 = size(inp.busgw, 1);           % number of wind units
newgen = zeros(nw0, size(mpc0.gen, 2));
newgenc =  zeros(nw0, size(mpc0.gencost, 2));
pcap = inp.wp_max;                  % max power capacity
newgen(:,VG) = 1;
newgen(:, MBASE) = 100;
newgen(:, GEN_STATUS) = 1;
newgen(:, GEN_BUS)  = inp.busgw;
newgen(:, [PG PMAX]) = pcap * ...   % add initial values for PG, PMAX
  ones(1, 2);
newgen(:, PMIN)  = 0;
newgen(:, [RAMP_AGC, ...            % assign ramp limits
    RAMP_10, RAMP_30]) = (pcap * inp.ramp) * ones(1, 3) ;
newgen(:, RAMP_Q) = Inf;
newgenc(:, MODEL)   = POLYNOMIAL;
if inp.wfn
  newgenc(:, NCOST)   = 2;
  newgenc(:, COST)    = -1500;
else
  newgenc(:, NCOST)   = 1;
end
%if isfield(inp, 'npcc')
%    if inp.npcc
%        genfuel = cell(size(inp.busgw, 1), 1);
%        genfuel(:, 1) = {'wind'};
%        genname = cell(size(inp.busgw, 1), 1);
%        genname(:, 1) = {'wind Unit'};
%        genrto = mpc0.busrto(inp.busgw);
%        mpc0.genfuel = [mpc0.genfuel; genfuel];
%        mpc0.genname = [mpc0.genname; genname];
%        mpc0.genrto = [mpc0.genrto; genrto];
%    else
%        genfuel = cell(size(inp.busgw, 1), 1);
%        genfuel(:, 1) = {'wind'};
%        if ~isfield(mpc0, 'genfuel') || isempty(mpc0.genfuel)
%            mpc0.genfuel = cell(ng0, 1);
%        end
%        mpc0.genfuel = [mpc0.genfuel; genfuel];
%    end
%else
%    genfuel = cell(size(inp.busgw, 1), 1);
%    genfuel(:, 1) = {'wind'};
%    if ~isfield(mpc0, 'genfuel') || isempty(mpc0.genfuel)
%        mpc0.genfuel = cell(ng0, 1);
%    end
%    mpc0.genfuel = [mpc0.genfuel; genfuel];
%end

wind.gen = newgen;
wind.gencost = newgenc;

%% xGenData
wind.xgd_table.colnames = {
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

wind.xgd_table.data = ones(nw0, 1)* [
	1	0	0.001	1	0.002	1	0.001	0.002	0.001	1	0.002	1;
];

wind.xgd_table.data(:, idxrescol)...% assign contingency reserves proportional to capacity installed
  = pcap*inp.res*ones(1, size(idxrescol, 2));
wind.xgd_table.data(:, idxrpcol)... % assign load follow reserves proportional to capacity installed
  = pcap*inp.ramp*ones(1, size(idxrpcol, 2));
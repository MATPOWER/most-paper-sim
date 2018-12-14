function [CRPPOS, QRPPOS, CRPNEG, QRPNEG, DCPPOS, DCPNEG, CRPPOS2, ...
    CRPNEG2, DCPPOS2, DCPNEG2, PCMIN, PCMAX] = idx_rof
%IDX_DISP   Defines constants for named column indices to reserve offer matrix.
%   [CRPPOS, QRPPOS, CRPNEG, QRPNEG, DCPPOS, DCPNEG, CRPPOS2, ...
%   CRPNEG2, DCPPOS2, DCPNEG2, PCMIN, PCMAX] = idx_rof
%
%   The index, name and meaning of each column of the reserve offer matrix is given
%   below:
% 
%   columns 1-6
%   1  CRPPOS       Cost of positive reserves ($)
%   2  QRPPOS       Quantity of positive reserves
%   3  CRPNEG       Cost of negative reserves ($)
%   4  QRPNEG       Quantity of negative reserves
%   5  DCPPOS       Positive Delta price (incs)
%   6  DCPNEG       Negative delta price (decs)
% 2014.04.12
% Alberto J. Lamadrid

%   MOST Paper Simulations
%   Copyright (c) 2014-2018 by Alberto J. Lamadrid
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

%% define the indices for  power information
CRPPOS  = 1;        % Cost of positive reserves ($)
QRPPOS  = 2;        % Quantity of positive reserves
CRPNEG  = 3;        % Cost of negative reserves ($)
QRPNEG  = 4;        % Quantity of negative reserves
DCPPOS  = 5;        % Positive Delta price
DCPNEG  = 6;        % Negative delta price
CRPPOS2 = 7;        % Cost of positive reserves ($)
CRPNEG2 = 8;        % Cost of negative reserves ($)
DCPPOS2 = 9;        % Positive Delta price
DCPNEG2 = 10;       % Negative delta price
PCMIN   = 11;       % Lower bound on Pc
PCMAX   = 12;       % Upper bound on Pc
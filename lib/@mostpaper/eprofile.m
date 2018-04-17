function eprof = eprofile(TransMat, profile, contabi, alph)
% eprof = eprofile(transmat, profile, contabi, alph)
% Calculates the expected value of a profile. Returns a profile file with expected values
%
% Inputs
%     TRANSMAT  :     Transition probability matrix
%     PROFILE   :     Profile with different realizations
%     CONTABI   :     Contingency matrix to be discounted from transmat
%                       - if  single matrix, the same probability adjustment 
%                         is applied to all periods
%                       - if array, needs to be consistent with the number 
%                         of periods in profile 
%     ALPH      :     Fraction of period spent in base case before contingency
%                     begins
% 
%
% Assumptions
% - The contingency matrix adjusts the probabilities in the transition probability 
%   matrix, discounting the values to be used
% - The final calculation includes the probability of reaching a given state
% - current version assumes a master contab used for all scenarios and time periods
% - current version assumes that the number of scenarios is the same for all periods of time
% - alpha changes the probabilities for contingencies CostWeightsAdj vs CostWeights. Sums are the same
% - parameter named alph to avoid conflicts with:
%   /Applications/MATLAB_R2013b.app/toolbox/matlab/graph3d/alpha.m
% 
% Future Enhancements
% - Verify alpha correction - time of occurrence of contingency (current preliminary code in place)
%
% 2013.12.04
% Alberto J. Lamadrid

define_constants;
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;

%% default inputs
if nargin < 4
  alph = 0;
%elseif alph ~= 0
%  error('eprofile: non-zero value for alpha not yet implemented');
end
if nargin < 3
  contabi = [];
  SecurityConstrained = 0;
else
  SecurityConstrained = 1;
end  


val     = profile.values;

switch profile.type
  case 'mpcData'
%    nt = size(val, 1);
    nt = size(TransMat, 2);
    nj_max = size(val, 2);
    otherwise
      error('eprofile: profile.type must be ''mpcData''');
end

nj = nj_max;                        % number of scenarios

ctprob = zeros(nt, nj_max);         % vector with contab probabilities
tprob = zeros(nt, 1);               % probability of reaching a given time period
type = {'array'};
if iscell(contabi) | isstruct(contabi)
  error('eprofile: cell or struct format for contingencies not yet implemented');
end
contab0 = loadgenericdata(contabi, type);

if (~iscell(contabi)) && (~isempty(contabi))
  [tr, idc] = unique(contab0(:, CT_LABEL));
  for t = 1:nt
    ctprob(t, :) = sum(contab0(idc, CT_PROB));
  end
end
njt = nj_max *ones(nt, 1);          % number scenarios in period t

t = 1;
for t = 1:nt
  % First get current step's scenario probabilities
  if t == 1
    scenario_probs = TransMat{1}; % the probability of the initial state is 1
  else
    scenario_probs = TransMat{t} * CostWeights(1, 1:njt(t-1), t-1)'; % otherwise compute from previous step base cases
  end
  StepProb(t) = sum(scenario_probs); % probability of making it to the t-th step
  if SecurityConstrained && ~isempty(contab0)
    for j = 1:njt(t)
      [tmp, ii] = sort(contab0(:, CT_LABEL)); %sort in ascending contingency label
      contab = contab0(ii, :);
      rowdecomlist = ones(size(contab,1), 1);
%      for l = 1:size(contab, 1)
%        if contab(l, CT_TABLE) == CT_TGEN  && contab(l, CT_COL) == GEN_STATUS ...
%            && contab(l, CT_CHGTYPE) == CT_REP && contab(l, CT_NEWVAL) == 0 ... % gen turned off
%            && Istr.flow(t,j,1).mpc.gen(contab(l, CT_ROW), GEN_STATUS) <= 0   % but it was off on input
%         rowdecomlist(l) = 0;
%        elseif contab(l, CT_TABLE) == CT_TBRCH && contab(l, CT_COL) == BR_STATUS ...
%            && contab(l, CT_CHGTYPE) == CT_REP && contab(l, CT_NEWVAL) == 0... % branch taken out
%            && Istr.flow(t,j,1).mpc.branch(contab(l, CT_ROW), BR_STATUS) <= 0  % but it was off on input
%          rowdecomlist(l) = 0;
%        end
%      end
      contab = contab(rowdecomlist ~= 0, :);
%      Istr.cont(t, j).contab = contab;
      clist = unique(contab(:, CT_LABEL));
      nc(t, j) = length(clist);
      k = 2;
      for label = clist'
%        Istr.flow(t, j, k).mpc = apply_contingency(label, Istr.flow(t, j, 1).mpc, contab);
        ii = find( label == contab(:, CT_LABEL) );
        CostWeights(k, j, t) = contab(ii(1), CT_PROB);
%        Istr.idx.nb(t, j, k) = size(Istr.flow(t, j, k).mpc.bus, 1);
%        Istr.idx.ny(t, j, k) = length(find(Istr.flow(t, j, 1).mpc.gencost(:, MODEL) == PW_LINEAR));
        k = k + 1;
      end
      CostWeights(1, j, t) = 1 - sum(CostWeights(2:nc(t,j)+1, j, t));
      CostWeights(1:nc(t,j)+1, j, t) = scenario_probs(j) * CostWeights(1:nc(t,j)+1, j, t);
    end
  else
    for j = 1:njt(t)
      nc(t, j) = 0;
      CostWeights(1, j, t) = scenario_probs(j);
    end
  end
end

% Compute adjusted (for alph) cost weights for objective function
if SecurityConstrained && alph ~= 0
  for t = 1:nt
    for j = 1:njt(t)
      CostWeightsAdj(1, j, t) = CostWeights(1, j, t);
      for k = 2:nc(t,j)+1
        CostWeightsAdj(k, j, t) = (1-alph) * CostWeights(k, j, t);
        CostWeightsAdj(1, j, t) = CostWeightsAdj(1, j, t) + alph * CostWeights(k, j, t);
      end
    end
  end
else
  CostWeightsAdj = CostWeights;
end

% create matrix nj x nt
CostWeightsAdjSum = squeeze(sum(CostWeightsAdj, 1));

valo = zeros(nt, 1, length(profile.rows));  % output values

for t = 1:nt
  for i = 1:length(profile.rows)
    valo(t, :, i)=   val(t, :, i) * CostWeightsAdjSum(:, t);
  end
end

eprof = struct( ...
  'type', profile.type, ...
  'table', profile.table, ...
  'rows', profile.rows, ...
  'col', profile.col, ...
  'chgtype', profile.chgtype, ...
  'values', [] );
eprof.values = valo;
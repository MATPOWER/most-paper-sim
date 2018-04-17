% Define selected contingencies
function contab = contabt9(mpc)
% CONTABt9      Defines the contingencies to be considered in the mpsopf
%               for the 9-bus system.
% 
% Created by Daniel Muñoz-Alvarez (9/30/2012)

define_constants;

if nargin<1
  mpc = loadcase('case9d');
end

[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;

% Include here idx of lines to be considered as contingencies.
l_cont = [...
            8,...
            ];

% Indicate buses of generators to be considered as contingencies.
% If 2 or more generators are located at the same bus, the first one listed
% at the gen table is the one to be included as a contingency.
g_cont_bus = [...
              1,
              ];

g_cont = zeros(1,length(g_cont_bus));

for k = 1:length(g_cont_bus)
    g_cont(1,k) = find(mpc.gen(:,GEN_BUS)==g_cont_bus(k),1,'first');
    if g_cont(1,k) == []
        error('define_contingencies: the indicated contingent generator was not found at the bus given in g_cont_bus')
    end
end


%% Contingency table

contab = [];
label = 0;

for c = 1:length(l_cont)
    label = label + 1;
    contab = [contab ;...
%       label   probty  type        row         column      chgtype newvalue
        label   0.002   CT_TBRCH    l_cont(c)   BR_STATUS   CT_REP  0  ...
              ];
end

for c = 1:length(g_cont)
    label = label + 1;
    contab = [contab ;...
%       label   probty  type        row         column      chgtype newvalue
        label   0.002   CT_TGEN     g_cont(c)   GEN_STATUS  CT_REP  0  ...
              ];
end
          
          
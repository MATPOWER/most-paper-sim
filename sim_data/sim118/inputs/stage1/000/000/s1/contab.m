% Define selected contingencies
function contab = contab118V1(mpc)

define_constants;

[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;


% Potential change for indicating lines with FBUS and TBUS.
l_cont = [...
            42,...  % between buses 30 and 17: row 42 in c118swf case is still row 42 in c118et2 case
            64,...  % between buses 30 and 38: row 62 in c118swf case becomes row 64 in c118et2 case (although this line has been split in 2)
            13,...  % between buses  5 and 11: row 13 in c118swf case is still row 13 in c118et2 case
            ];

g_cont = [...
              3, ...    % at bus 10: row 3 in c118swf case is still row 3 in c118et2 case
              18, ...   % CORRECTED -- at bus 65: row 17 in c118swf case becomes row 18 in c118et2 case (although this gen has been split in 2)
              29, ...   % CORRECTED -- at bus 89: row 26 in c118swf case becomes row 29 in c118et2 case (although this gen has been split in 2)
              27, ...   % CORRECTED -- at bus 80: row 24 in c118swf case becomes row 27 in c118et2 case
              ];
          
% Contingency of gen at bus 65 yields more dispatch changes in the rest of
% the generators, while contingency of gen at bus 80 implies the loss of a
% large amount of generation and reserves, although it does not cause more
% dispatch changes that the first described contingency. The interesting
% part of the second contingency is the fact that a considerable amount of
% reserves are lost when that generator is lost.



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
          
          
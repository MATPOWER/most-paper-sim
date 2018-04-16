function mpco = mpsetfs2(mpsd, r1, r2, t, modct)
% function mpco = mpsetfs2(mpsd, r1, r2, t, modct)
% Sets up information for each trajectory in the second stage run, fixed reserves
% This file sets up information for each one of the individuals second stage runs
% This includes:
% 1- Set up case conditions for the case (net load, committed gens, and last period schedule)
% 2- Set limits according to contracted fixed reserves in first stage
% 3- Apply operating conditions e.g. contracts
%
% Inputs
%     MPSD      :     Casefile used in frist stage
%     R1        :     Structure with first stage results
%     R2        :     Structure with second stage results
%     T         :     Time period considered
%     MODC(T)   :     Modifications and scaling to be applied for case file for period t (from profiles), contab form
%     S2RESREDUCTIONFACTOR: Reduction factor for second stage
%
% Outputs
%     MPCO      :     Casefile modified with restrictions for second stage
%
% Assumptions
% (ig = conventional generators, il = demands, iw = wind units)
% - first stage results are provided
% - CommitSched are saved as a field in mpc, but do not play a role (check this)
% - The offers are taken from mpsd.offer(t)
% - The run is deterministic, calculating expecting winds and loads
%
% Functions required
% - adj_res_fix
%
% Pending: 
% - replace all mpci for mpco
% - replace all Ostr for r1

% 2013.11.10
% Daniel Munoz
% Alberto J. Lamadrid

define_constants;
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, ...
    CT_TAREABUS, CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, ...
    CT_REP, CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, ...
    CT_LOAD_ALL_PQ, CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, ...
    CT_LOAD_FIX_P, CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, ...
    CT_MODCOST_F, CT_MODCOST_X] = idx_ct;
    
%%----- set basic info including commitment -----
mpco = r1.mpc;
if r1.UC.CommitKey
  mpco.gen(:, GEN_STATUS) = r1.UC.CommitSched(:, t);
end
ng = size(mpco.gen, 1);
nt = mpsd.idx.nt;
js = 1;                             % scenario from which contab table will be taken

%%----- set offers for run -----
roffer = [
  mpsd.offer(t).PositiveActiveReservePrice,...
  mpsd.offer(t).PositiveActiveReserveQuantity,...
  mpsd.offer(t).NegativeActiveReservePrice,...
  mpsd.offer(t).NegativeActiveReserveQuantity,...
  mpsd.offer(t).PositiveActiveDeltaPrice,...
  mpsd.offer(t).NegativeActiveDeltaPrice
];
mpco = offer2mpc(mpco, roffer);

%%----- set modifications from profile -----
mpco = apply_contingency(0, mpco, modct);

%%----- create constraints for generators and demands -----
% Compute s2 generation ranges for all generators except wind and
% dispatchable loads (ess units not yet supported).

if t > 1
  j = 1;
  Pactual_prior = r2.results{t-1, j}.gen(:, PG);
else
  Pactual_prior = r1.InitialPg;
end
RampLimit = r1.flow(t,1,1).mpc.gen(:, RAMP_30)*2*r1.Delta_T;
r1.Delta_T
ig = ~isload(mpco.gen) & ~iswind(mpco.gen, mpco.iwind);

mpco.gen(ig, PMAX)   = min(mpco.gen(ig, PMAX),...
                               Pactual_prior(ig) + RampLimit(ig));
                           
mpco.gen(ig, PMIN)   = max(mpco.gen(ig, PMIN),...
                               Pactual_prior(ig) - RampLimit(ig));

if any(mpco.gen(ig, PMAX)-mpco.gen(ig, PMIN)< 0)
    unfeas = find(mpco.gen(ig, PMAX)-mpco.gen(ig, PMIN) < 0);
    if any(mpco.gen(unfeas, PMAX)-mpco.gen(unfeas, PMIN) < -0.1)
        mpco.gen(unfeas, PMIN) = mpco.gen(unfeas, PMAX);
        warning('%i significantly-unfeasible second-stage (conventional) generation range(s) was (were) modified to be feasible.',size(unfeas,1))
    else
        mpco.gen(unfeas, PMIN) = mpco.gen(unfeas, PMAX);
        warning('%i acceptably-unfeasible second-stage (conventional) generation range(s)  was (were) modified to be feasible.',size(unfeas,1));
    end
end

%%----- Fix contracts obtained from s1 -----
% mpco.gen(ig, PG)   = r1.results.Pc(ig, t); % 2015.06.11, Ray says not necessary
%mpco.reserves = r1.FixedReserves(t,1,1);        % NOT up-to-date with MOST
mpco.reserves = r1.flow(t,1,1).mpc.reserves;
% mpco = adj_res_fix(r1, t, mpco, s2ResReductionFactor);

%%----- No contingencies added in the fixed reserves version -----
mpco.contab = [];
mpco.UC.CommitKey = [];            % second stage does not run UC
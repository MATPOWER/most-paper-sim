function doplots_hpdcf(mpsd, savedvars, optp)
%FUNCTION DOPLOTS_HPDC(SAVEFILE)
% Creates ALL plots from horizon planning problem
% This function REQUIRES that hp_revenuedc is run first, as it takes the 
% database there created. The prerequisite information is mostly economic
%
% Inputs
%   mpsd      :     results from s1 run
%   savedvars :     name of dataset where variables from data_mpsd are saved
%   optp      :     options for run, include
%     savepath      ('') location of files
%     profiles      ('') Information on profiles to extract wind data
%     savefile      ('data-cx_fs') name provided to save databases
%     
%
% Outputs
% All plots are saved in folder 'SAVEFILE-PLOTS'
%   SAVEFILE_PLOTS
%             :     .MAT database with information used for plots 
%                   The following groups of variables are part of the dataset
%                   - parameters: thresholds used for plotting purposes
%                   - variables information, mostly 2d tables plotted, 
%                     (e.g lamP, nodal prices)
%
% There are internal flags to determine which plots to create
% LOADPLOTS   :     Set to 1 for creating load plots
% OPT.INITIALR:     Set in file wrapper, creates plots for iterative setup of
%                   initial conditions (convergence)
% Possible changes:
% look at loadgenericdata (pass any struct or filename to load struct), load ostr
% return structure (do not save by default, maybe...)
% save additional data that is generated
% Check comments in data_mpsd
%
% Future Changes
% After design discussions, check with Ray/Carlos what the optimal plot function should be
% suggested name:
% mps_doplots
% - eliminate dependencies on data - e.g. profiles information to extract wind information. can this information be inferred from mpsd?
% - maybe create many independent files for plots (a la plot_storage), and a main calling file
% 
% 2014.01.10
% modified 2014.07.21
% Alberto J. Lamadrid

if nargin < 3
  mpsd = input('base results?\n');
  savedvars = input('Name of data set with save variables?\n');
  optp.savepath = '';
  optp.profiles = [];
  optp.savefile = 'data-cx_fs';
end
if isempty(optp.savepath)
  optp.savepath = '.';
end

saveit = 1;
shed_threshold = 1e-3;
flow_threshold = 5e-1;
v_threshold = 1e-3;
muS_threshold = 10;
muVmin_threshold = 80;
var_threshold = 0;                                  % variance threshold for generators
loadplots = 0;                                      % set to 0 if not interested in load plots

%% load the data
if isstr(savedvars)
  load(savedvars);
else
  mpsd = savedvars;
end

optg = 1;                                           % set to 1 if use these values

%% define named indices into bus, gen, branch matrices
define_constants;
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;

% SELECT HERE IF ALL ESS UNITS WILL BE PLOTTED, DEFAULT IS ASSIGN IE (ALL ESS UNITS)
idess = ie;
% SELECT HERE IF ALL WIND UNITS WILL BE PLOTTED, DEFAULT IS ASSIGN IW (ALL WIND UNITS)
idwind = iw;
% SELECT HERE IF ALL GEN UNITS WILL BE PLOTTED, DEFAULT IS ASSIGN GENS WITH CHANGES IN PC, GMAX AND GMIN
idp = find(var(Pc, 0, 2) > var_threshold);
idg1 = find(var(GG, 0, 2) > var_threshold);
idg2 = find(var(GGm, 0, 2) > var_threshold);
idp1 = union(idp, idg1);
idp2 = union(idp1, idg2);
idp3 = intersect(idp2, ig);
idp4 = intersect(idp2, il);

% PENDING add Pc for each scenario as a dotted line? MAYBE NOT GOOD INFO

idgen = idp3;
idload = idp4;

%basedir = sprintf('%s%s%s', optp.savepath, filesep, optp.savefile);
basedir = sprintf('%s%s', optp.savepath, optp.savefile);
trange = 1:nt;
tranger = 1:nt-1;

% trange = [nt-5:nt, 1:nt-6];             % rearrange time index
% tranger = [nt-6:nt-1, 1:nt-7];          % rearrange time index

% Create directory to put plots
if ~exist(basedir, 'dir')
    mkdir(basedir);
end

fn_prefix = sprintf('%s/', basedir);

clabels = {
    'Base', ...
	'case 1', ...
	'case 2', ...
	'case 3', ...
	'case 4', ...
	'case 5', ...
	'case 6', ...
	'case 7', ...
	'case 8', ...
	'case 9', ...
};

my_xlabel = 'Hour';
cm = 'copper';
cm = 'hot';
cm = 'jet';

Markers= ['o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*','o','x','^','<','h','.','>','p','s','d','v',...
'o','x','+','*','s','d','v','^','<','>','p','h','.', ...
'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*', 'o','x','+','*','s','d','v','^','<','>','p','h','.'];

limnames = 279;
[Names, ~] = regexp(num2str(1:limnames), '  ', 'split', 'match');

if ~exist('Istr')
  Istr = mpsd;
  OstrDCC = mpsd;
  ref.ess = ie;
  ref.wind = iw;
  profiles = optp.profiles;
  gen = mpsd.mpc.gen;
end

if ~exist('ld')                             % security net for labels, assumes loadprof exists
  fact = 1:nt;
  ld = zeros(size(fact'));
  ld (:, 1) = fact';
%  ld(:, 2) = loadprof;                     % security net, new setup, commented out
else
  fact = ld(:,1,1);
  if fact(1) ==0
    fact = fact+1;
  end
end

if ~isfield(Istr.mpc, 'genfuel')            % security net for fuel types, leave them empty
  Istr.mpc.genfuel = cell(ng, 1);
end

sc = 1;
[tr, lsp] = unique(Istr.mpc.gen(ig, ...
        GEN_BUS));                          % unique nodal prices
lampn = squeeze(lamP(ig, :, sc, 1));        % plot nodal prices over generators
figure;
hold ('all');
for j = 1:size(lsp, 1)
    plot(fact, lampn(lsp(j), trange), ['-' Markers(j)], 'LineWidth', 1);
end
hold ('off');
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Nodal Prices observed\n', sc), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Price, $/MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(Names(1:nb), 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) - (v(1, 1) + v(1, 1))/10-.5, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3)+(v(1, 4)+v(1, 3))/35, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('nodal-prices-gens.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;


%% Information for ESS units

if size(ref.ess, 1)>0                       % do these plots only if ess units are available in the system

% Combined plots for power and reserves
for ed = 1:size(idess, 1)
    k = idess(ed);
    b = gen(idess(ed), GEN_BUS);
    figure;
    % plot power information 
    subplot(2, 1, 1, 'align');
    plot(fact, Pc(idess(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idess(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idess(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idess(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idess(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idess(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idess(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc <2
            scatter(fact, squeeze(Pg(idess(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idess(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end    
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, ESS @ bus %d, Gen %d\n', b, k), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    % plot reserves information
    subplot(2, 1, 2, 'align');
    plot(fact, Rpp(idess(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idess(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idess(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idess(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserves and Ramp reserves, ESS @ bus %d, Gen %d\n', b, k), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'R. Up', 'R. Down', 'Rp Up', 'Rp Dwn'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    %% Saving information
    
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 11 8]);
    if saveit
        pdf_name = sprintf('ESSpowerRES-gen%d.pdf', idess(ed));
%        eval(['print -dpdf ' fn_prefix pdf_name]);
      print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Power plots
for ed = 1:size(idess, 1)
    k = idess(ed);
    b = gen(idess(ed), GEN_BUS);
    figure;
    plot(fact, Pc(idess(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idess(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idess(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idess(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idess(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idess(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idess(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc <2
            scatter(fact, squeeze(Pg(idess(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idess(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end    
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, ESS @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('ESSpower-gen%d.pdf', idess(ed));
%        eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Reserve Plots
for ed = 1:size(idess, 1)
    k = idess(ed);
    b = gen(idess(ed), GEN_BUS);
    figure;
    plot(fact, Rpp(idess(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idess(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idess(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idess(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserves and Ramp reserves, ESS @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Res Up', 'Res Down', 'Ramp Up', 'Ramp Down'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('ESSreserve-gen%d.pdf', idess(ed));
%        eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);  
    end
    close;   
end

% Energy plots
for ed = 1:size(idess, 1)
    k = idess(ed);
    b = gen(idess(ed), GEN_BUS);     
    figure;     % Corrected to have the Initial storage (first and last periods should correspond)
    if fact(1) == 0
      fact1 = [fact, fact(end)+1];
    else
      fact1 = [0, fact];
    end
    plot(fact1, [OstrDCC.Storage.InitialStorage(ed), eStorSt(ed, trange)], 'k', 'LineWidth', 2);
    hold on;
    plot(fact1, mstorl(ed, [trange(1), trange]), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact1, Mstorl(ed, [trange(1), trange]), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact1, [OstrDCC.Storage.InitialStorage(ed), Sp(ed, trange)], '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact1, [OstrDCC.Storage.InitialStorage(ed), Sm(ed, trange)], '-.ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact1(1) fact1(end)];
   	axis(v);
    title(sprintf('Real Energy Available, ESS @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Energy at end of period, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Expected Storage Level', 'Min Stor. L', 'Max Stor. L', 'S+', 'S-'}; 
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact1')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('ESSenergy-gen%d.pdf', idess(ed));
%        eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

end

%% Generation plots
% Combined plots for power and reserves
for ed = 1:size(idgen, 1)
    k = idgen(ed);
    b = gen(idgen(ed), GEN_BUS);
    figure;
    % plot power information 
    subplot(2, 1, 1, 'align');
    plot(fact, Pc(idgen(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idgen(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idgen(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idgen(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idgen(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idgen(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idgen(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc < 2
            scatter(fact, squeeze(Pg(idgen(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idgen(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end  
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, Gen @ bus %d, Gen %d, fuel: %s\n', b, k, char(Istr.mpc.genfuel{k})), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman'); 
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    % plot reserves information
    subplot(2, 1, 2, 'align');
    plot(fact, Rpp(idgen(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idgen(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idgen(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idgen(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserve and Ramp reserves, Gen @ bus %d, Gen %d\nFuel type: %s\n', b, k, char(Istr.mpc.genfuel{k})), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'R. Up', 'R. Down', 'Rp Up', 'Rp Dwn'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    %% Saving information
    
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 11 8]);
    if saveit
        pdf_name = sprintf('GenpowerRES-gen%d.pdf', idgen(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Power plots 
for ed = 1:size(idgen, 1)
    k = idgen(ed);
    b = gen(idgen(ed), GEN_BUS);
    figure;
    plot(fact, Pc(idgen(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idgen(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idgen(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idgen(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idgen(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idgen(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idgen(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc < 2
            scatter(fact, squeeze(Pg(idgen(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idgen(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end  
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, Gen @ bus %d, Gen %d\nFuel type: %s\n', b, k, char(Istr.mpc.genfuel{k})), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('Genpower-gen%d.pdf', idgen(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Reserve Plots
for ed = 1:size(idgen, 1)
    k = idgen(ed);
    b = gen(idgen(ed), GEN_BUS);
    figure;
    plot(fact, Rpp(idgen(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idgen(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idgen(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idgen(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserve and Ramp reserves, Gen @ bus %d, Gen %d\nFuel type: %s\n', b, k, char(Istr.mpc.genfuel{k})), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Res Up', 'Res Down', 'Ramp Up', 'Ramp Down'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3)-(v(1, 4) + v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('Genreserve-gen%d.pdf', idgen(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

%% information for Wind units
% Combined plots for power and reserves
for ed = 1:size(idwind, 1)
    k = idwind(ed);
    b = gen(idwind(ed), GEN_BUS);
    figure;
    % plot power information 
    subplot(2, 1, 1, 'align');
    plot(fact, Pc(idwind(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idwind(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idwind(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idwind(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idwind(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idwind(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idwind(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc <2
            scatter(fact, squeeze(Pg(idwind(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idwind(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end    
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, Wind unit @ bus %d, Gen %d\n', b, k), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman'); 
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    % plot reserves information
    subplot(2, 1, 2, 'align');
    plot(fact, Rpp(idwind(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idwind(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idwind(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idwind(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserves and Ramp reserves, Wind unit @ bus %d, Gen %d\n', b, k), 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 12, 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 8, 'FontName', 'Times New Roman');
    lnames = {'R. Up', 'R. Down', 'Rp Up', 'Rp Dwn'};
    legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/10, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    
    %% Saving information
    
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 11 8]);
    if saveit
        pdf_name = sprintf('WindpowerRES-gen%d.pdf', idwind(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Power plots
for ed = 1:size(idwind, 1)
    k = idwind(ed);
    b = gen(idwind(ed), GEN_BUS);
    figure;
    plot(fact, Pc(idwind(ed), trange), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, e2Pg(idwind(ed), trange), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, Lim(idwind(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, lim(idwind(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, GG(idwind(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, GGm(idwind(ed), trange), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(Pg(idwind(ed), trange, sc, 1)), 35, [0 0.6 0], '+');
        if nc <2
            scatter(fact, squeeze(Pg(idwind(ed), trange, sc, 2:end)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(Pg(idwind(ed), trange, sc, 2:end))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end    
        end
    end
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Real Power Output, Wind unit @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('Windpower-gen%d.pdf', idwind(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Reserve Plots
for ed = 1:size(idwind, 1)
    k = idwind(ed);
    b = gen(idwind(ed), GEN_BUS);
    figure;
    plot(fact, Rpp(idwind(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    hold on;
    plot(fact, Rpm(idwind(ed), trange), ':o', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact(1:end-1), Rrp(idwind(ed), tranger), '-.xb', 'LineWidth', 1);
    plot(fact(1:end-1), Rrm(idwind(ed), tranger), ':ob', 'LineWidth', 1);
    hold off;
    v = axis;
   	v(1:2) = [fact(1) fact(end)];
   	axis(v);
    title(sprintf('Reserves and Ramp reserves, Wind unit @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Res Up', 'Res Down', 'Ramp Up', 'Ramp Down'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('Windreserve-gen%d.pdf', idwind(ed));
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;   
end

% Cost of load shedding
figure;
plot(fact, -LNScst(:, trange), 'b', 'LineWidth', 2);
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Expected Cost of Load Shed, all system'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Cost, $', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
lnames = {'Cost Load Shed'};
legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('LNS-cost.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;   

%% Load plots
if loadplots
    for ed = 1:size(idload, 1)
        k = idload(ed);
        b = gen(idload(ed), GEN_BUS);
        figure;
        plot(fact, -Pc(idload(ed), trange), 'k', 'LineWidth', 2);
        hold on;
        plot(fact, -Rpp(idload(ed), trange), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
        plot(fact, -Rpm(idload(ed), trange), '-o', 'Color', [0 0.6 0], 'LineWidth', 1);
        plot(fact(1:end-1), -Rrp(ed, tranger), '-.b', 'LineWidth', 1);
        plot(fact(1:end-1), -Rrm(ed, tranger), '--xb', 'LineWidth', 1);
        plot(fact, -Lim(idload(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
        plot(fact, -lim(idload(ed), trange), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
        plot(fact, -GG(idload(ed), trange), '-*', 'Color', [0.6 0 0.3], 'LineWidth', 1);
        hold off;
        v = axis;
        v(1:2) = [fact(1) fact(end)];
        axis(v);
        title(sprintf('Real Power Demand, Load @ bus %d, Gen %d\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
        ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
        xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
        lnames = {'Pc', 'Res Up', 'Load Shed', 'Ramp Up', 'Ramp Down', 'Upper lim.', 'Lower lim.', 'Gmax L'};
        legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
        set(gca,'XTick',fact')
        set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
        h = gcf;
        text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
        text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
        text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
        set(h, 'PaperOrientation', 'landscape');
        set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
        if saveit
            pdf_name = sprintf('demand-load%d.pdf', idload(ed));
%             eval(['print -dpdf ' fn_prefix pdf_name]);
            print('-dpdf',[fn_prefix pdf_name]);
        end
        close;   
    end
end

%% Total load Plot, assumes all loads are dispatchable
figure;
%loade = -sum(squeeze(prs).* squeeze(sum(Pg(il, :, :, 1)))', 1);
loade = -sum(e2Pg(il, trange));
loade = sum(tloadp);
plot(fact, loade, 'k', 'LineWidth', 2);
hold on;
plot(fact, -max(max(sum(Pg(il, trange, :, :)), [], 4), [], 3), '-.o', 'Color', [0 0.6 0], 'LineWidth', 1);
%plot(fact, -sum(GG(il, :)), '-o', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, -min(min(sum(Pg(il, trange, :, :)), [], 4), [], 3), '-x', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, -sum(Lim(il, trange)), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
plot(fact, -sum(lim(il, trange)), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
hold off;
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Real Total Power Demand'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
lnames = {'E[sum(D_i)]', 'Min[D_i]', 'Max[D_i]', 'L. Lim ', 'U. Lim'};
legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('demand-total-load.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;

%% Total Wind plot
figure;
% winde = sum(squeeze(prs).* squeeze(sum(Pg(idwind, :, :, 1)))', 1);
winde = sum(e2Pg(idwind, trange), 1);
plot(fact, winde, 'k', 'LineWidth', 2);
%plot(fact, sum(e2Pg(idwind, :)), 'k', 'LineWidth', 2);
hold on;
plot(fact, min(min(sum(Pg(idwind, trange, :, :), 1), [], 4), [], 3), '-o', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, max(max(sum(Pg(idwind, trange, :, :), 1), [], 4), [], 3), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, sum(lim(idwind, trange), 1), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
plot(fact, sum(Lim(idwind, trange), 1), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
hold off;
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Real Total Wind Output'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
lnames = {'E[Pg]', 'Min[Pg]', 'Max[Pg]', 'L. Lim', 'U. Lim'};
legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('Wind-total-output.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;

%% Total Wind plot, extra information
figure;
plot(fact, winde, 'b', 'LineWidth', 2);
hold on;
winda = sum(Gmaxe2(idwind, trange), 1);
plot(fact, winda, 'Color', [0 0.6 0], 'LineWidth', 2);
plot(fact, min(min(sum(Pg(idwind, trange, :, :), 1), [], 4), [], 3), '-o', 'Color', [0 0 1], 'LineWidth', 1);
plot(fact, max(max(sum(Pg(idwind, trange, :, :), 1), [], 4), [], 3), '-.x', 'Color', [0 0 1], 'LineWidth', 1);
plot(fact, min(min(sum(Gmaxlim(idwind, trange, :, :), 1), [], 4), [], 3), '-o', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, max(max(sum(Gmaxlim(idwind, trange, :, :), 1), [], 4), [], 3), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
%plot(fact, sum(Lim(idwind, trange), 1), '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
hold off;
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Real Total Wind Output'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
%lnames = {'E[Pg]', 'E[Pmax]', 'Min[Pg]', 'Max[Pg]', 'Min[Pmax]', 'Max[Pmax]'};
lnames = {'E[dispatch]', 'E[available]', 'Min[dispatch]', 'Max[dispatch]', 'Min[available]', 'Max[available]'};
legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('Wind-total-output2.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;

%% Plot wind availabilities
if ref.wind
  figure;
  if ~exist('wd')                   % security net, wind data
    nz = size(profiles(1).values, 3);
    wd = zeros(nt, nj, nz+1);
    wd(:, :, 2:end) = profiles(1).values(1:nt, 1:nj, 1:nz);
  end
  windi = reshape(wd(trange, :, 2:end), nt, nj*(size(wd, 3)-1));
  plot(fact, windi', 'LineWidth', 2); 
  v = axis;
  v(1:2) = [fact(1) fact(end)];
  axis(v);
  title(sprintf('Wind Forecasts'), 'FontSize', 18, 'FontName', 'Times New Roman');
  ylabel('% of Pmax', 'FontSize', 16, 'FontName', 'Times New Roman');
  xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
  set(gca,'XTick',fact')
  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
  h = gcf;
  text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
  text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
  text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
  set(h, 'PaperOrientation', 'landscape');
  set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
  if saveit
      pdf_name = sprintf('Wind-availability.pdf');
%       eval(['print -dpdf ' fn_prefix pdf_name]);
      print('-dpdf',[fn_prefix pdf_name]);
  end
  close;
end

% plot that uses code initialrf.m which runs iterations for hi13 files.
if  exist('opt') && isfield(opt, 'initialr')
  if opt.initialr
    if size(storprice, 1)>0
      %% Plot time series of prices for final storage prices, charging
      figure;
      xax = 1:size(storprice, 2);
      plot(xax, storprice, 'LineWidth', 2); 
      v = axis;
      v(1:2) = [xax(1) xax(end)];
      axis(v);
      title('Final Prices Assigned to ESS, Charging Contingencies', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_essprices.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;

      %% Plot time series of prices for final storage prices discharging
      figure;
      xax = 1:size(storpriced, 2);
      plot(xax, storpriced, 'LineWidth', 2); 
      v = axis;
      v(1:2) = [xax(1) xax(end)];
      axis(v);
      title('Final Prices Assigned to ESS, Discharging Contingencies', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_esspricesd.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
  
      %% plot time series for maximum prices expected over the horizon, lo
      figure;
      xax = 1:size(storpricech, 2);
      plot(xax, storpricech, 'LineWidth', 2); 
      if size(storpricech, 2)>1
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Final Low Prices Assigned to ESS, Charging', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_esspriceslo.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
  
      %% plot time series for maximum prices expected over the horizon, high
      figure;
      xax = 1:size(storpricedh, 2);
      plot(xax, storpricedh, 'LineWidth', 2); 
      if size(storpricedh, 2)>1
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Final High Prices Assigned to ESS, Discharging', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_esspriceshi.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
  
      %% plot time series for average prices expected over the horizon
      figure;
      xax = 1:size(storpriceav, 2);
      plot(xax, storpriceav, 'LineWidth', 2);
      if size(storpriceav, 2)>1;
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Average prices in ESS buses', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_esspricesav.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
  
      %% Plot time series of quantities in ESS expected
      figure;
      xax = 1:size(storene, 2);
      plot(xax, storene, 'LineWidth', 2); 
      if size(storene, 2)>1
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Expected Energy ESS, start of the horizon', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_essamount.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
      
      %% Plot time series for multipliers on storage constraints
      figure;
      xax = 1:size(stormult, 2);
      plot(xax, stormult, 'LineWidth', 2); 
      if size(stormult, 2)>1
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Difference (u-l) of Storage Multipliers', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_stormult.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;

      %% plot time series for terminal prices
      figure;
      xax = 1:size(stortprice, 2);
      plot(xax, stortprice, 'LineWidth', 2); 
      if size(stortprice, 2)>1
        v = axis;
        v(1:2) = [xax(1) xax(end)];
        axis(v);
      end
      title('Terminal prices in ESS buses', 'FontSize', 18, 'FontName', 'Times New Roman');
      ylabel('$/MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
      xlabel('Iteration', 'FontSize', 16, 'FontName', 'Times New Roman');
      set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
      h = gcf;
      set(h, 'PaperOrientation', 'landscape');
      set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
      if saveit
          pdf_name = sprintf('it_esspricesav.pdf');
%           eval(['print -dpdf ' fn_prefix pdf_name]);
          print('-dpdf',[fn_prefix pdf_name]);
      end
      close;
    end
    
    %% Plot time series for difference of dispatches
    figure;
    xax = 1:(size(dispe, 2));
    difv = max((dispe(:, 2:end)-dispe(:, 1:end-1)));
    plot(xax(1:end-1), difv, 'LineWidth', 2); 
    if (size(dispe, 2))>2
      v = axis;
      v(1:2) = [xax(1) xax(end-1)];
      axis(v);
    end
    title('Max difference across dispatches', 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel('Iteration - 1', 'FontSize', 16, 'FontName', 'Times New Roman');
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
      pdf_name = sprintf('it_e2pgdisp.pdf');
%       eval(['print -dpdf ' fn_prefix pdf_name]);
      print('-dpdf',[fn_prefix pdf_name]);
    end
    close;
  end
end

%% Plot prices in the ESS nodes
if size(ref.ess, 1) >0
    lampne = lamP(idess, :);                     % plot nodal prices over ESS
    figure;
    hold ('all');
    for j = 1:size(lampne, 1)
        plot(fact, lampne(j, trange), ['-' Markers(j)], 'LineWidth', 1);
    end
    hold ('off');
    v = axis;
    v(1:2) = [fact(1) fact(end)];
    axis(v);
    title(sprintf('Nodal Prices observed in ESS nodes\n', sc), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Price, $/MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    Namese = Names(gen(ref.ess, GEN_BUS));
    legend(Namese, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) - (v(1, 1) + v(1, 1))/10-.5, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3)+(v(1, 4)+v(1, 3))/35, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('nodal-prices-ess.pdf');
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;
    
    %% plot sum of all ESS in the system, Power
    figure;
    plot(fact, sum(Pc(idess, trange), 1), 'k', 'LineWidth', 1);
    hold on;
    plot(fact, sum(e2Pg(idess, trange), 1), '--', 'Color', [0.8 0 0], 'LineWidth', 2);
    plot(fact, sum(Lim(idess, trange), 1), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, sum(lim(idess, trange), 1), '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact, sum(GG(idess, trange), 1), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    plot(fact, sum(GGm(idess, trange), 1), '-.', 'Color', [0 0 1], 'LineWidth', 1);
    for sc = 1:nj
        scatter(fact, squeeze(sum(Pg(idess, trange, sc, 1), 1)), 35, [0 0.6 0], '+');
        if nc <2
            scatter(fact, squeeze(sum(Pg(idess, trange, sc, 2:end), 1)), 30, [0 0.6 0], 'p');
        else
            dat = squeeze(sum(Pg(idess, trange, sc, 2:end), 1))';
            for c = 1:nc
                scatter(fact, dat(c, :), 30, [0 0.6 0], 'p');
            end    
        end
    end
    hold off;
    v = axis;
    v(1:2) = [fact(1) fact(end)];
    axis(v);
    title(sprintf('Real Power Output, ESS all buses\n', b, k), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Pc', 'E[Pg]', 'Upper lim.', 'Lower lim.', 'Gmax', 'Gmin', 'Base', 'Contin.'};
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('ESSpower-allgen.pdf');
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;
    
    %% plot sum of all ESS in the system, Energy. Corrected to have the Initial storage (first and last periods should correspond)
    figure
    if fact(1) == 0
      fact1 = [fact, fact(end)+1];
    else
      fact1 = [0, fact];
    end
    plot(fact1, [sum(OstrDCC.Storage.InitialStorage, 1), sum(eStorSt(:, trange), 1)], 'k', 'LineWidth', 2);
    hold on;
    llim = sum(mstorl(:, trange), 1);
    ulim = sum(Mstorl(:, trange), 1);
    plot(fact1, [sum(llim(1, 1), 1), sum(mstorl(:, trange), 1)], '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact1, [sum(ulim(1, 1), 1), sum(Mstorl(:, trange), 1)], '--', 'Color', [0.6 0 0.3], 'LineWidth', 1);
    plot(fact1, [sum(OstrDCC.Storage.InitialStorage, 1), sum(Sp(:, trange), 1)], '-.x', 'Color', [0 0.6 0], 'LineWidth', 1);
    plot(fact1, [sum(OstrDCC.Storage.InitialStorage, 1), sum(Sm(:, trange), 1)], '-.ob', 'LineWidth', 1);
    hold off;
    v = axis;
    v(1:2) = [fact1(1) fact1(end)];
    axis(v);
    title(sprintf('Real Energy Available, ESS all buses\n'), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Energy at end of period, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    lnames = {'Expected Storage Level', 'Min Stor. L', 'Max Stor. L', 'S+', 'S-'}; 
    legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact1')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('ESSenergy-allgen.pdf');
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close;  
end

% Plots expected load shed
if exist('e2shedP2')
    figure
    plot(fact, sum(e2shedP2(il, :), 1), 'b', 'LineWidth', 2);
    v = axis;
    v(1:2) = [fact(1) fact(end)];
    axis(v);
    title(sprintf('Expected Load Shed\n'), 'FontSize', 18, 'FontName', 'Times New Roman');
    ylabel('Expected Load Shed, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
    xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
    legend('Load Shed', 'Location', 'EastOutside', 'FontName', 'Times New Roman');
    set(gca,'XTick',fact')
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    h = gcf;
    text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
    text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
    text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
    if saveit
        pdf_name = sprintf('Elns2s.pdf');
%         eval(['print -dpdf ' fn_prefix pdf_name]);
        print('-dpdf',[fn_prefix pdf_name]);
    end
    close; 
end

% Plots area prices

figure
%% RDZ - 6/9/15
%% the following line was causing crashes due to negative lampn -> complex fplots
% if max(max(lampn)) >1e3
if max(max(lampn)) > 1e3 && min(min(lampn)) > 0
  fplots = log(lampn);
else
  fplots = lampn;
end
surf(fplots, 'EdgeColor', 'None');
view(2); 
axis tight
colorbar
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Nodal Prices Areas\n'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Bus Number', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
%legend('Load Shed', 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) + (v(1, 1) + v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3) + (v(1, 4)-v(1, 3))/25, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
  pdf_name = sprintf('surfprices.pdf');
%   eval(['print -dpdf ' fn_prefix pdf_name]);
  print('-dpdf',[fn_prefix pdf_name]);
end
close; 

[blid, lampbus, lampcbus] = npricesmpf(OstrDCC);

figure;
hold ('all');
for j = 1:size(lampbus, 1)
    plot(fact, lampbus(j, trange), ['-' Markers(j)], 'LineWidth', 1);
end
hold ('off');
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Nodal Prices observed\n', sc), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Price, $/MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(Names(1:nb), 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
h = gcf;
text(v(1, 1) + (v(1, 1) + v(1, 1))/40, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(startnt+1, 1)), 'FontName', 'Times New Roman')
text(v(1, 2) - (v(1, 1) + v(1, 1))/10-.5, v(1, 3)+(v(1, 4)-v(1, 3))/35, sprintf('h = %d', ld(end, 1)), 'FontName', 'Times New Roman')
text((v(1, 1) + v(1, 2))/2 + (v(1, 1)+v(1, 1))/40, v(1, 3)+(v(1, 4)+v(1, 3))/35, sprintf('h = %d', ld(floor((startnt+size(ld, 1))/2)+1, 1)), 'FontName', 'Times New Roman')
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if saveit
    pdf_name = sprintf('nodal-prices-bus.pdf');
%     eval(['print -dpdf ' fn_prefix pdf_name]);
    print('-dpdf',[fn_prefix pdf_name]);
end
close;

% eval(sprintf('save %s%s', optp.savepath, optp.savefile));
save([optp.savepath optp.savefile])
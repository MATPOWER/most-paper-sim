function respgplots_replicate(simname, configf, theta_info)
% Function to create plots with value of reserves in the horizontal axis, expected PG in the vertical
%
% Assumptions:
% deterministic only needs to be called once, info is in the same database for s1 and s2
%
% Dependencies:
% revenuef.m
% 2016.02.22
% 2018.03.14
% Alberto J. Lamadrid

%simnameroot = 'tr_c118_500ucr';      % base directory
outputdir = sprintf('%s%s/outputs/', configf.outputs, simname);
%dprefix = '/Volumes/Drive 2/shares/alberto/';  % location where plot will be saved
plotname = 'respg';                 % name of plot, dispatch
plotname2 = 'resgmax';              % name of plot, max dispatch
plotname3 = 'respmax';              % name of plot, max availability
plotname4 = 'resres';               % name of plot, reserves
plotname5 = 'resres0';              % name of plot, reserves
plotname6 = 'respg2';               % name of plot, dispatch s2
nfuels = 6;                         % number of fuels

%simnamesct = {'10'};                % single case used for all runs
%simnameres = sprintf('%s%s', simnameroot, simnamesct{1});
%simnamepath = sprintf('%s%s', dprefix, simname{ct1});

theta_len = theta_info{1};                     % number of runs
theta_min = theta_info{2};
theta_max = theta_info{3};
theta1 = linspace(theta_min,theta_max,theta_len);
%resf = sprintf('%s/outputs/comp/%s_compfxst2.mat', simnamepath, simname);
%data1 = load(resf);

%configf = configfajl1;              % configuration directory structure files
%configf = configfraptor;           % raptor old file scheme
%configf = configfraptor2;           % raptor new file scheme
define_constants;

vval = [10e4;
      12e4
      15e4
      15e3
      ];                        % determine yaxis so they are consistent

nOut = 17;
%% -- stochastic info --
ct1 = 1;
%simname = sprintf('%s%s', simnameroot, simnamesct{1});
[outArgs{1:nOut}] = dirstruct(configf, simname);

[savefiledirs1, savefiles1, savefiledirs2, savefiles2, savefileresds1, ...
    savefileress1, savefileresds2, savefileress2, savefilelog, ...
    savefileplots1, s1inputs, strinputs, savefiles1f, savefileress1f, savefileplots1f, ...
    savefiletrs2, savefiletrs2f] = deal(outArgs{:});

s1r = load(savefileplots1);
s2r = load(savefileress2);
s1b = load(savefiles1);
mpc = s1b.second_stage.mpsd.mpc;

[a, infops2{ct1}, infols2{ct1}] = revenuef(mpc, s2r, 'savepath', savefileplots1, 'saveit', true, 'savename1', 'Cost-area2.pdf', ...
    'savename2', 'pg-area2.pdf', 'savename3', 'maxcap2.pdf');

[a, infops1{ct1}, infols1{ct1}] = revenuef(mpc, s1r, 'savepath', savefileplots1, 'saveit', true, 'savename1', 'Cost-area.pdf', ...
    'savename2', 'pg-area.pdf', 'savename3', 'maxcap.pdf');

pgress(ct1, :) = sum(infops2{ct1}.pgarea2, 1);% stochastic dispatch, first stage
gmress(ct1, :) = sum(infops1{ct1}.gmaxarp, 1);% stochastic gmax, first stage
pmress(ct1, :) = sum(infops1{ct1}.cpmaxrp, 1);% stochastic pmax, first stage, [1 x nfuels]
pgress2(ct1, :) = sum(infops2{ct1}.pgarea2s2, 1);% stochastic dispatch, second stage

s1b = load(savefiles1);
s1r = load(savefileress1);

[a, infors1{ct1}, infolrs1{ct1}] = rescompf(s1b, s1r, 'savepath', savefileplots1, 'saveit', true);

resress(ct1, :) = sum(infors1{ct1}.Rarea, 1);% stochastic reserve
resressk0(ct1, :) = sum(infors1{ct1}.Rk0, 1);% stochastic reserve including k0

color = infols2{1}.color;
order = infols2{1}.order;

%% -- fixed res info
for ct1 = 1:theta_len
  simnamef{ct1} = sprintf('%s/%s_default2_%3.3i/%s', simname, simname, ct1, simname);

  [outArgs{1:nOut}] = dirstruct(configf, simnamef{ct1});

  [savefiledirs1, savefiles1, savefiledirs2, savefiles2, savefileresds1, ...
      savefileress1, savefileresds2, savefileress2, savefilelog, ...
      savefileplots1, s1inputs, strinputs, savefiles1f, savefileress1f, ...
      savefileplots1f, savefiletrs2, savefiletrs2f] = deal(outArgs{:});
      
%--- deterministic runs ---
  s2r = load(savefileress1f);

  [a, infopd2{ct1}, infold2{ct1}] = revenuef(mpc, s2r, 'savepath', savefileresds1, 'saveit', true, 'savename1', 'Cost-area2.pdf', ...
    'savename2', 'pg-area2.pdf', 'savename3', 'maxcap.pdf', 'savename4', 'cpmax.pdf', 'addres', true);
    
% deterministic only needs to be called once, info is in the same database for s1 and s2
      
  pgresd(ct1, :) = sum(infopd2{ct1}.pgarea2, 1);% deterministic dispatch
  gmresd(ct1, :) = sum(infopd2{ct1}.gmaxarp, 1);% deterministic max dispatch
  pmresd(ct1, :) = sum(infopd2{ct1}.cpmaxrp, 1);% deterministic max committed [nsims x nfuels] where nsims are the steps for fixed reserves
  pgresd2(ct1, :) = sum(infopd2{ct1}.pgarea2s2, 1);% deterministic dispatch
 
% reserves
  %savefiles1f = sprintf('%s%s/%s_default2_%3.3i/%s/workdir/stage1/000/results_fr_000', ...
  %  configf.outputs, simname, simname, scale_1_dir, simname);
  s1b = load(savefiles1f);
  s1r = load(savefileress1f);

  [a, inford1{ct1}, infolrd1{ct1}] = rescompf(s1b, s1r, 'savepath', savefileresds1, 'saveit', true, ...
    'savename1', 'res-aread.pdf', 'savename2', 'resk0-aread.pdf', 'drun', true);
    
% deterministic only needs to be called once, info is in the same database for s1 and s2
      
  resresd(ct1, :) = sum(inford1{ct1}.Rarea, 1);% deterministic reserves
  resresdk0(ct1, :) = sum(inford1{ct1}.Rk0, 1);% deterministic 
end

%-- expected dispatch
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = pgress;
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('E[Dispatch] per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legendfm = infols2{1}.legend;
legendfm(5) = {'gas CC'};
legendfm(6) = {'gas CT'};
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, pgresd);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('E[Dispatch] per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of maximum expected dispatches from the first stage--
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname2);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = gmress;
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6;                        %Change axis limit
warning('manually fixing axes');
ax(4) = vval(2);
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('M[Dispatch] per fuel type, MWh, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legend(infols2{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, gmresd);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(2);
axis(ax);
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('M[Dispatch] per fuel type, MWh, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(infold2{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of maximum expected dispatches from the first stage, no wind--
nom = sprintf('%sc118%s_stackfresnw_rep', outputdir, plotname2);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = gmress(:, 2:end);
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6;                        %Change axis limit
warning('manually fixing axes');
ax(4) = vval(2);
axis(ax);
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('M[Dispatch] per fuel type, MWh, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legendf = infols2{1}.legend;
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, gmresd(:, 2:end));
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(2);
axis(ax);
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('M[Dispatch] per fuel type, MWh, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of maximum committed capacities from the first stage--
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname3);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = pmress(:, 1:end);         % exclude wind generators
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6;                        %Change axis limit
warning('manually fixing axes');
ax(4) = vval(3);
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('M[Committed] per fuel type, MW, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, pmresd(:, 1:end)); % filter wind out, capacity of wind is too large and covers all the others
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(3);
axis(ax);
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('M[Committed] per fuel type, MW, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of maximum committed capacities from the first stage, no wind--
nom = sprintf('%sc118%s_stackfresnw_rep', outputdir, plotname3);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = pmress(:, 2:end);         % exclude wind generators
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6;                        %Change axis limit
warning('manually fixing axes');
ax(4) = vval(3);
axis(ax);
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
%title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Stochastic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('M[Committed] per fuel type, MW, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
%legendf = infols2{1}.legend;
legendf = legendfm;
legendfm(3) = {'nuclear'};
legendfm(5) = {'gas CC'};
legendfm(6) = {'gas CT'};
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, pmresd(:, 2:end)); % filter wind out, capacity of wind is too large and covers all the others
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(3);
axis(ax);
%title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Deterministic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Max Committed Capacity by Fuel Type (MW)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('M[Committed] per fuel type, MW, 1 set.', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Reserve Scaling Factor', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Reserve Scaling Factor', 'FontSize', 22, 'FontName', 'Times New Roman');
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of reserves composition
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname4);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = resress;
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(4);
axis(ax);
%title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Stochastic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');
%legend(infolrs1{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, resresd);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(4) = vval(4);
axis(ax);
%title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Deterministic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 22, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');
%legend(infolrd1{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of reserves composition no wind
nom = sprintf('%sc118%s_stackfresnw_rep', outputdir, plotname4);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = resress(:, 2:end);
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
warning('manually fixing axes');
ax(3) = 0;
ax(4) = vval(4);
axis(ax);
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
%title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Stochastic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', 'units','normalized');
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
%legendf = infolrs1{1}.legend;
legendf = legendfm;
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, resresd(:, 2:end));
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
%title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Deterministic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Reserve Capacity by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Reserve Scaling Factor', 'FontSize', 22, 'FontName', 'Times New Roman');
%xlabel('Reserve Scaling Factor', 'FontSize', 16, 'FontName', 'Times New Roman');
%legendf = infolrd1{1}.legend;
legendf = legendfm;
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', 'units','normalized');
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of reserves composition only base cases
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname5);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = resressk0;
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
ax = axis;
warning('manually fixing axes');
ax(3) = 0;
ax(4) = vval(4);
axis(ax);
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legend(infolrs1{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, resresd);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(infolrd1{1}.legend, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%%-- plot of reserves composition only base cases, no wind
nom = sprintf('%sc118%s_stackfresnw_rep', outputdir, plotname5);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = resressk0(:, 2:end);
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
axis(ax);
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
ax = axis;
warning('manually fixing axes');
ax(3) = 0;
ax(4) = vval(4);
axis(ax);
title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
legendf = infolrs1{1}.legend;
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, resresd(:, 2:end));
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))
title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
ylabel('Reserves per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
legendf = infolrd1{1}.legend;
legend(legendf(2:end), 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;

%-- expected dispatch s2
nom = sprintf('%sc118%s_stackfres_rep', outputdir, plotname6);
fig=figure;
subplot(1, 2, 1, 'align');          % stochastic
infobar = pgress2;
infobar(length(infobar), 2) = 0;
h = bar(infobar, 'stacked');
ax = axis;
ax(2) = 1.6; %Change axis limit
axis(ax);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
%title(sprintf('Stochastic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Stochastic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('E[Dispatch] per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
% xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
legendfm = infols2{1}.legend;
legendfm(3) = {'nuclear'};
legendfm(5) = {'gas CC'};
legendfm(6) = {'gas CT'};
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');

subplot(1, 2, 2, 'align');          % deterministic
h = area(theta1, pgresd2);
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(1), :))
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))
%title(sprintf('Deterministic'), 'FontSize', 17, 'FontName', 'Times New Roman');
title(sprintf('Deterministic'), 'FontSize', 25, 'FontName', 'Times New Roman');
ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 22, 'FontName', 'Times New Roman');
%ylabel('Expected Dispatch by Fuel Type (MWh)', 'FontSize', 16, 'FontName', 'Times New Roman');
%ylabel('E[Dispatch] per fuel type, MWh', 'FontSize', 16, 'FontName', 'Times New Roman');
% xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Reserve Scaling Factor', 'FontSize', 22, 'FontName', 'Times New Roman');
%xlabel('Reserve Scaling Factor', 'FontSize', 16, 'FontName', 'Times New Roman');
legend(legendfm, 'Location', 'Best', 'FontName', 'Times New Roman');
h = gca;
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
eval(sprintf('print -dpdf ''%s''', nom));
close;
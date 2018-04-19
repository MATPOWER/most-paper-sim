function [hh, infop, infol] = revenuef(mpc, res, varargin)
% Expected utilization per fuel type
% Expects structure with precalculated fields
% modify vector order to shift the order the fuels presented
% INPUTS
% MPC   :   mpc of the case
% RES   :   results from running case
%
% OUTPUTS
% HH    :   Function handle for last function
% INFOP :   Struct information of the matrices used in the plots
% INFOL :   Struct information of additional fields   
%
%% FILTER REVENUE RESULTS TO FILTER BUSES IF DESIRED

% 2016.02.08
% 2016.03.09
% Alberto J. Lamadrid

my_xlabel = 'Period';

ng = res.ng;
nb = res.nb;
nt = res.nt;
ig = res.ig;
il = res.il;
ie = res.ie;
iw = res.iw;
cstarea = res.e2cstP;               % [ng x nt]
pgarea = res.e2Pg;                  % [ng x nt]
if isfield(res, 'e2Pg2')            % for s1 cases, these results wont exist
  pgareas2 = res.e2Pg2;             % [ng x nt]
else
  pgareas2 = res.e2Pg;              % [ng x nt]
end
%gmax = squeeze(max(max(res.Pg, [], 4), [], 3));
gmax = res.GG;
fres = zeros(size(gmax));           % [ng x nt]
ucpmax = res.Lim;                   % [ng x nt]

%% default options
opt = struct( ...
    'saveit', false, ...
    'savepath', '', ...
    'savename1', 'Cost-area.pdf', ...
    'savename2', 'pg-area.pdf', ...
    'savename3', 'maxcap.pdf', ...
    'savename4', 'cpmax.pdf', ...
    'savename5', 'pg-area2.pdf', ...
    'addres', false);
    
%% process options
if mod(length(varargin), 2) %% odd number of options, first must be OPT struct
    if ~isstruct(varargin{1})
        error('plot_gentr: Single OPT argument must be a struct');
    end
    myopt = varargin{1};
    k = 2;
else                        %% even number of options
    myopt = struct;
    k = 1;
end
while k < length(varargin)
    opt_name = varargin{k};
    opt_val  = varargin{k+1};
    if ~isfield(opt, opt_name)
        error('plot_gentr: ''%s'' is not a valid option name', opt_name);
    end
    myopt.(opt_name) = opt_val;
    k = k + 2;
end
fields = fieldnames(myopt);
for f = 1:length(fields)
    opt.(fields{f}) = myopt.(fields{f});
end

if opt.addres                       % user indicated that positive reserves will be added to max
  fres = res.Rpp;
end

lfuels = unique(mpc.genfuel);       % coal, hydro, na, ng, ngcc, nuke, wind
if length(lfuels) == 5
    order = [5, 2, 1, 4];
else
    order = [7, 2, 6, 1, 5, 4];         % wind, hydro, nuke, coal, ngcc, ng(from baseload to peaking)
end

color = [
[1 0.75 0.15]                       % coal
[0.8 0 0]                           % hydro
[.2 .2 .2]                          % na
[.8 .8 .8]                          % ng
[0.52 0.8 .98]                      % ngcc
[0 0 1]                             % nuke
[0 0.5 0]                           % wind
];

%order = [2, 6, 1, 5, 4, 7, 8];     % nuke, hydro, coal, ngcc, ng, wind, ess(from baseload to peaking)

idn2 = ones(ng, 1);                 % select all generators
idn3 = ones(nb, 1);                 % select all buses in the system

igf = intersect(ig, find(idn2));
ilf = intersect(il, find(idn2));
ief = intersect(ie, find(idn2));
iwf = intersect(iw, find(idn2));
ibld = find(idn3);

%% area plots

fuel = mpc.genfuel;
idn = zeros(ng, size(mpc.fuelname, 1)+1);
for ct1 = 1:ng
    idn(ct1, 1) = strcmp(fuel(ct1, :), 'coal');
    idn(ct1, 2) = strcmp(fuel(ct1, :), 'hydro');
    idn(ct1, 3) = strcmp(fuel(ct1, :), 'na');
    idn(ct1, 4) = strcmp(fuel(ct1, :), 'ng');
    if length(lfuels) > 5
        idn(ct1, 5) = strcmp(fuel(ct1, :), 'ngcc');
        idn(ct1, 6) = strcmp(fuel(ct1, :), 'nuke');
        idn(ct1, 7) = strcmp(fuel(ct1, :), 'wind');
        idn(ct1, 8) = or(strcmp(fuel(ct1, :), 'ESS'), strcmp(fuel(ct1, :), 'Flex ld'));
    else
        idn(ct1, 5) = strcmp(fuel(ct1, :), 'wind');
        idn(ct1, 6) = or(strcmp(fuel(ct1, :), 'ESS'), strcmp(fuel(ct1, :), 'Flex ld'));
    end
end
for ct1= 1:size(idn, 2)
  cstarear(:, ct1) = sum(cstarea(find(idn(:, ct1)), :), 1)';
  pgarear(:, ct1) = sum(pgarea(find(idn(:, ct1)), :), 1)';
  gmaxar(:, ct1) = sum(gmax(find(idn(:, ct1)), :), 1)' + ...
    sum(fres(find(idn(:, ct1)), :), 1)';% unless specified, this component is zero
  ucpmaxr(:, ct1) = sum(ucpmax(find(idn(:, ct1)), :), 1)';
  pgarears2(:, ct1) = sum(pgareas2(find(idn(:, ct1)), :), 1)';
end

if length(lfuels) > 5
    lfuelsl = {lfuels{order(1)}, lfuels{order(2)}, lfuels{order(3)}, lfuels{order(4)}, lfuels{order(5)}, lfuels{order(6)}};
    %lfuelsl = {lfuels{order(1)}, lfuels{order(2)}, lfuels{order(3)}, lfuels{order(4)}, lfuels{order(5)}, lfuels{order(6)}, lfuels{order(7)}};
else
    lfuelsl = {lfuels{order(1)}, lfuels{order(2)}, lfuels{order(3)}, lfuels{order(4)}};
end

trange = [1:nt];                                    % time range to be plotted
frange = [1:length(order)];                                     % fuel range to be plotted
if length(order) > 5
    cstarea = [cstarear(:, order(1)), cstarear(:, order(2)), cstarear(:, order(3)), cstarear(:, order(4)), cstarear(:, order(5)), cstarear(:, order(6))];
    %cstarea = [cstarear(:, order(1)), cstarear(:, order(2)), cstarear(:, order(3)), cstarear(:, order(4)), cstarear(:, order(5)), cstarear(:, order(6)), cstarear(:, order(7))];
else
    cstarea = [cstarear(:, order(1)), cstarear(:, order(2)), cstarear(:, order(3)), cstarear(:, order(4))];
end
figure;
h = area(cstarea(trange, frange));
for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
end
%set(h(2),'FaceColor', color(order(2), :))
%set(h(3),'FaceColor', color(order(3), :))
%set(h(4),'FaceColor', color(order(4), :))
%set(h(5),'FaceColor', color(order(5), :))
%set(h(6),'FaceColor', color(order(6), :))

%set(h(7),'FaceColor',[1 0 0])
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Expected Cost per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Cost per fuel type, $', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(lfuelsl, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
    pdf_name = sprintf('%s', opt.savename1);
    eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if length(order) > 5
    pgarea2 = [pgarear(:, order(1)), pgarear(:, order(2)), pgarear(:, order(3)), pgarear(:, order(4)), pgarear(:, order(5)), pgarear(:, order(6))];
else
    pgarea2 = [pgarear(:, order(1)), pgarear(:, order(2)), pgarear(:, order(3)), pgarear(:, order(4))];
end
figure;
h = area(pgarea2(trange, frange));
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
hold on;
%plot(fact, sum([pgarea2(trange, :), pgarear(trange, 7)], 2), 'Color', [1 0.54 0], 'LineWidth', 2); % ess
hold off;
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Expected Dispatch per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('E[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(lfuelsl, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
    pdf_name = sprintf('%s', opt.savename2);
    eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if length(order) > 5
    gmaxarp = [gmaxar(:, order(1)), gmaxar(:, order(2)), gmaxar(:, order(3)), gmaxar(:, order(4)), gmaxar(:, order(5)), gmaxar(:, order(6))];
else
    gmaxarp = [gmaxar(:, order(1)), gmaxar(:, order(2)), gmaxar(:, order(3)), gmaxar(:, order(4))];
end
figure;
h = area(gmaxarp(trange, frange));
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
hold on;
%plot(fact, sum([pgarea2(trange, :), pgarear(trange, 7)], 2), 'Color', [1 0.54 0], 'LineWidth', 2); % ess
hold off;
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Max Intact Dispatch per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('M[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(lfuelsl, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
    pdf_name = sprintf('%s', opt.savename3);
    eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if length(order) > 5
    cpmaxrp = [ucpmaxr(:, order(1)), ucpmaxr(:, order(2)), ucpmaxr(:, order(3)), ucpmaxr(:, order(4)), ucpmaxr(:, order(5)), ucpmaxr(:, order(6))];
else
    cpmaxrp = [ucpmaxr(:, order(1)), ucpmaxr(:, order(2)), ucpmaxr(:, order(3)), ucpmaxr(:, order(4))];
end
figure;
h = area(cpmaxrp(trange, frange));
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
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Max Capacity Committed per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('M[Capacity] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(lfuelsl, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
    pdf_name = sprintf('%s', opt.savename4);
    eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if length(order) > 5
    pgarea2s2 = [pgarears2(:, order(1)), pgarears2(:, order(2)), pgarears2(:, order(3)), pgarears2(:, order(4)), pgarears2(:, order(5)), pgarears2(:, order(6))];
else
    pgarea2s2 = [pgarears2(:, order(1)), pgarears2(:, order(2)), pgarears2(:, order(3)), pgarears2(:, order(4))];
end
figure;
h = area(pgarea2s2(trange, frange));
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
hold on;
%plot(fact, sum([pgarea2(trange, :), pgarear(trange, 7)], 2), 'Color', [1 0.54 0], 'LineWidth', 2); % ess
hold off;
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Expected Dispatch per Fuel Type, S2'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('E[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legend(lfuelsl, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
    pdf_name = sprintf('%s', opt.savename5);
    eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if nargout                          % save only last plot
    hh = h;
    infop.cstarea = cstarea;        % info plot, cost, [nt x nfuels]
    infop.pgarea2 = pgarea2;        % dispatch, [nt x nfuels]
    infop.gmaxarp = gmaxarp;        % max dispatch, [nt x nfuels]
    infop.cpmaxrp = cpmaxrp;        % max committed, [nt x nfuels]
    infop.pgarea2s2 = pgarea2s2;    % dispatch s2, [nt x nfuels]
    infol.idn = idn;                % fuel order
    infol.legend = lfuelsl;         % label of fuels
    infol.order = order;            % order of plots
    infol.color = color;            % colors used
end
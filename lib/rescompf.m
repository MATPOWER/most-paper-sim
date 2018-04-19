function [hh, infop, infol] = rescompf(rs, ss, varargin)
% Creates graphs for the reserves composition by fuel type
% distingushes between stochastic and deterministic cases
% 2016.03.14 lax
% Alberto J. Lamadrid

my_xlabel = 'Period';

opt = struct( ...
    'drun', false, ...
    'saveit', false, ...
    'savepath', '', ...
    'savename1', 'res-area.pdf', ...
    'savename2', 'resk0-area.pdf');
    
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

ng = ss.ng;
nb = ss.nb;
ig = ss.ig;
il = ss.il;
ie = ss.ie;
iw = ss.iw;
%cstarea = ss.e2cstP;               % [ng x nt]

if opt.drun                         % deterministic run
  [nt, nj, nk] = size(rs.r1f.flow);
  icg = setdiff(ig, rs.r1f.mpc.iwind); % conventional generators (no wind)
  for t = 1:nt
      %R(:, t) = rs.r1f.FixedReserves(t).R;
      R(:, t) = rs.r1f.flow(t).mpc.reserves.R;
  end
  Rk0 = zeros(size(R));             % 
  lfuels = unique(rs.second_stage.mpsdf.mpc.genfuel);       % coal, hydro, na, ng, ngcc, nuke, wind
  fuel = rs.second_stage.mpsdf.mpc.genfuel;
  idn = zeros(ng, size(rs.second_stage.mpsdf.mpc.fuelname, 1)+1);
else
  [nt, nj, nk] = size(rs.r1.flow);
  icg = setdiff(ig, rs.r1.mpc.iwind); % conventional generators (no wind)
  ePg = ss.e2Pg;                   % expected dispatch
  Pc = rs.r1.results.Pc;
  Gmax   = -Inf(ng, 24);
  Gmaxk0 = -Inf(ng, 24);
  for t = 1:nt
      for j = 1:nj
          Gmaxk0(:,t) = max(Gmaxk0(:,t), rs.r1.flow(t,j,1).mpc.gen(:, rs.PG));
          for k = 1:nk
              Gmax(:,t) = max(Gmax(:,t), rs.r1.flow(t,j,k).mpc.gen(:, rs.PG));
          end
      end
  end

  R = Pc + rs.r1.results.Rpp - ePg;  % stochastic reserves, same as: Gmax - ePg
  Rk0 = Gmaxk0 - ePg;
  lfuels = unique(rs.second_stage.mpsd.mpc.genfuel);       % coal, hydro, na, ng, ngcc, nuke, wind
  fuel = rs.second_stage.mpsd.mpc.genfuel;
  idn = zeros(ng, size(rs.second_stage.mpsd.mpc.fuelname, 1)+1);
end

if length(lfuels) > 5
    order = [7, 2, 6, 1, 5, 4];         % wind, , hydro, nuke, coal, ngcc, ng(from baseload to peaking)
    lfuelsl = {lfuels{order(1)}, lfuels{order(2)}, lfuels{order(3)}, lfuels{order(4)}, lfuels{order(5)}, lfuels{order(6)}};
else
    order = [5, 2, 1, 4];         % wind, , hydro, nuke, coal, ngcc, ng(from baseload to peaking)
    lfuelsl = {lfuels{order(1)}, lfuels{order(2)}, lfuels{order(3)}, lfuels{order(4)}};
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
  Rarear(:, ct1) = sum(R(find(idn(:, ct1)), :), 1)';
  Rk0arear(:, ct1) = sum(Rk0(find(idn(:, ct1)), :), 1)';
end

trange = [1:nt];                                    % time range to be plotted
frange = [1:length(order)];                                     % fuel range to be plotted
if length(order) > 5
    Rarea = [Rarear(:, order(1)), Rarear(:, order(2)), Rarear(:, order(3)), Rarear(:, order(4)), Rarear(:, order(5)), Rarear(:, order(6))];
else
    Rarea = [Rarear(:, order(1)), Rarear(:, order(2)), Rarear(:, order(3)), Rarear(:, order(4))];
end
figure;
h = area(Rarea(trange, frange));
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
title(sprintf('Expected Reserves per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('E[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
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

figure;
frange = [2:length(order)];                                     % fuel range to be plotted
h = area(Rarea(trange, frange));
for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
end
%set(h(1),'FaceColor', color(order(2), :))
%set(h(2),'FaceColor', color(order(3), :))
%set(h(3),'FaceColor', color(order(4), :))
%set(h(4),'FaceColor', color(order(5), :))
%set(h(5),'FaceColor', color(order(6), :))

%set(h(6),'FaceColor', color(order(6), :))
%set(h(7),'FaceColor',[1 0 0])
%v = axis;
%v(1:2) = [fact(1) fact(end)];
%axis(v);
title(sprintf('Expected Reserves per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('E[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
legendf = lfuelsl;
legend(legendf(2:end), 'Location', 'EastOutside', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
if opt.saveit
  pdf_name = sprintf('nw%s', opt.savename1);
  eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
end
close;

if ~opt.drun
  if length(order) > 5
    Rk0area = [Rk0arear(:, order(1)), Rk0arear(:, order(2)), Rk0arear(:, order(3)), Rk0arear(:, order(4)), Rk0arear(:, order(5)), Rk0arear(:, order(6))];
  else
      Rk0area = [Rk0arear(:, order(1)), Rk0arear(:, order(2)), Rk0arear(:, order(3)), Rk0arear(:, order(4))];
  end
  figure;
  frange = [1:length(order)];                                     % fuel range to be plotted
  h = area(Rk0area(trange, frange));
  for i=1:length(order)
    set(h(i),'FaceColor', color(order(i), :))
  end
  %set(h(1),'FaceColor', color(order(1), :))
  %set(h(2),'FaceColor', color(order(2), :))
  %set(h(3),'FaceColor', color(order(3), :))
  %set(h(4),'FaceColor', color(order(4), :))
  %set(h(5),'FaceColor', color(order(5), :))
  %set(h(6),'FaceColor', color(order(6), :))
  
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

  frange = [2:length(order)];                                     % fuel range to be plotted
  h = area(Rk0area(trange, frange));
  for i=2:length(order)
    set(h(i-1),'FaceColor', color(order(i), :))
  end
  %set(h(1),'FaceColor', color(order(2), :))
  %set(h(2),'FaceColor', color(order(3), :))
  %set(h(3),'FaceColor', color(order(4), :))
  %set(h(4),'FaceColor', color(order(5), :))
  %set(h(5),'FaceColor', color(order(6), :))
  
  %v = axis;
  %v(1:2) = [fact(1) fact(end)];
  %axis(v);
  title(sprintf('Expected Dispatch per Fuel Type'), 'FontSize', 18, 'FontName', 'Times New Roman');
  ylabel('E[Dispatch] per fuel type, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
  xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
  legendf = lfuelsl;
  legend(legendf(2:end), 'Location', 'EastOutside', 'FontName', 'Times New Roman');
  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
  h = gcf;
  set(h, 'PaperOrientation', 'landscape');
  set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
  if opt.saveit
      pdf_name = sprintf('nw%s', opt.savename2);
      eval(sprintf('print -dpdf ''%s/%s''', opt.savepath, pdf_name))    
  end
  close;
else
  Rk0area = zeros(nt, 6);            % hardcode if deterministic run
end

if nargout                          % save only last plot
    hh = h;
    infop.Rarea = Rarea;            % Reserves, [nt x nfuels]
    infop.Rk0 = Rk0area;            % Reserves including base, [nt x nfuels]
    infol.idn = idn;                % fuel order
    infol.legend = lfuelsl;         % label of fuels
    infol.order = order;            % order of plots
    infol.color = color;            % colors used
end
function resplot1_replicate(simname, configf, theta)
% Function for plot reserves from first stage runs
%
% 2016.03.08
% 2018.03.14
% Ray D. Zimmerman
% Alberto J. Lamadrid

%   MOST Paper Simulations
%   Copyright (c) 2016-2018 by Alberto J. Lamadrid, Ray Zimmerman
%
%   This file is part of MOST Paper Simulations.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

%simnameroot = 'tr_c118_500ucr';      % base directory
%dprefix = '/Volumes/Drive 2/shares/alberto/';  % location where plot will be saved
%configf = configfraptor2;           % raptor new file scheme

%simnamesct = {'10'};
outputdir = sprintf('%s%s/outputs/', configf.outputs, simname);
%nOut = 15;
nOut = 17;
%simname = sprintf('%s%s', simnameroot, simnamesct{1});
[outArgs{1:nOut}] = dirstruct(configf, simname);

[savefiledirs1, savefiles1, savefiledirs2, savefiles2, savefileresds1, ...
    savefileress1, savefileresds2, savefileress2, savefilelog, ...
    savefileplots1, s1inputs, strinputs, savefiles1f, savefileress1f, savefileplots1f, ...
    savefiletrs2, savefiletrs2f] = deal(outArgs{:});

rs = load(sprintf('%s.mat', savefiles1));
scale_1_dir = find(theta == 1);
savefiles1f = sprintf('%s%s/%s_default2_%3.3i/%s/workdir/stage1/000/results_fr_000', ...
    configf.outputs, simname, simname, scale_1_dir, simname);
rd = load(sprintf('%s.mat', savefiles1f));
ss = load(sprintf('%s.mat', savefileress1));
%sd = load(sprintf('%s.mat', savefileress1f));

ng = size(rs.r1.mpc.gen, 1);
ig = find(~isload(rs.r1.mpc.gen));  % generators
icg = setdiff(ig, rs.r1.mpc.iwind); % conventional generators (no wind)
ePg = ss.e2Pg;                      % expected dispatch
Pc = rs.r1.results.Pc;

[nt, nj, nk] = size(rs.r1.flow);
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

Rs = Pc + rs.r1.results.Rpp - ePg;  % stochastic reserves, same as: Gmax - ePg
Rsk0 = Gmaxk0 - ePg;
% Rpp = rs.r1.results.Rpp;
% Rst = Rpp + rs.r1.results.Rpm;

Rd = zeros(size(Rs));               % deterministic reserves
for t = 1:nt
    %Rd(:, t) = rd.r1f.FixedReserves(t).R;
    Rd(:, t) = rd.r1f.flow(t).mpc.reserves.R;
end

figure
y = [sum(Rs(icg, :))' sum(Rsk0(icg, :))' sum(Rd(icg, :))'];
plot(y, 'LineWidth', 3);
h = legend('Stochastic (base+contingencies)', 'Stochastic (base)', 'Deterministic', 'Location', 'NorthWest');
set(h, 'FontSize', 12);
title('Reserve Comparison', 'FontSize', 18, 'FontName', 'Times New Roman');
ylabel('Total Reserve Capacity, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('Period', 'FontSize', 16, 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0 0 11 8.5]);
pdf_name = 'reserve_comparison_replicate.pdf';
nom = sprintf('%s%s', outputdir, pdf_name);
eval(sprintf('print -dpdf ''%s''', nom));
close

figure
y = [sum(Rs(icg, :))' sum(Rd(icg, :))'];
plot(y, 'LineWidth', 3);
h = legend('Stochastic', 'Deterministic', 'Location', 'NorthWest');
set(h, 'FontSize', 22);
%title('Reserve Comparison by Period', 'FontSize', 18, 'FontName', 'Times New Roman');
%ylabel('Total Reserve Capacity, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel('Period', 'FontSize', 16, 'FontName', 'Times New Roman');
title('Reserve Comparison by Period', 'FontSize', 27, 'FontName', 'Times New Roman');
ylabel('Total Reserve Capacity, MW', 'FontSize', 22, 'FontName', 'Times New Roman');
xlabel('Period', 'FontSize', 22, 'FontName', 'Times New Roman');
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0 0 11 8.5]);
pdf_name = 'reserve_comparisonf_replicate.pdf';
nom = sprintf('%s%s', outputdir, pdf_name);
eval(sprintf('print -dpdf ''%s''', nom));
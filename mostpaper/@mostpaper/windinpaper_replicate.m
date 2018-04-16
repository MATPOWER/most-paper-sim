function windinpaper(simname, configf)
% Function to create wind input information for the paper
% 
% 2016.02.10
% 2018.03.14
% Alberto J. Lamadrid

%simname = 'tr_c118_500ucr10_3';        % base directory
%configf = configfajl1;              % configuration directory structure files
%configf = configfraptor;           % raptor old file scheme
%configf = configfraptor2;           % raptor new file scheme
define_constants;

my_xlabel = 'Period';
define_constants;

nOut = 17;
[outArgs{1:nOut}] = dirstruct(configf, simname);

[savefiledirs1, savefiles1, savefiledirs2, savefiles2...
      savefileresds1, savefileress1, savefileresds2, savefileress2, ...
      savefilelog, savefileplots1, s1inputs, strinputs, ...
      savefiles1f, savefileress1f, savefileplots1f, ...
      savefiletrs2, savefiletrs2f] = deal(outArgs{:});
      
fn_prefix = sprintf('%s/', savefileplots1);

s1r = load(savefileplots1);         % load results
s2r = load(savefileress2);
s2d = load(savefileress1f);

idwind = s1r.idwind;
trange = s1r.trange;
fact = s1r.fact;

winde2 = sum(s2r.e2Pg2(idwind, :)); % 1 x nt, equivalent to calculation above, mean stochastic
winde2d = sum(s2d.e2Pg2(idwind, :)); % 1 x nt, equivalent to calculation above, mean deterministic
winda2 = mean(squeeze(sum(s2r.Gmaxlim2(idwind, trange, :, 1), 1)), 2); % nt x 1, originally ng x nt x ntr x nc0 + 1. Sum over all wind units, take mean over trajectories

s2rMa = max(max(s2r.Gmaxlim2, [], 4), [], 3);
s2rma = min(min(s2r.Gmaxlim2, [], 4), [], 3);
s2rMp = max(max(s2r.Pg2, [], 4), [], 3);
s2rmp = min(min(s2r.Pg2, [], 4), [], 3);
s2dMp = max(max(s2d.Pg2, [], 4), [], 3);
s2dmp = min(min(s2d.Pg2, [], 4), [], 3);

figure;
plot(fact, winde2, 'b', 'LineWidth', 2);
hold on;
plot(fact, winda2', 'Color', [0 0.6 0], 'LineWidth', 2);
plot(fact, min(sum(s2r.Gmaxlim2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1); % 1 x nt
plot(fact, max(sum(s2r.Gmaxlim2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1);
plot(fact, min(sum(s2r.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1); % 1 x nt
plot(fact, max(sum(s2r.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1);

%plot(fact, winde2, 'b', 'LineWidth', 2);
%hold on;
%plot(fact, winde2d, 'Color', [0.8 0 0], 'LineWidth', 2);
%plot(fact, winda2', 'Color', [0 0.6 0], 'LineWidth', 2);
%plot(fact, min(sum(s2r.Gmaxlim2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1); % 1 x nt
%plot(fact, max(sum(s2r.Gmaxlim2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1);
%plot(fact, min(sum(s2r.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1); % 1 x nt
%plot(fact, max(sum(s2r.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1);
%plot(fact, min(sum(s2d.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0.8 0 0], 'LineWidth', 1); % 1 x nt
%plot(fact, max(sum(s2d.Pg2(idwind, trange, :, 1), 1), [], 3), '-.', 'Color', [0.8 0 0], 'LineWidth', 1);

%plot(fact, min(min(sum(s2r.Gmaxlim2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1); % 1 x nt
%plot(fact, max(max(sum(s2r.Gmaxlim2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0 0.6 0], 'LineWidth', 1);
%plot(fact, min(min(sum(s2r.Pg2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1); % 1 x nt
%plot(fact, max(max(sum(s2r.Pg2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0 0 1], 'LineWidth', 1);
%plot(fact, min(min(sum(s2d.Pg2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0.8 0 0], 'LineWidth', 1); % 1 x nt
%plot(fact, max(max(sum(s2d.Pg2(idwind, trange, :, :), 1), [], 4), [], 3), '-.', 'Color', [0.8 0 0], 'LineWidth', 1);

% the following is less conservative, but does not show a real case
%plot(fact, sum(s2rMa(idwind, trange), 1), '-.', 'Color', [0 0.6 0], 'LineWidth', 1); % 1 x nt
%plot(fact, sum(s2rma(idwind, trange), 1), '-.', 'Color', [0 0.6 0], 'LineWidth', 1);
%plot(fact, sum(s2rMp(idwind, trange), 1), '-.', 'Color', [0 0 1], 'LineWidth', 1); % 1 x nt
%plot(fact, sum(s2rmp(idwind, trange), 1), '-.', 'Color', [0 0 1], 'LineWidth', 1);
%plot(fact, sum(s2dMp(idwind, trange), 1), '-.', 'Color', [0.8 0 0], 'LineWidth', 1); % 1 x nt
%plot(fact, sum(s2dmp(idwind, trange), 1), '-.', 'Color', [0.8 0 0], 'LineWidth', 1);

hold off;
v = axis;
hold off;
v = axis;
v(1:2) = [fact(1) fact(end)];
axis(v);
title(sprintf('Total Wind Power Availability and Dispatch'), 'FontSize', 27, 'FontName', 'Times New Roman');
%title(sprintf('Total Wind Power Availability and Dispatch'), 'FontSize', 18, 'FontName', 'Times New Roman');
%title(sprintf('Real Total Wind Output, 2 set.'), 'FontSize', 18, 'FontName', 'Times New Roman');
%ylabel('Power, MW', 'FontSize', 16, 'FontName', 'Times New Roman');
%xlabel(my_xlabel, 'FontSize', 16, 'FontName', 'Times New Roman');
ylabel('Power, MW', 'FontSize', 22, 'FontName', 'Times New Roman');
xlabel(my_xlabel, 'FontSize', 22, 'FontName', 'Times New Roman');
%lnames = {'E[dispatch]', 'E[available]', 'Min[dispatch]', 'Max[dispatch]', 'Min[available]', 'Max[available]'};
%lnames = {'E[dispatch] Stc', 'E[dispatch] Det', 'E[available]', 'Min[available]', 'Max[available]'};
%lnames = {'E[dispatch] Stc', 'E[dispatch] Det', 'E[available]'};
%lnames = {'Expected Wind Dispatch, Stochastic', 'Expected Wind Dispatch, Deterministic', 'Wind Availability (Expected + Min/Max Range)'};
%lnames = {'Wind Dispatch, Stochastic (Expected + Min/Max Range)', 'Wind Dispatch, Deterministic (Expected + Min/Max Range)', 'Wind Availability (Expected + Min/Max Range)'};
lnames = {'Wind Power Dispatch', 'Realized Wind Power Availability'};
%legend(lnames, 'Location', 'EastOutside', 'FontName', 'Times New Roman');
legend(lnames, 'Location', 'Best', 'FontName', 'Times New Roman');
set(gca,'XTick',fact')
%set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
h = gcf;
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
pdf_name = sprintf('windinpaper_rep.pdf');
print('-dpdf',[fn_prefix pdf_name]);
close;
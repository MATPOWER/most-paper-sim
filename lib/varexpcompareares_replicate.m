function varexpcompareares_replicate(simname, configf, theta_info)
% Creates area plots of the variance and expected value as a function of the reserve level, only for deterministic run
%
% 
% Assumptions
% order of 
%   -dirplots
%   - datal
%   - dataln
%  variables should correspond to put meaningful legends and save files properly
%
% 2015.12.07
% 2018.03.01
% Alberto J. Lamadrid

%configf = configfajl1;              % configuration directory structure files
%configf = configfraptor2;            % configuration directory structure files
%configf = configfraptor2;           % configuration directory structure files

%dprefix = '/Users/ajlamadrid/Copy/matlab/results/';  % mine
%dprefix = '/Users/matlabuser/Documents/alberto/matlab/results/';  % raptor
%dprefix = '/Volumes/Drive 2/shares/alberto/';  % raptor2
%dprefix = '/Volumes/shares/alberto/';  % raptor2 when logged from local

%varint = {'5'};
%varint = {'5', '10'};
%varint = {'1', '3'};
%simnameroot = 'tr_c118_500ucr10_';     % base directory
%simnameroot = 'tr_c118_500uc';
%simnameroot = 'tr_c118_500ucr10_3';
%dprefixt = '/Users/ajlamadrid/Copy/matlab/results/';

%ct2 = 2;
%simname = sprintf('%s%s', simnameroot, varint{ct2});
simnamepath = sprintf('%s%s', configf.outputs, simname);
save_dir = sprintf('%s%s/outputs/', configf.outputs, simname);

%legend1 = {'[0.6-1.2] 7 points, 500 tr'};
legend1 = {'[0.6-1.2] 25 points, 500 tr'};

vval = [1.5e6 3e6;
      .1e5 7e5];                    % determine yaxis so they are consistent

plot_setup()

sto = 1;                            % location of stochasti runs
det = 2;                            % location of deterministic runs
Ecost  = 1;                         % energy cost
Rcost  = 2;                         % reserve cost
Lcost  = 3;                         % load not served (lns) cost
R2cost = 4;                         % second stage (real-time) reserve cost
UCcost = 5;                         % unit commitment cost
Tcost  = 6;                         % total cost

dirplots = [
Ecost 
Rcost 
Lcost 
R2cost
UCcost
Tcost 
];                                  % list of plots to be included

datal = {'Fuel Cost', 'DA Reserve', 'LNS', 'RT Reserve', 'Commitment', 'Total Cost'};
%dataln = {
%'Ecost'
%'Rcost'
%'Lcost'
%'R2cost'
%'UCcost'
%'Tcost'
%};

dataln = {
'Energy'
'Day-ahead Reserves'
'Load Not Served'
'Real-Time Reserves'
'Unit Commitment'
'Tcost'
};

%theta_len = 7;
%theta_len = 25; % too much space
theta_len = theta_info{1};
theta_min = theta_info{2};
theta_max = theta_info{3};
theta1 = linspace(theta_min,theta_max,theta_len);
%resf = sprintf('%s/outputs/comp/%s_compfxst2.mat', simnamepath, simname);
resf = sprintf('%s/outputs/comp/%s_compfxst2va_replicate.mat', simnamepath, simname);
data1 = load(resf);

%stackplots = {'Average', 'St. Dev.'};
stackplots = {'Average'};
%stackname = {'av', 'sd'};
stackname = {'av'};

for ct= 1:length(dirplots)          % each row has a different component of the cost, only deterministic
    tableav1(ct, :) = data1.data{sto}.average(:, dirplots(ct));
    tablesd1(ct, :) = data1.data{sto}.stddev(:, dirplots(ct));
    tableav2(ct, :) = data1.data{det}.average(:, dirplots(ct));
    tablesd2(ct, :) = data1.data{det}.stddev(:, dirplots(ct));
end

for ct= 1:length(stackplots)          % create a plot for each component of the cost
  % --------
  fig=figure;                         % deterministic
  nom = sprintf('%sc118%s_stackfres_rep', save_dir, stackname{ct});
  eval(sprintf('h = area(theta1, transpose(table%s2([Ecost, Rcost, Lcost, R2cost, UCcost], :)));', stackname{ct}));
  set(h(1),'FaceColor',[0.8 0 0])   % fcost 1
  set(h(2),'FaceColor',[0 0 1])     % rcost 4
  set(h(3),'FaceColor',[1 0.75 0.15])% lcost 6
  set(h(4),'FaceColor',[1 0.5 0.5]) % rcost2 5
%  set(h(2),'FaceColor',[0 0.8 0])  % nlcost 2
  set(h(5),'FaceColor',[0.2 0 0.5]) %  uc 3
  title(sprintf('%s System Costs, Det.', stackplots{ct}), 'FontSize', 18, 'FontName', 'Times New Roman');
  ylabel('E[Costs] $/Period', 'FontSize', 16, 'FontName', 'Times New Roman');
  xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
  set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
  datal = dataln(1:5);
  legend(datal, 'Location', 'Best', 'FontName', 'Times New Roman');
  h = gca;
  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

  h = gcf;
  set(h, 'PaperOrientation', 'landscape');
  set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
  eval(sprintf('print -dpdf ''%s''', nom));
%  close

  fig=figure;                       % stochastic
  nom = sprintf('%sc118%s_stackfresh_rep', save_dir, stackname{ct});
  subplot(1, 2, 1, 'align');
  infobar = eval(sprintf('table%s1([Ecost, Rcost, Lcost, R2cost, UCcost], :)', stackname{ct}));
  infobar(length(infobar), 2) = 0;
  h = bar(infobar', 'stacked');
  ax = axis;
  ax(2) = 1.6; %Change axis limit
  warning('manually fixing axes');
  ax(3:4) = vval(ct, :);
  axis(ax);
%  eval(sprintf('h = bar((table%s1([Ecost, Rcost, Lcost, R2cost, UCcost], :)), ''stacked'');', stackname{ct}));
  set(h(1),'FaceColor',[0.8 0 0])   % fcost 1
  set(h(2),'FaceColor',[0 0 1])     % rcost 4
  set(h(3),'FaceColor',[1 0.75 0.15])% lcost 6
  set(h(4),'FaceColor',[1 0.5 0.5]) % rcost2 5
%  set(h(2),'FaceColor',[0 0.8 0])  % nlcost 2
  set(h(5),'FaceColor',[0.2 0 0.5]) %  uc 3
%  title(sprintf('Stochastic', stackplots{ct}), 'FontSize', 18, 'FontName', 'Times New Roman');
  title(sprintf('Stochastic', stackplots{ct}), 'FontSize', 25, 'FontName', 'Times New Roman');
  ylabel('Expected Average System Costs ($/Period)', 'FontSize', 22, 'FontName', 'Times New Roman');
%  ylabel('Expected Average System Costs ($/Period)', 'FontSize', 16, 'FontName', 'Times New Roman');  
%  xlabel('Reserve Scaling Factor', 'FontSize', 16, 'FontName', 'Times New Roman');
  datal = dataln(1:5);
  legend(datal, 'Location', 'Best', 'FontName', 'Times New Roman', 'FontSize', 18);
  h = gca;
  set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
%  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

  subplot(1, 2, 2, 'align');        % deterministic
  eval(sprintf('h = area(theta1, transpose(table%s2([Ecost, Rcost, Lcost, R2cost, UCcost], :)));', stackname{ct}));
  ax = axis;
  warning('manually fixing axes');
  ax(3:4) = vval(ct, :);
  axis(ax);
  set(h(1),'FaceColor',[0.8 0 0])   % fcost 1
  set(h(2),'FaceColor',[0 0 1])     % rcost 4
  set(h(3),'FaceColor',[1 0.75 0.15])% lcost 6
  set(h(4),'FaceColor',[1 0.5 0.5]) % rcost2 5
%  set(h(2),'FaceColor',[0 0.8 0])  % nlcost 2
  set(h(5),'FaceColor',[0.2 0 0.5]) %  uc 3
  title(sprintf('Deterministic', stackplots{ct}), 'FontSize', 25, 'FontName', 'Times New Roman');
  ylabel('Expected Average System Costs ($/Period)', 'FontSize', 22, 'FontName', 'Times New Roman');
  xlabel('Reserve Scaling Factor', 'FontSize', 22, 'FontName', 'Times New Roman');
%  title(sprintf('Deterministic', stackplots{ct}), 'FontSize', 18, 'FontName', 'Times New Roman');
%  ylabel('Expected Average System Costs ($/Period)', 'FontSize', 16, 'FontName', 'Times New Roman');
%  xlabel('Reserve Scaling Factor', 'FontSize', 16, 'FontName', 'Times New Roman');
  datal = dataln(1:5);
  legend(datal, 'Location', 'Best', 'FontName', 'Times New Roman', 'FontSize', 18);
  h = gca;
  set(gca, 'FontSize', 22, 'FontName', 'Times New Roman');
%  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

  h = gcf;
  set(h, 'PaperOrientation', 'landscape');
  set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
  eval(sprintf('print -dpdf ''%s''', nom));
%  close

  fig=figure;                       % stochastic
  nom = sprintf('%sc118%s_stackfresv_rep', save_dir, stackname{ct});
  subplot(2, 1, 1, 'align');
  infobar = eval(sprintf('table%s1([Ecost, Rcost, Lcost, R2cost, UCcost], :)', stackname{ct}));
  infobar(length(infobar), 2) = 0;
  h = bar(infobar', 'stacked');
  ax = axis;
  ax(2) = 1.6; %Change axis limit
  warning('manually fixing axes');
  ax(3:4) = vval(ct, :);
  axis(ax);
%  eval(sprintf('h = bar((table%s1([Ecost, Rcost, Lcost, R2cost, UCcost], :)), ''stacked'');', stackname{ct}));
  set(h(1),'FaceColor',[0.8 0 0])   % fcost 1
  set(h(2),'FaceColor',[0 0 1])     % rcost 4
  set(h(3),'FaceColor',[1 0.75 0.15])% lcost 6
  set(h(4),'FaceColor',[1 0.5 0.5]) % rcost2 5
%  set(h(2),'FaceColor',[0 0.8 0])  % nlcost 2
  set(h(5),'FaceColor',[0.2 0 0.5]) %  uc 3
  title(sprintf('%s System Costs, Stochastic', stackplots{ct}), 'FontSize', 18, 'FontName', 'Times New Roman');
  ylabel('E[Costs] $/Period', 'FontSize', 16, 'FontName', 'Times New Roman');
  xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
  set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
  datal = dataln(1:5);
  legend(datal, 'Location', 'Best', 'FontName', 'Times New Roman');
  h = gca;
  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

  subplot(2, 1, 2, 'align');        % deterministic
  eval(sprintf('h = area(theta1, transpose(table%s2([Ecost, Rcost, Lcost, R2cost, UCcost], :)));', stackname{ct}));
  ax = axis;
  warning('manually fixing axes');
  if ct ==1
    ax(4) = 3e6;
  else
    ax(4) = 7e5;
  end
  axis(ax);
  set(h(1),'FaceColor',[0.8 0 0])   % fcost 1
  set(h(2),'FaceColor',[0 0 1])     % rcost 4
  set(h(3),'FaceColor',[1 0.75 0.15])% lcost 6
  set(h(4),'FaceColor',[1 0.5 0.5]) % rcost2 5
%  set(h(2),'FaceColor',[0 0.8 0])  % nlcost 2
  set(h(5),'FaceColor',[0.2 0 0.5]) %  uc 3
  title(sprintf('%s System Costs, Deterministic', stackplots{ct}), 'FontSize', 18, 'FontName', 'Times New Roman');
  ylabel('E[Costs] $/Period', 'FontSize', 16, 'FontName', 'Times New Roman');
  xlabel('Scaling factor Reserves', 'FontSize', 16, 'FontName', 'Times New Roman');
  set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
  datal = dataln(1:5);
  legend(datal, 'Location', 'Best', 'FontName', 'Times New Roman');
  h = gca;
  set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');

  h = gcf;
  set(h, 'PaperOrientation', 'landscape');
  set(h, 'PaperPosition', [0.25 0.25 10.5 8]);
  eval(sprintf('print -dpdf ''%s''', nom));
%  close

end
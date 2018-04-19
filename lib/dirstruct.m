function [varargout] = dirstruct(configf, simname, savetr, s1cont, s2cont, s1datan, s2datan, res2name, s1plots, s1fdatan, s1fplots, res2namef)

% Information on directory structure
%
% Assumptions
% - 14 outputs
% - delete savefiles2f?
%
% Alberto J. Lamadrid
% 2015.02.03

if nargin < 12
  res2namef = 'trajf';              % short name for results of second stage (to save)
  if nargin<11
    s1fplots = 's1f_plots';         % name of mat file with s1 fixed data for plots
    if nargin <10
      s1fdatan = 's1f-data';        % name of mat file with s1 fixed data
      if nargin<9
        s1plots = 's1_plots';       % name of directory s1 data for plots
        if nargin<8
          res2name = 'traj';        % short name for results of second stage (to save)
          if nargin<7
            s2datan = 's2-data';    % name of mat file with s2 data
            if nargin <6
              s1datan = 's1-data';  % name of mat file with s1 data
              if nargin <5
                s2cont = 0;         % stage 2 counter
                if nargin <4
                  s1cont = 0;       % stage 1 counter
                  if nargin <3
                    savetr = 0;     % simulation counter
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

savefiledirs1 = sprintf('%s%s/work/stage1/%3.3i/', ...
  configf.workdir, simname, savetr);% directory for stage 1 results
savefiles1 = sprintf('%s%s/work/stage1/%3.3i/results_%3.3i', ...
  configf.workdir, simname, savetr, s1cont);% file for stage 1 results
savefiledirs2 = sprintf('%s%s/work/stage2/%3.3i/', ...
  configf.workdir, simname, savetr);% directory for stage 2 results
savefiles2 = sprintf('%s%s/work/stage2/%3.3i/results_%3.3i', ...
  configf.workdir, simname, savetr, s2cont);% file for stage 2 results
savefileresds1 = sprintf('%s%s/outputs/stage1/%3.3i/', ...
  configf.outputs, simname, savetr);% directory for processed outputs, s1
savefileress1 = sprintf('%s%s/outputs/stage1/%3.3i/%s', ...
  configf.outputs, simname, savetr, s1datan);% file for processed outputs, s1
savefileresds2 = sprintf('%s%s/outputs/stage2/%3.3i/', ...
  configf.outputs, simname, savetr);% directory for processed outputs, s2
savefileress2 = sprintf('%s%s/outputs/stage2/%3.3i/%s', ...
  configf.outputs, simname, savetr, s2datan);% file for processed outputs, s2
savefilelog = [configf.workdir, simname, ...% save log for all runs, includes prefix
  '/outputs/', sprintf('%s_log', simname)];
savefileplots1 = sprintf('%s%s/outputs/stage1/%3.3i/%s', ...
  configf.outputs, simname, savetr, s1plots);% file for plots data, directory same name
s1inputs = sprintf('%s%s/inputs/stage1/%3.3i/%3.3i/', configf.inputs, simname, savetr, s1cont);
strinputs = sprintf('%s%s/inputs/trajectory/', configf.inputs, simname);
savefiles1f = sprintf('%s%s/workdir/stage1/%3.3i/results_fr_%3.3i', ...
  configf.workdir, simname, savetr, s1cont);% file for stage 1 results, fixed
savefiles2f = sprintf('%s%s/workdir/stage2/%3.3i/results_fr_%3.3i', ...
  configf.workdir, simname, savetr, s2cont);% file for stage 2 results, fixed
savefileress1f = sprintf('%s%s/outputs/stage1/%3.3i/%s', ...
  configf.outputs, simname, savetr, s1fdatan);% file for processed outputs, s1
savefileplots1f = sprintf('%s%s/outputs/stage1/%3.3i/%s', ...
  configf.outputs, simname, savetr, s1fplots);% file for plots data, directory same name
savefiletrs2 = sprintf('%s%s/outputs/stage2/%3.3i/%s', ...
  configf.outputs, simname, savetr, res2name);% file for trajectory results s2
savefiletrs2f = sprintf('%s%s/outputs/stage2/%3.3i/%s', ...
  configf.outputs, simname, savetr, res2namef);% file for trajectory results s2


avoutv = {'savefiledirs1', 'savefiles1', 'savefiledirs2', 'savefiles2'...
      'savefileresds1', 'savefileress1', 'savefileresds2', 'savefileress2', ...
      'savefilelog', 'savefileplots1', 's1inputs', 'strinputs', ...
      'savefiles1f', 'savefileress1f', 'savefileplots1f', ...
      'savefiletrs2', 'savefiletrs2f', ...
%      'savefiles2f'
      };

for st = 1:nargout  
  varargout{st} = eval(avoutv{st});
end
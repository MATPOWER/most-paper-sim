function plot_setup()
% Plots setup: Run after loading data and before plotting

%factor = 0.7;
factor = 0.8;
font = factor*30;
%font_size_axes = font - 8;
%font_size_legend = font - 8;
font_size_axes = font-0;
font_size_legend = font-0;
font_name_axes = 'Arial';
smfont = 0.8;   % Font size reducer factor for axis labels and legend
Papersize = factor*[15 12];
PaperPos = [0.25 0.25 10.5 8];
set(0, 'defaultTextInterpreter', 'tex');

linew = 2;

plot_variance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color);

% Colors
blue        = [0 .48 .65]/1;    % cerulean (blue)
purple      = [128 0 242]/255;    % Purple
lightblue   = [128 204 242]/255;  % Blue light
orange      = [.91 .41 .17]/1;    % Deep carrot orange
white       = [1 1 1];

line1       = [1 0 0];
line2       = [0 0 0];

color1 = [128 0 242]/255;   % Purple
color2 = [128 204 242]/255; % Blue light
color3 = [.91 .41 .17]/1;   % Deep carrot orange
color4 = [1 1 1];           % White

line1 = [1 0 0];
line2 = [0 0 0];


% Color for error plot figure
%color3 = lightblue;





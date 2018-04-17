% Information on storage sites
% 
% Assumptions
% - creates inputs for createess.m to add standard storage units
% 
% 2014.10.22
% Alberto J. Lamadrid

function inpe = storagedatac118(mpc)

inpw.wp_max = [
  300
];                                  % installed wind capacity


inpe.busge =  [
  3
];                                  % ess buses
ns = size(inpe.busge, 1);
inpe.ee_max = inpw.wp_max * 1.5;    % max energy cap., 15% of pmax for wind
inpe.ee_min = zeros(ns, 1);         % min energy cap.
inpe.ep_max = inpe.ee_max/10;       % max power cap.
inpe.ep_min = -inpe.ep_max;         % min power cap.
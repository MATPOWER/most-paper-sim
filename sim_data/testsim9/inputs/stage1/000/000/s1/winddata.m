% Information on wind sites
% 
% Assumptions
% - creates inputs for createwind.m to add standard wind units
%  
% 2014.06.07
% Alberto J. Lamadrid

function inpw = winddatac9v1

inpw.busgw =  [
  6
];                                  % wind buses

inpw.wp_max = [
  100
];                                  % wind pmax
inpw.wfn = 0;                       % wind cost
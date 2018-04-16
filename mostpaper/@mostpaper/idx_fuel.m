function mpco = idx_fuel(mpci, opt)
%
% Creates fuel idx fields for use in mpc
%
% Inputs:
%   MPCI      :     Name of the directory where the run for the simulation is stored
%   OPT       :     Options for file
%     'saveit'      (true) flag to indicate whether to save info into output file
% 
% First checks if the fields are available
% If saveit, adds the fields to mpco
%
% Assumptions
% data on fuelcost is available in mpci.genfuel
% 
% Alberto J. Lamadrid
% 2015.03.11

if nargin<2
  opt.saveit = 1;
end

col = 0;
oil = 0;
ngi = 0;
ngc = 0;
hyd = 0;
nuk = 0;
win = 0;
ess = 0;
syn = 0;
ilo = 0;


if isfield(mpci, 'icoal')
  col = 1;
end
if isfield(mpci, 'ioil')
  oil = 1;
end
if isfield(mpci, 'ing')
  ngi = 1;
end
if isfield(mpci, 'ingcc')
  ngc = 1;
end
if isfield(mpci, 'ihydro')
  hyd = 1;
end
if isfield(mpci, 'inuke')
  nuk = 1;
end
if isfield(mpci, 'iwind')
  win = 1;
end
if isfield(mpci, 'iess')
  ess = 1;
end
if isfield(mpci, 'isyncgen')
  syn = 1;
end
if isfield(mpci, 'ilo')
  ilo = 1;
end

icoal = [];
ioil = [];
ing = [];
ingcc = [];
ihydro = [];
inuke = [];
iwind = [];
iess = [];
isyncgen = [];
ilo = [];
for i = 1:length(mpci.genfuel)
  if strcmp('coal', mpci.genfuel{i})
    icoal = [ icoal; i];
  elseif strcmp('oil', mpci.genfuel{i})
    ioil = [ ioil; i];
  elseif strcmp('hydro', mpci.genfuel{i})
    ihydro = [ ihydro; i];
  elseif strcmp('ng', mpci.genfuel{i})
    ing = [ ing; i];
  elseif strcmp('ngcc', mpci.genfuel{i})
    ingcc = [ ingcc; i];
  elseif strcmp('nuke', mpci.genfuel{i})
    inuke = [ inuke; i];
  elseif strcmp('wind', mpci.genfuel{i})
    iwind = [ iwind; i];
  elseif strcmp('ess', mpci.genfuel{i})
    iess = [ iess; i];
  elseif strcmp('syncgen', mpci.genfuel{i})
    isyncgen = [ isyncgen; i];
  elseif strcmp('na', mpci.genfuel{i})
    ilo = [ilo; i];    
  else
    warning('unrecognized fuel type');
  end
end

% for exisitng fields, check they are consistent
if col
  warning('Existing field, keeping original, max difference %d', max(icoal-mpci.icoal));
  icoal = mpci.icoal;
end
if oil
  warning('Existing field, keeping original, max difference %d', max(ioil-mpci.ioil));
  ioil =  mpci.ioil;
end
if ngi
  warning('Existing field, keeping original, max difference %d', max(ing-mpci.ing));
  ing = mpci.ing;
end
if ngc
  warning('Existing field, keeping original, max difference %d', max(ingcc-mpci.ingcc));
  ing = mpci.ing;
end
if hyd
  warning('Existing field, keeping original, max difference %d', max(ihydro-mpci.ihydro));
  ihydro = mpci.ihydro; 
end
if nuk
  warning('Existing field, keeping original, max difference %d', max(inuke-mpci.inuke));
  inuke = mpci.inuke; 
end
if win
  warning('Existing field, keeping original, max difference %d', max(iwind-mpci.iwind));
  iwind = mpci.iwind; 
end
if ess
  warning('Existing field, keeping original, max difference %d', max(iess-mpci.iess));
  iess = mpci.iess; 
end
if syn
  warning('Existing field, keeping original, max difference %d', max(isyncgen-mpci.isyncgen));
  isyncgen = mpci.isyncgen; 
end
if ilo
  warning('Existing field, keeping original, max difference %d', max(ilo-mpci.ilo));
  ilo = mpci.ilo;
end

mpco = mpci;
if opt.saveit
  mpco.icoal = icoal;
  mpco.ioil = ioil;
  mpco.ing = ing;
  mpco.ingcc = ingcc;
  mpco.ihydro = ihydro;
  mpco.inuke = inuke;
  mpco.iwind = iwind;
  mpco.iess = iess;
  mpco.isyncgen = isyncgen;
  mpco.ilo = ilo;
end
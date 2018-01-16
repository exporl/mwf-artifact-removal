% Retrieve subject identifier from numerical index. This allows to specify
% subjects as number from 1-10 for easier handling in code (looping,...).
%
% INPUTS:
%   id      numerical index corresponding to subject
%
% OUTPUTS: 
%   name    subject identifier (string)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [name] = get_name_from_id(id)

switch id
    case 1
        name = 'alex';
    case 2
        name = 'anneleen';
    case 3
        name = 'hanneke';
    case 4
        name = 'janpeter';
    case 5
        name = 'jeroen';
    case 6
        name = 'jonas';
    case 7
        name = 'lorenz';
    case 8
        name = 'olivia';
    case 9
        name = 'otto';
    case 10
        name = 'steven';
    otherwise
        error('Error: invalid name specifier');
end

end


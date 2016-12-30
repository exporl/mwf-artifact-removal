function [name] = get_name(id)
% Return one of the 10 subject names, depending on index id.
%
% The names are ordered alphabetically:
% alex, anneleen, hanneke, jan-peter, jeroen, jonas, lorenz, olivia, otto, steven

switch id
    case 1
        name = 'alex';
    case 2
        name = 'anneleen';
    case 3
        name = 'hanneke';
    case 4
        name = 'jan-peter';
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


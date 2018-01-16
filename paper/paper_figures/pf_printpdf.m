% Print generated figure to pdf.
%
% INPUTS:
%   h       figure handle
%   name    pdf file name
%   ext     file extension: 'pdf' (default), 'eps'
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function pf_printpdf(h, name, ext)

if nargin < 3
    ext = 'pdf';
end

if ~strcmp(h.Renderer,'painters')
    h.Renderer = 'Painters';
    warning('Setting figure renderer to Painters for vector graphics')
end

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

switch ext
    case 'pdf'
        print(h, name,'-dpdf','-r0')
    case 'eps'
        print(h, name, '-depsc2', '-loose', '-r0');
    otherwise
        error('Unknown file extension');
end

end

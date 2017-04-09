% save figure as pdf cropped to content size
function pf_printpdf(h, name)
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h, name,'-dpdf','-r0')
end

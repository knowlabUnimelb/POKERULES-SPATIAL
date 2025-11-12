function plotSIC(tsic, sic, sichi, siclo, mint, maxt, MIC, newfig, nrows, ncols, subplotloc)

if newfig
    figure('WindowStyle', 'docked')
end

subplot(nrows, ncols, subplotloc)

hsic = plot(tsic, sic);
hold on
set(hsic, 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)

hsicCI = plot(tsic, sichi, '--b', tsic, siclo, '--b');
set(hsicCI, 'LineWidth', 1)

xlabel('t', 'FontSize', 14)
ylabel('SIC(t)', 'FontSize', 14)
axis tight
l = line([mint maxt], [0 0]); set(l, 'Color', 'k')
set(gca,'FontSize', 14)
title(sprintf('MIC = %4.2f', MIC), 'FontSize', 20)
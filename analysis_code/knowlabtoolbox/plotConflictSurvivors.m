function plotConflictSurvivors(tccf, eccf, mint, maxt, newfig, nrows, ncols, subplotloc)

if newfig
    figure('WindowStyle', 'docked')
end

subplot(nrows, ncols, subplotloc)

hs = plot(tccf, eccf);
set(hs(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
set(hs(2), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
set(hs(3), 'Color', 'b', 'LineStyle', '-' , 'LineWidth', 2)
set(hs(4), 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2)
legend(hs, 'AH', 'AL', 'BH', 'BL')
xlabel('t', 'FontSize', 14)
ylabel('P (T > t)', 'FontSize', 14)
axis([mint maxt 0 1])
set(gca,'FontSize', 14)
title('Survivor Functions', 'FontSize', 14)
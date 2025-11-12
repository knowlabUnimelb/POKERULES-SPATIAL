function plotSurvivors(tsic, tsf, mint, maxt, newfig, nrows, ncols, subplotloc)

if newfig
    figure('WindowStyle', 'docked')
end

subplot(nrows, ncols, subplotloc)
hold on

hs = plot(tsic, tsf(:, 4:-1:1));
set(hs(4), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
set(hs(3), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
set(hs(2), 'Color', 'b', 'LineStyle', '-' , 'LineWidth', 2)
set(hs(1), 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2)
legend(hs, 'LL', 'LH', 'HL', 'HH')
xlabel('t', 'FontSize', 14)
ylabel('P (T > t)', 'FontSize', 14)
axis([mint maxt 0 1])
set(gca,'FontSize', 14)
title('Survivor Functions', 'FontSize', 14)
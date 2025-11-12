function plotCCF(tccf, ccf, ccfhi, ccflo, mint, maxt, Mccf, newfig, nrows, ncols, subplotloc)

if newfig
    figure('WindowStyle', 'docked')
end

subplot(nrows, ncols, subplotloc)

sm = 2; % 2 * std boot

plot(tccf, zeros(1, length(tccf)), '-k');
hold on

hc = plot(tccf, ccf);
set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
hold on
hcCI = plot(tccf, ccfhi, '--b', tccf,  ccflo, '--b');    % plot 95% Confidence Interval
set(hcCI, 'LineWidth', 1)
title(sprintf('Mean_{CCF} = %4.2f', Mccf), 'FontSize', 14)
xlabel('t', 'FontSize', 14)
ylabel('CCF(t)', 'FontSize', 14)
set(gca,'FontSize', 12, 'XLim', [mint maxt])
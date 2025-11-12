function plotMeans(d, dimensions, newfig, nrows, ncols, subplotloc)

if newfig
    figure('WindowStyle', 'docked')
end

targ = [mean(d{4}) mean(d{2}) mean(d{3}) mean(d{1})]';
targerr = [std(d{4})/sqrt(length(d{4})) std(d{2})/sqrt(length(d{2})) std(d{3})/sqrt(length(d{3})) std(d{1})/sqrt(length(d{1}))]';

cont = [mean(d{5}) mean(d{6}) mean(d{7}) mean(d{8}) mean(d{9})]';
conterr = [std(d{5})/sqrt(length(d{5})) std(d{6})/sqrt(length(d{6})) std(d{7})/sqrt(length(d{7})) std(d{8})/sqrt(length(d{8})) std(d{9})/sqrt(length(d{9}))]';

lowYlim = floor((min([targ; cont] - [targerr; conterr]) - 50)/100) * 100;
highYlim = lowYlim + ceil(max([max([targ; cont] + [targerr; conterr]) - lowYlim + 50, 600])/100) * 100;
    

%% Target Category
subplot(nrows, ncols, subplotloc)
hold on
e1 = errorbar(1:2, targ(1:2), targerr(1:2), '-k');
set(e1, 'LineWidth', 2)
e2 = errorbar(1:2, targ(3:4), targerr(3:4), '--k');
set(e2, 'LineWidth', 2)

h = plot(1:2, targ(1:2), '-ko', 1:2, targ(3:4), '--ko');
set(gca,'XLim', [.5 2.5], 'XTick', [1 2], 'XTickLabel', {'L', 'H'}, 'YLim', [lowYlim highYlim], 'FontSize', 12);
title('Target Category Mean RTs', 'FontSize', 14)
    
set(h(1), 'MarkerFaceColor', [0 0 0], 'LineWidth', 2, 'MarkerSize',10)
set(h(2), 'MarkerFaceColor', [1 1 1], 'LineWidth', 2, 'MarkerSize',10)
legend(sprintf('Low (%s)', dimensions{2}), sprintf('High (%s)', dimensions{2}), 'Location', 'NorthEast')
xlabel(dimensions{1}, 'FontSize', 14)
box on

%% Contrast Category
subplot(nrows, ncols, subplotloc+1)
hold on
e3 = errorbar(1, cont(5), conterr(1)); set(e3, 'LineStyle', 'none', 'Color', [0 0 0]);
set(e3, 'LineWidth', 2)
e4 = errorbar(2:3, cont([2 1]), conterr([2 1]), '-k');
set(e4, 'LineWidth', 2)
e5 = errorbar(2:3, cont([4 3]), conterr([4 3]), '-k');
set(e5, 'LineWidth', 2)

h2 = plot(1, cont(5), ' sk', 2:3, cont([4 3]), '-ko', 2:3, cont([2 1]), '-kd');

set(gca,'XLim', [.5 3.5], 'XTick', [1 2 3], 'XTickLabel', {'R', 'I', 'E'});
set(h2(1), 'MarkerFaceColor', [1 1 1], 'LineWidth', 2, 'MarkerSize',10)
set(h2(2), 'MarkerFaceColor', [1 1 1], 'LineWidth', 2, 'MarkerSize',10)
set(h2(3), 'MarkerFaceColor', [0 0 0], 'LineWidth', 2, 'MarkerSize',10)

legend(h2([2 3 1]), dimensions{2}, dimensions{1}, 'Redundant', 'Location', 'NorthWest')

box on
set(gca,'YLim', [lowYlim highYlim],'FontSize', 12)
xlabel('Interior-Exterior', 'FontSize', 14)
ylabel('Mean RT (ms)', 'FontSize', 14)
title('Contrast Category Mean RTs', 'FontSize', 14)
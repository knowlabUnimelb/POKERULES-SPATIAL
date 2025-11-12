function anova = runANOVA(data, cols, channelCodes, dimensions, anovaTable)

data(:,strcmp(cols, 'rt')) = data(:,strcmp(cols, 'rt'))/1000;

anovadata = data(:, [find(strcmp('sub', cols)), find(strcmp('ses', cols)), find(strcmp('itm', cols)), find(strcmp('rt', cols))]);
anovadata(:,5:6) = channelCodes(data(:,strcmp(cols, 'itm')), :);

x = anovadata(ismember(anovadata(:,3), 1:4), [3 5 6 4]);
%targ = aggregate(x, [2 3], 4, [],1); 
%mic = targ(1) - targ(2) - targ(3) + targ(4);
%targstd = aggregate(x, [2 3], 4, @std,1); targcnt = aggregate(x, [2 3], 4, @count,1);
%targerr = targstd./sqrt(targcnt);


[p, t1, stats, terms] = anovan(x(:,4), {x(:,2), x(:,3)},...
    'varnames', dimensions, 'model', 'full', 'display', anovaTable);
    
% Run sessions anova
sessionX = anovadata(ismember(anovadata(:,3), 1:4), [2 3 5 6 4]);
[anovap, t2, stats, terms] = anovan(sessionX(:,5), {sessionX(:,1), sessionX(:,3), sessionX(:,4)},...
    'varnames', ['Sessions', dimensions], 'model', 'full', 'display', anovaTable);
    
anova.t1 = t1; 
anova.t2 = t2; 
function pd = makePriorDistribution(varname, hyperprior)

switch varname
    case {'db1', 'db2', 'sp1', 'sp2','A', 'bMa1', 'bMa2', 's', 't0', 'pX',...
            'm', 'pSer', 'pSerTarg','pSerCont','Aser', 'Apar', 'rmu', 'rSigma',...
            'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8', 'v9'}
        pd = makedist('Normal', 'mu', hyperprior(1), 'sigma', hyperprior(2)); % Sample starting points from a truncated normal
end
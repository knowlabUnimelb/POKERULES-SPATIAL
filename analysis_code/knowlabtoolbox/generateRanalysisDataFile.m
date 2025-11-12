function rdata = generateRanalysisDataFile(data, cols, channelCodes)

cedata = sortrows(data, find(strcmp(cols, 'itm')));
rdata = cedata(:,mstrfind(cols, {'sub', 'con',  'rt', 'acc', 'itm'}));
rdata(:,6:7) = zeros(size(rdata, 1),2);

for i = 1:size(rdata,1)
    rdata(i, 6:7) = channelCodes(rdata(i,5),:);
end
rdata(:,5) = [];
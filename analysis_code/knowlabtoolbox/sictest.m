function result = sictest(HH, HL, LH, LL, sic)
% Test significance of sic

N = 1/(1/length(HH) + 1/length(HL) + 1/length(LH) + 1/length(LL));

result.Dplus = max([0; sic]);
result.p_Dplus = exp(-2 * N * result.Dplus.^2);
result.Dplus_alternativeH = 'the SIC is above 0 at some time';

result.Dminus = abs(min([0; sic]));
result.p_Dminus = exp(-2 * N * result.Dminus.^2);
result.Dminus_alternativeH = 'the SIC is below 0 at some time';

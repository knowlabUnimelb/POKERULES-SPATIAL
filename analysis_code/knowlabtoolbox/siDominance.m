function result = siDominance(HH, HL, LH, LL)
% Test stochastic dominance by comparing distributions
%
% ksTest2 tests the null hypothesis that data in vectors x1 and x2 comes from 
% populations with the same distribution, against the alternative hypothesis 
% that the cdf of the distribution of x1 is larger than the cdf of the 
% distribution of x2.

% REMEMBER THIS TESTS THE CDF, NOT THE SURVIVOR FUNCTION

% Test stochastic dominance
% HH vs HL - should be significant
[result.h.hh_vs_hl, result.p.hh_vs_hl, result.k.hh_vs_hl] = kstest2(HH, HL, 'Tail', 'larger');
% HH vs LH - should be significant
[result.h.hh_vs_lh, result.p.hh_vs_lh, result.k.hh_vs_lh] = kstest2(HH, LH, 'Tail', 'larger');
% HL vs LL - should be significant
[result.h.hl_vs_ll, result.p.hl_vs_ll, result.k.hl_vs_ll] = kstest2(HL, LL, 'Tail', 'larger');
% LH vs LL - should be significant
[result.h.lh_vs_ll, result.p.lh_vs_ll, result.k.lh_vs_ll] = kstest2(LH, LL, 'Tail', 'larger');

% HL vs HH - should be nonsignificant
[result.h.hl_vs_hh, result.p.hl_vs_hh, result.k.hl_vs_hh] = kstest2(HL, HH, 'Tail', 'larger');
% LH vs HL - should be nonsignificant
[result.h.lh_vs_hh, result.p.lh_vs_hh, result.k.lh_vs_hh] = kstest2(LH, HH, 'Tail', 'larger');
% LL vs HL - should be nonsignificant
[result.h.ll_vs_hl, result.p.ll_vs_hl, result.k.ll_vs_hl] = kstest2(LL, HL, 'Tail', 'larger');
% LL vs LH - should be nonsignificant
[result.h.ll_vs_lh, result.p.ll_vs_lh, result.k.ll_vs_lh] = kstest2(LL, LH, 'Tail', 'larger');



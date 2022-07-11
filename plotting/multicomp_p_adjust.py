import statsmodels.stats.multitest as multi

def p_adjusted_multicomp(ps, multicomp_method='holm'):
    reject, ps_adjusted, _, _ = multi.multipletests(ps, method=multicomp_method)
    return reject, ps_adjusted

if __name__ == '__main__':
    reject, ps_adjusted = p_adjusted_multicomp([0.019,0.10,0.032,0.052])
    reject_bonferroni, ps_bonferroni = p_adjusted_multicomp([0.019,0.10,0.032,0.052])
    print("adjusted p values: {}".format(ps_adjusted))
    print("reject Null Hypothesis: {}".format(reject))
    print("adjusted p values: {}".format(ps_bonferroni))
    print("reject Null Hypothesis: {}".format(reject_bonferroni))
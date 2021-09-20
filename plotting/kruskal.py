import scipy
import pandas as pd
import statsmodels
import statsmodels.stats.multicomp as multi
from statsmodels.stats.multicomp import (MultiComparison)

import scipy.stats as stats
x = [1, 3, 5, 7, 9]
y = [2, 4, 6, 8, 10]
z = [2, 2, 2, 3, 5]


def kruskal(*args):
    localargs = locals()['args']
    print(localargs)
    statsk = stats.kruskal(*args)
    print(statsk)
    df = pd.DataFrame(localargs)
    print(df)
    stacked_data = df.stack().reset_index()
    print(stacked_data)
    stacked_data = stacked_data.rename(columns={'level_0': 'genotype',

                                                0: 'result'})
    print(stacked_data)
    MultiComp = MultiComparison(stacked_data['result'],
                                stacked_data['genotype'])
    print(MultiComp.allpairtest(stats.mannwhitneyu, method='Holm'))


kruskal(x, y, z)

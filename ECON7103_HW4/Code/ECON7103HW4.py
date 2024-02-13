#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 10 22:50:28 2024

@author: sedators
"""

# Clear all
from IPython import get_ipython
get_ipython().magic('reset -sf')

import math
import os
from pathlib import Path

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import statsmodels.api as sm
import statsmodels.formula.api as smf
from scipy import stats
import statistics

datapath = Path('/Users/sedators/Documents/GitHub/phdee-2024-db/homework4')
outputpath = Path('/Users/sedators/Documents/GitHub/phdee-202-so/ECON7103HW4/Output')

data = pd.read_csv(datapath / 'fishbycatch.csv')
data2 = pd.wide_to_long(data, ['salmon', 'shrimp', 'bycatch'], i='firm', j='month')
data2 = data2.reset_index()

# Q1
control = data2[(data2['treated'] == 0)]
treated = data2[(data2['treated'] == 1)]
treated2 = treated.groupby(['month']).mean('bycatch').reset_index()
control2 = control.groupby(['month']).mean('bycatch').reset_index()

fig, ax = plt.subplots()
plt.ticklabel_format(style='plain')
for frame, color, label in zip([control2, treated2], ['red', 'yellow'], ['Control', 'Treated']):
    ax.plot(frame['month'], frame['bycatch'], color=color, label=label)

ax.axvline(x=12.5, color='blue', linestyle='dashed')  
ax.set_xlabel('Month')
ax.set_ylabel('Bycatch')
ax.set_title('Treated - Control')
ax.legend()
plt.savefig(outputpath / 'HW4Q1.pdf', format='pdf')
plt.show()

#Q2
differt1 = data2[(data2['treated'] == 1) & (data2['month'] == 12)]['bycatch'].mean()
differt2 = data2[(data2['treated'] == 1) & (data2['month'] == 13)]['bycatch'].mean()
differ1 = differt2 - differt1

differc1 = data2[(data2['treated'] == 0) & (data2['month'] == 12)]['bycatch'].mean()
differc2 = data2[(data2['treated'] == 0) & (data2['month'] == 13)]['bycatch'].mean()
differ2 = differc2 - differc1

diff = differ1 - differ2
print(diff)

#Q3

time = data2[(data2['month'] == 12) | (data2['month'] == 13)]
time['lambda'] = 0 
time.loc[data2['month'] == 12, 'lambda'] = 1
time['treatment'] = 0
time.loc[data2['treated'] == 1, 'treatment'] = 1
time['timetr'] = 0
time.loc[(time['treatment'] == 1) & (time ['month'] == 13) , 'timetr'] = 1

regress1 = sm.OLS(time['bycatch'], sm.add_constant(time[['lambda', 'treatment', 'timetr']]))
results = regress1.fit()

robust = results.get_robustcov_results(cov_type='cluster', groups=time['firm'])
coef = np.round(robust.params, 2) 
params = len(coef)
nobs = np.array(robust.nobs)

con = pd.DataFrame(np.round(robust.conf_int(), 2)) 
conr = '(' + con.loc[:,0].map(str) + ', ' + con.loc[:,1].map(str) + ')'
result = pd.DataFrame(pd.concat([pd.Series(np.append(coef,nobs)),conr],axis=1).stack()) 
result.columns = ['(1)']
result.index = pd.concat([pd.Series(['Alpha','Pre period','Treatment','Time Treated','After-treatment']), pd.Series([' ']*params)], axis=1).stack()

dummyv = pd.get_dummies(data2['month'], prefix='time')
data2['timetr'] = 0 
data2.loc[(data2['treated'] == 1) & (data2['month'] > 12), 'timetr'] = 1

xvar = pd.concat([data2[['treated', 'timetr']], dummyv], axis=1) 
yvar = data2['bycatch']
regres2 = sm.OLS(yvar, sm.add_constant(xvar)).fit()

robust2 = regres2.get_robustcov_results(cov_type='cluster', groups=data2['firm'])

coef = np.round(robust2.params,2) 
params, = np.shape(coef)

nobs2 = np.array(robust2.nobs)


con2 = pd.DataFrame(np.round(robust2.conf_int(),2)) 
conr2 = '(' + con2.loc[:,0].map(str) + ', ' + con2.loc[:,1].map(str) + ')'

result2 = pd.DataFrame(pd.concat([pd.Series(np.append(coef,nobs2)),conr2],axis = 1).stack())
result2.columns = ['(2)'] 
result2.index = pd.concat([pd.Series(['Alpha','Treatment','Time Treated','dummy','dummy','dummy', 'dummy', 'dummy', 'dummy','dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'After-Treatment']),pd.Series([' ']*params)], axis = 1).stack()




yvar2 = data2['bycatch']
dummyv2 = pd.get_dummies(data2['month'],prefix = 'time',drop_first = True)
xvar2 = pd.concat([data2[['treated','timetr','shrimp','salmon','firmsize']],dummyv2],axis = 1)

regress3 = sm.OLS(yvar2,sm.add_constant(xvar2)).fit()


robust3 = regress3.get_robustcov_results(cov_type = 'cluster', groups = data2['firm'])



coef3 = np.round(robust3.params,2) 
params3, = np.shape(coef3) 

nobs3 = np.array(robust3.nobs) 


con3 = pd.DataFrame(np.round(robust3.conf_int(),2)) 
conr3 = '(' + con3.loc[:,0].map(str) + ', ' + con3.loc[:,1].map(str) + ')' 

result3 = pd.DataFrame(pd.concat([pd.Series(np.append(coef3,nobs3)),conr3],axis = 1).stack())

result3.columns = ['(3)']

result3.index = pd.concat([pd.Series(['Alpha','Treatment','Time Treated', 'shrimp', 'salmon', 'firmsize', 'dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'dummy','dummy','dummy', 'dummy', 'dummy', 'dummy', 'dummy','dummy','dummy', 'dummy', 'dummy', 'After Treatment']),pd.Series(['']*params3)], axis = 1).stack()


pd.set_option('display.max_columns', 3)
pd.set_option('display.max_rows', 123)

total = pd.concat([result, result2, result3], axis=0)

total

total.to_latex('HW4Q3.tex')
print()


from IPython import get_ipython
get_ipython().magic('reset -sf')


# Import packages
import os
import numpy as np
import pandas as pd
import random
import statsmodels.api as sm
from linearmodels.iv import IVGMM
from scipy import stats
from pathlib import Path
from stargazer.stargazer import Stargazer as stargazer
from stargazer.stargazer import LineLocation
from linearmodels.iv import IV2SLS, IVGMM
from stargazer.stargazer import Stargazer, LineLocation
import pickle
import math
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm
import statistics
import scipy
import rdrobust
from scipy import stats
from pathlib import Path
from stargazer.stargazer import Stargazer as stargazer
from stargazer.stargazer import LineLocation
from linearmodels.iv import IV2SLS, IVGMM
from rdrobust import rdbwselect
from rdrobust import rdplot
from rdd import rdd
from statsmodels.graphics.regressionplots import abline_plot
from statsmodels.sandbox.regression.predstd import wls_prediction_std

datapath = r'/Users/sedators/Documents/GitHub/phdee-2023-db/'
outputpath = r'/Users/sedators/Documents/GitHub/phdee-2024-SO/ECON7103HW7/Output'

os.chdir(outputpath)

random.seed(96333)
np.random.seed(5659)

data = pd.read_csv(r'/Users/sedators/Documents/GitHub/phdee-2023-db/homework5/instrumentalvehicles.csv')

#Q2

cutoff = 225
mpg = data['mpg']
length = data['length']
lengthcut = data['length'] - cutoff
treated = (length>225)*1
lengthcutabove = lengthcut*treated

plt.scatter(lengthcut, mpg, facecolors='none', edgecolors='green')
plt.axvline(linewidth=2, color='black', linestyle='solid')
plt.xlabel('distance to cutoff')
plt.ylabel('mpg')
plt.savefig('HW6Q2.pdf', format='pdf')
plt.show()


#Q3


lengthcutabove=lengthcut*treated

regressdis = sm.OLS(mpg,sm.add_constant(pd.concat([lengthcut,treated,lengthcutabove],axis=1),prepend = False)).fit()
regressdiscoeff = regressdis.params

print(regressdiscoeff)

np.savetxt('regressdiscoeffQ3.txt', regressdiscoeff)




data['lc'] = data['length'] - cutoff
data['treated'] = (data['length'] > cutoff).astype(int)
treated = data['treated']

mpg = data['mpg']
length = data['length']
lc = data['lc']


length = data['length']

differ1 = data[data['length'] < 225]

y_var1 = differ1['mpg']
x_var1 = differ1['lc']

regressl = sm.OLS(y_var1, sm.add_constant(x_var1)).fit()


differ2 = data[data['length'] > 224]

y_var2 = differ2['mpg']
x_var2 = differ2['lc']

regressr = sm.OLS(y_var2, sm.add_constant(x_var2)).fit()

fig, ax = plt.subplots()


ax.plot(x_var1, y_var1, 'o', color='red', label='Length < 225')
ax.plot(x_var1, regressl.fittedvalues, '--', color='green')


ax.plot(x_var2, y_var2, 'p', color='yellow', label='Length > 224')
ax.plot(x_var2, regressr.fittedvalues, '--', color='green')

ax.axvline(x=0, color='black')

plt.xlabel('Distance to cutoff')
plt.ylabel('MPG')

ax.legend(loc='best')
plt.savefig('HW6Q3a.pdf', format='pdf')


plt.ylabel('MPG')
plt.savefig('HW6Q3a.pdf',format='pdf')

regresst3 = sm.OLS(data['mpg'], sm.add_constant(data[['treated', 'lc']])).fit(cov_type='HC1')


result3 = stargazer([regresst3])
result3.covariate_order(['treated', 'lc', 'const'])
result3.rename_covariates({'lc':'Length minus Cutoff','treated':'Treated', 'Const': 'Const'})
result3.significant_digits(2)
result3.show_degrees_of_freedom(False)
result3

tex_file = open('HW6Q3a.tex', "w" )
tex_file.write( result3.render_latex() )
tex_file.close()

#Q4

data['lc2'] = data['lc'] ** 2

left = data[data['treated'] == 0]

right = data[data['treated'] == 1]

poly_right = np.polyfit(right['lc'], right['mpg'], 2)
poly_left = np.polyfit(left['lc'], left['mpg'], 2)

right['fitted_y'] = np.polyval(poly_right, right['lc'])
left['fitted_y'] = np.polyval(poly_left, left['lc'])

fig, ax = plt.subplots()


mask = data['lc'] < 0
ax.scatter(data[mask]['lc'], data[mask]['mpg'], color='red', label='Before Cutoff')
ax.plot(data[mask]['lc'], poly_left[0] * data[mask]['lc'] ** 2 + poly_left[1] * data[mask]['lc'] + poly_left[2], '--', color='green')


mask = data['lc'] >= 0
ax.scatter(data[mask]['lc'], data[mask]['mpg'], color='yellow', label='After Cutoff')
ax.plot(data[mask]['lc'], poly_right[0] * data[mask]['lc'] ** 2 + poly_right[1] * data[mask]['lc'] + poly_right[2], '--', color='green')

ax.axvline(x=0, color='black')

ax.set_xlabel('Distance to cutoff')
ax.set_ylabel('MPG')
ax.legend()

plt.savefig('HW6Q4a.pdf', format='pdf')


te = poly_right[1] - poly_left[0]
print(f'Treatment effect: {te:.2f}')



#Q5


data['lc2'] = data['lc'] ** 2

left = data[data['treated'] == 0]

right = data[data['treated'] == 1]

poly_right2 = np.polyfit(right['lc'], right['mpg'], 5)
poly_left2 = np.polyfit(left['lc'], left['mpg'], 5)

right['fitted_y2'] = np.polyval(poly_right2, right['lc'])
left['fitted_y2'] = np.polyval(poly_left2, left['lc'])

fig, ax = plt.subplots()

mask = data['lc'] < 0
ax.scatter(data[mask]['lc'], data[mask]['mpg'], color='red', label='Before Cutoff')
ax.plot(data[mask]['lc'], np.polyval(poly_left2, data[mask]['lc']), '--', color='green')


mask = data['lc'] >= 0
ax.scatter(data[mask]['lc'], data[mask]['mpg'], color='yellow', label='After Cutoff')
ax.plot(data[mask]['lc'], np.polyval(poly_right2, data[mask]['lc']), '--', color='green')

ax.axvline(x=0, color='black')

ax.set_xlabel('Distance to cutoff')
ax.set_ylabel('MPG')
ax.legend()

plt.savefig('HW6Q5a.pdf', format='pdf')


te3 = poly_right[1] - poly_left[0]
print(f'Treatment effect: {te:.2f}')


#Q6


yvar = data['price']
car = data['car']

treated = treated.rename('Treatment')
lengthcutabove = lengthcutabove.rename('Length X Treat')

ivest = IV2SLS(yvar,sm.add_constant(car,prepend = False),mpg,pd.concat([lengthcut,treated,lengthcutabove],axis=1)).fit(cov_type='robust')

beta = pd.DataFrame(np.round(ivest.params,2)).reindex(['car','mpg','const'])

ci = pd.DataFrame(np.round(ivest.conf_int(),2)).reindex(['car','mpg','const'])

cis = '(' + ci.loc[:,'lower'].map(str) + ', ' + ci.loc[:,'upper'].map(str) + ')'

regress6 = pd.DataFrame(pd.concat([beta,cis],axis = 1).stack())
regress6.columns = ['Q6']
regress6.index = ['Sedan',' ','MPG','','Constant','']
regress6 = regress6.append(pd.DataFrame([str(ivest.nobs)],index = ['Observations'],columns = ['Question 6']))

regress6.to_latex('HW6Q6.tex',column_format = 'lc', na_rep = ' ')




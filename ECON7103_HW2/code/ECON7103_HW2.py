#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 28 22:29:03 2024

@author: sedators
"""



from IPython import get_ipython
get_ipython().magic('reset -sf')

import os
import numpy as np
import pandas as pd
import scipy.stats as sc
import scipy.optimize as opt
import matplotlib.pyplot as plt
import seaborn as sns
import random
import statsmodels.api as sm
import statistics



datapath = r'/Users/sedators/Desktop/ECON7103_2024/phdee-2024-db-main/homework2'

outputpath = r'/Users/sedators/Desktop/ECON7103_2024/phdee-2024-so/ECON7103_HW2/output'
data = pd.read_csv( r'/Users/sedators/Desktop/ECON7103_2024/phdee-2024-db-main/homework2/kwh.csv')
data1= ['electricity', 'sqft', 'temp']
data2 = pd.DataFrame(data, columns = ['electricity','sqft','temp', 'retrofit'])

#Q1

control = data2.loc[data2['retrofit'] == 0]
treat= data2.loc[data2['retrofit'] == 1]
cols = ['electricity','sqft','temp']
nobs2 = data2.count().min()

rowname = pd.concat([pd.Series(['electricity','sqft','temp']), pd.Series(["", "", ""])], axis = 1).stack()
coloumnname = [("Control", "Mean", "(Std dev)"), ("Treat", "Mean", "(Std dev)"), ("", "p-value", "")]

cmean = control[cols].mean()
cmeans = cmean.map('{:.2f}'.format)
csd = control[cols].std()
csd1 = csd.map('{:.2f}'.format)


tmean = treat[cols].mean()
tmeans = tmean.map('{:.2f}'.format)
tsd = treat[cols].std()
tsd1 = tsd.map('{:.2f}'.format)

diff = cmean - tmean
diff = diff.map('{:.2f}'.format)

diff = sc.ttest_ind(control[cols], treat[cols])

pv = pd.Series(diff[1], index = ['electricity','sqft','temp'])
pv = pv.map('{:.2f}'.format)

col0 = pd.concat([cmeans,csd1],axis = 1).stack()
col1 = pd.concat([tmeans,tsd1],axis = 1).stack()
col0 = pd.DataFrame(col0)

nan = pd.Series(np.array(["","",""]), index = ['electricity','sqft','temp']) 
pn = pd.concat([pv,nan], axis = 1).stack()
tab = pd.concat([col0, col1, pn], axis = 1)
tab = pd.DataFrame(tab)

tab.row = rowname
tab.columns = pd.MultiIndex.from_tuples(coloumnname)
tab

os.chdir(outputpath) 
tab.to_latex('HW1py.tex') 

#Q2

colors = ['red', 'yellow']
sns.distplot(data[ data[ 'retrofit' ] == 0 ]['electricity'], hist=False, label='Did not receive retrofit', color = colors[0]) 
sns.distplot(data[ data[ 'retrofit' ] == 1 ]['electricity'], hist=False, label='Received retrofit', color = colors[1])
plt.xlabel('Electricity Usage')
plt.savefig('HW2pyf.pdf',format='pdf') 
plt.show()

sns.histplot(data=data, x='electricity', hue='retrofit', kde=False, multiple='stack', palette=colors)

# Set axis labels and legend
plt.xlabel('Electricity Usage')
plt.ylabel('Count')
plt.legend(title='Retrofit', labels=['Did not receive retrofit', 'Received retrofit'])

# Save and show plot
plt.savefig('histogram.pdf', format='pdf')
plt.show()
#Q3

#to find the betas, we can use matrix eguation of beta 

#Q3a)

N = data.shape[0]
Y = data.electricity.values[:,np.newaxis]

X = np.stack([np.ones((N,)), data.sqft.values, data.temp.values, data.retrofit.values], axis = 1)

betahat = np.linalg.inv(X.T @ X) @ X.T @ Y
b_hat = pd.DataFrame(betahat, index = ['Constant', 'sqft', 'temp', 'retrofit'], columns = ['Estimates'])

b_hat.to_latex('HW3apy).tex')

#Q3b)

def leastsq(beta,Y,X):
    return np.sum((Y-np.matmul(X,beta))**2)


betaols3b = opt.minimize(leastsq,np.array([0,1,1,1]).T, args = (Y, X)).x
nobs3b = Y.shape


#3c)

ols = sm.OLS(data['electricity'],sm.add_constant(data.drop('electricity',axis = 1))).fit()
olsresult = ols.summary()


betaols = ols.params.to_numpy() 
params, = np.shape(betaols)
nobs3 = int(ols.nobs)

betaols = np.round(betaols,2)
order = [1,2,0]
output = pd.DataFrame(np.column_stack([betaols])).reindex(order)

rownames = pd.Series(['sqft','retrofit','temp','Observations'])
colnames = ['Estimates']

Regreoutput = pd.DataFrame(output.stack().append(pd.Series(nobs3)))
output.index = rownames
output.columns = colnames

output.to_latex('HW3cPy).tex')





















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


datapath = r'/Users/sedators/Documents/GitHub/phdee-2024-db/homework5'
outputpath = r'/Users/sedators/Documents/GitHub/phdee-2024-so/ECON7103HW5/Output'

os.chdir(outputpath)

random.seed(96333)
np.random.seed(5659)

data = pd.read_csv(r'/Users/sedators/Documents/GitHub/phdee-2024-db/homework5/instrumentalvehicles.csv')

#Q1 
# Perform OLS regression
regress1 = sm.OLS(data['price'], sm.add_constant(data[['mpg', 'car']])).fit()

# Save regression results to a text file
with open('regression_results.txt', 'w') as f:
    f.write(regress1.summary2().as_text())

#Q2 Endogeneity explain

#Q3a

# Define variables
y_var = data.price
x1_var = data.car
x2_var = data.mpg
z_var = data[['height', 'car']]

# First-stage regression
FSLS = sm.OLS(x2_var, sm.add_constant(z_var)).fit()
mpg = FSLS.fittedvalues

# Calculate F-statistic for instrument
fstat = (FSLS.tvalues['height'])**2
fstats = round(fstat, 2)

# Second-stage regression
xv = pd.concat([x1_var, mpg], axis=1)
xv.columns = ['Car', 'MPG']
SSLS = sm.OLS(y_var, sm.add_constant(xv)).fit()

# Print summary of regression results
print(SSLS.summary())

with open('regression_results2.txt', 'w') as f:
    f.write(SSLS.summary2().as_text())

#Q3b

# Define variables
y = data['price']
x2 = data['car']
y2 = data['mpg']
data['weight2'] = data['weight'].apply(lambda x: x ** 2)
z2 = data[['weight2', 'car']]

# First-stage regression
z_c2 = sm.add_constant(z2)
FSLS2 = sm.OLS(y2, z_c2).fit()
mpg2 = FSLS2.fittedvalues

# Calculate F-statistic for instrument
fstat2 = (FSLS2.tvalues['weight2'])**2
fstats2 = round(fstat2, 2)

# Second-stage regression
x_c2 = sm.add_constant(pd.concat([x2, mpg2], axis=1))
x_c2.columns = ['Const', 'Car', 'MPG']
SSLS2 = sm.OLS(y, x_c2).fit()

# Print summary of regression results
print(SSLS2.summary())

with open('regression_results3.txt', 'w') as f:
    f.write(SSLS2.summary2().as_text())
    
#Q3c)

# Define variables
y3 = data['mpg']
x3 = data['car']
z3 = data[['height', 'car']]

# First-stage regression
z_c3 = sm.add_constant(z3)
FSLS3 = sm.OLS(y3, z_c3).fit()
mpg3 = FSLS3.fittedvalues

# Calculate F-statistic for instrument
fstat3 = FSLS3.tvalues['height'] ** 2
fstats3 = round(fstat3, 2)

# Second-stage regression
y23 = data['price']
x_c3 = sm.add_constant(pd.concat([x3, mpg3], axis=1))
x_c3.columns = ['Const', 'Car', 'MPG']
SSLS3 = sm.OLS(y23, x_c3).fit()

# Print summary of regression results
print(SSLS3.summary())
    
    
with open('regression_results4.txt', 'w') as f:
    f.write(SSLS3.summary2().as_text())
    

# Create Stargazer table
models = [SSLS, SSLS2, SSLS3]
f_stats = [fstats, fstats2, fstats3]
stargazer = stargazer(models)
stargazer.covariate_order(['MPG', 'Car', 'Const'])
stargazer.rename_covariates({'MPG': 'MPG', 'Car': 'Car type (Sedan)', 'Const': 'Constant'})
stargazer.add_line('F-test for Stage 1', f_stats, LineLocation.FOOTER_TOP)
stargazer.significant_digits(2)
stargazer.show_degrees_of_freedom(False)

tex_file = open('HW5Q3.tex', "w" ) #This will overwrite an existing file
tex_file.write( stargazer.render_latex() )
tex_file.close()


#Q4


# fit GMM model and save the result
GMMres_ = IVGMM.from_formula('price ~ 1 + car + [mpg ~ weight]', data).fit()
print(GMMres_)

# specify output path for pickled result
output_path = "gmm_result.pkl"

# save GMMres_ as a pickled object
with open(output_path, 'wb') as f:
    pickle.dump(GMMres_, f)


    
    


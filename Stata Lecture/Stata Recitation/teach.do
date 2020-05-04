clear
set more off
set seed 100		/* Set random seed to keep the results comparable */


cd "D:\Dropbox\Dropbox\My documents\Rochester\博五下\TA for ECO 485\Stata Recitation"
global folder "D:\Dropbox\Dropbox\My documents\Rochester\博五下\TA for ECO 485\Stata Recitation\data"		/* Sometimes you want to store your results in another folder */


capture log close
log using "$folder\Census_2010 Cleaning", replace t


/* Census data from China - household level survey - Each observation is a person */
/* id: personal identifier; hhid: household identifier */
use "$folder\census2010_1p.dta",clear


/* Change data format */
tostring hhid id, format(%100.0g) replace
destring id,replace

/* Labelling */
label var hhid "The ID of the household"		/* Label for variable */

label define sex_1 1 "male" 2 "female"			/* Label for values of a variable */
tab sex
label value sex sex_1 
tab sex

label define sex 1 "male" 
label define sex 2 "female",add
label value sex sex 

/*** Data Management ***/
describe sex
describe _all
des sex

summarize sex
sum sex

tabulate sex
tab sex

count if sex==1

kdensity income							/* Kernel-smoothed density function */

rename eduy education

gen age=2010-born_year					/* Generate new variables */

gen province=substr(prefect,1,2)		/* String variable functions */
destring province,replace

gen st1="hello"

gen st2=substr(st1,1,1)					/* substr(string, starting point, number of letters) */
gen st3=substr(st1,1,2)
gen st4=substr(st1,2,.)
gen st5=substr(st1,-2,2)


/* Change sex indicator */
gen sex1=.
replace sex1=0 if sex==1
replace sex1=1 if sex==2

order id hhid
sort id hhid

drop birthplace			/* Drop variable */
drop if literated==2	/* Drop observation */


/* Simulation - generate an income variable with log-normal distribution */
gen temp=rnormal()
gen income1=exp(temp)*10000			/* Random variable with a log-normal distribution */

gen rand_num=runiform()				/* Uniform distribution */

drop temp



/** egen function - Generate number of children in the HH **/
egen avg_income=mean(income)
egen tot_income=sum(income)

gen chi=1 if relation==2
replace chi=0 if relation!=2
egen numchi_hh=sum(chi),by(hhid)					/* by: means implement the function in each group of the categorical variable */
label var numchi_hh "Number of Children in HH"


/* xfill - Identify first child's information */
net from https://www.sealedenvelope.com/

/* Find who is the first child - the child with oldest birthday */
tostring born_year born_month, format(%100.0g) replace
replace born_month="0"+born_month if length(born_month)==1
gen born_date=born_year+born_month
destring born_date born_year born_month,replace

egen fc_date=min(born_date) if relation==2,by(hhid)
destring hhid,replace
xfill fc_date,i(hhid)
gen fc=1 if fc_date==born_date & relation==2
egen temp=sum(fc),by(hhid)

save "$folder\temp.dta",replace


/*** Regression ***/
reg education sex
reg education sex,r
reg education sex,cluster(province)
reg education sex i.province,r
reg education sex i.province sex#province,r
outreg2 using temp,tex replace keep(sex) ctitle(1)			/* Latex output of the regression table */

reg education sex##province,r

/* Regression with high-dimensional FE */
ssc install ftools
ssc install reghdfe

tostring age,replace
gen prefect_age=prefect+age
destring prefect_age,replace
reg education sex i.prefect_age,r

reghdfe education sex,absorb(prefect_age) vce(r)

/* Linear GMM */
ivregress 2sls numchi_hh nationality (education=born_year born_month),r
ivregress gmm numchi_hh nationality (education=born_year born_month),r
ivregress gmm numchi_hh nationality (education sex=born_year born_month),r


/*Postregression estimation */
reg education sex nationality
predict pre,xb
test sex=1
test (sex=1) (nationality=0)


/* Local */
forvalues i=1(1)10{
	a=i+1
	display a
	}
local t=10
forvalues i=1(1)`t'{
	local a=`i'+1
	display `a'
	}
	


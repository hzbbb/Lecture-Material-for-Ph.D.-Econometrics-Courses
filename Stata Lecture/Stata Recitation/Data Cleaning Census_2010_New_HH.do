****** Census 2010 Data Cleaning ******
/*
Input: census2010_1p.dta  Census 2010 original data
Output: census10 cleaned data.dta; Census_2010 Cleaning.txt
*/

clear
set more off
set maxvar 20000

global folder "D:\Dropbox\Dropbox\My documents\Rochester\博三下\TA for ECON 485\Stata Recitation"

capture log close
log using "$folder\Census_2010 Cleaning", replace t

use "$folder\census2010_1p.dta",clear
mvencode _all, mv(-999)



/* Rename and construct dummies for variables */
rename h1 hhid

rename r2 relation

rename r3 sex

rename r4_1 born_year

rename r4_2 born_month

tostring hhid locationcode, format(%100.0g) replace

/* Calculate age at Nov. 2010 */
gen age=2010-born_year
replace age=age-1 if born_month>=11			/* Census was implemented in Nov. 2010 */

rename r5 nationality

rename r6_1 living_place

rename r6_2 living_place_code  
tostring living_place_code, format(%100.0g) replace
replace living_place_code=substr(locationcode,1,6) if living_place<5

rename r7_1 hukou_place

rename r7_2 hukou_place_code
tostring hukou_place_code, format(%100.0g) replace
replace hukou_place_code=substr(locationcode,1,6) if hukou_place<4

rename r8 migtime

rename r9 migreason
replace migreason=-9 if migtime==1

drop r10

rename r11 hukoutype
replace hukoutype=0 if hukoutype==2
label var hukoutype "Whether holding agricultural Hukou" 

rename r12_1 birthplace

rename r12_2 birthprovince
tostring birthprovince, format(%100.0g) replace
replace birthprovince=substr(locationcode,1,2) if birthplace<3

rename r13_1 past_place
replace past_place=0 if past_place==2
label var past_place "Whether living in this province five years ago"

rename r13_2 past_province
tostring past_province, format(%100.0g) replace
replace past_province=substr(locationcode,1,2) if past_place==1

rename r14 literated

rename r15 education

rename r16 school_completion
replace school_completion=-9 if education==1

rename r17_1 working

rename r17_2 worktime
replace worktime=0 if working==2 | working==3

rename r18 industry
replace industry=-9 if working==3

rename r19 occupation
replace occupation=-9 if working==3

rename r20 unemp_reason
replace unemp_reason=-9 if working==1 | working==2

rename r21 huntjob
replace huntjob=-9 if working==1 | working==2
replace huntjob=-8 if unemp_reason==1
replace huntjob=-7 if unemp_reason==2

rename r22_1 ab_work
replace ab_work=-9 if working==1 | working==2
replace ab_work=-8 if unemp_reason==1
replace ab_work=-7 if unemp_reason==2

rename r22_2 unemp_time
replace unemp_time=0 if working==1 | working==2

rename r23 incomeresource

rename r24 marriage

rename r25_1 matime_year
rename r25_2 matime_month
gen matime=2010-matime_year if matime_year!=-999
replace matime=matime-1 if matime_month>=11 

rename r26_1 birth_b
rename r26_2 birth_g
rename r26_3 sur_b
rename r26_4 sur_g



mvdecode _all, mv(-9=.a \ -8=.b \ -7=.c \ -999=.d \)

sort hhid relation
egen numhhid=group(hhid)

/* Extract prefect from locationcode */
gen prefect=substr(locationcode,1,4)
destring prefect, replace


/* Identify the family Construction */
gen x=1
egen numpe=sum(x),by(hhid)
label var numpe "Number of People in the household"
drop x

gen x=1 if relation==0
egen numhh=sum(x),by(hhid)
drop x 
drop if numhh!=1			/* Drop the households with a number of head that is not equal to one */

gen x=1 if relation==1
egen numsp=sum(x),by(hhid)
drop x
drop if numsp>1				/* Drop the households with more than one head's spouse */

gen x=1 if relation==2
gen y=1 if relation==2 & sex==1
gen z=1 if relation==2 & sex==2
egen numchi_hh=sum(x),by(hhid)
label var numchi_hh "Number of Children in HH"
egen numboy_hh=sum(y),by(hhid)
label var numboy_hh "Number of Boys in HH"
egen numgirl_hh=sum(z),by(hhid)
label var numgirl_hh "Number of Girls in HH"
drop x y z

gen x=1 if relation==3
egen numpar_hh=sum(x),by(hhid)
label var numpar_hh "Number of Parents in HH"
drop x

gen x=1 if relation==4
egen numpinlaw_hh=sum(x),by(hhid)
label var numpinlaw_hh "Number of Parents-in-Law in HH"
drop x

gen x=1 if relation==5
egen numgrandpa_hh=sum(x),by(hhid)
label var numgrandpa_hh "Number of Grandparents in HH"
drop x

gen x=1 if relation==6
egen numcinlaw_hh=sum(x),by(hhid)
label var numcinlaw_hh "Number of Child-in-Law in HH"
drop x

gen x=1 if relation==7
egen numgrandch_hh=sum(x),by(hhid)
label var numgrandch "Number of Grandchild in HH"
drop x

gen x=1 if relation==8
egen numbrosis_hh=sum(x),by(hhid)
label var numbrosis_hh "Number of Brothers/Sisters in HH"
drop x

gen malehead=1 if (relation==0 | relation==1) & sex==1
replace malehead=0 if malehead==.
gen femalehead=1 if (relation==0 | relation==1) & sex==2
replace femalehead=0 if femalehead==.

egen numhh_m=sum(malehead),by(hhid)
egen numhh_f=sum(femalehead),by(hhid)
drop if numhh_m>1
drop if numhh_f>1							/* Drop households with more than one malehead or more than one femalehead */

gen x=1 if hukou_place==5 & (relation==0 | relation==1)
gen y=1 if living_place==6 & (relation==0 | relation==1)
replace x=0 if x!=1
replace y=0 if y!=1
egen t1=sum(x),by(hhid)
egen t2=sum(y),by(hhid)
drop if t1!=0								/*Drop those with undetermined hukou for HH head */
drop if t2!=0								/* Drop those migrating internationally for HH head*/

/* Calculate birth history */
gen child_born=birth_b+birth_g if femalehead==1
gen child_sur=sur_b+sur_g if femalehead==1
xfill child_born child_sur, i(numhhid)
keep if child_born==child_sur								/* Drop the individuals with dead children */

/* Keep only those in initial marriage */
gen hh_m_matime1=matime_year if malehead==1
gen hh_f_matime1=matime_year if femalehead==1
gen hh_m_matime2=matime_month if malehead==1
gen hh_f_matime2=matime_month if femalehead==1
xfill hh_m_matime1 hh_f_matime1 hh_m_matime2 hh_f_matime2, i(numhhid)

gen ma_hh_m=marriage if malehead==1
gen ma_hh_f=marriage if femalehead==1
xfill ma_hh_m ma_hh_f, i(numhhid)

keep if ma_hh_f==2											/* Drop those in status of divorce, unmarried or spouse-lost */
keep if ma_hh_m==2		
drop if hh_f_matime1!=hh_m_matime1
drop if hh_f_matime2!=hh_m_matime2							/* Drop those with a different initial marriage time for male and femalehead */


/* Identify first child's information */
keep if numchi_hh==child_sur								/* Keep the number of children in the household to be equal to number of children have ever born */

tostring born_year born_month, format(%100.0g) replace
replace born_month="0"+born_month if length(born_month)==1
gen born_date=born_year+born_month
destring born_date born_year born_month,replace
egen fc_date=min(born_date) if relation==2,by(hhid)
xfill fc_date, i(numhhid)
gen fc=1 if fc_date==born_date & relation==2
egen temp=sum(fc),by(hhid)
drop if temp!=1												/* Drop first-born twins and no child in the family */
drop temp

gen fc_sex=sex if fc==1
xfill fc_sex, i(numhhid)
gen fc_age=age if fc==1
xfill fc_age, i(numhhid)

keep if fc_age<=18											/* Keep the households with all the children to be under 18 */

gen head_hukou=hukou_place if relation==0
xfill head_hukou, i(numhhid)
keep if head_hukou==1										
gen temp=1 if head_hukou!=hukou_place & relation==1
replace temp=0 if temp==.
xfill temp, i(numhhid)
drop if temp==1
drop temp													/* Keep the original based households */


gen smchild=1 if relation==2 & age<=6						/* Generate the number of pre-school age children in household */
replace smchild=0 if smchild==.
egen preschild=sum(smchild), by(hhid)	


/* Keep only one-child and two-children families */
tab numchi_hh
drop if numchi_hh>2

/* Identify second child's information */
gen sc_date=born_date if fc!=1 & relation==2
xfill sc_date, i(numhhid)
gen sc=1 if sc_date==born_date & relation==2

egen temp=sum(sc),by(hhid)
drop if temp!=1 & temp!=0									/* Drop second-born twins in the family */
drop temp

gen sc_sex=sex if sc==1
xfill sc_sex, i(numhhid)
gen sc_age=age if sc==1
xfill sc_age, i(numhhid)


keep if femalehead==1 | malehead==1							/* Keep only household heads */
gen f_head_na=nationality if femalehead==1
gen m_head_na=nationality if malehead==1
xfill f_head_na m_head_na, i(numhhid)
keep if f_head_na==1 & m_head_na==1							/* Keep only both heads are Han */

/* Make sure all HHs have two heads */						
gen x=1
egen num_hh=sum(x),by(hhid)
drop if num_hh!=2

/* Redefine some dummies */
replace sex=0 if sex==1					/* Zero for boy, One for girl */
replace sex=1 if sex==2
replace fc_sex=0 if fc_sex==1
replace fc_sex=1 if fc_sex==2
replace sc_sex=0 if sc_sex==1
replace sc_sex=1 if sc_sex==2
replace literated=0 if literated==2		/* One for literated, zero for not */

save "$folder\census10 cleaned data.dta",replace


/* Merge information of male and female head in the household */
keep if femalehead==1

# delimit ;
local varlist "
age
sex 
born_year 
born_month 
nationality 
living_place 
living_place_code 
hukou_place 
hukou_place_code 
migtime 
migreason 
hukoutype 
birthplace 
birthprovince 
past_place 
past_province 
literated 
education 
school_completion 
working 
worktime 
industry 
occupation 
unemp_reason 
huntjob 
ab_work 
unemp_time 
incomeresource
";

#delimit cr


foreach var of local varlist {
	rename `var' f_`var'
	}

save "$folder\female temp.dta",replace

use "$folder\census10 cleaned data.dta",clear
keep if malehead==1
merge 1:1 hhid using "$folder\female temp.dta"
drop _merge


/* Further Restrictions */
keep if hukoutype==1 & f_hukoutype==1								/* Keep only rural samples */
tostring prefect, format(%100.0g) replace
gen province=substr(prefect,1,2)
destring prefect province,replace
drop if province==11 | province==12 | province==31 | province==32 | province==46 | province==50 | province==51 | province==53 | province==54 ///
 | province==63 | province==64 | province==65					/* Drop provinces without 1.5 Child Policy */
keep if age>=35 & f_age>=35

/* Drop redundant variables */
drop age_raw id numhh numsp numhh_m numhh_f hh_m_matime1 hh_f_matime1 hh_m_matime2 hh_f_matime2 ma_hh_m ma_hh_f fc_date fc smchild sc_date sc f_head_na m_head_na x num_hh malehead femalehead child_born child_sur born_date head_hukou

/* Tag for always takers */			
gen at=1 if numchi_hh==2 & fc_sex==0
replace at=0 if numchi_hh==1 & fc_sex==0

save "$folder\temp.dta",replace

/* Decompose categorical variables into dummies */
mvencode _all, mv(.a=-9 \ .b=-8 \ .c=-7 \ .d=-999 \)


# delimit ;
local varlist "
housetype 
housefloor 
housestrcture 
houseyear 
cookingresource 
tapwater 
kitchen 
restroom 
bath 
housebuying 
rent 
nationality 
living_place 
living_place_code 
hukou_place 
hukou_place_code 
migtime 
migreason 
birthplace 
birthprovince 
past_place 
past_province 
literated 
education 
school_completion 
working 
worktime
industry 
occupation 
unemp_reason 
huntjob 
ab_work 
unemp_time 
incomeresource
prefect 
f_nationality 
f_living_place 
f_living_place_code 
f_hukou_place 
f_hukou_place_code 
f_migtime 
f_migreason 
f_birthplace 
f_birthprovince 
f_past_place 
f_past_province 
f_literated 
f_education 
f_school_completion 
f_working 
f_worktime
f_industry 
f_occupation 
f_unemp_reason 
f_huntjob 
f_ab_work
f_unemp_time 
f_incomeresource
";

#delimit cr

foreach var of local varlist {
	tab `var',gen(`var')
	}



order hhid fc_sex sc_sex numchi_hh at housesquare houseroom age matime numpar_hh numpinlaw_hh numgrandpa_hh numcinlaw_hh numgrandch_hh numbrosis_hh f_age housetype1-f_incomeresource5
keep hhid fc_sex sc_sex numchi_hh at housesquare houseroom age matime numpar_hh numpinlaw_hh numgrandpa_hh numcinlaw_hh numgrandch_hh numbrosis_hh f_age housetype1-f_incomeresource5
save "$folder\census10 cleaned data.dta",replace



/* Dataset with only predetermined X */
# delimit ;
local varlist "
nationality 
living_place 
living_place_code 
hukou_place 
hukou_place_code  
birthplace 
birthprovince 
past_place 
past_province 
literated 
education 
school_completion
prefect 
f_nationality 
f_living_place 
f_living_place_code 
f_hukou_place 
f_hukou_place_code 
f_birthplace 
f_birthprovince 
f_past_place 
f_past_province 
f_literated 
f_education 
f_school_completion
";

#delimit cr

foreach var of local varlist {
	tab `var',gen(`var')
	}



order hhid fc_sex sc_sex numchi_hh at age matime numpar_hh numpinlaw_hh numgrandpa_hh numcinlaw_hh numgrandch_hh numbrosis_hh f_age nationality1-f_school_completion5
keep hhid fc_sex sc_sex numchi_hh at age matime numpar_hh numpinlaw_hh numgrandpa_hh numcinlaw_hh numgrandch_hh numbrosis_hh f_age nationality1-f_school_completion5
save "$folder\census10 cleaned data predetermined.dta",replace

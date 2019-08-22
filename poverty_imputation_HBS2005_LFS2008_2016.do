local years "2008 2009 2011 2012 2013 2014 2015 2016"
foreach i of local years {

tempfile LFS2008_2016
 use "Z:\Dropbox\WorldBank_Qi\St Lucia and Grenada Multi-year\St Lucia\Processed_Qi\lca_2008_2016.dta",clear 
//  use "/Users/yd/Dropbox/WorldBank_Qi/St Lucia and Grenada Multi-year/St Lucia/Processed_Qi/lca_2008_2016.dta", clear
quietly{
replace age_range=. if age_range>=15
recode age_range (1/3=1 0_14)(4/5=2 15_24)(6/8=3 25_40)(9/13=4 41_64)(14=5 above65), gen(age_group)

rename maxedu1 edu_group
rename unemploy2 unemployed
rename hhsize members

rename homeown own_home
rename vehic car
rename washer wash_machine
gen telef=(phone==1|cel==1)
rename rooms nex_room 
rename bedrooms n_bedroom

rename wgt weight
gen nweight = weight*members

rename hrs1 total_hrs
destring hhid, replace
gen survey = "LFS"

tab edu_group, gen(edu_group_)
tab age_group, gen(age_group_) 

gen member_sq = members*members

gen parish=dist
egen no_no_school	   =total(edu_group_1==1), by(hhid)
egen no_primary 	   =total(edu_group_2==1), by(hhid)
egen no_secondary      =total(edu_group_3==1), by(hhid)
egen no_tertiary       =total(edu_group_4==1), by(hhid)

gen occupation=1 if selfemp==1
replace occupation=2 if employer==1
replace occupation=3 if employee==1

label define occupation 1 self_employed 2 employer 3 employee
label values occupation occupation

tab occupation, gen(occupation_)
egen no_self_employed=total(occupation_1==1), by(hhid)
egen no_employer     =total(occupation_2==1), by(hhid)
egen no_employee     =total(occupation_3==1), by(hhid)

egen married=total(relation==2), by(hhid)
replace married =1 if married>0

keep if hhead==1
destring ed, replace
global head_char "married age_group age_group_1 age_group_2 age_group_3 age_group_4 age_group_5 edu_group edu_group_1 edu_group_2 edu_group_3 edu_group_4 unemployed sector occupation occupation_1 occupation_2 occupation_3"
global hh_char "urban parish no_self_employed no_employer no_employee no_no_school no_primary no_secondary no_tertiary members member_sq own_home wash_machine fridge telef n_bedroom car computer"

keep ed nweight weight survey year sex $head_char $hh_char 
keep if year==`i'
save `LFS2008_2016'
*


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// HBS 2005 preparation
tempfile HBS2005
use "Z:\Dropbox\Imputation\HBS\LCA 2005\lca_2005_SLC.dta",clear
rename p1_2 relation 
gen sex=0 if  p1_3 == 2 
replace sex=1 if  p1_3 == 1
gen age= p1_4
recode age (0/14=1 0_14)(15/24=2 15_24)(25/40=3 25_40)(41/64=4 41_64)(65/96=5 above65), gen(age_group)
gen edu_level = p4_23
recode edu_level (0/3 =1 no_school)(11/22=2 primary)(25/30=3 secondary)(31/41 = 4 tertiary)(else=.), gen(edu_group)
gen unemployed = unemp
gen members=hhsize
gen mem_sq=members^2

gen married=(p6_1>=1&p6_1<=3)

gen own_home=(h3_1==1|h3_1==2)
gen wash_machine = (h4_110>0)
gen fridge = (h4_18>0)
gen telef = (h4_11>0|h4_12>0) 
gen car = (h4_111>0)
gen computer = (h4_112>0)
 
gen n_bedroom = h3_101
replace n_bedroom=. if n_bedroom==99

gen elect_access=(h3_7==3|h3_7==4)

gen weight = wt
gen nweight=weight*members

gen cpi11=1.0619
gen pcexpae_def11=pcexpae/cpi11
gen povline_def11 = povline/cpi11
gen ln_pcexpae_def11=log(pcexpae_def11)
gen survey="HBS"
gen year=2005

tab edu_group, gen(edu_group_)
tab age_group, gen(age_group_) 

gen member_sq = members*members

tostring ed hhno, replace
gen hhid=ed+hhno

egen no_childr=total(age<15), by(hhid)
gen dependent_rate=no_childr/hhsize

recode p5_10 (4 6=1 self_employed)(5=2 employer)(1 2 3=3 employee) (else=. ), gen(occupation)
tab occupation, gen(occupation_)
egen no_self_employed=total(occupation_1==1), by(hhid)
egen no_employer     =total(occupation_2==1), by(hhid)
egen no_employee      =total(occupation_3==1), by(hhid)

recode p5_9 (1 2=1 agriculture)(3 4=2 manufacturing)(5 6 =3 construction)(16 17 =5 edu_health_social) ///
			(12 13 14 15 = 6 professional_service)(10 11=7 transportation)(7 8 =8 wholesale_trade)(9=9 hotel_restaurant) (18 19=10 other) (else=.), gen(sector)

egen no_no_school	   =total(edu_group_1==1), by(hhid)
egen no_primary 	   =total(edu_group_2==1), by(hhid)
egen no_secondary      =total(edu_group_3==1), by(hhid)
egen no_tertiary       =total(edu_group_4==1), by(hhid)

	gen				parish = district
	recode			parish (4=3) (6=4) (7=5) (8=6) (9=7) (10=8) (11=9) (12=10)
	label def		parish 	1 "Castries City" 2 "Castries Rural" 3 "Anse la Raye/Canaries" 4 "SoufriËre" ///
							5 "Choiseul" 6 "Laborie" 7 "Vieux Fort" 8 "Micoud" 9 "Dennery" 10 "Gros Islet"
	label val		parish parish
	label var		parish "District"
	gen				urban = (parish == 1 | parish == 2 | parish == 3 | parish == 6 | parish == 9 | parish == 12) if parish != .
	label var		urban "Urban locality"
	
	
global head_char "married age_group age_group_1 age_group_2 age_group_3 age_group_4 age_group_5 edu_group edu_group_1 edu_group_2 edu_group_3 edu_group_4 unemployed sector occupation occupation_1 occupation_2 occupation_3"
global hh_char "urban parish no_self_employed no_employer no_employee no_no_school no_primary no_secondary no_tertiary members member_sq own_home wash_machine fridge telef n_bedroom car computer"

keep if relation==1 // keep head only

keep cpi11 povline povline_def11 pcexpae pcexpae_def11 ln_pcexpae_def11 nweight weight survey year sex ed $head_char $hh_char 
destring ed, replace
append using `LFS2008_2016'

replace sector=10 if sector==4
drop if parish==0 | parish==.
tab parish, gen(parish_)
tab sector, gen(sector_)

replace povline 	 	=	6443 		if povline ==.
replace povline_def11	=	6067.426	if povline_def11==.

global head_char "married age_group_2-age_group_5 edu_group_2-edu_group_4 sector_2-sector_9 occupation_2 occupation_3"
global hh_char "own_home wash_machine fridge telef car computer"
global hh_con "n_bedroom"

svyset 	ed	[pw=nweight], strata(parish)

// impute missing values for all necessary variables
mi set mlong
mi register imputed  ln_pcexpae_def11 $head_char $hh_char $hh_con


// mi impute chained (regress) ln_pcexpae_def11 $hh_con (logit) $head_char $hh_char = sex [pw=nweight], augment add(10) rseed(1234) force noisily 
mi impute mvn ln_pcexpae_def11 $hh_con $head_char $hh_char = sex, add(10) rseed(1234) force noisily 

gen poverty=(pcexpae_def11<= povline_def11)

gen pcexpae_def11_hat=exp(ln_pcexpae_def11)
gen poverty_hat=(pcexpae_def11_hat<= povline_def11)
}
mi estimate: svy: mean poverty poverty_hat  if year==2005 & survey=="HBS"
dis `i'
mi estimate: svy: mean poverty poverty_hat if year==`i' & survey=="LFS"
}


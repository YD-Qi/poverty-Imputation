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
save `HBS2005'

// HBS DATA PREPERATION

use "Z:\Dropbox\Imputation\HBS\LCA 2016\LCA_2016_SLCHB_v01_M_v01_A_SEDLAC-03__deflated_all.dta",clear
// use "/Users/yd/Dropbox/Imputation/HBS/LCA 2016/LCA_2016_SLCHB_v01_M_v01_A_SEDLAC-03__deflated_all.dta", clear
rename (hombre edad casado nivel aedu ocupado unemp relab region_est2 urban)(sex age married edu_level edu_year employed unemployed employment_type med_region urban)
rename (miembros agua elect propieta auto moto bici tv_cable lavarropas heladera precaria)(members water_access elect_access own_home car motor bike tv wash_machine fridge bad_loc)
rename (gedad1 habita dormi banio cloacas)(age_group nex_room n_bedroom toilet toilet_sewer)
rename internet_casa internet 
rename deseo_emp xtrawork
rename contrato signed_contract
rename hstrt total_hrs
rename computadora computer
rename durades mo_unemp
rename id hhid 
rename ano_ocaux year
rename relacion relation

rename pondera weight
gen nweight = weight*members

gen pcexpae_def11 = pcexpae/cpi11
gen povline_def11 = povline/cpi11
gen ln_pcexpae_def11 = log(pcexpae_def11)

recode edu_level (0  =1 no_school)(1/2=2 primary)(3/4=3 secondary)(5/6 = 4 tertiary) (else=.), gen(edu_group)
tab edu_group, gen(edu_group_)
tab age_group, gen(age_group_) 

egen no_no_school	   =total(edu_group_1==1), by(hhid)
egen no_primary 	   =total(edu_group_2==1), by(hhid)
egen no_secondary      =total(edu_group_3==1), by(hhid)
egen no_tertiary       =total(edu_group_4==1), by(hhid)

gen occupation = 1 if employment_type==3
replace occupation=2 if employment_type==1
replace occupation=3 if employment_type==2
tab occupation, gen(occupation_)
egen no_self_employed=total(occupation_1==1), by(hhid)
egen no_employer     =total(occupation_2==1), by(hhid)
egen no_employee     =total(occupation_3==1), by(hhid)

drop sector
recode sector1d (1 2=1 agriculture)(4 = 2 manufacturing)(6 = 3 construction)(3 5 =4 mining_energy)(13 14 15 = 5 edu_health_social_service) ///
				(10 11 12 17= 6 professional_service)(9 = 7 tansportation)(7=8 wholesale_retail)(8 = 9 hotel_restaurants)(16 = 10 other), gen(sector)

	gen				parish = region_est1
	recode			parish (4=3) (6=4) (7=5) (8=6) (9=7) (10=8) (11=9) (12=10)
	label def		parish 	1 "Castries City" 2 "Castries Rural" 3 "Anse la Raye/Canaries" 4 "SoufriËre" ///
							5 "Choiseul" 6 "Laborie" 7 "Vieux Fort" 8 "Micoud" 9 "Dennery" 10 "Gros Islet"
	label val		parish parish
	label var		parish "District"
	drop urban
	gen				urban = (parish == 1 | parish == 2 | parish == 3 | parish == 6 | parish == 9 | parish == 12) if parish != .
	label var		urban "Urban locality"

gen member_sq = members*members
gen survey = "HBS"
keep if relation==1

global head_char "married age_group age_group_1 age_group_2 age_group_3 age_group_4 age_group_5 edu_group edu_group_1 edu_group_2 edu_group_3 edu_group_4 unemployed sector occupation occupation_1 occupation_2 occupation_3"
global hh_char "urban parish no_self_employed no_employer no_employee no_no_school no_primary no_secondary no_tertiary members member_sq own_home wash_machine fridge telef n_bedroom car computer"

keep ed cpi11 povline povline_def11 pcexpae pcexpae_def11 ln_pcexpae_def11 nweight weight survey year sex $head_char $hh_char 
append using `HBS2005'

replace sector=10 if sector==4
drop if parish==0 | parish==.
tab parish, gen(parish_)
tab sector, gen(sector_)

svyset 	ed	[pw=nweight], strata(parish)
gen poverty=(pcexpae_def11<=povline_def11)
svy: mean poverty if year==2005
svy: mean poverty if year==2016

gen ln_povline_def11=log(povline_def11)

global head_char "married age_group_2-age_group_5 edu_group_2-edu_group_4 sector_2-sector_9 occupation_2 occupation_3"
global hh_char "own_home wash_machine fridge telef car computer"
global hh_con "n_bedroom"

replace ln_pcexpae_def11=. if year==2005

// impute missing values for all necessary variables
mi set mlong
mi register imputed  ln_pcexpae_def11 $head_char $hh_char $hh_con


// mi impute chained (regress) ln_pcexpae_def11 $hh_con (logit) $head_char $hh_char = sex [pw=nweight], augment add(10) rseed(1234) force noisily 
mi impute mvn ln_pcexpae_def11 $hh_con $head_char $hh_char = sex, add(10) rseed(1234) force noisily 


gen pcexpae_def11_hat=exp(ln_pcexpae_def11)
gen poverty_hat=(pcexpae_def11_hat<= povline_def11)

mi estimate: svy: mean poverty poverty_hat if year==2016 & survey=="HBS"
mi estimate: svy: mean poverty poverty_hat if year==2005 & survey=="HBS"


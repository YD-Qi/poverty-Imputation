clear 

use "https://www.dropbox.com/s/kpniuza3u0ezo3t/LCA_2016_SLCHB_v01_M_v01_A_SEDLAC-03__deflated_all.dta?dl=1", clear


di 5

rename (hombre edad casado nivel aedu relab region_est2 urban)(sex age married edu_level edu_year employment_type med_region urban)
rename (miembros agua elect auto moto bici televisor lavarropas heladera precaria)(members water_access elect_access car motor bike tv wash_machine fridge bad_loc)
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

gen bank=0
replace bank=1 if p1_11__1>0 | p1_11__2>0

egen no_dependent	   =total(age<=14), by(hhid)

recode edu_level (0  =1 no_school)(1/2=2 primary)(3/4=3 secondary)(5/6 = 4 tertiary) (else=.), gen(edu_group)
gen own_home = (h1_5 == 1 | h1_5 == 2) if h1_5 !=.
gen own_land = (h1_4 == 1 | h1_4 == 2) if h1_4 !=.
gen priv_house =h1_1==1 if h1_1 !=.
gen poor_mat = (h1_2==1 | h1_2==6 | h1_2 ==7) if h1_2!=.
gen multi_job=0
replace multi_job = 1 if p4_9==1

gen n_room = 0
replace n_room=h1_14 if h1_14!=.
/*
gen rent=0
replace rent=log(c0421101/cpi11) if own_home==1 & c0421101>0
replace rent=log(c0411100/cpi11) if own_home==0 & c0411100>0
replace rent=log(c0421101/cpi11) if own_home==0 & c0411100==.& c0421101>0 
replace rent=. if c0421101==. & c0411100==.
gen int_rent = rent*own_home
gen int_rent2 = rent*(own_home==0)
*/
gen employed 	= (ocupado==1 & desocupa==0 & age>14)
gen unemployed	= (ocupado==0 & desocupa==1 & age>14)
gen not_LF		= (employed==0 & unemployed==0 & age>14)

gen 	emp_status	 =1 if 	employed	== 1 
replace emp_status	 =2 if 	unemployed  == 1
replace emp_status	 =3 if  not_LF		== 1
label 	def			emp_status 	1 "employed" 2 "unemployed" 3 "out of LF" 
label 	val			emp_status emp_status

gen 	occupation = 1	 if employment_type == 3 | (employment_type == 4) //self_employed 
replace occupation = 2	 if employment_type == 1 //employer
replace occupation = 3   if employment_type == 2  & inrange(p4_12,1,2) // public employee
replace occupation = 4   if (employment_type == 2 & p4_12>2)  // private employee including unpaid family workers

gen hr_work_a=0
replace hr_work_a=log(hstrp) if hstrp!=. & employed==1 & hstrp!=0

gen hr_work=0
replace hr_work=log(hstrp) if hstrp!=. & employed==1 & hstrp!=0

gen want_work = 0
replace want_work = 1 if xtrawork==1
//label 	def			occupation 	1 "self employed" 2 "employer" 3 "public employee" 4 "private employee" 0 "unemployed" 100 "out of LF"
//label 	val			occupation occupation

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
gen age_sq=age*age
gen survey = "HBS"

global head_char "sex relation hhid married age_group edu_group emp_status sector occupation unemployed emp_status hr_work hr_work_a want_work n_room poor_mat"
global hh_char "no_dependent urban parish members member_sq own_home wash_machine fridge telef n_bedroom car computer tv"

keep ed cpi11 povline povline_def11 pcexpae pcexpae_def11 ln_pcexpae_def11 nweight weight survey year $head_char $hh_char 

replace sector=10 if sector==4
drop if parish==0 | parish==.

replace povline 	 	=	6443 		if povline ==.
replace povline_def11	=	6067.426	if povline_def11==.


replace sector=0	if unemployed ==1
replace sector=100	if emp_status ==3 //out of LF

replace occupation = 0		if unemployed == 1 //unemployed
replace occupation = 100	if emp_status ==	 3 //out of LF

tab age_group, gen(age_group_) 

tab edu_group, gen(edu_group_)
egen no_no_school	   =total(edu_group_1==1), by(hhid)
egen no_primary 	   =total(edu_group_2==1), by(hhid)
egen no_secondary      =total(edu_group_3==1), by(hhid)
egen no_tertiary       =total(edu_group_4==1), by(hhid)

tab occupation, gen(occupation_)
egen no_unemployed   =total(occupation_1==1), by(hhid)
egen no_self_employed=total(occupation_2==1), by(hhid)
egen no_employer     =total(occupation_3==1), by(hhid)
egen no_employee_priv  =total(occupation_4==1), by(hhid)
egen no_employee_pub  =total(occupation_5==1), by(hhid)
tab sector, gen(sector_)
tab parish, gen(parish_)
tab emp_status, gen(emp_status_)

egen married_temp=sum(relation==2), by(hhid)
replace married =1 if married_temp>0 & married==. & relation==1
replace married =0 if married_temp==0 & married==. & relation==1



keep if relation==1

tempfile HBS2016
save `HBS2016'

*============ Program =================*
capture program drop errorsampling
program define errorsampling, rclass
	preserve 
	bsample, weight(nweight)
	rename res res_sim
	drop nweight
	merge m:m parish using survey_temp
	cap drop res
    sort hhid
    quietly by hhid:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	gen x= exp(ln_pcexpae_def11_hat+res_sim)
	gen poverty_hat=(x<= povline_def11)
	svyset ed [pw=nweight], strata(parish)
	svy: mean poverty_hat
	mat B=e(b)
	return scalar pp=B[1,1]
	restore
end
*============ End program =================*

putexcel set "Z:\Dropbox\Imputation\poverty_imputation results.xlsx", sheet(imputed poverty) modify
loc c=20

	global head_char "sex age_group_2-age_group_5 edu_group_2-edu_group_4 sector_7-sector_9 occupation_2-occupation_4 emp_status_2 emp_status_3 hr_work want_work" 
	global hh_char "parish_2-parish_10 no_unemployed no_employer no_employee_priv no_employee_pub no_secondary no_tertiary members member_sq wash_machine fridge telef tv n_bedroom car computer own_home"

	global head_char_temp "sex, age_group_2-age_group_5, edu_group_2-edu_group_4, sector_7-sector_9, occupation_2-occupation_4, emp_status_2, emp_status_3, hr_work, want_work" 
	global hh_char_temp "parish_2-parish_10, no_unemployed, no_employer, no_employee_priv, no_employee_pub, no_secondary, no_tertiary, members, member_sq, wash_machine, fridge, telef, n_bedroom, car, computer, own_home"

	
	svyset ed [pw=nweight], strata(parish)
	gen poverty_d=(pcexpae_def11<=povline_def11) 
	svy: mean poverty_d if !missing(ln_pcexpae_def11, $head_char_temp, $hh_char_temp)
	estpost tabstat ln_pcexpae_def11 $head_char $hh_char if !missing(ln_pcexpae_def11, $head_char_temp, $hh_char_temp ), ///
	listwise statistics(mean sd) columns(statistics)
	
	svy: regress ln_pcexpae_def11 $head_char $hh_char if survey=="HBS"
	outreg2 using consumption_model.xlsx, replace excel dec(2)

	predict res if survey=="HBS", residuals
	predict ln_pcexpae_def11_hat if survey=="HBS", xb	
	drop if (res==. & survey=="HBS")
	
	preserve
	keep if survey=="HBS"
	by hhid, sort: gen nhh = _n == 1
	count if nhh
	loc nhh=r(N)
	drop if ln_pcexpae_def11_hat==.
	by hhid, sort: gen nvals = _n == 1
	count if nvals
	loc nobs=r(N)	
	loc survey_temp
	save survey_temp,replace
	restore
	

	keep if survey=="HBS"
	keep res parish nweight
	expand 4
*Step 3
simulate pov_rate=r(pp), reps(300): errorsampling
di "year = `i'"
di "# of households = `nhh'"
di "# of observations = `nobs'"
summarize
local a=r(mean)
local b=r(sd)
putexcel I`c' = `a'
putexcel J`c' = `b'
loc ++c
//=======================================LFS =====================================
use "https://www.dropbox.com/s/s51usnayx0emobg/lca_2008_2016.dta?dl=1", clear

local years "2016 2015 2014 2012 2011 2009 2008"
		foreach i of local years {
		use "https://www.dropbox.com/s/s51usnayx0emobg/lca_2008_2016.dta?dl=1", clear
		
		quietly{
		keep if year==`i'
		drop if qtr=="4" & year==2015 // Q4 missing all asset variables
		replace wgt=wgt/4 if year==2016
		replace wgt=wgt/3 if year==2015
		replace age_range=. if age_range>=15
		recode age_range (1/3=1 0_14)(4/5=2 15_24)(6/8=3 25_40)(9/13=4 41_64)(14=5 above65), gen(age_group)

		rename maxedu1 edu_group

		rename hhsize members
		rename age_original age

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


		gen employed 	= (unemploy1==0 & eap1==1 & age>14)
		gen unemployed	= (unemploy1==1 & eap1==1 & age>14)
		gen not_LF		= (eap1==0 & age>14)

		gen 	emp_status	 =1 if 	employed	== 1 
		replace emp_status	 =2 if 	unemployed  == 1
		replace emp_status	 =3 if  not_LF		== 1
		label 	def			emp_status 	1 "employed" 2 "unemployed" 3 "out of LF" 
		label 	val			emp_status emp_status

		gen hr_work=0
		replace hr_work=log(hrs) if hrs!=. & employed==1 & hrs!=0

		gen hr_work_a=0
		replace hr_work_a=log(hrs_a) if hrs_a!=. & employed==1 & hrs!=0
		
		gen want_work=0
		replace want_work=1 if xtrawork==1

		/*
		gen cpi11=1.0619
		
		gen rent=0
		replace  rent=log(c0421101/cpi11) if own_home==1 & (year==2008|year==2009) & c0421101>0
		replace  rent=log(c0411100/cpi11) if own_home==0 & (year==2008|year==2009) & c0411100>0
		replace  rent=log(c0421101/cpi11) if own_home==0 & (year==2008|year==2009) & c0411100==.& c0421101>0 
		replace  rent=. if (year==2008|year==2009) & c0421101==. & c0411100==.
		
		replace  rent=log(h4/cpi11) if own_home==1 & (year>2009) & h4>0
		replace  rent=log(h5/cpi11) if own_home==0 & (year>2009) & h5>0	
		replace  rent=log(h4/cpi11) if own_home==0 & (year>2009) & h5==.& h4>0 
		replace  rent=. if h4==. & h5==. & (year>2009)
	

		gen int_rent = rent*own_home
		gen int_rent2 = rent*(own_home==0)
		*/
		gen poor_mat = (h2==1 | h2==6 | h2 ==7) if h2!=.
		
		gen n_room = 0
		replace n_room=h6_1 if h6_1!=.

		gen member_sq = members*members

		gen parish=dist

		egen no_dependent	   =total(age_group==1), by(hhid)

		gen occupation=1 if selfemp==1 | emptype==4 //self employed 
		replace occupation=2 if employer==1  // employer
		replace occupation=3 if emptype==2  // public employee
		replace occupation=4 if emptype==1   // private employee
	
		label define occupation 1 "self_employed" 2 "employer" 3 "public employee" 4 "private employee"
		label values occupation occupation

		egen married=total(relation==2), by(hhid)
		replace married =1 if married>0

		destring ed, replace

		replace sector=10 if sector==4
		drop if parish==0 | parish==.

		global head_char "sex relation hhid married age_group edu_group emp_status sector occupation unemployed emp_status hr_work hr_work_a want_work"
		global hh_char "no_dependent urban parish members member_sq own_home wash_machine fridge telef car computer tv n_bedroom poor_mat n_room"

		keep ed hhead nweight weight survey year $head_char $hh_char 


		gen povline 	 	=	6443 		
		gen povline_def11	=	6067.426	
		
		replace sector=0	if unemployed ==1
		replace sector=100	if emp_status ==3 //out of LF

		replace occupation = 0		if unemployed == 1 //unemployed
		replace occupation = 100	if emp_status ==	 3 //out of LF

		tab age_group, gen(age_group_) 

		tab edu_group, gen(edu_group_)
		egen no_no_school	   =total(edu_group_1==1), by(hhid)
		egen no_primary 	   =total(edu_group_2==1), by(hhid)
		egen no_secondary      =total(edu_group_3==1), by(hhid)
		egen no_tertiary       =total(edu_group_4==1), by(hhid)

		tab occupation, gen(occupation_)
		egen no_unemployed   =total(occupation_1==1), by(hhid)
		egen no_self_employed=total(occupation_2==1), by(hhid)
		egen no_employer     =total(occupation_3==1), by(hhid)
		egen no_employee_priv  =total(occupation_4==1), by(hhid)
		egen no_employee_pub  =total(occupation_5==1), by(hhid)
		tab sector, gen(sector_)
		tab parish, gen(parish_)
		tab emp_status, gen(emp_status_)
		
		bys hhid: egen tot_hhead=total(hhead)
	
		keep if hhead==1
		
		estpost tabstat $head_char $hh_char if !missing( $head_char_temp, $hh_char_temp ), ///
		listwise statistics(mean sd) columns(statistics)
	
		append using `HBS2016'


		global head_char "sex age_group_2-age_group_5 edu_group_2-edu_group_4 sector_7-sector_9 occupation_2-occupation_4 emp_status_2 emp_status_3 hr_work want_work" 
		global hh_char "parish_2-parish_10 no_unemployed no_employer no_employee_priv no_employee_pub no_secondary no_tertiary members member_sq wash_machine fridge telef tv n_bedroom car computer own_home"
	//want_work int_rent int_rent2 poor_mat n_room hr_work"


		svyset ed [pw=nweight], strata(parish)
		svy: regress ln_pcexpae_def11 $head_char $hh_char if survey=="HBS"
		predict res if survey=="HBS", residuals
		predict ln_pcexpae_def11_hat if survey=="LFS", xb	
		drop if (res==. & survey=="HBS")
		

		preserve
		keep if survey=="LFS"
		by hhid, sort: gen nhh = _n == 1
		count if nhh
		loc nhh=r(N)
		drop if ln_pcexpae_def11_hat==.
		by hhid, sort: gen nvals = _n == 1
		count if nvals
		loc nobs=r(N)	
		mat pob=J(10,1,.)
		forval p=1/10{
		count if parish==`p'
		mat pob[`p',1]=r(N)
		}
		loc survey_temp
		save survey_temp,replace
		restore


		keep if survey=="HBS"
		keep res parish nweight
		expand 4	
		
}
*Step 3
simulate pov_rate=r(pp), reps(300): errorsampling
di "year = `i'"
di "# of households = `nhh'"
di "# of observations = `nobs'"
summarize
local a=r(mean)
local b=r(sd)
putexcel I`c' = `a'
putexcel J`c' = `b'
loc ++c
}



/*******************************************************************************
El Colegio de Mexico
Centro de Estudios Demograficos Urbanos y Ambientales - CEDUA
Title: Pre y pandemia por COVID-19: Comportamiento de la Pobreza y desigualdad en la población mayor indígena boliviana

Objective:
Examinar el comportamiento de la pobreza y desigualdad en la población indígena, en contexto de la pandemia por COVID-19, estratificado por edad.

Dependent variable: People who self-reported symptoms of COVID-19
Independent variables: Employment type, Household living arrangements, Attained education, Age, Ethnicity
Control variables: gender, current status, residence area 

Database: Household Survey 2020. Representative of houses, households and their residing population at a national, urban and rural level. 

Analytical sample n2019=17 676; n2020=16 910; n2021=19 298

Date created:Dec/13/2022
Last modification: Jan/08/2023

License:	El Colegio de México
Ado(s):	ginidesc, lorenz, chowtest

Database site: http://anda.ine.gob.bo/index.php/catalog/88
*******************************************************************************/

**# Bookmark #1
************************************************
****************Bolivia 2021********************
************************************************

*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2021_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2021_Persona.dta"

***Begining of the the database analisys

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2021_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2021
label variable year "year"

**# Bookmark #2
*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_05 ///
	(1 = 1 "With symptoms") ///
	(2 3 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing


*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #3
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aestudio ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #4
***********Ethnicity

***A) Ethnic affiliation - PE
tab s01a_09, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s01a_09 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s01a_07_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s01a_07_1 ///
	(2/5 7/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(40/996 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s01a_07_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s01a_07_2 ///
	(2/5 7/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(38/62 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s01a_08,mi
*Conversion of variable s01a_08 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s01a_08 ///
	(2 4 7/33 = 1 "Native") ///
	(6 41/58  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #5
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #6 
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #7
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s01a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #8
***********Gender
*Recode variable s01a_02 into gender
tab s01a_02, mi

recode s01a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #9
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s04a_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #10
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #11
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s01a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"

**# Bookmark #12
*Individual Income
generate float YPE:YPE = (yper/6.86)*1.08897
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #13
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1.08897
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/


**# Bookmark #14
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi


*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #15
*Pensiones-AFP
clonevar afiliacion = s04f_35
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 .= 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi

**# Bookmark #16
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #17
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year covid educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2021_Persona_Recortada.dta", replace

**# Bookmark #18
************************************************
****************Bolivia 2020********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2020_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2020_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2020_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2020
label variable year "year"


**# Bookmark #19
*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing


*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #20
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aestudio ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #21
***********Ethnicity

***A) Ethnic affiliation - PE
tab s01a_08, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s01a_08 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s01a_06_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s01a_06_1 ///
	(2 10/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/996 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s01a_06_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s01a_06_2 ///
	(1/4 7/34 39 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/70 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s01a_07,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s01a_07 ///
	(2 4 7/33 = 1 "Native") ///
	(6 34/60  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #22
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #23
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #24
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s01a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #25
***********Gender
*Recode variable s01a_02 into gender
tab s01a_02, mi

recode s01a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #26
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s04a_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #27
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #28
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s01a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #29
*Individual Income
generate float YPE:YPE = (yper/6.86)*1.08101
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #30
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1.08101
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/


**# Bookmark #31
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi


*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #32
*Pensiones-AFP
clonevar afiliacion = s04f_39
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 .= 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi

**# Bookmark #33
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #34
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year covid educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2020_Persona_Recortada.dta", replace



**# Bookmark #35
************************************************
****************Bolivia 2019********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2019_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2019_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2019_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2019
label variable year "year"


**# Bookmark #36
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #37
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aestudio ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/22 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #38
***********Ethnicity

***A) Ethnic affiliation - PE
tab s03a_04, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s03a_04 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s02a_07_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s02a_07_1 ///
	(2 5 10/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/996 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s02a_07_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s02a_07_2 ///
	(1/4 7/39 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/62 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s02a_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s02a_08 ///
	(2 4 7/33 = 1 "Native") ///
	(6 38/998  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #39
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #40
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #41
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s02a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #42
***********Gender
*Recode variable s01a_02 into gender
tab s02a_02, mi

recode s02a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #43
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s06a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #44
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #45
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s02a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #46
*Individual Income
generate float YPE:YPE = (yper/6.86)*1.07092
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #47
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1.07092
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #48
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #49
*Pensiones-AFP
clonevar afiliacion = s06g_54
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 .= 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #50
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #51
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2019_Persona_Recortada.dta", replace

**# Bookmark #52
************************************************
****************Bolivia 2018********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2018_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2018_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2018_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2018
label variable year "year"


**# Bookmark #53
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #54
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aestudio ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/22 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #55
***********Ethnicity

***A) Ethnic affiliation - PE
tab s03a_04, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s03a_04 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s02a_07_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s02a_07_1 ///
	(1 5 7/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(38/997 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s02a_07_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s02a_07_2 ///
	(2/4 7/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/998 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s02a_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s02a_08 ///
	(2 5 7/33 = 1 "Native") ///
	(6 38/998  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #56
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #57
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #58
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s02a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #59
***********Gender
*Recode variable s01a_02 into gender
tab s02a_02, mi

recode s02a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #60
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s06a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #61
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #62
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s02a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #63
*Individual Income
generate float YPE:YPE = (yper/6.86)*1.05158
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #64
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1.05158
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #65
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #66
*Pensiones-AFP
clonevar afiliacion = s06h_59
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 .= 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #67
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #68
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2018_Persona_Recortada.dta", replace

**# Bookmark #69
************************************************
****************Bolivia 2017********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2017_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2017_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2017_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2017
label variable year "year"


**# Bookmark #70
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #71
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aoesc ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/22 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #72
***********Ethnicity

***A) Ethnic affiliation - PE
tab s03a_04, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s03a_04 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s02a_07_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s02a_07_1 ///
	(2 5 8/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/996 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s02a_07_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s02a_07_2 ///
	(2/4 7/34 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/998 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s02a_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s02a_08 ///
	(2 4 7/34 = 1 "Native") ///
	(6 41/58  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #73
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #74
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #75
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s02a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #76
***********Gender
*Recode variable s01a_02 into gender
tab s02a_02, mi

recode s02a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #77
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s06a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #78
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #79
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s02a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #80
*Individual Income
generate float YPE:YPE = (yper/6.86)*1.02822
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #81
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1.02822
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex

/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #82
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi


*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #83
*Pensiones-AFP
clonevar afiliacion = s06h_58b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 .= 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #84
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #85
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2017_Persona_Recortada.dta", replace

**# Bookmark #86
************************************************
****************Bolivia 2016********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2016_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2016_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2016_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2016
label variable year "year"


**# Bookmark #87
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #88
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #89
***********Ethnicity

***A) Ethnic affiliation - PE
tab s03a_2, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s03a_2 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s02a_07_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s02a_07_1 ///
	(2 7/36 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/998 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s02a_07_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s02a_07_2 ///
	(2/4 7/36 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/998 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s02a_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s02a_08 ///
	(2 4 7/36 = 1 "Native") ///
	(6 41/998  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #90
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #91
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #92
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s02a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #93
***********Gender
*Recode variable s01a_02 into gender
tab s02a_02, mi

recode s02a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #94
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s06a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #95
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #96
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s02a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #97
*Individual Income
generate float YPE:YPE = (yper/6.86)*1
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #98
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*1
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #99
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #100
*Pensiones-AFP
clonevar afiliacion = s06h_59b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi

**# Bookmark #101
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #102
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2016_Persona_Recortada.dta", replace

**# Bookmark #103
************************************************
****************Bolivia 2015********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2015_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2015_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2015_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2015
label variable year "year"


**# Bookmark #104
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #105
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/24 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #106
***********Ethnicity

***A) Ethnic affiliation - PE
tab s3a_2a, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s3a_2a ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s2a_07acod,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

encode s2a_07acod, generate (s2a_07acod_aux)
recode s2a_07acod_aux ///
	(1 3/9 = 1 "Native language") ///
	(2 = 0 "Spanish") ///
	(10/23 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s2a_07bcod,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s2a_07bcod, generate (s2a_07bcod_aux)
recode s2a_07bcod_aux ///
	(1/2 4/17 = 1 "Native language") ///
	(3 = 0 "Spanish") ///
	(18/28 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s2a_08cod,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

encode s2a_08cod, generate (s2a_08cod_aux)
recode s2a_08cod_aux ///
	(1 3/12 = 1 "Native") ///
	(2 13/29  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #107
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #108
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #109
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s2a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #110
***********Gender
*Recode variable s01a_02 into gender
tab s2a_02, mi

recode s2a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #111
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s6a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #112
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #113
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s2a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #114
*Individual Income
generate float YPE:YPE = (yper/6.86)*0.96502
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #115
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*0.96502
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #116
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #117
*Pensiones-AFP
clonevar afiliacion = s6g_52b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #118
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #119
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2015_Persona_Recortada.dta", replace

**# Bookmark #120
************************************************
****************Bolivia 2014********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2014_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2014_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2014_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2014
label variable year "year"


**# Bookmark #121
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #122
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/27 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #123
***********Ethnicity

***A) Ethnic affiliation - PE
tab s3a_02a, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s3a_02a ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s2a_07a,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

encode s2a_07a, generate (s2a_07a_aux)
recode s2a_07a_aux ///
	(1 2 4/14 = 1 "Native language") ///
	(3 = 0 "Spanish") ///
	(15/23 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s2a_07b,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s2a_07b, generate (s2a_07b_aux)
recode s2a_07b_aux ///
	(1/3 5/18 = 1 "Native language") ///
	(4 = 0 "Spanish") ///
	(19/31 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s2a_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

encode s2a_08, generate (s2a_08_aux)
recode s2a_08_aux ///
	(1 2 4/15 = 1 "Native") ///
	(3 16/22  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #124
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #125
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #126
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s2a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #127
***********Gender
*Recode variable s01a_02 into gender
tab s2a_02, mi

recode s2a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #128
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s6a_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #129
***********Residence area 
*Recode variable area into urban
tab URBRUR, mi
recode URBRUR ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #130
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s2a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 127= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #131
*Individual Income
generate float YPE:YPE = (yper/6.86)*0.92736
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #132
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*0.92736
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #133
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #134
*Pensiones-AFP
clonevar afiliacion = s6g_52b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #135
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #136
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2014_Persona_Recortada.dta", replace


**# Bookmark #137
************************************************
****************Bolivia 2013********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2013_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2013_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2013_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2013
label variable year "year"


**# Bookmark #138
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #139
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . 99 = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #140
***********Ethnicity

***A) Ethnic affiliation - PE
tab s3_02a, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s3_02a ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s2_07a,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

encode s2_07a, generate (s2_07a_aux)
recode s2_07a_aux ///
	(3 5 8 10 14 19 20 21 23 26 27 = 1 "Native language") ///
	(6 12 = 0 "Spanish") ///
	(1 2 4 7 9 11 13 15 16 17 18 22 24 25 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s2_07b,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s2_07b, generate (s2_07b_aux)
recode s2_07b_aux ///
	(2/4 7 9 10 13 14 21/27 29 32 34/36 = 1 "Native language") ///
	(5 11 = 0 "Spanish") ///
	(1 6 8 12 15/20 28 30/31 33  = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s2_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

encode s2_08, generate (s2_08_aux)
recode s2_08_aux ///
	(2/4 7 9 13 14 19/23 25 29/31 = 1 "Native") ///
	(1 5 6 8 10/12 15/18 24 26/28  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #141
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #142
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #143
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s2_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #144
***********Gender
*Recode variable s01a_02 into gender
tab s2_02, mi

recode s2_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #145
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s6_01 ///
	(1 = 1 "Working") ///
	(2 .= 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #146
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #147
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s2_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #148
*Individual Income
generate float YPE:YPE = (yper/6.86)*0.87682
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #149
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*0.87682
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #150
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #151
*Pensiones-AFP
clonevar afiliacion = s6_52b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #152
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #153
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2013_Persona_Recortada.dta", replace

**# Bookmark #154
************************************************
****************Bolivia 2012********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2012_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2012_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2012_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2012
label variable year "year"


**# Bookmark #155
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #156
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . 99 = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #157
***********Ethnicity

***A) Ethnic affiliation - PE
tab s2_05a, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s2_05a ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_10a,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

encode s1_10a, generate (s1_10a_aux)
recode s1_10a_aux ///
	(2 6 10 11 = 1 "Native language") ///
	(3 = 0 "Spanish") ///
	(1 4 5 7 8 9 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_10b,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s1_10b, generate (s1_10b_aux)
recode s1_10b_aux ///
	(3 4 5 7/9 11 17 18 20 22 24 = 1 "Native language") ///
	(6  = 0 "Spanish") ///
	(1 2 10 12/16 19 21 23 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_11,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

encode s1_11, generate (s1_11_aux)
recode s1_11_aux ///
	(3 4 7 9 12 16 17 19 21 22 = 1 "Native") ///
	(1 2 5 6 8 10 11 13 14 15 18 20 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #158
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #159
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #160
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s1_04
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #161
***********Gender
*Recode variable s01a_02 into gender
tab s1_03, mi

recode s1_03 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #162
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #163
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #164
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s1_08

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 121= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #165
*Individual Income
generate float YPE:YPE = (yper/6.86)*0.82925
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.86)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #166
*Per capita Income
generate float YPC:YPC = (yhogpc/6.86)*0.82925
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.86)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #167
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #168
*Pensiones-AFP
clonevar afiliacion = s5_59b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #169
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #170
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2012_Persona_Recortada.dta", replace

**# Bookmark #171
************************************************
****************Bolivia 2011********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2011_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2011_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2011_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2011
label variable year "year"


**# Bookmark #172
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #173
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . 99 = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/22 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #174
***********Ethnicity

***A) Ethnic affiliation - PE
tab s2_05, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

encode s2_05, generate (s2_05_aux)
recode s2_05_aux ///
	(1/12 15/19= 1 "Belong") ///
	(13 14 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_10a,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

encode s1_10a, generate (s1_10a_aux)
recode s1_10a_aux ///
	(1 2 4 7 9 12 13 17 21/25= 1 "Native language") ///
	(5 6 10 11 = 0 "Spanish") ///
	(3 8 14/16 18/20= 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_10b,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s1_10b, generate (s1_10b_aux)
recode s1_10b_aux ///
	(1 2 4 5 7 8 10/14 18/21 23 27 28/35 40/41 45/51 = 1 "Native language") ///
	(6 15/16 = 0 "Spanish") ///
	(3 9 17 22 24/26 36/39 42/44 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_11,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

encode s1_11, generate (s1_11_aux)
recode s1_11_aux ///
	(1 3 4 10 11 13 16/18 20 23/25 30/31 34/38 = 1 "Native") ///
	(2 5/9 12 14 15 19 21 22 26/29 32 33 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #175
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #176
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #177
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s1_04
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #178
***********Gender
*Recode variable s01a_02 into gender
tab s1_03, mi

recode s1_03 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #179
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #180
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #181
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s1_08

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #182
*Individual Income
generate float YPE:YPE = (yper/6.89)*0.79340
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yper/6.89)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #183
*Per capita Income
generate float YPC:YPC = (yhogpc/6.89)*0.79340
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpc/6.89)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #184
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #185
*Pensiones-AFP
clonevar afiliacion = s5_59b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 9 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #186
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #187
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2011_Persona_Recortada.dta", replace

**# Bookmark #188
************************************************
****************Bolivia 2009********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2009_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2009_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2009_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2009
label variable year "year"


**# Bookmark #189
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #190
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode e ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/21 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #191
***********Ethnicity

***A) Ethnic affiliation - PE
tab s1_14, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

*encode s1_111, generate (s2_05_aux)
recode s1_14 ///
	(1/6= 1 "Belong") ///
	(7 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_111,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

*encode s1_10a, generate (s1_10a_aux)
recode s1_111 ///
	(2/5 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(6 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_112,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

*encode s1_112, generate (s1_10b_aux)
recode s1_112 ///
	(3/6 = 1 "Native language") ///
	(1 2 = 0 "Spanish") ///
	(7 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_10,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

*encode s1_10, generate (s1_11_aux)
recode s1_10 ///
	(2/5 = 1 "Native") ///
	(1 6/8 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #192
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #193
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op1 ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #194
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s1_04
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #195
***********Gender
*Recode variable s01a_02 into gender
tab s1_03, mi

recode s1_03 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #196
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #197
***********Residence area 
*Recode variable area into urban
tab urb_rur, mi
recode urb_rur ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #198
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s1_08

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #199
*Individual Income
generate float YPE:YPE = (yperf/6.97)*0.70442
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yperf/6.97)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #200
*Per capita Income
generate float YPC:YPC = (yhogpcf/6.97)*0.70442
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpcf/6.97)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #201
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab pext0, mi
recode pext0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #202
*Pensiones-AFP
clonevar afiliacion = s5_58b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #203
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #204
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2009_Persona_Recortada.dta", replace

**# Bookmark #205
************************************************
****************Bolivia 2008********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2008_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2008_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2008_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2008
label variable year "year"


**# Bookmark #206
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #207
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode E ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/22 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #208
***********Ethnicity

***A) Ethnic affiliation - PE
tab S1_12, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

*encode s1_111, generate (s2_05_aux)
recode S1_12 ///
	(1/6= 1 "Belong") ///
	(7 8 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab S1_091,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

*encode s1_10a, generate (s1_10a_aux)
recode S1_091 ///
	(2/5 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(6 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab S1_092,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

*encode s1_112, generate (s1_10b_aux)
recode S1_092 ///
	(3/6 = 1 "Native language") ///
	(2 = 0 "Spanish") ///
	(7 1 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab S1_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

*encode s1_10, generate (s1_11_aux)
recode S1_08 ///
	(2/5 = 1 "Native") ///
	(1 6/8 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #209
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #210
***********Employment type
*Conversion of variable cob_op to Employment type
recode COB_OP1 ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #211
***********Age
*Recode variable s01a_03 into edad
clonevar edad = S1_04
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #212
***********Gender
*Recode variable s01a_02 into gender
tab S1_03, mi

recode S1_03 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #213
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode S5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #214
***********Residence area 
*Recode variable area into urban
tab URB_RUR, mi
recode URB_RUR ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #215
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort FOLIO
clonevar p_parentescor=S1_06

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (FOLIO)
egen esp_1 = total(esp), by (FOLIO) 
egen hijo_1 = total (hijo), by (FOLIO)
egen yerno_1 = total(yerno), by (FOLIO)
egen nieto_1 = total(nieto), by (FOLIO)
egen hercuña_1 = total(padres), by (FOLIO)
egen padres_1 = total(padres), by (FOLIO)
egen otropar_1 = total(otropar), by (FOLIO)
egen empl_1 = total(empl), by (FOLIO)
egen emplpar_1 = total(emplpar), by (FOLIO)
egen otronopar_1 = total(otronopar), by (FOLIO)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"

*cambiar Factor por factor
clonevar factor = FACTOR

**# Bookmark #216
*Individual Income
generate float YPE:YPE = (YPERF/7.19)*0.68162
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (YPERF/7.19)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #217
*Per capita Income
generate float YPC:YPC = (YHOGPCF/7.19)*0.68162
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (YHOGPCF/7.19)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #218
*Pobreza
*Recode variable p0 into pobreza
tab P0, mi
recode P0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab PEXT0, mi
recode PEXT0 ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #219
*Pensiones-AFP
clonevar afiliacion = S5_58B
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #220
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #221
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2008_Persona_Recortada.dta", replace


**# Bookmark #222
************************************************
****************Bolivia 2007********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2007_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2007_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2007_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2007
label variable year "year"


**# Bookmark #223
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #224
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode a_oe ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/19 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #225
***********Ethnicity

***A) Ethnic affiliation - PE
tab s1_11, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

*encode s1_111, generate (s2_05_aux)
recode s1_11 ///
	(1/6= 1 "Belong") ///
	(7 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_09_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

*encode s1_10a, generate (s1_10a_aux)
recode s1_09_1 ///
	(2/5 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(6 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_09_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

*encode s1_112, generate (s1_10b_aux)
recode s1_09_2 ///
	(3/6 = 1 "Native language") ///
	(2 = 0 "Spanish") ///
	(7 1 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_08,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

*encode s1_10, generate (s1_11_aux)
recode s1_08 ///
	(2/5 = 1 "Native") ///
	(1 6/8 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #226
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #227
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/10 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #228
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s1_04
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #229
***********Gender
*Recode variable s01a_02 into gender
tab s1_03, mi

recode s1_03 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #230
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #231
***********Residence area 
*Recode variable area into urban
tab urb_rur, mi
recode urb_rur ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #232
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s1_06

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 125= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #233
*Individual Income
generate float YPE:YPE = (yperf/7.80)*0.59786
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yperf/7.80)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #234
*Per capita Income
generate float YPC:YPC = (yhogpcf/7.80)*0.59786
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpcf/7.80)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #235
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab indig, mi
recode indig ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .


label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #236
*Pensiones-AFP
clonevar afiliacion = s5_58b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #237
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #238
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2007_Persona_Recortada.dta", replace


**# Bookmark #239
************************************************
****************Bolivia 2006********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2006_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2006_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2006_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2006
label variable year "year"


**# Bookmark #240
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #241
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode añoe ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/19 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #242
***********Ethnicity

***A) Ethnic affiliation - PE
tab S1_10, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

*encode s1_111, generate (s2_05_aux)
recode S1_10 ///
	(1/6= 1 "Belong") ///
	(7 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_08_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

*encode s1_10a, generate (s1_10a_aux)
recode s1_08_1 ///
	(2/4 6 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(5 0 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_08_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

encode s1_08_2, generate (s1_08_2_aux)
recode s1_08_2_aux ///
	(2/4 6 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(5 0 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_07,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

*encode s1_10, generate (s1_11_aux)
recode s1_07 ///
	(2/5 = 1 "Native") ///
	(1 6/8 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #243
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #244
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #245
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s1_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #246
***********Gender
*Recode variable s01a_02 into gender
tab s1_02, mi

recode s1_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #247
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s5_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #248
***********Residence area 
*Recode variable area into urban
tab Urb_Rur, mi
recode Urb_Rur ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #249
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort Folio
clonevar p_parentescor=s1_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (Folio)
egen esp_1 = total(esp), by (Folio) 
egen hijo_1 = total (hijo), by (Folio)
egen yerno_1 = total(yerno), by (Folio)
egen nieto_1 = total(nieto), by (Folio)
egen hercuña_1 = total(padres), by (Folio)
egen padres_1 = total(padres), by (Folio)
egen otropar_1 = total(otropar), by (Folio)
egen empl_1 = total(empl), by (Folio)
egen emplpar_1 = total(emplpar), by (Folio)
egen otronopar_1 = total(otronopar), by (Folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #250
*Individual Income
generate float YPE:YPE = (yperf/7.96)*0.54999
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (yperf/7.96)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #251
*Per capita Income
generate float YPC:YPC = (yhogpcf/7.96)*0.54999
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (yhogpcf/7.96)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #252
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab p0_ext, mi
recode p0_ext ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .


label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #253
*Pensiones-AFP
clonevar afiliacion = s5_54
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #254
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #255
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2006_Persona_Recortada.dta", replace

**# Bookmark #256
************************************************
****************Bolivia 2005********************
************************************************
clear all
*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_Persona.dta"

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_Persona.dta", clear
set more off

*Crear variable de año
generate int year:YEAR = 2005
label variable year "year"


**# Bookmark #257
/*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing
*/

*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #258
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aoesc ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/19 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #259
***********Ethnicity

***A) Ethnic affiliation - PE
tab s1_10, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

*encode s1_111, generate (s2_05_aux)
recode s1_10 ///
	(1/6= 1 "Belong") ///
	(7 8 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s1_08_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

*encode s1_10a, generate (s1_10a_aux)
recode s1_08_1 ///
	(2/4 6 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(5 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s1_08_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

*encode s1_08_2, generate (s1_08_2_aux)
recode s1_08_2 ///
	(2/4 6 = 1 "Native language") ///
	(1 = 0 "Spanish") ///
	(5 0 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s1_07,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

*encode s1_10, generate (s1_11_aux)
recode s1_07 ///
	(2/5 = 1 "Native") ///
	(1 6/8 = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #260
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #261
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_ag ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. 99 = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #262
***********Age
*Recode variable s01a_03 into edad
clonevar edad_aux = s1_03
destring (edad_aux),replace

****Age groups
recode edad_aux ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #263
***********Gender
*Recode variable s01a_02 into gender
tab s1_02, mi

recode s1_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #264
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s4_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #265
***********Residence area 
*Recode variable area into urban
tab urb_rur, mi
recode urb_rur ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #266
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s1_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #267
*Individual Income
generate float YPE:YPE = (y_totalA/8.05)*0.52741
label variable YPE "Individual Income $us/month 2016=100"
sum YPE

generate float YPE_noindex:YPE_noindex = (y_totalA/8.05)
label variable YPE_noindex "Individual Income $us/month"
sum YPE_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPE [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #268
*Per capita Income
generate float YPC:YPC = (y_percapB/8.05)*0.52741
label variable YPC "Per capita Income $us/month 2016=100"
sum YPC

generate float YPC_noindex:YPC_noindex = (y_percapB/8.05)
label variable YPC_noindex "Per capita Income $us/month"
sum YPC_noindex


/*    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         YPE |     42,090    227.3996    369.7605          0   8752.293

*/

sum YPC [iw=factor]
/*    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
         YPE |  42,090    11903958    225.0483   363.8274          0   8752.293

*/

**# Bookmark #269
*Pobreza
*Recode variable p0 into pobreza
tab p0, mi
recode p0 ///
	(0 . = 0 "No pobre") ///
	(1 = 1 "Pobre") ///
	, gen (pobreza) label (pobreza)
label variable pobreza "Pobreza por ingreso"
tab pobreza,mi


*Pobreza extrema
*Recode variable pext0 into pobreza
tab p0_ext, mi
recode p0_ext ///
	(0 . = 0 "No pobre extremo") ///
	(1 = 1 "Pobre extremo") ///
	, gen (pobreza_extrema) label (pobreza_extrema)
label variable pobreza_extrema "Pobreza extrema o indigencia por ingreso"
tab pobreza_extrema,mi

*Pobreza y pobreza extrema por ingreso
gen pobre = .
replace pobre = 0 if pobreza == 0
replace pobre = 1 if pobreza == 1
replace pobre = 2 if pobreza_extrema == 1
replace pobre = 1 if pobreza == .

label define pobre ///
0 "No_pobre" ///
1 "Pobre" ///
2 "Pobre_extremo"
label values pobre pobre
label variable pobre "Pobreza por ingreso"
tab pobre, missing

**# Bookmark #270
*Pensiones-AFP
clonevar afiliacion = s4_76b
tab afiliacion, mi
recode afiliacion ///
	(1 = 1 "Si") ///
	(2 . = 0 "No") ///
	, gen (afp) label (afp)
label variable afp "Afiliación a AFP"
tab afp,mi


**# Bookmark #271
***Sample to the age group of interest: 30-98
mark univ if inrange(edad_aux,30,98)

tab univ, mi
keep if univ

**# Bookmark #272
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor year educacion condic_etnica ocupacion edad_tres_grupos sex condicion_laboral urban tipo_hogar YPE YPC pobreza pobreza_extrema pobre YPC_noindex YPE_noindex afp

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_Persona_Recortada.dta", replace

*************************************************************************************************************************************
************************************ JUNTANDO LAS BASES DE DATOS PARA 2005 - 2021 ***************************************************
*************************************************************************************************************************************

clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2021_Persona_Recortada.dta", clear
set more off

append using "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2020_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2019_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2018_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2017_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2016_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2015_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2014_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2013_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2012_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2011_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2009_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2008_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2007_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2006_Persona_Recortada.dta" "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_Persona_Recortada.dta"

save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_2021_Persona_Recortada.dta", replace

use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Ageing in latin america - book chapter\Database\EH2005_2021_Persona_Recortada.dta"

***************************************************************************
****************************ANÁLISIS BIVARIADO*****************************
***************************************************************************

**# Bookmark #273
**********Pobreza****************
*** Pobreza total
tab pobreza year [iw=factor], col nofreq

***Pobreza por grupos de edades
bysort edad_tres_grupos: tab pobreza year [iw=factor], col nofreq

*Pobreza por condición étnica
bysort condic_etnica: tab pobreza year [iw=factor], col nofreq

*Pobreza por sexo
bysort sex: tab pobreza year [iw=factor], col nofreq


**********Pobreza extrema****************
*** Pobreza extrema total
tab pobreza_extrema year [iw=factor], col nofreq

***Pobreza por grupos de edades
bysort edad_tres_grupos: tab pobreza_extrema year [iw=factor], col nofreq

*Pobreza por condición étnica
bysort condic_etnica: tab pobreza_extrema year [iw=factor], col nofreq

*Pobreza por sexo
bysort sex: tab pobreza_extrema year [iw=factor], col nofreq


**********Comparación de medias***********


*Verificar tres supuestos para elección prueba paramétrica: t/U Mann Whitney
*i) muestra aleatoria

*ii) Distribución de los datos normal;
*Distribución gráfica
histogram pobreza, normal by(condic_etnica)

*iii) Varianzas de los grupos sean homogéneas.
sdtest pobreza, by( condic_etnica )
*Varianzas diferentes

*No se cumplen supuestos ii) y iii), entonces prueba no paramétrica

*Comparación medianas con prueba no paramétrica U Mann Whitney, por año y por condición étnica
by year, sort : ranksum pobreza, by(condic_etnica)

*********Medidas de desigualdad
*****Índice de Gini
*Total
ginidesc YPC if YPC >0, by(year)

*Condición étnica
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	ginidesc YPC if year==`num' & YPC >0, by(condic_etnica)
}
*Edades
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	ginidesc YPC if year==`num' & YPC>0 , by(edad_tres_grupos)
}
*Sexo
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	ginidesc YPC if year==`num' & YPC>0 , by(sex)
}


*Edades y condición étnica
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	display "No indígena"
	ginidesc YPC if year==`num' & YPC >0 & condic_etnica==0, by(edad_tres_grupos)
	display `num'
	display "Indígena"
	ginidesc YPC if year==`num' & YPC >0 & condic_etnica==1, by(edad_tres_grupos)
}


**********Curva de Lorenz

***Total
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	lorenz YPC if year==`num' & YPC > 0
}

***Condición étnica
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	display "No indígena"
	lorenz YPC if year==`num' & condic_etnica==0 & YPC > 0
	display `num'
	display "Indígena"
	lorenz YPC if year==`num' & condic_etnica==1 & YPC > 0
}

***Edades
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	display "30-44"
	lorenz YPC if year==`num' & edad_tres_grupos==0 & YPC > 0
	display `num'
	display "45-59"
	lorenz YPC if year==`num' & edad_tres_grupos==1 & YPC > 0
	display `num'
	display "60 y +"
	lorenz YPC if year==`num' & edad_tres_grupos==2 & YPC > 0
}


***Edades * condición étnica
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display "******No indígena********"
	display `num'
	display "30-44"
	lorenz YPC if year==`num' & edad_tres_grupos==0 & condic_etnica==0 & YPC > 0
	display `num'
	display "45-59"
	lorenz YPC if year==`num' & edad_tres_grupos==1 & condic_etnica==0 & YPC > 0
	display `num'
	display "60 y +"
	lorenz YPC if year==`num' & edad_tres_grupos==2 & condic_etnica==0 & YPC > 0
	display "******Indígena********"
	display `num'
	display "30-44"
	lorenz YPC if year==`num' & edad_tres_grupos==0 & condic_etnica==1 & YPC > 0
	display `num'
	display "45-59"
	lorenz YPC if year==`num' & edad_tres_grupos==1 & condic_etnica==1 & YPC > 0
	display `num'
	display "60 y +"
	lorenz YPC if year==`num' & edad_tres_grupos==2 & condic_etnica==1 & YPC > 0
}

***Sexo
foreach num of numlist 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	display `num'
	display "No indígena"
	lorenz YPC if year==`num' & condic_etnica==0 & YPC > 0
	display `num'
	display "Indígena"
	lorenz YPC if year==`num' & condic_etnica==1 & YPC > 0
}

***************************************
*******Análisis bivariado**************

**# Bookmark #274
***************************************
******Pobreza
tab pobre, gen(pobre)
tab1 pobre1 pobre2 pobre3, mi
*Para tabla 1
tab pobre year [iw=factor] if year >=2017, col nofreq

******Educación
tab educacion, gen(educacion)
tab1 educacion1 educacion2 educacion3 educacion4, mi
*Para tabla 1
tab educacion year [iw=factor] if year >=2017, col nofreq

******Condición étnica
tab condic_etnica, gen(condic_etnica)
tab1 condic_etnica1 condic_etnica2, mi
*Para tabla 1
tab condic_etnica year [iw=factor] if year >=2017, col nofreq

******Ocupación
tab ocupacion, gen(ocupacion)
tab1 ocupacion1 ocupacion2 ocupacion3, mi
*Para tabla 1
tab ocupacion year [iw=factor] if year >=2017, col nofreq

*******Condición laboral
tab condicion_laboral, gen(condicion_laboral)
tab1 condicion_laboral1 condicion_laboral2, mi
*Para tabla 1
tab condicion_laboral year [iw=factor] if year >=2017, col nofreq

******Grupos de edad
tab edad_tres_grupos, gen(edad_tres_grupos)
tab1 edad_tres_grupos1 edad_tres_grupos2 edad_tres_grupos3, mi
*Para tabla 1
tab edad_tres_grupos year [iw=factor] if year >=2017, col nofreq

*******Área de residencia
tab urban, gen(urban)
tab1 urban1 urban2, mi
*Para tabla 1
tab urban year [iw=factor] if year >=2017, col nofreq

******Tipo de hogar
tab tipo_hogar, gen(tipo_hogar)
tab1 tipo_hogar1 tipo_hogar2 tipo_hogar3, mi
*Para tabla 1
tab tipo_hogar year [iw=factor] if year >=2017, col nofreq

******Afiliación AFP
tab afp, gen(afp)
tab1 afp1 afp2, mi
*Para tabla 1
tab afp year [iw=factor] if year >=2017, col nofreq

******Sexo
tab sex, gen(sex)
tab1 sex1 sex2, mi
*Para tabla 1
tab sex year [iw=factor] if year >=2017, col nofreq

**# Bookmark #275
***************************************
*************Modelaje******************
*******Modelo bivariado****************

fvset base 3 ocupacion
mlogit pobre i.ocupacion#year if year >=2019, rrr
estat ic

fvset base 3 tipo_hogar
mlogit pobre i.tipo_hogar if year >=2019, rrr
estat ic

fvset base 4 educacion
mlogit pobre i.educacion if year >=2019, rrr
estat ic

fvset base 2 edad_tres_grupos
mlogit pobre i.edad_tres_grupos if year >=2019, rrr
estat ic

fvset base 0 condic_etnica
mlogit pobre i.condic_etnica if year >=2019, rrr
estat ic

fvset base 0 sex
mlogit pobre i.sex if year >=2019, rrr
estat ic

fvset base 1 condicion_laboral
mlogit pobre i.condicion_laboral if year >=2019, rrr
estat ic

fvset base 1 urban
mlogit pobre i.urban if year >=2019, rrr
estat ic

fvset base 1 afp
mlogit pobre i.afp if year >=2019, rrr
estat ic

**# Bookmark #276
***Modelo basal interactuado por año, para 30-44***

***Establecer categorías de referencia
fvset base 2 ocupacion
fvset base 3 tipo_hogar
fvset base 4 educacion
fvset base 2 edad_tres_grupos
fvset base 1 afp
fvset base 1 sex
fvset base 1 condicion_laboral
fvset base 1 urban

***Modelo basal interactuado por año, para 30-44, no indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==0 & condic_etnica==0, rrr
estat ic

***Modelo basal interactuado por año, para 30-44, indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==0 & condic_etnica==1, rrr
estat ic

**# Bookmark #277
***Modelo basal interactuado por año, para 45-59***

***Establecer categorías de referencia
fvset base 2 ocupacion
fvset base 3 tipo_hogar
fvset base 4 educacion
fvset base 2 edad_tres_grupos
fvset base 1 afp
fvset base 1 sex
fvset base 1 condicion_laboral
fvset base 1 urban

***Modelo basal interactuado por año, para 45-59, no indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==1 & condic_etnica==0, rrr
estat ic

***Modelo basal interactuado por año, para 45-59, indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==1 & condic_etnica==1, rrr
estat ic

**# Bookmark #278
***Modelo basal interactuado por año, para 60+***

***Establecer categorías de referencia
fvset base 2 ocupacion
fvset base 3 tipo_hogar
fvset base 4 educacion
fvset base 2 edad_tres_grupos
fvset base 1 afp
fvset base 1 sex
fvset base 1 condicion_laboral
fvset base 1 urban

***Modelo basal interactuado por año, para 60+, no indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==2 & condic_etnica==0, rrr
estat ic

***Modelo basal interactuado por año, para 60+, indígena - Odds Ratio
mlogit pobre i.ocupacion#year /// 
	i.tipo_hogar#year ///
	i.educacion#year ///
	i.afp#year ///
	i.sex#year ///
	i.condicion_laboral#year ///
	i.urban#year if year >=2019 & edad_tres_grupos==2 & condic_etnica==1, rrr
estat ic

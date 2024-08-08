# Rachel Grisham Cohort

<b>Path:</b> `OCRA."HRD_RG_data"` <br/>
<b>Table Type:</b> `Static` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

Dr. Rachel Grisham <br/>
|_ `OCRA."HRD_RG_data"` <br/>

<b>Summary Statistics:</b>

Total number of rows: 426 <br/>
Total number of unique patients: 426 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Dataset presented by Dr. Rachel Grisham, containing genomic instability scores (GIS)
from Myriad testing across a small cohort of patients. 

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| Result | | categorical | string | P, N, I, IT |
| Result_Binary | | boolean | string | 0, 1 |
| Date | | date | string | MM/DD/YYYY |
| MRN | Medical Record Number | ID | string | |
| DOB | Date of Birth | date | string | MM/DD/YYYY |
| GIS | Genomic Instability Score (Myriad test) | | string | 1 - 99 |
| Histology_1 | | categorical | string | '1', '2', ... [Key](https://mskconfluence.mskcc.org/pages/viewpage.action?spaceKey=CDSI&title=OCRA#OCRA-Histology) |
| Prim_Inter | surgery type | categorical | string | '1', '2', ... [Key](https://mskconfluence.mskcc.org/pages/viewpage.action?spaceKey=CDSI&title=OCRA#OCRA-Prim_Inter) |
| Spec_Source | specimen type | categorical | string | '1', '2', ... [Key](https://mskconfluence.mskcc.org/pages/viewpage.action?spaceKey=CDSI&title=OCRA#OCRA-SpecSource) |
| Chemo_Naive | has patient received chemo? | boolean | string | 0, 1 |
| Stage | Cancer stage | | string | 3A1, 4B, etc. |
| Residual_Disease | | | string | '1', '2', ... [Key](https://mskconfluence.mskcc.org/pages/viewpage.action?spaceKey=CDSI&title=OCRA#OCRA-ResidualDisease) |
| NA_Cycles | | | string | |
| Adj_Cycles | | | string | |
| TUF_Plat_Cycles | | | string | |
| UF_Chemo_Regm | | | string | |
| Race | | categorical | string | '0', '1', ... [Key](https://mskconfluence.mskcc.org/pages/viewpage.action?spaceKey=CDSI&title=OCRA#OCRA-Race) |
| First_Treat | | date | string | MM/DD/YYYY |
| Diag_Date | | date | string | MM/DD/YYYY |
| Path_Date | | date | string | MM/DD/YYYY |
| UF_Start_Date | | date | string | MM/DD/YYYY |
| Last_Plat_Date | | date | string | MM/DD/YYYY |
| Maint_Regm | | | string | |
| Maint_Disc_Reason | | | string | |
| Bev_Start | | date | string | MM/DD/YYYY |
| Bev_End | | date | string | MM/DD/YYYY |
| PARP_Type | | | string | |
| PARP_Start_Date | | date | string | MM/DD/YYYY |
| PARP_End_Date | | date | string | MM/DD/YYYY |
| Rad_Progr_Date | | date | string | MM/DD/YYYY |
| Total_Lines | | | string | |
| Date_Death | | date | string | MM/DD/YYYY |
| Date_Followup | | date | string | MM/DD/YYYY |


## Rules <a name="rules"></a>

1. PARP treatment wasn't available before 2018


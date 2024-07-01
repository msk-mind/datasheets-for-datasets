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

Dataset presented by Dr. Grisham containing Myriad GIS score for a small cohort of patients. 

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| Result | | string | P, N, I, IT |
| Result_Binary | | string | 0, 1 |
| Date | | string | MM/DD/YYYY |
| MRN | Medical Record Number | string | |
| DOB | Date of Birth | string | MM/DD/YYYY |
| GIS | Genomic Instability Score (from Myriad) | string | 1 - 99 |
| Histology_1 | | string | |
| Prim_Inter | | string | |
| Spec_Source | | string | |
| Chemo_Naive | | string | 0, 1 |
| Stage | Cancer stage | string | 3A1, 4B, etc. |
| Residual_Disease | | string | |
| NA_Cycles | | string | |
| Adj_Cycles | | string | |
| TUF_Plat_Cycles | | string | |
| UF_Chemo_Regm | | string | |
| Race | | string | |
| First_Treat | | string | MM/DD/YYYY |
| Diag_Date | | string | MM/DD/YYYY |
| Path_Date | | string | MM/DD/YYYY |
| UF_Start_Date | | string | MM/DD/YYYY |
| Last_Plat_Date | | string | MM/DD/YYYY |
| Maint_Regm | | string | |
| Maint_Disc_Reason | | string | |
| Bev_Start | | string | MM/DD/YYYY |
| Bev_End | | string | MM/DD/YYYY |
| PARP_Type | | string | |
| PARP_Start_Date | | string | MM/DD/YYYY |
| PARP_End_Date | | string | MM/DD/YYYY |
| Rad_Progr_Date | | string | MM/DD/YYYY |
| Total_Lines | | string | |
| Date_Death | | string | MM/DD/YYYY |
| Date_Followup | | string | MM/DD/YYYY |


## Rules <a name="rules"></a>

1. An important field in the table is the GIS score obtained from the Myriad test. 
2. PARP treatment wasn't available before 2018


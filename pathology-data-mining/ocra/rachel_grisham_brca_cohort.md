# Rachel Grisham BRCA Cohort

<b>Path:</b> `OCRA."HRD_Shah_cohort"` <br/>
<b>Table Type:</b> `Static` <br/>
<b>Last updated:</b> `2024-07-06` <br/>

<b>Lineage:</b> 

Dr. Rachel Grisham <br/>
|_ `phi_data_lake.ocra."HRD_Shah_cohort.csv"` <br/>

<b>Summary Statistics:</b>

Total number of rows: 105 <br/>
Total number of unique patients: 105 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Dataset presented by Dr. Grisham for patients with BRCA mutations.  These patients did not
receive Myriad testing because BRCA1/2 mutations already indicate homologous recombination
deficiency (HRD).

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| A | | | string | |
| Provider | | | string | |
| ID/Requisition | | ID | string | |
| Name | Patient name | | string | |
| DOB | Date of Birth | date | string | MM/DD/YYYY |
| MRN | Medical Record Number | ID | string | |
| Race | | categorical | string | '1', '2', ... |
| Histology_1 | | | string | |
| Histology_M1 | | | string | |
| Histology_M2 | | | string | |
| Hist_Grade | | | string | |
| Prim_Inter | | | string | |
| Spec_Source | | | string | |
| Chemo_Naive | has the patient received chemo? | boolean | string | 0, 1 |
| Stage | Cancer stage | categorical | string | 3A1, 4B, etc. |
| Residual_Disease | | | string | |
| NA_Cycles | | conut | string | |
| Adj_Cycles | | count | string | |
| TUF_Plat_Cycles | | | string | |
| UF_Chemo_Regm | | | string | |
| Diag_Date | | date | string | MM/DD/YYYY |
| Path_Date of tested sample| | date | string | MM/DD/YYYY |
| UF_Start_Date | | date | string | MM/DD/YYYY |
| Last_Plat_Date | | date | string | MM/DD/YYYY |
| Maint_Regm | | | string | |
| Maint_Disc_Reason | | | string | |
| Bev_Start | | date | string | MM/DD/YYYY |
| Bev_End | | date | string | MM/DD/YYYY |
| PARP_Type | | | string | |
| PARP_Start_Dose | | | string | |
| PARP_Start_Date | | date | string | MM/DD/YYYY |
| PARP_End_Dose | | | string | |
| PARP_End_Date | | date | string | MM/DD/YYYY |
| Rad_Progr_Date | | date | string | MM/DD/YYYY |
| Next_Tx_Regimen | | | string | |
| Next_start_Date | | date | string | |
| Total_Lines | | count | string | |
| Date_Death | | date | string | MM/DD/YYYY |
| Cause_Death | | | string | |
| Date_Followup | | date | string | MM/DD/YYYY |
| Comments | | text | string | |
| UF_Chemo_Regm_Comm | | | string | |


## Rules <a name="rules"></a>

1. PARP treatment wasn't available before 2018


# data_clinical_sample.oncokb

<b>Path:</b> `"phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

[cBioportal - data_clinical_sample.oncokb](https://github.mskcc.org/cdsi/oncokb-annotated-msk-impact/blob/main/data_clinical_sample.oncokb.txt.gz) <br/>
|_ `"phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt"` <br/>

<b>Summary Statistics:</b>

Total number of rows: 125,071 <br/>
Total number of unique patients: 88,072 <br/>
Total number of unique IMPACT samples: 125,071 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Contains patient level information and sample level information for patients w/ tumors sequenced for MSK IMPACT.

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| SAMPLE_ID | The IMPACT sample ID | string | |
| PATIENT_ID | The patient's DMP_ID | string | |
| GLEASON_SAMPLE_LEVEL | Gleason score reported on sample| string | integer 0 to 9 |
| PDL1_POSITIVE | Was sample labelled PD-L1 positive? | string | 'Yes', 'No', or empty string |
| MONTH_ADDED | Month added to cBioPortal | string | YYYY/MM |
| WEEK_ADDED | Week added to cBioPortal | string | YYYY 'Wk.' # |
| CANCER_TYPE | General cancer type | string | |
| SAMPLE_TYPE | Is sample primary of metastatic? | string | Primary, Metastasis |
| SAMPLE_CLASS | | string | |
| METASTATIC_SITE | Location of metastatic site | string | |
| PRIMARY_SITE | Location of primary site | string | |
| CANCER_TYPE_DETAILED | Specific cancer subtype | string | |
| GENE_PANEL | The IMPACT gene panel that was used | string | IMPACT341, IMPACT410, etc.|
| SO_COMMENTS | Physician sign-out comments | | |
| SAMPLE_COVERAGE | | | |
| TUMOR_PURITY | Proportion of cancer cells in tissue sample | string | |
| ONCOTREE_CODE | The OncoTree cancer-type code | string | |
| MSI_COMMENT | Microsatellite Instability (MSI) comment | string | |
| MSI_SCORE | Microsatellite Instability (MSI) score | string | |
| MSI_TYPE | Microsatellite Instability (MSI) type | string | Stable, Instable, or Indeterminate |
| INSTITUTE | Institute source (.e.g. MSKCC) | string | |
| SOMATIC_STATUS | Is there a matched somatic sample for comparison? | string | |
| ARCHER | Was MSK-ARCHER test performed? | string | |
| CVR_TMB_COHORT_PERCENTILE | | | |
| CVR_TMB_SCORE | | | |
| CVR_TMB_TT_COHORT_PERCENTILE | | | |
| PATH_SLIDE_EXISTS | | | |
| MSK_SLIDE_ID | | | |
| LEVEL_1 | | | |
| LEVEL_2 | | | |
| LEVEL_3A | | | |
| LEVEL_3B | | | |
| LEVEL_4 | | | |
| LEVEL_R1 | | | |
| LEVEL_R2 | | | |
| HIGHEST_LEVEL | | | |
| HIGHEST_SENSITIVE_LEVEL | | | |
| HIGHEST_RESISTANCE_LEVEL | | | |
| LEVEL_Dx1 | | | |
| LEVEL_Dx2 | | | |
| LEVEL_Dx3 | | | |
| HIGHEST_DX_LEVEL | | | |
| LEVEL_Px1 | | | |
| LEVEL_Px2 | | | |
| LEVEL_Px3 | | | |
| HIGHEST_PX_LEVEL | | | |
| ONCOGENIC_MUTATIONS | | | |
| #ONCOGENIC_MUTATIONS | | | |
| RESISTANCE_MUTATIONS | | | |
| #RESISTANCE_MUTATIONS | | | |
| #MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS | | | |
| #MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS | | | |
| #MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS | | | |
| #MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS | | | |
| #MUTATIONS | | | |

## Rules <a name="rules"></a>

1. Each row represents a single MSK-IMPACT sample w/ OncoKB annotated variants and the corresponding patient level clinical data.
2. This dataset excludes cf-DNA samples from the main IMPACT cohort dataset from cBioPortal.


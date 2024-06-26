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
| SO_COMMENTS | Physician sign-out comments | string | |
| SAMPLE_COVERAGE | | string | |
| TUMOR_PURITY | Proportion of cancer cells in tissue sample | string | |
| ONCOTREE_CODE | The OncoTree cancer-type code | string | |
| MSI_COMMENT | Microsatellite Instability (MSI) comment | string | |
| MSI_SCORE | Microsatellite Instability (MSI) score | string | |
| MSI_TYPE | Microsatellite Instability (MSI) type | string | Stable, Instable, or Indeterminate |
| INSTITUTE | Institute source | string | MSKCC, etc. |
| SOMATIC_STATUS | Is there a matched somatic sample for comparison? | string | Matched, Unmatched |
| ARCHER | Was MSK-ARCHER test performed? | string | YES, NO |
| CVR_TMB_COHORT_PERCENTILE | Tumor Mutation Burden % across cancer types | string | |
| CVR_TMB_SCORE | Tumor Mutation Burden score | string | |
| CVR_TMB_TT_COHORT_PERCENTILE | Tumor Mutation Burden % within cancer type | string | |
| PATH_SLIDE_EXISTS | Is there a pathology slide ID? | string | YES, NO |
| MSK_SLIDE_ID | Matching pathology slide ID | string | |
| LEVEL_1 | | string | |
| LEVEL_2 | | string | |
| LEVEL_3A | | string | |
| LEVEL_3B | | string | |
| LEVEL_4 | | string | |
| LEVEL_R1 | | string | |
| LEVEL_R2 | | string | |
| HIGHEST_LEVEL | | string | |
| HIGHEST_SENSITIVE_LEVEL | | string | |
| HIGHEST_RESISTANCE_LEVEL | | string | |
| LEVEL_Dx1 | | string | |
| LEVEL_Dx2 | | string | |
| LEVEL_Dx3 | | string | |
| HIGHEST_DX_LEVEL | | string | |
| LEVEL_Px1 | | string | |
| LEVEL_Px2 | | string | |
| LEVEL_Px3 | | string | |
| HIGHEST_PX_LEVEL | | string | |
| ONCOGENIC_MUTATIONS | | string | |
| #ONCOGENIC_MUTATIONS | | string | |
| RESISTANCE_MUTATIONS | | string | |
| #RESISTANCE_MUTATIONS | | string | |
| #MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS | | string | |
| #MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS | | string | |
| #MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS | | string | |
| #MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS | | string | |
| #MUTATIONS | | string | |

## Rules <a name="rules"></a>

1. Each row represents a single MSK-IMPACT sample w/ OncoKB annotated variants and the corresponding patient level clinical data.
2. This dataset excludes cf-DNA samples from the main IMPACT cohort dataset from cBioPortal.
3. You can't rely on the MSK slide ID, because it's only available for about a quarter of the IMPACT samples in this dataset.


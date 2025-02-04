# data_clinical_sample.oncokb

<b>Path:</b> "cdsi_prod.msk_impact_oncokb_annotated.data_clinical_sample_oncokb_raw" <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

[cBioportal - data_clinical_sample.oncokb](https://github.mskcc.org/cdsi/oncokb-annotated-msk-impact/blob/main/data_clinical_sample.oncokb.txt.gz) <br/>
|_ ["cdsi_prod.msk_impact_oncokb_annotated.data_clinical_sample_oncokb_raw"](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/msk_impact_oncokb_annotated/data_clinical_sample_oncokb_raw) <br/>

<b>Summary Statistics:</b>

Total number of rows: 125,071 <br/>
Total number of unique patients: 88,072 <br/>
Total number of unique IMPACT samples: 125,071 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
4. [Notes](#notes)


## Description <a name="description"></a>

Contains patient level information and sample level information for patients w/ tumors sequenced for MSK IMPACT.

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

Abbreviations:
* TMB - Tumor Mutational Burden
* MSI - Microsatellite Instability

| **Field name** | **Description** | **Field Type** | **Data Type** | **Format** |
|---|---|---|---|---|
| SAMPLE_ID | IMPACT sample ID | ID | string | |
| PATIENT_ID | Patient DMP_ID | ID | string | |
| GLEASON_SAMPLE_LEVEL | Gleason score | | string | '0', '1', ... '9' |
| PDL1_POSITIVE | Sample PD-L1 positive? | boolean | string | 'Yes', 'No', or '' |
| MONTH_ADDED | Month added to cBioPortal | date | string | YYYY/MM |
| WEEK_ADDED | Week added to cBioPortal | date | string | YYYY 'Wk.' # |
| CANCER_TYPE | General cancer type | categorical | string | |
| SAMPLE_TYPE | Is sample primary of metastatic? | categorical | string | 'Primary', 'Metastasis', 'Unknowm', 'Local Recurrence' |
| SAMPLE_CLASS | | categorical | string | 'cfDNA', 'Tumor'|
| METASTATIC_SITE | Location of metastatic site | categorical | string | |
| PRIMARY_SITE | Location of primary site | categorical | string | |
| CANCER_TYPE_DETAILED | Specific cancer subtype | categorical | string | |
| GENE_PANEL | The IMPACT gene panel used | categorical | string | IMPACT341, IMPACT410, etc.|
| SO_COMMENTS | Physician sign-out comments | | string | |
| SAMPLE_COVERAGE | | | string | |
| TUMOR_PURITY | Proportion of cancer cells in sample | | string | |
| ONCOTREE_CODE | OncoTree cancer-type code | ID | string | |
| MSI_COMMENT | MSI comment | | string | |
| MSI_SCORE | MSI score | | string | |
| MSI_TYPE | MSI type | categorical | string | Stable, Instable, or Indeterminate |
| INSTITUTE | Source institution | categorical | string | MSKCC, etc. |
| SOMATIC_STATUS | Does matched somatic sample exist? | categorical | string | Matched, Unmatched |
| ARCHER | MSK-ARCHER performed? | boolean | string | 'YES', 'NO' |
| CVR_TMB_COHORT_PERCENTILE | TMB % across cancer types | | string | |
| CVR_TMB_SCORE | TMB score | | string | |
| CVR_TMB_TT_COHORT_PERCENTILE | TMB % for cancer type | | string | |
| PATH_SLIDE_EXISTS | | boolean | string | YES, NO |
| MSK_SLIDE_ID | slide ID | ID | string | |
| LEVEL_1 | | | string | |
| LEVEL_2 | | | string | |
| LEVEL_3A | | | string | |
| LEVEL_3B | | | string | |
| LEVEL_4 | | | string | |
| LEVEL_R1 | | | string | |
| LEVEL_R2 | | | string | |
| HIGHEST_LEVEL | | | string | |
| HIGHEST_SENSITIVE_LEVEL | | | string | |
| HIGHEST_RESISTANCE_LEVEL | | | string | |
| LEVEL_Dx1 | | | string | |
| LEVEL_Dx2 | | | string | |
| LEVEL_Dx3 | | | string | |
| HIGHEST_DX_LEVEL | | | string | |
| LEVEL_Px1 | | | string | |
| LEVEL_Px2 | | | string | |
| LEVEL_Px3 | | | string | |
| HIGHEST_PX_LEVEL | | | string | |
| ONCOGENIC_MUTATIONS | Oncogenic variants | | string | semi-colon separated list of variants |
| #ONCOGENIC_MUTATIONS | | count | string | number |
| RESISTANCE_MUTATIONS | Variants conferring resistance| | string | semi-colon separated list of variants |
| #RESISTANCE_MUTATIONS | | count | string | number |
| #MUTATIONS | Total mutations | count | string | number |

Four additional columns provide counts of particular classes of mutations:

* #MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS
* #MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS
* #MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS
* #MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS

## Notes <a name="notes"></a>

1. Each row represents a single MSK-IMPACT sample w/ OncoKB annotated variants and the corresponding patient level clinical data.
2. This dataset excludes cf-DNA samples from the main IMPACT cohort dataset from cBioPortal.
3. You can't rely on the MSK slide ID, because it's only available for about a quarter of the IMPACT samples in this dataset.


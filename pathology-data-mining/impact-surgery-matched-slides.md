# Impact-surgery-matched-Slides

<b>Path:</b> [`"cdsi_prod.pathology_data_mining.impact_surgery_matched_slides"`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/impact_surgery_matched_slides) <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Last updated:</b> `2025-11-11` <br/>

<b>Lineage ([SQL](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact-surgery-matched-slides.sql)): </b> 



<b>Summary Statistics:</b>

Total number of unique patients: 71,607 <br/>
Total number of IMPACT samples: 82,389 <br/>
Total number of whole slide images: 976,440 <br/>
Total number of whole slide images in PDM inventory: 571,191 <br/>


1. [Description](#description)
2. [Vocabulary](#vocabulary)
3. [Notes](#notes)


## Description <a name="description"></a>

This table represents all IMPACT patients and samples for which we have whole slide images matched at the surgery level (NOTE: not matched at part of block level). This table was built using multiple tables starting from the Hobbit table as base. The [Hobbit table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/hobbit-casebreakdown-cleaned.md) includes all patients for whom de-identified slides exist. The [surgical_specimen_diagnoses table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_diagnoses.md) was added to the Hobbit table to include detailed information about the patient's diagnosis relative to the time at which tissue was accessioned from a surgery event. The [pathology reports table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) from the CDM team was added to include the mapping between IMPACT sample_id and accession. This mapping is required to integrate the whole slide image information from Hobbit with the genomic sample information from IMPACT. These two additions form an extended version of the Hobbit table. 

Next, the intersection between the extended Hobbit table and select gene panels for solid tumors (see NOTES below) from the IMPACT table (cdsi_public.msk_impact.data_clinical_sample) was made to generate the final table that integrates genomic sample information with whole slide image information at the surgery level.   


## Vocabulary <a name="vocabulary"></a>

The following columns have been selected from the superset of columns in the lineage as they are seen relevant for the purpose of matching slides to IMPACT samples at the surgery level. 

Key columns include...

| **Field name** | **Description** | **Field Type** | **Data type** | **Format** |
|---|---|---|---|---|
patient_id_impact | anonymized medical record number from MPath | ID | string | |
sample_id_impact | the IMPACT sample ID associated with the genomics results | ID | string | |
accession_number | accession number from HoBBIT record. <b>This data element is considered PHI</b> | ID  | string | |
date_of_procedure_surgical | Date of surgical procedure <b>This data element is considered PHI</b> | Date  | Datetime | |
datetime_accession | anonymized date of tissue accession <b>This data element is considered PHI</b> | Date  | Datetime | |
date_sequencing_report | Date of sequencing report generation <b>This data element is considered PHI</b> | Date  | Datetime | |
is_hne | 1 if H&E, else 0 | categorical  | string | |
is_ihc | 1 if IHC, else 0 | categorgical  | string | |
stain_name | Type of stain used and sometimes carries processing info | Categorical / Natural Language Description  | string | 'H%E' implies H&E stain, 'RECUT' indicates, a new slide was requested possible for higher tumor content for sequencing, 'SUBMITTED' indicates an outside MSK case that was submitted to MSK |
scanner_id | scanner id | ID | string | |
scanner_brand | scanner brand | categorical | string | |
scanner_model | scanner model | categorical | string | |
image_id | image id that is globally unique | ID | string | |
IMAGE_ID_INVENTORY | image id if image is present in PDM inventory, else null | ID | string | |
PATH_INVENTORY | location of image if it exists in PDM inventory | variable | string | |
SOURCE_INVENTORY | source at which image is present in PDM inventory | categorical | string | |
LAST_MODIFIED_INVENTORY | Date when the image was last updated in PDM inventory | Date | Datetime | |
magnification | slide magnification | categorical | string | '20x', '40x', ... |
path_dx_spec_desc | detailed tissue diagnosis | natural language text | string | |
path_dx_spec_title | brief tissue diagnosis | natural language text | string | |
GLEASON_SAMPLE_LEVEL |  |  |  |  |
pdl1_positive |  |  |  |  |
cancer_type |  |  |  |  |
sample_class |  |  |  |  |
metastatic_site |  |  |  |  |
primary_site |  |  |  |  |
cancer_type_detailed |  |  |  |  |
gene_panel |  |  |  |  |
so_comments |  |  |  |  |
sample_coverage |  |  |  |  |
tumor_purity |  |  |  |  |
oncotree_code |  |  |  |  |
msi_comment |  |  |  |  |
msi_score |  |  |  |  |
msi_type |  |  |  |  |
institute |  |  |  |  |
somatic_status |  |  |  |  |
archer |  |  |  |  |
cvr_tmb_cohort_percentile |  |  |  |  |
cvr_tmb_score |  |  |  |  |
cvr_tmb_tt_cohort_percentile |  |  |  |  |


## Notes <a name="notes"></a>

1. Slides and IMPACT samples are matched based on the accession number for the tissue used to make those slides and those samples.  

2. The IMPACT samples have been filtered to include only solid tumors, using SAMPLE_CLASS = 'Tumor' AND GENE_PANEL = ['IMPACT341', 'IMPACT410', 'IMPACT505', 'IMPACT468']

3. Data attrition: We start with patients = 502,266 patients from the Hobbit table and 104,440 patients in the IMPACT table. The integrating pathology reports table from CDM team that helps to bring these two tables together has 110,636 patients. Of these 110,636 patients, 83,084 patients are found to intersect with the patients in the Hobbit table. The IMPACT table after filtering for solid tumor assays, contains 83,568 patients, down from 104,440 patients. The intersection of the 83,084 patients from the Hobbit table that overlaps with the pathology reports table and the 83,568 patients with solid tumor samples in the IMPACT table finally yields 76,604 patients that have at least one matching slide.

4. Not all of the slides in HoBBIT can be used for research. In practice, roughly 1% of requested slides contain PHI on the slide itself and thus cannot be de-identified for research use. This cannot be determined via HoBBIT, and is only determined during data transfer.

5. This table is missing some mutation data that needs to be brought in from another IMPACT table. For example, 
    `ONCOGENIC_MUTATIONS,`
    `#ONCOGENIC_MUTATIONS`,
    `RESISTANCE_MUTATIONS`,
    `#RESISTANCE_MUTATIONS`,
    `#MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS` 








# CPTAC Slide Metadata (CPTAC-2 and CPTAC-3)

<b>Path:</b> `s3://cptac/cptac-2/` and `s3://cptac/cptac-3/` (endpoint http://pmindecs.mskcc.org:9020) <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 2026-09-02 <br/>

<b>Lineage:</b> TCIA PathDB slide catalog enriched with GDC biospecimen slide entities and GDC clinical bundles. Rows are restricted to slides that physically exist in the `cptac` ECS bucket.

<b>Summary Statistics:</b>

CPTAC-2: 1,245 slides, 451 patients, 3 collections (CPTAC-BRCA, CPTAC-COAD, CPTAC-OV). <br/>
CPTAC-3: 7,178 slides, 1,980 patients, 12 collections (AML, CCRCC, CM, GBM, HNSCC, LSCC, LUAD, PDA, SAR, STAD, UCEC, non-CCRCC). <br/>
All slides are H&E, 40x, whole slide images. All are diagnostic; no frozen sections. <br/>
CPTAC-3 tissue split (where GDC biospecimen exists): 1,940 Primary Tumor, 841 Solid Tissue Normal. 272 CPTAC-AML slides are bone marrow. <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This dataset indexes the CPTAC whole slide images downloaded from the TCIA PathDB catalog and stored on the ECS `cptac` bucket, one row per slide, with patient and slide level metadata. CPTAC-2 covers the three original collections (BRCA, COAD, OV); CPTAC-3 covers all later collections.

Metadata is assembled from three sources:

- <b>A. PathDB slide catalog</b> (per slide, both phases): stain, modality, magnification, mpp, cancer type and location, data availability flags, cAMIC id, DOI, S3 path.
- <b>B. GDC biospecimen slide entities</b> (CPTAC-3 only, joined by slide id): sample type (tumor vs normal), tissue type, tumor descriptor, section location, and slide level percent tumor and necrosis. CPTAC-2 has no GDC slide entities.
- <b>C. GDC clinical bundles</b> (primary source for patient clinical, pathology, exposure, and follow-up): demographics, diagnosis, AJCC stage, pathology detail, smoking and alcohol exposure, and a follow-up summary. Populated for CPTAC-3; largely empty at GDC for CPTAC-2.

### Vocabulary <a name="vocab"></a>

Primary key: <b>slide_id</b> (unique within each phase). <b>path</b> is also unique. GDC null markers are normalized to empty strings.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| collection | CPTAC collection (e.g. CPTAC-LUAD) | Categorical | string | |
| patient_id | Patient/case submitter id | ID | string | e.g. C3L-00004 |
| slide_id | Slide identifier (svs stem) | ID | string | e.g. C3L-00004-21 |
| svs_filename | Slide file name | ID | string | `<slide_id>.svs` |
| magnification | Scan magnification | Categorical | string | 40x |
| mpp | Microns per pixel | Mixed | string | e.g. (0.246,0.246)mpp |
| stain_protocol | Stain | Categorical | string | Hematoxylin and eosin |
| modality | Image modality | Categorical | string | Whole slide image |
| cancer_type | Cancer type (PathDB) | Categorical | string | |
| cancer_location | Anatomic location (PathDB) | Categorical | string | |
| has_radiology | Radiology available in TCIA | Categorical | string | Yes/No |
| has_genomics | Genomics available | Categorical | string | Yes/No |
| has_proteomics | Proteomics available | Categorical | string | Yes/No |
| supporting_data_type | Supporting data (PathDB) | Categorical | string | |
| camic_id | caMicroscope id | ID | string | |
| collection_doi | Collection DOI | ID | string | |
| path | Full S3 URI of the slide | ID | string | s3://cptac/... |
| catalog_update | PathDB catalog update date | Mixed | string | |
| sex_at_birth | Sex at birth | Categorical | string | |
| race | Race | Categorical | string | |
| ethnicity | Ethnicity | Categorical | string | |
| vital_status | Vital status | Categorical | string | Alive/Dead |
| days_to_birth | Days from index to birth (negative) | Continuous | integer | |
| year_of_birth | Year of birth | Continuous | integer | YYYY |
| country_of_birth | Country of birth | Categorical | string | |
| cause_of_death | Cause of death | Categorical | string | |
| days_to_death | Days from index to death | Continuous | integer | |
| primary_site | Primary site | Categorical | string | |
| disease_type | Disease type | Categorical | string | |
| primary_diagnosis | Primary diagnosis | Categorical | string | |
| morphology | ICD-O-3 morphology code | Categorical | string | |
| tumor_grade | Tumor grade | Categorical | string | |
| ajcc_pathologic_stage | AJCC pathologic stage | Categorical | string | |
| ajcc_pathologic_t | AJCC pathologic T | Categorical | string | |
| ajcc_pathologic_n | AJCC pathologic N | Categorical | string | |
| ajcc_pathologic_m | AJCC pathologic M | Categorical | string | |
| ajcc_staging_system_edition | AJCC staging edition | Categorical | string | |
| age_at_diagnosis | Age at diagnosis (days) | Continuous | integer | |
| year_of_diagnosis | Year of diagnosis | Continuous | integer | YYYY |
| site_of_resection_or_biopsy | Site of resection or biopsy | Categorical | string | |
| tissue_or_organ_of_origin | Tissue or organ of origin | Categorical | string | |
| classification_of_tumor | Classification of tumor | Categorical | string | |
| prior_malignancy | Prior malignancy | Categorical | string | yes/no |
| progression_or_recurrence | Progression or recurrence | Categorical | string | yes/no |
| last_known_disease_status | Last known disease status | Categorical | string | |
| days_to_last_follow_up | Days to last follow up (diagnosis) | Continuous | float | |
| lymph_node_involvement | Lymph node involvement | Categorical | string | |
| lymph_nodes_positive | Number of positive lymph nodes | Continuous | integer | |
| lymph_nodes_tested | Number of lymph nodes tested | Continuous | integer | |
| greatest_tumor_dimension | Greatest tumor dimension (cm) | Continuous | float | |
| tumor_largest_dimension_diameter | Largest tumor diameter (cm) | Continuous | float | |
| margin_status | Surgical margin status | Categorical | string | |
| lymphatic_invasion_present | Lymphatic invasion present | Categorical | string | yes/no |
| vascular_invasion_present | Vascular invasion present | Categorical | string | yes/no |
| perineural_invasion_present | Perineural invasion present | Categorical | string | yes/no |
| tobacco_smoking_status | Tobacco smoking status | Categorical | string | |
| pack_years_smoked | Pack years smoked | Continuous | float | |
| cigarettes_per_day | Cigarettes per day | Continuous | float | |
| alcohol_history | Alcohol history | Categorical | string | yes/no |
| alcohol_intensity | Alcohol intensity | Categorical | string | |
| follow_up_count | Number of follow-up records | Continuous | integer | |
| last_days_to_follow_up | Days to latest follow up | Continuous | float | |
| last_disease_response | Disease response at latest follow up | Categorical | string | |
| case_id | GDC case UUID | ID | string | |
| slide_gdc_uuid | GDC slide entity UUID (source B) | ID | string | |
| sample_submitter_id | Parent sample submitter id (source B) | ID | string | e.g. C3L-00004-01 |
| sample_type | Sample type (source B) | Categorical | string | Primary Tumor, Solid Tissue Normal, ... |
| tissue_type | Tissue type (source B) | Categorical | string | Tumor/Normal |
| tumor_descriptor | Tumor descriptor (source B) | Categorical | string | |
| sample_preservation_method | Preservation method of the parent analyte sample, not the slide (source B) | Categorical | string | |
| section_location | Slide section location (source B) | Categorical | string | |
| slide_percent_tumor_nuclei | Slide percent tumor nuclei (source B) | Continuous | float | 0-100 |
| slide_percent_necrosis | Slide percent necrosis (source B) | Continuous | float | 0-100 |

## Notes <a name="notes"></a>

1. <b>Rows equal existing objects.</b> Each row corresponds to an slide that exists in the `cptac` bucket. `slide_id` is unique per phase and `path` is unique.
2. <b>File naming.</b> Files are named `<slide_id>.svs`. CPTAC-3 uses case-style ids (e.g. C3L-00004-21); CPTAC-2 uses opaque legacy ids (numeric or UUID). CPTAC-3 slide part codes: `-2x` are FFPE tissue sections, `-4x` are CPTAC-AML bone marrow, `_D1` are diagnostic FFPE.
3. <b>All diagnostic, no frozen.</b> `stain_protocol` is Hematoxylin and eosin for 100% of rows; no `-1x` frozen part codes are present.
4. <b>Do not infer slide preservation from `sample_preservation_method`.</b> It describes the parent analyte sample and can read Frozen even for FFPE diagnostic slides.
5. <b>Coverage (fields may be blank).</b>
   - CPTAC-2: patient clinical (primary_diagnosis) about 63%. Pathology, exposure, follow-up, and slide biospecimen are absent (GDC holds none for CPTAC-2).
   - CPTAC-3: clinical about 82%, pathology (lymph_nodes_tested) about 66%, exposure about 79%, follow-up about 79%, slide biospecimen (sample_type) about 38%.
6. <b>Sample to slide.</b> Where source B exists (CPTAC-3), `sample_submitter_id` to `slide_id` is 1:1 in this dataset. The GDC model permits one sample to many slides, so this is not guaranteed in general.
7. <b>Known gaps.</b> 8 CPTAC-PDA slides in the PathDB catalog are absent from the bucket and are therefore not in this table. PathDB has a corrupt record where slide id `C3l-04086-21` (lowercase L) is repeated for 8 distinct LSCC slides; the downloader collapsed them to one file, so only that one object exists.

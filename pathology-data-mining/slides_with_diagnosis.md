# Slides with Diagnosis

<b>Path:</b> `"pathology-data-mining"."slides_with_diagnosis"` <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Last updated:</b> `2024-08-06` <br/>

<b>Lineage:</b> 

["pathology-data-mining".impact_slide.case_breakdown_cleaned](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/hobbit-casebreakdown-cleaned.md) (as t1) <br/>
[phi_data_lake."cdm-data".pathology."table_pathology_surgical_samples_parsed_specimen.tsv"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_diagnoses.md) (as t2) <br/>
&nbsp; |_ t1 LEFT JOIN t2 ON t1.ACCESSION_NUMBER = t2.ACCESSION_NUMBER_PATH_DX AND t1.PART_NUMBER = t2.PART_NUMBER_PATH_DX (as t3) <br/>
&nbsp; &nbsp; ["pathology-data-mining"."master_slide_inventory"."master_slide_inventory"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/master_slide_inventory.md) (as t4) <br/>
&nbsp; &nbsp; |_ t3 LEFT JOIN t4 ON t3.image_id = t4.IMAGE_ID_INVENTORY (as t5) <br/>


<b>Summary Statistics:</b>

Total number of rows (slides): 6,269,634 <br/>
Total number of slides with diagnoses: 1,816,553 <br/>
Total number of patients: 369,732 <br/>
Total number of downloaded slides: 83,076 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Data describing WSI slides in HoBBIT database, with detailed diagnoses of the tissue
samples from which they were made, and the slides' availability on the CDSI servers.

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

Most of the columns in the master table are described in datasheets from the lineage
A number of columns were added to make common queries simpler.
In some cases, a columns that appeared in multiple base tables were renamed to reflect
which base table they came from.

Key columns in the final table include,

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| MRN | medical record number from HoBBIT records | string | |
| ACCESSION_NUMBER | accession number from HoBBIT record |  string | |
| PART_NUMBER | part number from HoBBIT record |  integer  | |
| BLOCK_NUMBER | block number from HoBBIT record | integer  | |
| BLOCK_LABEL | block label from HoBBIT record |  string  | |
| stain_group | | string | |
| IS_HNE | Is the stain group  "H&E (Initial)" or "H&E (Other)" ? | integer | |
| IS_IHC | Is the stain group "IHC"? | integer | |
| MRN_PATH | medical record number from pathology report | string | |
| PATH_DX_SPEC_TITLE | brief tissue diagnosis | string | |
| PATH_DX_SPEC_DESC | detailed tissue diagnosis | string | |
| image_id | the slide ID for the whole-slide image | string | |
| magnification | slide magnification (20x, 40x, etc.) | string | |
| SLIDE_URL | the file:// URL for the downloaded slide | string | |


## Rules <a name="rules"></a>

1. The SLIDE_URL is NULL if the slide has not been downloaded to a CDSI storage system.




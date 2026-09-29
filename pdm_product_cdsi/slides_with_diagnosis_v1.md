# slides_with_diagnosis_v1

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.slides_with_diagnosis_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/slides_with_diagnosis_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 696,758 <br/>
Unique image_ids (slides): 683,953 <br/>
Unique PATIENT_ID_IMPACT: 75,490 <br/>
Unique SAMPLE_ID_IMPACT: 87,393 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (WSI) in the HoBBIT database with detailed diagnoses of the tissue samples from which they were made, restricted to slides that match an MSK-IMPACT sample. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent.

This is the widest of the MSK slide tables (683,953 slides across 75,490 patients) and is the parent of [impact_matched_slides_v1](impact_matched_slides_v1.md), which adds the IMPACT genomic annotations.

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

The first three columns are the IMPACT identifiers, followed by the slide, part, stain, and diagnosis columns (31 columns total).

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | string (varchar(100)) | |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| specclass_id | Specimen class identifier | ID | string | |
| subspecialty | Pathology subspecialty | Categorical | string | e.g. `Breast`, `GU`, ... |
| priority / reduced_priority | Case priority as recorded, and its collapsed form | Categorical | string | |
| PART_NUMBER | Part number from HoBBIT record | ID | integer | |
| part_designator | Part designator label | ID | string | |
| part_type | Part type | Categorical | string | |
| part_description | Free-text description of the tissue part | Natural Language Description | string | |
| BLOCK_NUMBER | Block number from HoBBIT record | ID | string | varchar(10); *not* an integer |
| BLOCK_LABEL | Block label from HoBBIT record | ID | string | |
| IS_HNE | Is the stain group "H&E (Initial)" or "H&E (Other)"? | Categorical | integer | 0, 1 |
| IS_IHC | Is the stain group "IHC"? | Categorical | integer | 0, 1 |
| stain_inst | Stain instance identifier | ID | integer | |
| stain_name | Stain name | Categorical | string | |
| stain_group | The type of stain used | Categorical | string | 'H&E (Initial)', 'H&E (Other)', 'IHC', 'Surgical Submitted', 'Other', 'Frozen', 'SS' |
| scanner_id | Scanner identifier | ID | string | |
| brand / model | Scanner brand and model | Categorical | string | |
| magnification | Slide magnification | Categorical | string | '20x', '40x', '25x', '50x', 'NA' |
| status_id | Slide status | Categorical | string | |
| file_size_bytes | Slide file size in bytes | Continuous | long | bytes |
| ACCESSION_NUMBER_PATH_DX | Accession number from the pathology diagnosis record | ID | string | |
| PART_NUMBER_PATH_DX | Part number from the pathology diagnosis record | ID | integer | |
| PATH_DX_SPEC_TITLE | Brief tissue diagnosis | Natural Language Description | string | |
| PATH_DX_SPEC_DESC | Detailed tissue diagnosis | Natural Language Description | string | |
| IMAGE_ID_INVENTORY | Image ID as recorded in the slide inventory | ID | long | |
| project_name | Project the slide belongs to | Categorical | string | |
| SLIDE_URL | The `file://` URL for the downloaded slide | ID | string | `file://<pathname>`; NULL if not downloaded |

## Notes <a name="notes"></a>

1. <b>Multi-sample fan-out.</b> A slide that matches multiple IMPACT samples appears on multiple rows (one per `SAMPLE_ID_IMPACT`): 696,758 rows cover 683,953 distinct `image_id`s. Each `image_id` still corresponds to a single physical slide; repeated values come only from this fan-out.

2. <b>Duplicate (`image_id`, `SAMPLE_ID_IMPACT`) pairs.</b> 696,758 rows collapse to 696,498 distinct pairs, so 260 rows repeat a pair that is already present. De-duplicate before counting slides or samples.

3. <b>`SLIDE_URL` is mostly NULL.</b> Only 22,089 of 696,758 rows (3%) carry a `file://` URL; the remainder have not been downloaded to a CDSI storage system. For slides staged on S3, join to [msk_slide_inventory_v1](msk_slide_inventory_v1.md) on `image_id` instead.

4. <b>`stain_group` is NULL on 12,293 rows</b> and carries values beyond H&E/IHC (`Surgical Submitted`, `Frozen`, `SS`, `Other`). `IS_HNE` and `IS_IHC` are derived from it, so both are 0 for those rows.

5. <b>`IMAGE_ID_INVENTORY` is a `bigint` while `image_id` is a `varchar(100)`.</b> Cast explicitly when comparing the two.

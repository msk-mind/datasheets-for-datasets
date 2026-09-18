# impact_matched_slides_v1

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_matched_slides_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_matched_slides_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 657,598 <br/>
Unique image_ids (slides): 645,067 <br/>
Unique PATIENT_ID_IMPACT: 70,352 <br/>
Unique SAMPLE_ID_IMPACT: 81,707 <br/>
Total columns: 37 <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

A table listing all whole-slide images (WSI) for which there are matching MSK-IMPACT genomic results. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent.

Slides and IMPACT samples are matched at the **part** level using the accession number and part number of the tissue used to make the slides and samples. See [impact_block_matched_slides_v1](impact_block_matched_slides_v1.md) for the finer, block-level match.

### Vocabulary <a name="vocab"></a>

Primary key: none declared. The natural key is (`image_id`, `SAMPLE_ID_IMPACT`); see note 1 for the fan-out and note 2 for the duplicate rows that keep it from being a strict key.

The first three columns are the IMPACT identifiers, followed by slide, part, and diagnosis columns. Key columns include:

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | string (varchar(100)) | |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier associated with the genomic results | ID | string | `P-XXXXXXX-TNN-IMn` |
| subspecialty | Pathology subspecialty | Categorical | string | e.g. `Breast`, `GU`, ... |
| PART_NUMBER | Part number from HoBBIT record | ID | integer | |
| part_description | Free-text description of the tissue part | Natural Language Description | string | |
| BLOCK_NUMBER | Block number from HoBBIT record | ID | string | varchar(10); *not* an integer |
| BLOCK_LABEL | Block label from HoBBIT record | ID | string | |
| IS_HNE | Is the stain group "H&E (Initial)" or "H&E (Other)"? | Categorical | integer | 0, 1 |
| IS_IHC | Is the stain group "IHC"? | Categorical | integer | 0, 1 |
| stain_name | Stain name | Categorical | string | |
| stain_group | The type of stain used | Categorical | string | 'H&E (Initial)', 'H&E (Other)', 'IHC', 'Surgical Submitted', 'Other', 'Frozen', 'SS' |
| magnification | Slide magnification | Categorical | string | '20x', '40x', '25x', '50x', 'NA' |
| file_size_bytes | Slide file size in bytes | Continuous | long | bytes |
| ACCESSION_NUMBER_PATH_DX | Accession number from the pathology diagnosis record | ID | string | |
| PART_NUMBER_PATH_DX | Part number from the pathology diagnosis record | ID | integer | |
| PATH_DX_SPEC_TITLE | Brief tissue diagnosis | Natural Language Description | string | |
| PATH_DX_SPEC_DESC | Detailed tissue diagnosis | Natural Language Description | string | |
| SLIDE_URL | The `file://` URL for the downloaded slide | ID | string | `file://<pathname>`; NULL if not downloaded |
| SAMPLE_ID_PATH | The IMPACT sample ID associated with the slide (from the pathology side) | ID | string | `P-XXXXXXX-TNN-IMn` |
| DMP_ID | IMPACT DMP patient identifier from the ID mapping table | ID | string | `P-XXXXXXX` |

*This is an abbreviated list of the 37 columns; see the Databricks Catalog Overview tab for the complete schema. The dataset is de-identified and does not contain MRN, patient names, or other direct identifiers.*

## Notes <a name="notes"></a>

1. <b>Multi-sample fan-out — `image_id` is not unique.</b> Slides and IMPACT samples are matched by accession number and part number. In cases where multiple IMPACT samples are taken from the same part, *each slide from that part is matched to all of the IMPACT samples taken from that part*, so a single `image_id` can appear on multiple rows (one per `SAMPLE_ID_IMPACT`): 657,598 rows cover only 645,067 distinct `image_id`s. `image_id` <--> `SAMPLE_ID_IMPACT` is therefore a many-many relationship, not a one-one mapping. Slides associated with more than one IMPACT sample can be listed with:
```sql
SELECT image_id, count(SAMPLE_ID_IMPACT) AS samples
FROM cdsi_res_deid.pdm_product_cdsi.impact_matched_slides_v1
WHERE image_id IS NOT NULL
GROUP BY image_id
HAVING samples > 1
ORDER BY samples DESC
```

2. <b>Duplicate (`image_id`, `SAMPLE_ID_IMPACT`) pairs.</b> 657,598 rows collapse to 656,313 distinct (`image_id`, `SAMPLE_ID_IMPACT`) pairs, so about 1,285 rows (0.2%) repeat a pair that is already present. De-duplicate before counting slides or samples:
```sql
SELECT image_id, SAMPLE_ID_IMPACT, count(*) AS ct
FROM cdsi_res_deid.pdm_product_cdsi.impact_matched_slides_v1
GROUP BY image_id, SAMPLE_ID_IMPACT
HAVING ct > 1
ORDER BY ct DESC
```

3. <b>IMPACT sample filtering.</b> IMPACT samples are filtered to solid tumors only, using `SAMPLE_CLASS = 'Tumor'` and `GENE_PANEL IN ('IMPACT341','IMPACT410','IMPACT468','IMPACT505')`.

4. <b>De-identification.</b> The dataset is de-identified and does not contain MRN, patient names, or dates that could re-identify a patient. Only IMPACT-scoped slides for patients with Part A research consent are included.

5. <b>`SLIDE_URL` is mostly NULL.</b> Only 19,753 of 657,598 rows (3%) carry a `file://` URL; the rest have not been downloaded to a CDSI storage system. For slides staged on S3, join to [msk_slide_inventory_v1](msk_slide_inventory_v1.md) on `image_id` instead.

6. Not all slides in HoBBIT can be used for research; roughly 1% of requested slides contain PHI on the slide image itself and cannot be de-identified for research use. This cannot be determined via HoBBIT, and is only determined during data transfer.

7. <b>`stain_group` is NULL on 11,798 rows</b> and carries values beyond H&E/IHC (`Surgical Submitted`, `Frozen`, `SS`, `Other`). `IS_HNE` and `IS_IHC` are derived from it, so both are 0 for those rows.

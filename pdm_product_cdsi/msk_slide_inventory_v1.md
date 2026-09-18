# msk_slide_inventory_v1

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.msk_slide_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/msk_slide_inventory_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 652,495 <br/>
Unique image_ids (slides): 640,689 <br/>
Unique PATIENT_ID_IMPACT: 74,651 <br/>
Unique SAMPLE_ID_IMPACT: 86,439 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

An inventory of MSK whole-slide image (WSI) files, including their storage location, size, and last modification time, restricted to slides that match an MSK-IMPACT sample. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent.

Use this table to resolve an `image_id` to an S3 object; the slide-level metadata and diagnoses live in [slides_with_diagnosis_v1](slides_with_diagnosis_v1.md) and [impact_matched_slides_v1](impact_matched_slides_v1.md).

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | string (varchar(100)) | |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| path | Full path to the image file, including protocol prefix for cloud storage | ID | string | `s3://mskmind-bkt/reef-slides/...` |
| size | Size of the image file in bytes | Continuous | long | bytes |
| last_modified | Timestamp when the file was last modified | Continuous | timestamp | YYYY-MM-DD HH:MM:SS |

## Notes <a name="notes"></a>

1. <b>Multi-sample fan-out.</b> A slide that matches multiple IMPACT samples appears on multiple rows (one per `SAMPLE_ID_IMPACT`): 652,495 rows over 640,689 distinct `image_id`s. Counting rows overcounts slides by about 1.8%.

2. <b>No repeated (`image_id`, `SAMPLE_ID_IMPACT`) pairs.</b> Unlike [impact_matched_slides_v1](impact_matched_slides_v1.md) and [slides_with_diagnosis_v1](slides_with_diagnosis_v1.md), each slide/sample pair appears exactly once.

3. <b>MSK scope.</b> Only slides under `s3://mskmind-bkt/reef-slides/` are included (the MSK REEF slide bucket).

4. <b>`size` is always positive.</b> Zero or null `size` would indicate an incomplete upload or a metadata-collection error; there are currently 0 such rows.

5. <b>Fewer slides than the metadata tables.</b> 640,689 slides are on storage against 683,953 in [slides_with_diagnosis_v1](slides_with_diagnosis_v1.md). A slide can be catalogued in HoBBIT without having been transferred to the REEF bucket.

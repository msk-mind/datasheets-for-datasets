# tcga_slide_inventory_v1

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.tcga_slide_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/tcga_slide_inventory_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 11,741 <br/>
Unique image_ids (slides): 11,741 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

An inventory of TCGA whole-slide image (WSI) files, including their storage location, size, and last modification time. TCGA slides are public and exist outside the MSK-IMPACT cohort, so the full TCGA inventory is retained.

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | TCGA slide identifier | ID | string | |
| path | Full path to the image file, including protocol prefix for cloud storage | ID | string | `s3://pathology/TCGA/...` |
| size | Size of the image file in bytes | Continuous | long | bytes |
| last_modified | Timestamp when the file was last modified | Continuous | timestamp | YYYY-MM-DD HH:MM:SS |

## Notes <a name="notes"></a>

1. <b>Not IMPACT-scoped.</b> Unlike the MSK product tables, the TCGA inventory has no IMPACT identifiers; TCGA slides exist outside the MSK-IMPACT cohort, so the whole table is kept and the Part A consent restriction does not apply. There is consequently no multi-sample fan-out, so row count equals slide count.

2. <b>TCGA scope.</b> Only slides under `s3://pathology/TCGA/` are included.

3. <b>`last_modified` reflects the transfer, not the scan.</b> Every file was written during the 2025-09-05/06 bulk load from the GDC, so the column dates the copy into MSK storage rather than the original acquisition.

# tcga_reef_v1/v2_embeddings_inventory_v1

<b>Path:</b> <br/>
[`cdsi_res_deid.pdm_product_cdsi.tcga_reef_v1_embeddings_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/tcga_reef_v1_embeddings_inventory_v1) <br/>
[`cdsi_res_deid.pdm_product_cdsi.tcga_reef_v2_embeddings_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/tcga_reef_v2_embeddings_inventory_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

<b>v1</b>: Total rows: 10,925 | Unique image_ids: 10,925 <br/>
<b>v2</b>: Total rows: 23,601 | Unique image_ids: 11,802 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Inventories of pre-computed whole-slide-image embeddings for TCGA slides, pointing to the stored feature tensors and shards. Slides are sourced from the public [GDC Data Portal](https://portal.gdc.cancer.gov/) (TCGA program). Two versions are published:

- <b>v1 (REEF TCGA v1)</b>: per-slide feature tensors and tile coordinate files produced by [Mussel](https://github.com/pathology-data-mining/Mussel) (CTransPath + H-Optimus-0), bucket `reef-tcga-v1-0`. One row per slide.
- <b>v2 (REEF TCGA v2)</b>: the newer pipeline storing embeddings as [WebDataset](https://github.com/webdataset/webdataset) (WDS) tar shards on S3 (`reef-tcga-v2-0`), with the model and MPP provenance recorded per slide. One row per slide/**model** pair.

The slides themselves are inventoried in [tcga_slide_inventory_v1](tcga_slide_inventory_v1.md).

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

<b>v1: `tcga_reef_v1_embeddings_inventory_v1`</b>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | TCGA slide identifier | ID | string | |
| prefilter_ctranspath_features_tensor_path | CTransPath embedding tensor path (unfiltered) | ID | string | `s3://reef-tcga-v1-0/...` |
| tiles_h5_path | Tissue tile coordinates in HDF5 (unfiltered) | ID | string | `s3://reef-tcga-v1-0/...` |
| filtered_tiles_h5_path | Tissue tile coordinates in HDF5 (marker filtered) | ID | string | `s3://reef-tcga-v1-0/...` |
| ctranspath_features_tensor_path | CTransPath embedding tensor path (marker filtered) | ID | string | `s3://reef-tcga-v1-0/...` |
| optimus_features_tensor_path | H-Optimus-0 embedding tensor path (marker filtered) | ID | string | `s3://reef-tcga-v1-0/...` |
| _rescued_data | Autoloader column holding fields that failed to parse on ingest | Natural Language Description | string | JSON; normally NULL |

<b>v2: `tcga_reef_v2_embeddings_inventory_v1`</b>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | TCGA slide identifier | ID | string | |
| model | Feature-extraction model | Categorical | string | 'hoptimus1', 'titan_slide' |
| oncotree_code | OncoTree diagnosis code | Categorical | string | 32 distinct values |
| wds_path | S3 path to the WDS tar shard containing this slide's embeddings | ID | string | `s3://reef-tcga-v2-0/wds/{model}/...` |
| native_mpp | Scanner resolution read from the slide header | Continuous | double | microns per pixel; observed 0.11625 .. 0.504 |
| mpp_is_fallback | `true` when the 0.5 µm/px default was used because the header lacked a readable MPP tag | Categorical | boolean | True, False |
| _rescued_data | Autoloader column holding fields that failed to parse on ingest | Natural Language Description | string | JSON; normally NULL |

## Notes <a name="notes"></a>

1. <b>Not IMPACT-scoped.</b> TCGA slides exist outside the MSK-IMPACT cohort, so these tables have no IMPACT identifiers and the whole tables are kept. There is no multi-sample fan-out, unlike the MSK equivalents in [msk_reef_embeddings_inventory](msk_reef_embeddings_inventory.md).

2. <b>Multi-model fan-out in v2.</b> Each slide is embedded by up to two models, so v2's 23,601 rows cover 11,802 distinct slides. Filter on `model` when counting slides. hoptimus1 covers all 11,802; titan_slide covers 11,799.

3. <b>v1 covers fewer slides than v2.</b> 10,925 slides in v1 against 11,802 in v2. v2 extended coverage rather than replacing it in place.

4. <b>v2 storage.</b> WDS shards live under `s3://reef-tcga-v2-0/wds/{model}/`; the sample key within each shard is the `image_id`.

5. <b>MPP fallback applies to 51 rows.</b> Those slides lacked a readable MPP tag and were embedded assuming the 0.5 µm/px default; `native_mpp` reaches as low as 0.11625 µm/px elsewhere, so the assumption may be wrong for them. Filter on `mpp_is_fallback = false` for resolution-sensitive work.

6. TCGA slides are publicly downloadable from the [GDC Data Portal](https://portal.gdc.cancer.gov/) via `gdc-client`.

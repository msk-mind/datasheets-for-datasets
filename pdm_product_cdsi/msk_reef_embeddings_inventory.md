# msk_reef_v1/v2_embeddings_inventory_v1

<b>Path:</b> <br/>
[`cdsi_res_deid.pdm_product_cdsi.msk_reef_v1_embeddings_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/msk_reef_v1_embeddings_inventory_v1) <br/>
[`cdsi_res_deid.pdm_product_cdsi.msk_reef_v2_embeddings_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/msk_reef_v2_embeddings_inventory_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

<b>v1</b> — Total rows: 512,747 | Unique image_ids: 504,120 | PATIENT_ID_IMPACT: 71,412 | SAMPLE_ID_IMPACT: 82,078 <br/>
<b>v2</b> — Total rows: 1,629,873 | Unique image_ids: 535,083 | PATIENT_ID_IMPACT: 70,009 | SAMPLE_ID_IMPACT: 80,631 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Inventories of pre-computed whole-slide-image embeddings for MSK slides, pointing to the stored feature tensors and shards. Two versions are published:

- <b>v1 (REEF v1)</b>: per-slide feature tensors and tile coordinate files produced by [Mussel](https://github.com/pathology-data-mining/Mussel) (slides to tiles to CTransPath prefilter features to marker-filtered tiles to H-Optimus-0 + CTransPath features), stored as PyTorch tensors on S3 (bucket `reef-v1-0`). One row per slide/sample pair.
- <b>v2 (REEF v2)</b>: the newer pipeline storing embeddings as [WebDataset](https://github.com/webdataset/webdataset) (WDS) tar shards on S3, with the model and MPP provenance recorded per slide. One row per slide/sample/**model** combination.

Both are IMPACT-scoped: only slides matching an MSK-IMPACT sample are retained, and the IMPACT patient/sample identifiers are the leading columns. They are also limited to patients with Part A research consent. The slides themselves are inventoried in [msk_slide_inventory_v1](msk_slide_inventory_v1.md).

### Vocabulary <a name="vocab"></a>

Primary key: (`image_id`, `SAMPLE_ID_IMPACT`) for v1 and (`image_id`, `model`, `SAMPLE_ID_IMPACT`) for v2 — both verified unique across every row. `image_id` **alone is not a key in either table** (see note 1).

<b>v1: `msk_reef_v1_embeddings_inventory_v1`</b>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | integer | *int here, string in the slide tables — see note 4* |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| prefilter_ctranspath_features_tensor_path | CTransPath embedding tensor path (unfiltered) | ID | string | `s3://reef-v1-0/...` |
| tiles_h5_path | Tissue tile coordinates in HDF5 (unfiltered) | ID | string | `s3://reef-v1-0/...` |
| filtered_tiles_h5_path | Tissue tile coordinates in HDF5 (marker filtered) | ID | string | `s3://reef-v1-0/...` |
| ctranspath_features_tensor_path | CTransPath embedding tensor path (marker filtered) | ID | string | `s3://reef-v1-0/...` |
| optimus_features_tensor_path | H-Optimus-0 embedding tensor path (marker filtered) | ID | string | `s3://reef-v1-0/...` |
| _rescued_data | Autoloader column holding fields that failed to parse on ingest | Natural Language Description | string | JSON; normally NULL |

<b>v2: `msk_reef_v2_embeddings_inventory_v1`</b>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | integer | *int here, string in the slide tables — see note 4* |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| model | Feature-extraction model | Categorical | string | 'hoptimus1', 'optimus', 'titan_slide' |
| oncotree_code | OncoTree diagnosis code | Categorical | string | 593 distinct values |
| wds_path | S3 path to the WDS tar shard containing this slide's embeddings | ID | string | `s3://reef-v2-0/...` |
| native_mpp | Scanner resolution read from the slide header | Continuous | double | microns per pixel; observed 0.2507 .. 0.5051 |
| mpp_is_fallback | `true` when the 0.5 µm/px default was used because the header lacked a readable MPP tag | Categorical | boolean | True, False |
| _rescued_data | Autoloader column holding fields that failed to parse on ingest | Natural Language Description | string | JSON; normally NULL |

## Notes <a name="notes"></a>

1. <b>`image_id` is not the primary key.</b> Two separate fan-outs apply:
   - <b>Multi-sample</b> (both versions): a slide matching multiple IMPACT samples appears once per `SAMPLE_ID_IMPACT`.
   - <b>Multi-model</b> (v2 only): each slide is embedded by up to three models, so v2's 1,629,873 rows cover only 535,083 distinct slides — roughly 3x. Always filter on `model` when counting slides:
   ```sql
   SELECT count(DISTINCT image_id)
   FROM cdsi_res_deid.pdm_product_cdsi.msk_reef_v2_embeddings_inventory_v1
   WHERE model = 'hoptimus1'
   ```

2. <b>Model coverage is near-complete but not identical.</b> hoptimus1 covers 535,053 slides, optimus 534,915, and titan_slide 531,205; expect a few thousand slides to be missing from any single model.

3. <b>v1 and v2 cover different slide sets.</b> v1 has 504,120 slides, v2 has 535,083, and neither is a superset of the other by construction — check membership rather than assuming v2 supersedes v1.

4. <b>`image_id` type mismatch.</b> It is an `int` in both embedding inventories but a `varchar(100)`/`string` in [msk_slide_inventory_v1](msk_slide_inventory_v1.md), [slides_with_diagnosis_v1](slides_with_diagnosis_v1.md), and [impact_matched_slides_v1](impact_matched_slides_v1.md). Cast explicitly when joining, and note that an integer encoding cannot preserve any leading zeros.

5. <b>v1 storage.</b> For S3 paths use the `http://pmindecs.mskcc.org:9020` endpoint (bucket `reef-v1-0`).

6. <b>v2 storage.</b> WDS shards live under `s3://reef-v2-0/`; the sample key within each shard is the `image_id`.

7. <b>`native_mpp` is always real in v2.</b> `mpp_is_fallback` is `true` on 0 rows, so every MSK slide had a readable MPP tag — unlike the TCGA inventory (see [tcga_reef_embeddings_inventory](tcga_reef_embeddings_inventory.md)).

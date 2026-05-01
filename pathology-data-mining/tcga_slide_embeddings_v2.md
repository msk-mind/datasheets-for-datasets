# TCGA Slide Embeddings v2

<b>Path:</b> [`cdsi_prod.pathology_data_mining.tcga_slide_embeddings_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/tcga_slide_embeddings_v2) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-05-01 <br/>

<b>Lineage:</b>

[GDC Data Portal](https://portal.gdc.cancer.gov/) (TCGA slide inventory + clinical metadata) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ [`mussel-nf`](https://github.com/msk-mind/mussel-nf) feature extraction pipeline (hoptimus1, titan_slide) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ WDS shards on S3 (`s3://reef-tcga-v2-0/wds/`) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_prod.pathology_data_mining.tcga_slide_embeddings_v2` <br/>

<b>Summary Statistics:</b>

Total rows (one per slide × model): **23,696** <br/>
Unique DX slides: **11,848** <br/>
Unique patients (case_submitter_id): **9,743** <br/>
TCGA projects: **32** <br/>

| Model | Done | Pending |
|---|---|---|
| hoptimus1 | 11,838 | 10 |
| titan_slide | 11,802 | 46 |

<details>
<summary>Slides per project (hoptimus1 done)</summary>

| Project | Slides |
|---|---|
| TCGA-BRCA | 1,133 |
| TCGA-GBM | 858 |
| TCGA-LGG | 832 |
| TCGA-SARC | 579 |
| TCGA-UCEC | 566 |
| TCGA-LUAD | 540 |
| TCGA-KIRC | 519 |
| TCGA-THCA | 519 |
| TCGA-LUSC | 512 |
| TCGA-SKCM | 474 |
| TCGA-HNSC | 472 |
| TCGA-COAD | 459 |
| TCGA-BLCA | 457 |
| TCGA-PRAD | 449 |
| TCGA-STAD | 442 |
| TCGA-TGCT | 384 |
| TCGA-LIHC | 379 |
| TCGA-KIRP | 295 |
| TCGA-CESC | 279 |
| TCGA-ACC | 227 |
| TCGA-PAAD | 209 |
| TCGA-PCPG | 196 |
| TCGA-READ | 166 |
| TCGA-THYM | 166 |
| TCGA-ESCA | 158 |
| TCGA-KICH | 121 |
| TCGA-OV | 107 |
| TCGA-UCS | 91 |
| TCGA-MESO | 87 |
| TCGA-UVM | 80 |
| TCGA-DLBC | 44 |
| TCGA-CHOL | 39 |

</details>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Pan-cancer TCGA whole-slide image embeddings generated using [Mussel](https://github.com/pathology-data-mining/Mussel) via the [`mussel-nf`](https://github.com/msk-mind/mussel-nf) Nextflow pipeline. Slides are sourced from the [GDC Data Portal](https://portal.gdc.cancer.gov/) (TCGA program). Only diagnostic slides (slide_type starting with `DX`) are included.

**Processing pipeline:**

slides → tessellation → patch features (hoptimus1 / titan_slide) → WDS shards on S3

For titan_slide, patch-level hoptimus1 features are first aggregated by the TITAN slide encoder to produce a single slide-level embedding.

**Mussel parameters:**

| Parameter | Value |
|---|---|
| seg_config_group | tcga |
| patch_size | 224 px |
| mpp | 0.5 |
| filter_tiles | false |
| use_one_step_workflow | true |

**Feature storage:**

Embeddings are stored in [WebDataset](https://github.com/webdataset/webdataset) (WDS) tar shards on S3 at `s3://reef-tcga-v2-0/wds/{model}/`. Each shard contains multiple slides. The `pt_path` / `h5_path` columns in this table point to the S3 shard containing that slide's embeddings (not a per-slide file).

### Vocabulary <a name="vocab"></a>

**Primary key: (`file_id`, `model`)**

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| slide_id | TCGA slide barcode (without UUID suffix) | ID | string | e.g. `TCGA-27-1835-01Z-00-DX2` |
| file_id | GDC file UUID for the slide SVS file | ID (PK with model) | string | UUID, e.g. `0006ae80-5774-4199-bbd0-3c120ed547e6` |
| file_name | Full GDC filename including UUID suffix | ID | string | e.g. `TCGA-27-1835-01Z-00-DX2.213a0703-....svs` |
| project_id | TCGA project identifier | Categorical | string | e.g. `TCGA-BRCA`, `TCGA-LUAD` |
| slide_type | GDC slide portion type | Categorical | string | `DX1` (primary diagnostic), `DX2`–`DX17` (additional cuts/sections) |
| file_size | File size of the SVS file in bytes | Continuous | integer | bytes |
| model | Feature extraction model | Categorical | string | `hoptimus1` (patch encoder), `titan_slide` (slide-level encoder) |
| status | Feature extraction status | Categorical | string | `done` = embeddings available in WDS; `pending` = not yet extracted |
| pt_path | S3 path to the WDS tar shard containing this slide's embeddings | ID | string | S3 URI, e.g. `s3://reef-tcga-v2-0/wds/hoptimus1/TCGA-BRCA/000001.tar` |
| h5_path | S3 path to the WDS tar shard containing this slide's patch coordinates | ID | string | Same shard as pt_path for WDS-stored slides |
| last_updated | Timestamp when this row was last updated | Continuous | string | ISO 8601, e.g. `2026-05-01T18:36:00` |
| md5sum | MD5 checksum of the SVS file | ID | string | hex string |
| updated_datetime | GDC last-modified datetime for this file | Continuous | string | ISO 8601 |
| case_submitter_id | TCGA patient barcode | ID | string | e.g. `TCGA-27-1835` |
| primary_site | Anatomical site of the primary tumor | Categorical | string | e.g. `Breast`, `Lung` |
| disease_type | GDC disease type | Categorical | string | e.g. `Ductal and Lobular Neoplasms` |
| gender | Patient sex | Categorical | string | `male`, `female`, `not reported` |
| age_at_index | Patient age at diagnosis | Continuous | string | years (may be blank) |
| vital_status | Patient vital status at last follow-up | Categorical | string | `Alive`, `Dead`, `Not Reported` |
| race | Patient self-reported race | Categorical | string | e.g. `white`, `black or african american`, `not reported` |
| ethnicity | Patient self-reported ethnicity | Categorical | string | `not hispanic or latino`, `hispanic or latino`, `not reported` |
| primary_diagnosis | ICD-O-3 primary diagnosis text | Categorical | string | e.g. `Infiltrating duct carcinoma, NOS` |
| morphology | ICD-O-3 morphology code | Categorical | string | e.g. `8500/3` |
| ajcc_pathologic_stage | AJCC pathologic tumor stage | Categorical | string | e.g. `Stage I`, `Stage IIA`, `not reported` |
| tumor_grade | Histologic tumor grade | Categorical | string | e.g. `G1`, `G2`, `not reported` |
| sample_type | GDC sample type | Categorical | string | e.g. `Primary Tumor`, `Metastatic` |
| tissue_type | GDC tissue type | Categorical | string | e.g. `Tumor`, `Normal` |
| tumor_descriptor | Tumor descriptor | Categorical | string | e.g. `Primary`, `Metastatic`, `not reported` |
| section_location | Portion section location | Categorical | string | e.g. `TOP`, `BOTTOM`, `not reported` |
| percent_tumor_cells | Estimated percent tumor cells in the sample | Continuous | string | 0–100 (may be blank) |
| percent_stromal_cells | Estimated percent stromal cells | Continuous | string | 0–100 (may be blank) |
| percent_necrosis | Estimated percent necrosis | Continuous | string | 0–100 (may be blank) |
| percent_normal_cells | Estimated percent normal cells | Continuous | string | 0–100 (may be blank) |
| first_seen_date | Date this file first appeared in the GDC inventory | Continuous | string | ISO 8601 date |
| removed_date | Date this file was removed from the GDC inventory (if applicable) | Continuous | string | ISO 8601 date, or blank if still active |

## Notes <a name="notes"></a>

1. **Primary key** is (`file_id`, `model`). Each slide appears once per model (currently `hoptimus1` and `titan_slide`), so every `file_id` has exactly 2 rows.

2. **`pt_path` / `h5_path` are WDS shard paths, not per-slide file paths.** Multiple slides are packed into a single `.tar` shard. To read a specific slide's tensor, use the WDS API or the `wds_manifest.csv` in the dispatcher output directory to identify which shard contains which slide.

3. **S3 endpoint:** use `http://pmindecs.mskcc.org:9020` for on-premises S3 access. See usage examples for [AWS CLI](https://gist.github.com/raylim/2039b01cbb5f6682e1f115106aee65b6), [python](https://gist.github.com/raylim/ceb4ea7d8db8ff0c27b8d2322a1f9bd9).

4. **Only diagnostic slides are included** (`slide_type` starts with `DX`). Tissue section (TS), blood/bone marrow (BS), and other slide types from the GDC inventory are excluded.

5. **`titan_slide` embeddings** are slide-level aggregations produced by the [TITAN](https://github.com/mahmoodlab/TITAN) encoder, which takes the set of hoptimus1 patch embeddings as input. A slide must have hoptimus1 embeddings before titan_slide can be computed.

6. **`status = 'pending'`** (56 slides total as of 2026-05-01) indicates slides that failed feature extraction, typically due to GPU OOM on very large slides. These will be retried.

7. **Clinical metadata** (columns from `primary_site` onward) is sourced from the GDC API at the time of inventory download and reflects GDC annotations at that date. Fields may contain `not reported` or be blank where GDC has no value.

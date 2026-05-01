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

Embeddings are stored in [WebDataset](https://github.com/webdataset/webdataset) (WDS) tar shards on S3 at `s3://reef-tcga-v2-0/wds/{model}/`. Each shard contains multiple slides. The `wds_path` column points to the S3 shard containing that slide's embeddings (not a per-slide file). The sample key within each shard is the `slide_id`.

### Vocabulary <a name="vocab"></a>

**Primary key: (`file_id`, `model`)**

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format / Values** |
|---|---|---|---|---|
| slide_id | TCGA slide barcode (without UUID suffix) | ID | string | e.g. `TCGA-27-1835-01Z-00-DX2` |
| file_id | GDC file UUID for the slide SVS file | ID (PK with model) | string | UUID, e.g. `0006ae80-5774-4199-bbd0-3c120ed547e6` |
| file_name | Full GDC filename including UUID suffix | ID | string | e.g. `TCGA-27-1835-01Z-00-DX2.213a0703-....svs` |
| project_id | TCGA project identifier (32 distinct values) | Categorical | string | `TCGA-BRCA` (1,133), `TCGA-GBM` (858), `TCGA-LGG` (832), `TCGA-SARC` (579), `TCGA-UCEC` (566), … (see summary table above) |
| slide_type | GDC slide portion type | Categorical | string | `DX1` (9,774 = 82.6%), `DX2` (884 = 7.5%), `DX3` (425), `DX4` (298), `DX5` (225), `DX6`–`DX17` (<80 each) |
| file_size | SVS file size in bytes; range 0–5.12 GB, mean 1.11 GB | Continuous | integer | bytes |
| model | Feature extraction model | Categorical | string | `hoptimus1` — patch-level embeddings from [H-Optimus-1](https://huggingface.co/bioptimus/H-optimus-1); `titan_slide` — slide-level embedding from [TITAN](https://github.com/mahmoodlab/TITAN) |
| status | Feature extraction status | Categorical | string | `done` (23,640) = embeddings in WDS; `pending` (56) = not yet extracted |
| wds_path | S3 path to the WDS tar shard containing this slide's embeddings | ID | string | S3 URI, e.g. `s3://reef-tcga-v2-0/wds/hoptimus1/TCGA-BRCA/000001.tar`; blank when `status = pending` |
| wds_index_path | S3 path to the model-level WDS index JSON (`slide_id → shard_file` mapping) | ID | string | e.g. `s3://reef-tcga-v2-0/wds/hoptimus1/wds_index.json`; blank when `status = pending` |
| last_updated | Timestamp when this row was last written by the dispatcher | Continuous | string | ISO 8601, e.g. `2026-05-01T18:36:00` |
| md5sum | MD5 checksum of the SVS file as provided by GDC | ID | string | 32-character hex string |
| updated_datetime | GDC last-modified datetime for this file record | Continuous | string | ISO 8601 |
| case_submitter_id | TCGA patient barcode (9,743 unique patients across 11,838 done slides) | ID | string | e.g. `TCGA-27-1835`; format `TCGA-{site}-{patient}` |
| primary_site | Anatomical site of the primary tumor | Categorical | string | Brain (1,690), Breast (1,133), Lung (1,052), Kidney (934), Uterus (657), Colorectal (625), Soft Tissue (579), Thyroid (519), Skin (474), Head and Neck (472), … |
| disease_type | GDC disease classification | Categorical | string | Breast Invasive Carcinoma (1,133), Glioblastoma Multiforme (858), Brain Lower Grade Glioma (832), Sarcoma (579), Uterine Corpus Endometrial Carcinoma (566), Lung Adenocarcinoma (540), … |
| gender | Patient sex as reported to GDC | Categorical | string | `male` (6,032 = 51%), `female` (5,803 = 49%), `not reported` (3) |
| age_at_index | Patient age at diagnosis in years; range 10–89, mean 58.2; 97 slides missing | Continuous | string | integer years; blank if not available |
| vital_status | Patient vital status at last follow-up | Categorical | string | `Alive` (7,991 = 67%), `Dead` (3,798 = 32%), `Not Reported` (47), `Unknown` (2) |
| race | Patient self-reported race | Categorical | string | `white` (8,966 = 75.7%), `black or african american` (1,060 = 9.0%), `not reported` (910 = 7.7%), `asian` (686 = 5.8%), `Unknown` (182), `american indian or alaska native` (24), `native hawaiian or other pacific islander` (10) |
| ethnicity | Patient self-reported ethnicity | Categorical | string | `not hispanic or latino` (8,971 = 75.8%), `not reported` (2,152 = 18.2%), `hispanic or latino` (420 = 3.5%), `Unknown` (295) |
| primary_diagnosis | ICD-O-3 primary diagnosis free-text label | Categorical | string | e.g. `Infiltrating duct carcinoma, NOS`, `Glioblastoma` |
| morphology | ICD-O-3 morphology code | Categorical | string | e.g. `8500/3` (invasive breast), `9440/3` (GBM) |
| ajcc_pathologic_stage | AJCC pathologic tumor stage; missing for 4,680 slides (40%) that lack staging (e.g. brain tumors, sarcomas) | Categorical | string | `Stage I` (1,364), `Stage IIA` (835), `Stage IIB` (715), `Stage III` (670), `Stage II` (657), `Stage IIIA` (547), `Stage IV` (459), `Stage IB` (422), `Stage IA` (405), `Stage IVA` (316), `Stage IIIB` (303), `Stage IIIC` (261), …; blank if not available |
| tumor_grade | Histologic tumor grade; missing for 7,399 slides (63%) | Categorical | string | `G3` (1,754), `G2` (1,722), `High Grade` (442), `G1` (317), `G4` (100), `GX` (75), `Low Grade` (21); blank if not available |
| sample_type | GDC biospecimen sample type | Categorical | string | `Primary Tumor` (11,621 = 98.2%), `Metastatic` (172 = 1.5%), `Solid Tissue Normal` (18), `Additional - New Primary` (13), `Recurrent Tumor` (13), `Additional Metastatic` (1) |
| tissue_type | GDC tissue type | Categorical | string | `Tumor` (11,820 = 99.8%), `Normal` (18 = 0.2%) |
| tumor_descriptor | Tumor descriptor (how sample was classified at collection) | Categorical | string | `Primary`, `Metastatic`, `Recurrent`, `not reported`; frequently blank |
| section_location | Portion section location on the block | Categorical | string | `TOP`, `BOTTOM`, `not reported`; frequently blank |
| percent_tumor_cells | Estimated % tumor cells in section | Continuous | string | 0–100; **100% missing** in current data — GDC does not populate this for most TCGA cases |
| percent_stromal_cells | Estimated % stromal cells in section | Continuous | string | 0–100; **100% missing** in current data |
| percent_necrosis | Estimated % necrosis in section | Continuous | string | 0–100; **100% missing** in current data |
| percent_normal_cells | Estimated % normal cells in section | Continuous | string | 0–100; **100% missing** in current data |
| first_seen_date | Date this file first appeared in the GDC inventory (used by the dispatcher to detect new slides) | Continuous | string | ISO 8601 date, e.g. `2016-05-01` |
| removed_date | Date this file was removed from the GDC active inventory, if applicable | Continuous | string | ISO 8601 date; blank for all currently active files |

## Notes <a name="notes"></a>

1. **Primary key** is (`file_id`, `model`). Each slide appears once per model (currently `hoptimus1` and `titan_slide`), so every `file_id` has exactly 2 rows.

2. **`wds_path` is a WDS shard path, not a per-slide file path.** Multiple slides are packed into a single `.tar` shard. To read a specific slide's tensor, use the WDS API with the `slide_id` as the sample key (files inside the shard are named `{slide_id}.features.npy` and `{slide_id}.coords.npy`), or use `wds_index_path` to download the full index for batch lookups.

3. **`wds_index_path`** points to `wds_index.json` on S3 — a JSON file mapping every `slide_id` to its shard file for that model. Load it once to efficiently locate any slide without scanning shards.

4. **S3 endpoint:** use `http://pmindecs.mskcc.org:9020` for on-premises S3 access. See usage examples for [AWS CLI](https://gist.github.com/raylim/2039b01cbb5f6682e1f115106aee65b6), [python](https://gist.github.com/raylim/ceb4ea7d8db8ff0c27b8d2322a1f9bd9).

5. **Only diagnostic slides are included** (`slide_type` starts with `DX`). Tissue section (TS), blood/bone marrow (BS), and other slide types from the GDC inventory are excluded.

6. **`titan_slide` embeddings** are slide-level aggregations produced by the [TITAN](https://github.com/mahmoodlab/TITAN) encoder, which takes the set of hoptimus1 patch embeddings as input. A slide must have hoptimus1 embeddings before titan_slide can be computed. The 36-slide gap between hoptimus1 (11,838 done) and titan_slide (11,802 done) reflects slides where titan_slide extraction failed (typically GPU OOM on very large slides).

7. **`status = 'pending'`** (56 slides as of 2026-05-01): 10 hoptimus1 and 46 titan_slide failures, scattered across TCGA-GBM, TCGA-KIRP, TCGA-LGG, TCGA-STAD, and others. These will be retried.

8. **`ajcc_pathologic_stage` and `tumor_grade` are frequently blank** (40% and 63% missing respectively). Brain tumors (GBM, LGG), sarcomas, and several other disease types do not use AJCC staging or WHO grading in GDC annotations.

9. **`percent_tumor_cells`, `percent_stromal_cells`, `percent_necrosis`, `percent_normal_cells` are 100% missing.** GDC does not populate these pathologist-estimated fields for the vast majority of TCGA cases. These columns are retained to match the GDC schema but should not be used.

10. **Clinical metadata** (columns from `primary_site` onward) is sourced from the GDC API at the time of inventory download and reflects GDC annotations at that date. Fields may contain `not reported`, `Unknown`, or be blank where GDC has no value.

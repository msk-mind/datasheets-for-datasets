# TCGA Slide Embeddings v2

<b>Path:</b> [`cdsi_prod.pathology_data_mining.tcga_slide_embeddings_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/tcga_slide_embeddings_v2) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-05-08 <br/>

<b>Lineage:</b>

[GDC Data Portal](https://portal.gdc.cancer.gov/) (TCGA slide inventory + clinical metadata) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ [`mussel-nf`](https://github.com/msk-mind/mussel-nf) feature extraction pipeline (hoptimus1, titan_slide) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ WDS shards on S3 (`s3://reef-tcga-v2-0/wds/`) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_prod.pathology_data_mining.tcga_slide_embeddings_v2` <br/>

<b>Summary Statistics:</b>

Total rows (one per slide × model): **23,660** <br/>
Unique DX slides: **11,848** <br/>
Unique patients (case_submitter_id): **9,743** <br/>
TCGA projects: **32** <br/>

| Model | Done | Failed | Pending (re-dispatching) |
|---|---|---|---|
| hoptimus1 | 11,802 | 10 | 0 |
| titan_slide | 11,802 | 46 | 0 |

**46 slides permanently excluded** (0.39% of 11,848 DX slides) — see [Notes](#notes) for details.

**415 slides re-queued** — these slides were previously extracted but their WDS shards were written to an incorrect S3 path (`wds/{model}/{model}/{project}/` instead of `wds/{model}/{project}/`) due to an old misconfiguration of `wds_dest` in the dispatcher. They are not accessible via `wds_index.json` and are being re-extracted. See [Notes](#notes) for details.

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
3. [Downloading TCGA Slides](#downloading)
4. [Notes](#notes)

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
| status | Feature extraction status | Categorical | string | `done` (23,604) = embeddings in WDS; `failed` (92) = permanently excluded |
| failure_reason | Human-readable reason for failure; blank when `status ≠ failed` | Categorical | string | `Empty SVS file (~480 KB) - known corrupt GDC file, produces 0 tissue tiles on tessellation` (23 titan_slide rows); `Failed after max retries` (20 rows across both models); `zero-output: ... produced 0 patches in 4 attempts` (13 titan_slide rows) |
| native_mpp | Scanner resolution in µm per pixel, read from the SVS TIFF header (Aperio `MPP` tag or `XResolution`); same value applies across both models for a given slide | Continuous | float | 0.25 (9,851 slides = 83.4%), 0.50 (1,065 = 9.0%), 0.23 (748 = 6.3%), 0.49 (52), 0.19 (16), 0.16 (8), 0.46–0.47 (8), 0.11–0.12 (3); null for 99 slides whose SVS header lacks MPP metadata |
| mpp_is_fallback | `true` when Mussel used the 0.5 µm/px default because the SVS header had no readable MPP tag; `false` when `native_mpp` was used; null when MPP provenance is unknown | Categorical | boolean | `false` for ~99% of slides; `true` for slides with null/unreadable headers |
| tiling_mpp | MPP actually used for feature extraction: equals `native_mpp` when `mpp_is_fallback=false`, or `0.5` when `mpp_is_fallback=true`; null when MPP provenance is unknown | Continuous | float | 0.25 (majority), 0.5 (fallback slides), other native values |
| wds_path | S3 path to the WDS tar shard containing this slide's embeddings | ID | string | S3 URI, e.g. `s3://reef-tcga-v2-0/wds/hoptimus1/TCGA-BRCA/000001.tar`; blank when `status ≠ done` |
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

## Downloading TCGA Slides <a name="downloading"></a>

TCGA slides are publicly accessible from the [GDC Data Portal](https://portal.gdc.cancer.gov/) without authentication. The recommended download tool is [gdc-client](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool), which supports multi-connection parallel downloads and resumable transfers.

### Install gdc-client

```bash
# Via conda (recommended)
conda install -c bioconda gdc-client

# Or download the pre-built binary from GDC:
# https://gdc.cancer.gov/access-data/gdc-data-transfer-tool
```

### Download a single slide by file UUID

Each row in `tcga_slide_embeddings_v2` has a `file_id` (GDC file UUID) and `file_name`. Use these to download the corresponding SVS directly:

```bash
# Downloads to ./<file_id>/<file_name>.svs
gdc-client download --no-related-files -n 8 <file_id>

# Example
gdc-client download --no-related-files -n 8 0006ae80-5774-4199-bbd0-3c120ed547e6
```

`-n 8` opens 8 parallel connections per file — safe to increase for large slides on fast networks.

### Download multiple slides from a manifest

Build a GDC manifest from file UUIDs (one per line) and submit it in one call:

```bash
# Create a manifest file from the table
# (GDC manifest format: id<TAB>filename<TAB>md5<TAB>size<TAB>state)
python - <<'EOF'
import databricks.connect as db
df = spark.sql("""
    SELECT file_id, file_name, md5sum, file_size
    FROM cdsi_prod.pathology_data_mining.tcga_slide_embeddings_v2
    WHERE model = 'hoptimus1' AND status = 'done'
    LIMIT 100
""")
df.selectExpr(
    "file_id as id",
    "file_name as filename",
    "md5sum as md5",
    "CAST(file_size AS STRING) as size",
    "'validated' as state"
).toPandas().to_csv("gdc_manifest.txt", sep="\t", index=False)
EOF

gdc-client download --no-related-files -n 8 -m gdc_manifest.txt -d ./tcga-slides/
```

Alternatively, build a manifest interactively at [portal.gdc.cancer.gov](https://portal.gdc.cancer.gov/) by filtering cases/files and clicking **Download Manifest**.

### Download via mussel-nf pipeline (automatic)

The `mussel-nf` pipeline integrates GDC downloads directly. When a slide is not found on local disk or S3, it is automatically downloaded by the `DOWNLOAD_SLIDE` Nextflow process before feature extraction.

**Configure in `nextflow.config` or a params YAML:**

```groovy
params {
    download {
        local_dir       = "/path/to/tcga-slides"   // root cache dir
        gdc_client_bin  = "gdc-client"             // path to binary if not on PATH
        gdc_token_file  = ""                       // leave empty for public TCGA data
        n_connections   = 8                        // parallel connections per download
        max_concurrent  = 16                       // max simultaneous DOWNLOAD_SLIDE tasks
    }
}
```

Slides are cached under `local_dir/<file_id>/<file_name>` and re-used across pipeline runs (`storeDir` semantics — a slide is never re-downloaded if the file already exists at that path).

**Pass `needs_download = true` in the samples CSV** to route a slide through `DOWNLOAD_SLIDE`:

```csv
slide_id,slide_path,file_id,file_name,needs_download
TCGA-BR-A44T-01Z-00-DX1,TCGA-BR-A44T-01Z-00-DX1.svs,<uuid>,TCGA-BR-A44T-01Z-00-DX1.<uuid>.svs,true
```

The `tcga_prepare_samples.py` script in `scripts/tcga/` generates this CSV automatically, resolving each slide's path (local → S3 → needs_download) and writing both a samples CSV and a sidecar `.meta.csv`.

### Token (controlled-access data)

All TCGA open-access data (including slides) does **not** require a token. If you are downloading controlled-access data from other GDC programs (e.g. TARGET), obtain a token from [portal.gdc.cancer.gov/auth](https://portal.gdc.cancer.gov/auth) and pass it via:

```bash
gdc-client download -t /path/to/gdc-user-token.txt --no-related-files <file_id>
```

Or set `params.download.gdc_token_file` in `nextflow.config`.



1. **Primary key** is (`file_id`, `model`). Each slide appears once per model (currently `hoptimus1` and `titan_slide`), so every `file_id` has exactly 2 rows.

2. **`wds_path` is a WDS shard path, not a per-slide file path.** Multiple slides are packed into a single `.tar` shard. To read a specific slide's tensor, use the WDS API with the `slide_id` as the sample key (files inside the shard are named `{slide_id}.features.npy` and `{slide_id}.coords.npy`). To locate any slide without scanning shards, download `s3://reef-tcga-v2-0/wds/{model}/wds_index.json` — a JSON file mapping every `slide_id` to its shard file for that model.

3. **`tiling_mpp`** is the MPP actually used for feature extraction. Use this column — not `native_mpp` — for any analysis that requires knowing at what resolution features were computed. It equals `native_mpp` when the SVS header had a readable MPP tag, or `0.5` when Mussel fell back to the default. `null` means MPP provenance is unknown.

4. **S3 endpoint:** use `http://pmindecs.mskcc.org:9020` for on-premises S3 access. See usage examples for [AWS CLI](https://gist.github.com/raylim/2039b01cbb5f6682e1f115106aee65b6), [python](https://gist.github.com/raylim/ceb4ea7d8db8ff0c27b8d2322a1f9bd9).

5. **Only diagnostic slides are included** (`slide_type` starts with `DX`). Tissue section (TS), blood/bone marrow (BS), and other slide types from the GDC inventory are excluded.

6. **`titan_slide` embeddings** are slide-level aggregations produced by the [TITAN](https://github.com/mahmoodlab/TITAN) encoder, which takes the set of hoptimus1 patch embeddings as input. A slide must have hoptimus1 embeddings before titan_slide can be computed.

7. **`native_mpp` was recovered retroactively** from SVS TIFF headers (Aperio `ImageDescription` tag) via two HTTP range requests per file — no full SVS download required. For slides already on ECS S3, headers were read directly; for the 408 slides not yet on ECS S3, headers were fetched from GDC. The 99 null values are slides whose SVS TIFF header contains neither an Aperio MPP tag nor a usable `XResolution`/`ResolutionUnit` pair. Use **`tiling_mpp`** (not `native_mpp`) to determine the resolution at which features were computed — for null-header slides, `mpp_is_fallback=true` and `tiling_mpp=0.5`.

7. **Known failures — 46 slides permanently excluded (`status = 'failed'`):**

   **Group A — 23 TCGA-STAD slides (TCGA-BR-\* barcodes): `titan_slide` only (hoptimus1 succeeded)**
   These slides are stored as ~480 KB SVS files on GDC — far smaller than a real gastric WSI (typically 100 MB–3 GB). When tessellated, they produce zero tissue tiles. hoptimus1 patch extraction technically completes (producing an empty or minimal feature set), but the TITAN slide encoder cannot aggregate zero patches and produces no output. All 23 carry the failure reason: *"Empty SVS file (~480 KB) — known corrupt GDC file, produces 0 tissue tiles on tessellation"*. These files exist on GDC but are likely blank/thumbnail-only SVS artifacts from the TCGA-Brazil gastric cohort.

   **Group B — 10 slides across 5 projects: both `hoptimus1` and `titan_slide`**

   | slide_id | project | file_size | likely cause |
   |---|---|---|---|
   | TCGA-5P-A9KA-01Z-00-DX1 | TCGA-KIRP | 3.7 GB | GPU OOM (too many patches) |
   | TCGA-5P-A9KC-01Z-00-DX1 | TCGA-KIRP | 3.7 GB | GPU OOM |
   | TCGA-5P-A9KE-01Z-00-DX1 | TCGA-KIRP | 2.2 GB | GPU OOM |
   | TCGA-5P-A9KH-01Z-00-DX1 | TCGA-KIRP | 1.6 GB | GPU OOM |
   | TCGA-A4-7286-01Z-00-DX1 | TCGA-KIRP | 297 MB | undetermined (retried 10×) |
   | TCGA-19-1388-01Z-00-DX1 | TCGA-GBM | 19.5 MB | undetermined (retried 10×) |
   | TCGA-19-1389-01Z-00-DX1 | TCGA-GBM | 16.3 MB | undetermined (retried 10×) |
   | TCGA-HT-7483-01Z-00-DX1 | TCGA-LGG | 37.3 MB | undetermined (retried 10×) |
   | TCGA-05-5420-01Z-00-DX1 | TCGA-LUAD | 12.1 MB | undetermined (retried 10×) |
   | TCGA-RP-A690-01Z-00-DX1 | TCGA-SKCM | 75.8 MB | undetermined (retried 10×) |

   These slides failed the maximum number of dispatcher retries (10×) across both models. The 4 large KIRP slides (1.6–3.7 GB) are likely GPU out-of-memory errors; the remaining 6 are undetermined and may reflect corrupted SVS files or transient infrastructure failures.

   **Group C — 13 slides across 9 projects: `titan_slide` only (hoptimus1 succeeded)**

   | slide_id | project | file_size | failure pattern |
   |---|---|---|---|
   | TCGA-05-4425-01Z-00-DX1 | TCGA-LUAD | 6 MB | likely non-tissue overview image |
   | TCGA-CG-5725-01Z-00-DX1 | TCGA-STAD | 6 MB | likely non-tissue overview image |
   | TCGA-DQ-5630-01Z-00-DX1 | TCGA-HNSC | 10 MB | 0 tissue patches |
   | TCGA-HT-7873-01Z-00-DX2 | TCGA-LGG | 30 MB | 0 tissue patches |
   | TCGA-06-1802-01Z-00-DX1 | TCGA-GBM | 48 MB | 0 tissue patches |
   | TCGA-PN-A8MA-01A-01-DX1 | TCGA-CESC | 84 MB | 0 tissue patches |
   | TCGA-FF-8062-01Z-00-DX1 | TCGA-DLBC | 108 MB | task error (exit 1, ignored) then 0 patches |
   | TCGA-HT-7884-01Z-00-DX1 | TCGA-LGG | 118 MB | 0 tissue patches |
   | TCGA-19-0963-01Z-00-DX1 | TCGA-GBM | 158 MB | 0 tissue patches |
   | TCGA-TM-A7CF-01Z-00-DX1 | TCGA-LGG | 256 MB | 0 tissue patches |
   | TCGA-K7-A5RF-01Z-00-DX1 | TCGA-LIHC | 276 MB | 0 tissue patches |
   | TCGA-R5-A7ZR-01Z-00-DX1 | TCGA-STAD | 440 MB | 0 tissue patches |
   | TCGA-3H-AB3X-01Z-00-DX1 | TCGA-MESO | 711 MB | 0 tissue patches |

   hoptimus1 patch embeddings were successfully extracted for all 13 slides and are present in WDS. However, the `TESSELLATE_FEATURIZE_BATCH` step consistently produced zero output when run with the TITAN/conch1_5 model stack, across 4 independent dispatch attempts. The two 6 MB files are almost certainly non-tissue overview images masquerading as DX slides. The remaining 11 likely have tissue presentations (e.g. very sparse cellularity, unusual staining, or scan artifacts) that produce zero valid patches under the `tcga` segmentation configuration at 0.5 µm/px.

8. **`ajcc_pathologic_stage` and `tumor_grade` are frequently blank** (40% and 63% missing respectively). Brain tumors (GBM, LGG), sarcomas, and several other disease types do not use AJCC staging or WHO grading in GDC annotations.

9. **`percent_tumor_cells`, `percent_stromal_cells`, `percent_necrosis`, `percent_normal_cells` are 100% missing.** GDC does not populate these pathologist-estimated fields for the vast majority of TCGA cases. These columns are retained to match the GDC schema but should not be used.

10. **Clinical metadata** (columns from `primary_site` onward) is sourced from the GDC API at the time of inventory download and reflects GDC annotations at that date. Fields may contain `not reported`, `Unknown`, or be blank where GDC has no value.

11. **418 slides re-extracted due to wrong S3 path (resolved 2026-05-08):** An earlier version of the dispatcher config set `wds_dest` to `s3://reef-tcga-v2-0/wds/hoptimus1` (with the model name included). The `_ShardWriter` in `append_wds.py` then appended the model name a second time when constructing shard paths, resulting in objects uploaded to `wds/{model}/{model}/{project}/` instead of `wds/{model}/{project}/`. When the config was corrected, the `wds_index.json` was rebuilt without those slides. All 418 affected slides were re-extracted and are now `done`. The 39 orphan objects at double-model paths were deleted from S3. Projects affected (top 5): TCGA-TGCT (263 slides), TCGA-THYM (38 slides), TCGA-PCPG (23 slides), TCGA-DLBC (12 slides), TCGA-MESO (8 slides).


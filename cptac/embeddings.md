# CPTAC Slide Embeddings

<b>Path:</b> `s3://reef-cptac-v1-0/` (layout nested under `cptac-2/` and `cptac-3/`; endpoint http://pmindecs.mskcc.org:9020) <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 2026-09-02 <br/>

<b>Lineage:</b> Embeddings computed by [Mussel](https://github.com/pathology-data-mining/Mussel) from the CPTAC slides documented in [slide_metadata.md](./slide_metadata.md) (`s3://cptac/`).

<b>Summary Statistics:</b>

Total slides: 8,415 (CPTAC-2: 1,245; CPTAC-3: 7,170). <br/>
Slides with all 5 outputs: 8,400. <br/>
tiles_h5_path present: 8,415. ctranspath: 8,404. optimus: 8,400. prefilter_ctranspath: 8,404. filtered_tiles: 8,404. <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Slide embeddings are created using version 0.9.0 of [Mussel](https://github.com/pathology-data-mining/Mussel).

slides &rarr; tiles &rarr; prefilter ctranspath features &rarr; filtered tiles &rarr; h-optimus + ctranspath features

Outputs live in `s3://reef-cptac-v1-0/` under a `cptac-2/` or `cptac-3/` prefix, each holding the standard reef v1 layout (`features/`, `tiles/`, `filter_tiles/`).

The Mussel parameters used are summarized below.
| **Parameter** | **Value** |
|---|---|
| filter model type | ctranspath |
| filter threshold | 0.75 |
| filter tiles | true |
| patch size | 224 |
| mpp | 0.5 |
| segment threshold | 15 |
| median blur ksize | 11 |
| morphology ex kernel | 2 |
| tissue area threshold | 1 |
| hole area threshold | 1 |
| max num holes | 2 |

### Vocabulary <a name="vocab"></a>

Primary key: <b>slide_id</b>.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| slide_id | Slide id (matches slide_metadata.slide_id) | ID | string | |
| ctranspath_features_tensor_path | CTransPath embedding tensor (marker filtered) | ID | string | full path |
| optimus_features_tensor_path | H-Optimus-0 embedding tensor (marker filtered) | ID | string | full path |
| prefilter_ctranspath_features_tensor_path | CTransPath embedding tensor (unfiltered) | ID | string | full path |
| tiles_h5_path | Tissue tile coordinates in HDF5 (unfiltered) | ID | string | full path |
| filtered_tiles_h5_path | Tissue tile coordinates in HDF5 (marker filtered) | ID | string | full path |

## Notes <a name="notes"></a>

1. For S3 paths, use the http://pmindecs.mskcc.org:9020 endpoint. Bucket: `arn:aws:s3:::reef-cptac-v1-0/*`.
2. <b>Join.</b> `slide_id` joins 1:1 to [slide_metadata.md](./slide_metadata.md). Each row is one slide.
3. <b>Missing slides.</b> 8 slides in the source `cptac` bucket were not processed and are absent here; these are the 8 CPTAC-PDA slides missing from the source bucket.
4. <b>Partial outputs.</b> 15 slides have tiles but incomplete features: 4 are missing only the optimus tensor (C3L-01469-22, C3L-03956-22, C3L-04241-42, C3L-04269-42); 11 have tiles only (no feature or filtered outputs).
5. <b>Path columns may be blank</b> when the corresponding output is absent (see notes 3 and 4).

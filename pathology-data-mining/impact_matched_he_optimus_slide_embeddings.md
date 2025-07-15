# H&E Slide Embeddings

<b>Path:</b> [`"cdsi_prod.pathology_data_mining.impact_matched_he_optimus_slide_embeddings"`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/impact_matched_he_optimus_slide_embeddings) <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 2025-07-15 <br/>

<b>Lineage: ([SQL](https://msk-mode-prod.cloud.databricks.com/sql/editor/e5c4288b-5c95-423b-af15-2a4932367b53?o=646852163028571)) </b>
"cdsi_prod.pathology_data_mining.slide_embeddings" (as t1) <br/>
["cdsi_prod.pathology_data_mining.impact_matched_slides"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/impact-matched-slides.md) (as t2) <br/>
&nbsp; |_ t1 LEFT JOIN t2 ON t1.slide_id = t2.image_id WHERE t2.IS_HNE = 1 <br/>

<b>Summary Statistics:</b>

Total number of rows (slides): 419,624 <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Slide embeddings are created using [Mussel](https://github.com/pathology-data-mining/Mussel). 
We first segment each slide for tissue and define patches, 
storing the coordinates in an HDF5 file.  We then create CTransPath embeddings with a pretrained 
encoder and use those features to filter out marker tiles with a linear model.  Finally, we use 
the H-Optimus-0 pretrained encoder to generate embeddings on the filtered tiles.  The embeddings are stored as PyTorch tensors.

slides &rarr; tiles &rarr; prefilter ctranspath features &rarr; filtered tiles &rarr; h-optimus + ctranspath features

The Mussel parameters used to do all this are summarized below.
| **Parameter** | **Value** |
|---|---|
| filter model type | ctranspath |
| filter threshold | 0.75 |
| filter tiles | false |
| patch size | 224 |
| mpp | 0.5 |
| segment threshold | 15 |
| median blur ksize | 11 |
| morphology ex kernel | 2 |
| tissue area threshold | 1 |
| hole area threshold | 1 |
| max num holes | 2 |


### Vocabulary <a name="vocab"></a>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| slide_id | Slide ID | ID | string |  |
| workflow_id | Workflow ID  | ID  | string | |
| tiles_h5_path | Tissue tile coordinates in HDF5 format (marker filtered) | ID | string | full path |
| optimus_features_tensor_path | H-Optimus-0 embedding pytorch tensor path (marker filtered) | ID | string | full path |

## Notes <a name="notes"></a>

1. For S3 paths, use http://pmindecs.mskcc.org:9020 endpoint.
2. Usage examples for [AWS CLI](https://gist.github.com/raylim/2039b01cbb5f6682e1f115106aee65b6), [R](https://gist.github.com/raylim/4cff68d45a83cf6f28508c0a5f7afd33), and [python](https://gist.github.com/raylim/ceb4ea7d8db8ff0c27b8d2322a1f9bd9).

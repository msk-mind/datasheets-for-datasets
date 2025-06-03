# Slide Embeddings

<b>Path:</b> [`"cdsi_prod.pathology_data_mining.slide_embeddings"`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/slide_embeddings) <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 2025-06-02 <br/>

<b>Summary Statistics:</b>

Total number of rows (slides): 569,961 <br/>

Total number of rows with H-Optimus-0: 569,360 <br/>

Total number of non-IHC rows: 553,008 <br/>

Total number of non-IHC rows with H-Optimus-0: 552,569 <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Slide embeddings are created using [Mussel](https://github.com/pathology-data-mining/Mussel). 
We first segment each slide for tissue and define patches, 
storing the coordinates in an HDF5 file.  We then create CTransPath embeddings with a pretrained 
encoder and use those features to filter out marker tiles, with a linear model.  Finally, we use 
the H-Optimus-0 pretrained encoder to generate embeddings on the filtered tiles.  The embeddings are stored as PyTorch tensors.

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
| prefilter_ctranspath_features_tensor_path | CTransPath embedding pytorch tensor path (unfiltered)| ID | string | relative path |
| tiles_h5_path | Tissue tile coordinates in HDF5 format (unfiltered) | ID | string | relative path |
| filtered_tiles_h5_path | Tissue tile coordinates in HDF5 format (marker filtered) | ID | string | relative path |
| ctranspath_features_tensor_path | CTransPath embedding pytorch tensor path (marker filtered)| ID | string | relative path |
| optimus_features_tensor_path | H-Optimus-0 embedding pytorch tensor path (marker filtered) | ID | string | relative path |

## Notes <a name="notes"></a>

1. Relative paths are relative to the filesystem roots in the run parameters table.
2. Primary location on gpfs: /gpfs/cdsi_ess/foundation/reef
3. Iris location: /data1/pashaa/cdsi/pdm/reef (CTransPath not available)

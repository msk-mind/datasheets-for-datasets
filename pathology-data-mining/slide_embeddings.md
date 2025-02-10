# Slide Embeddings

<b>Path:</b> [`"cdsi_prod.pathology_data_mining.slide_embeddings"`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/slide_embeddings) <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 2025-02-10 <br/>

<b>Summary Statistics:</b>

Total number of rows (slides): 528,891 <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Slide embeddings created using Mussel. We first segment sides for tissue and
patch, storing the coordinates in an HDF file. We then create the embeddings
with the CTransPath pretrained encoder. Using the CTransPath features, we use a
linear model to filter out marker tiles. We use the H-Optimus-0 pretrained
encoder to create embeddings on the filtered tiles. Embeddings are stored as
PyTorch tensors.


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

Relative paths are relative to the filesystem roots in the run parameters table.

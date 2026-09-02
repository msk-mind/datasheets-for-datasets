CPTAC pathology whole slide images (CPTAC-2 and CPTAC-3) downloaded from the TCIA PathDB catalog, with patient and slide metadata, and Mussel embeddings. Slides are stored on the ECS `cptac` bucket and embeddings on `reef-cptac-v1-0` (endpoint http://pmindecs.mskcc.org:9020).

## Datasets:
[slide_metadata](slide_metadata.md) - CPTAC-2 and CPTAC-3 slide metadata, one row per slide (identity, PathDB catalog, GDC clinical/pathology, GDC slide biospecimen). <br/>
[embeddings](embeddings.md) - Mussel slide embeddings manifest (tiles and CTransPath/H-Optimus-0 feature tensors).

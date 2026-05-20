# msk_impact_path_images_metadata_deidentified_v1

<b>Path:</b> <br/>
cdsi_eng_phi.pdm_base_tables_dev.impact_block_matched_slides_v2 <br/>
|_ cdsi_res_deid.pdm_base_tables.msk_impact_path_images_metadata_deidentified_v2 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 04/23/0226 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b> <br/>
Total rows: 2,548,422<br/>
total patients: 100,093<br/>
image_ids: 2,548,422


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

All H&E and IHC slides for IMPACT patients across all patient timepoints with only deidentified ids and deidentified dates. 

### Vocabulary <a name="vocab"></a> 

Primary key: img_hid

## Notes <a name="notes"></a>

1. The table may be used to showcase all images associated with an IMPACT patient on a timeline. 

2. This data is obtained from systems that support clinical operations, and that are fine tuned for clinical operations, and not research. Therefore the dataset may contain some noise. 

3. The bulk of the data contains H&E and IHC images with solid tissue. There is likely a small percentage of ICC images with free flowing cells from cytopathology and hematopathology. For example, when the stain name contains "FROZEN" it generally indicates that the slide was prepared while the surgery was in progress to look for remaining margins of the tumor. These slides may or may not be solid tissue. Further curation will be required to identify a cleaner set of H&E and IHC slides. This is also a good example of how the data stems from fine tuned clinical workflows and is not designed for research.

4. Some hematopathology slides that may be considered as IHC (bone marrow core) for example may also be exluded in this dataset. 




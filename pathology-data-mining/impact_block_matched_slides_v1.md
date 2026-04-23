# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.impact_block_matched_slides_v1 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 04/22/0226 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 176,114<br/>
sample_ids: 40,696
block_ids: 40,674
image_ids: 175,970
block_id, m_accession_number, sample_id, image_id: 176,112




# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

(H&E and IHC) Slides matched to IMPACT samples at the block level. 

### Vocabulary <a name="vocab"></a> 

Primary key: (block_id, m_accession_number, sample_id, image_id)

## Notes <a name="notes"></a>

The table generally contains H&E and IHC images but it is hard to tell which stain was used for all images because the 'stain_group' column does not clearly specify the stain for all image_ids. 

While about 87% of MSK records (has_external_s_number = false) in the copath table have block_ids, the block_id coverage for IMPACT is rather low, at about 50% of sample_ids have block_ids if IMPACT had 80,000 samples in the summer of 2024. <b>The reason for this is inclear. </b>

<b>Assertions:<b/><br/>

1. Contains slides for solid tumors only obtained from S-accessions (surgery) that subsequently had M-accessions (molecular) generated for IMPACT sequencing. i.e. no 'C' cytology, 'H' heme etc. accessions included. 


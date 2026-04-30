# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.impact_block_matched_slides_v1 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 04/22/2026 (updated: 04/29/2026) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 176,114<br/>
sample_ids: 40,696<br/>
block_ids: 40,674<br/>
image_ids: 175,970<br/>
block_id, m_accession_number, sample_id, image_id: 176,112<br/>


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

While over 99% of MSK records (has_external_s_number = false) with S-accessions in the copath table have block_ids (see [copath_molecular_links_cleaned_v2](copath_molecular_links_cleaned_v2.md) ), the block_id coverage for IMPACT is rather low, at about 50% of sample_ids have block_ids if IMPACT had 80,000 samples in the summer of 2024. <b>The reason for this is partly because only 64% copath m-accession records (see [copath_molecular_links_cleaned_v2](copath_molecular_links_cleaned_v2.md) ) overlap with the IMPACT cohort. There is some other attrition that still needs to be accounted for. </b>

<b>Assertions:<b/><br/>

1. Contains slides for solid tumors only obtained from S-accessions (surgery) that subsequently had M-accessions (molecular) generated for IMPACT sequencing. i.e. no 'C' cytology, 'H' heme etc. accessions included. 


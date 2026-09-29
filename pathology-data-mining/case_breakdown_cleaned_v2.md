# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.case_breakdown_cleaned_v2 <br/>
<b>Table Type:</b> Live  <br/>
<b>Date created or last updated:</b> 04/22/0226  <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>


<b>Summary Statistics:</b>

Total rows: 10,154,319<br/>
Total images: 10,154,319<br/> 


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This table is like the previous version cdsi_eng_phi.pdm_base_tables.case_breakdown_cleaned but with improved curation. See SQL in Databricks for details. 

### Vocabulary <a name="vocab"></a>

Primary key: Image_id. 

Same as cdsi_eng_phi.pdm_base_tables.case_breakdown_cleaned


## Notes <a name="notes"></a>

<b>Assertions:</b> <br/>

1. All block ids are fully formed or null.  i.e. they contain S-number/part_number-block_label.

2. Many M-accessions can be generated from an S-accession number. 

3. Many sample_id can be generated from an M-accession number. 


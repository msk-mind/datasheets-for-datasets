# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.copath_molecular_links_cleaned_v2 <br/>
<b>Table Type:</b> Static <br/>
<b>Date created or last updated:</b> 04/22/0226 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 127,283 <br/>
Total accession_number, m_accession_number pairs: 117,239 <br/>
rows with has_external_s_number = false: 86,276<br/>
rows with has_external_s_number = true: 40,989<br/>
rows with has_external_s_number = false and non-null block_ids: 75,463 (87% of MSK cases have block_id)<br/>
Total block_ids: 69,477 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

The primary purpose of this table is to obtain the S-accession to M-accession mapping. This mapping is not available in the Hobbit casebreakdown table. The table also contains part number and block label information which is useful for constructing the block_id. 

This table is a snapshot from Copath obtained in the Summer of 2024. It needs to be replaced with a live table in MODE that maps S-accessions to M-accesions. 

This version 2 of the table has improved curation compared to the first version of the table named copath_molecular_linked_cleaned in the same schema. 

### Vocabulary <a name="vocab"></a>

Primary key: block_id



## Notes <a name="notes"></a>

<b>Assertions:</b> <br/>

1. All block ids are fully formed or null. i.e. they contain S-number/part_number-block_label.

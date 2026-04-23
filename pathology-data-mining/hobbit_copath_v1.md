# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.hobbit_copath_v1 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 04/22/2026 <br/>

<b>Lineage (See in databricks): </b>


<b>Summary Statistics:</b>

Total rows: 329,234 <br/>
accession_number, m_accession_number pairs: 67,989 <br/>
block_ids: 62,518
block_id, m_accession_number, image_id: 329,230 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This table joins the Hobbit casebreakdown table with the Copath table in order to map S-accessions (surgical) to M-accessions (molecular) and to also increase the number of valid block_ids. The block_id count is increased by taking the union of valid block_ids from both tables. 

### Vocabulary <a name="vocab"></a>

Primary Key: block_id, m_accession_number, image_id


## Notes <a name="notes"></a>

<b>Assertions:</b>
1. Only S-accessions (surgery) are mapped to M-accessions (molecular). S-accessions have an 'S' prefix and M-accessions have an 'M' prefix or 'DMG' prefix. All other types of accessions like 'C' (cytology), 'H' (heme) etc. are filtered out. <br/>

2. The S-accessions column (accession_numbner) contains only S accessions, and the m_accessions columns (m_accession_number) contains only M accesions. TODO: there is one M accession in the S accesion col. verify correctness. 





# Table Name 

<b>Path:</b> cdsi_eng_phi.pdm_base_tables_dev.hobbit_copath_v1 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 04/22/2026 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>


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

This table joins the Hobbit casebreakdown table with the Copath table in order to include the map from S-accessions (surgical) to M-accessions (molecular) in the case_breakdown table. This join was also done to possibly increase the number of valid block_ids in the casebreakdown table. 

The approach taken (See SQL definition on Databricks) to increase the overall block_id count was to 

1. first separate out casebreakdown records that have block_ids from those that don't have block_ids. <br/><br/>

The records that don't have block_ids in casebreakdown table, were then joined with the records in the copath table in two separate ways. <br/><br/>

2. By (S and M) accession number in casebreakdown to (S and M) accession number in copath. <br/>
3. By (M) accession number in casebreakdown to M accession number in copath. <br/><br/>

The union of these three sets of records is then taken to maximize block_id coverage in the casebreakdown table. It can be seen from commenting out the first and third unions that the block_ids obtained from the copath table largely overlap with the block_ids already present in the case_breakdown table. Therefore, little is gained from the join operation. 

### Vocabulary <a name="vocab"></a>

Primary Key: block_id, m_accession_number, image_id


## Notes <a name="notes"></a>

<b>Assertions:</b>
1. Only S-accessions (surgery) are mapped to M-accessions (molecular). S-accessions have an 'S' prefix and M-accessions have an 'M' prefix or 'DMG' prefix. All other types of accessions like 'C' (cytology), 'H' (heme) etc. are filtered out. <br/>

2. The S-accessions column (accession_numbner) contains only S accessions, and the m_accessions columns (m_accession_number) contains only M accesions. TODO: there is one M accession in the S accesion col. verify correctness. 





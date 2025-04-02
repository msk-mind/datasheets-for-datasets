# Table Name 

<b>Path:</b> `"pathology-data-mining"."copath_molecular_links_clean"` <br/>
<b>Table Type:</b> Live <br/>
<b>Last updated:</b> `2025-04-01` <br/>

<b>Lineage ([python](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/python/clean_copath.py)): </b> 


["hobbit-poc"."molecular_cases"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/copath_molecular_links.md) (as t1) <br/>
|_"pathology-data-mining"."copath_molecular_links_cleaned" <br/>


<b>Summary Statistics:</b>

Total number of rows (m-numbers): 127,433


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Table containing parsed and cleaned columns from [the source copath molecular links table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/copath_molecular_links.md).  

The following columns used to create the output table:
* `m_specnum_formatted` is the "M-number" for this sample.  It is labeled `m_number` in the cleaned table.
* `outside_number` is the non-MSK accession number (if any) associated with the tissue block.
* `accession_block_term` is the complete ID for the sequenced tissue block, composed of the S-accession number, part number and (usually) a block-designator label. 
* `part_description` includes a description of the sequenced tissue, along with the MSK block ID, an outside block ID (if any), the date-of-procedure, and the number of H&E or unstained slides made from this sample.  The output columns derived from the part description are described below.

The structured portion of the `part_description` contains an MSK block ID for the tissue block, based on the S-accession number.  This block id is written to the `block_id` column of the cleaned table.  It must match the `accession_block_term` from the input Copath table.

The block id is also parsed into the S-accession number, the part number, and the block designator, which are reported in the `s_number`, `part_number`, and `s_blkdesig_label` columns.

If an outside block ID is reported in the part description, the accession number is parsed out from it and saved as the `outside_number` in the output table.

For example, take the following `part_description`:
```
 Liver, lateral  section (MSK:S29-2342/23-1-a, DOP:02/03/2029)
 ```
 In this case, the portion in parentheses is extracted and the following fields are extracted:
 ```
 part_description: "Liver, lateral  section"
 block_id: S29-2342/23-1-a
 s_number: S29-2342
 part_number: 23
 s_blkdesig_label: 1-a
 dop: 02/03/2029
 ```
 Not all `part_description` values are this easily parsed and there is variation that leads to some values being unavailable. 

 Of all available samples (127,808), 41,116 come from external sources, and 782 have only an external accession.


### Vocabulary <a name="vocab"></a>


| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| m_number | M accession number from DMP or Molecular Number | ID | string | |
| part_description | the origin and nature of the tissue part | string  | string  | |
| dop | date of procedure | Date | date | |
| block_id | full block ID  | ID  | string  | |
| s_number | surgical accession ID  | ID  | string  | |
| part_number | surgical part number | ID  | integer  | |
| s_blkdesig_label | block label from surgical accession | ID | string  | |
| outside_block_id | full block ID for outside accession | ID  | string  | |
| outside_number | outside accession ID  | ID  | string  | |
| has_only_external_s_number | True, if only an external (non-MSK) accession number is available | Binary  | bool  | |
| has_external_s_number | True, if there's an external (non-MSK) accession number | Binary  | bool;  | |


## Notes <a name="notes"></a>

1. Not all `part_description` values contain a DOP, and in some cases there is no `DOP` label despite a date being indicated. These cases are not captured in the `DOP` column
4. Almost all cases that come from external sources also get internal accession numbers. In those cases, both the internal and external accessions are available. In order to flag these cases, use the `has_external_s_number` field.
5. Some external cases are also not given internal accessions. To flag these cases, use the `only_has_external_s_number`
6. Some internal and external accessions are formatted similarly (i.e., both are S\d+-[a set of digits])
7. Approximately 38,000 specnums do not have part_descriptions that contain structured data (for example: blood samples, normal samples, cfDNA, Nail, donor samples, )



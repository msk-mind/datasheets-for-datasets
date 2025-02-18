# Table Name 

<b>Path:</b> `"pathology-data-mining"."copath_molecular_links_cleaned"` <br/>
<b>Table Type:</b> Live <br/>
<b>Last updated:</b> `2024-12-05` <br/>

<b>Lineage ([SQL](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/copath_molecular_links_cleaned.sql)): </b> 


["hobbit-poc"."molecular_cases"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/copath_molecular_links.md) (as t1) <br/>
|_"pathology-data-mining"."copath_molecular_links_cleaned" <br/>


<b>Summary Statistics:</b>

Total number of rows (specimen numbers): 186,786



# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Table containing parsed and cleaned columns from [the source copath molecular links table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/copath_molecular_links.md). The `part_description` field is split up and parsed into separate columns that indicate the part and block numbers, as well as other potentially useful metadata columns. All columns in this table other than `specnum_formatted` are parsed from the `part_description` field. The process is described in the sql query.

In short, the structured portion of the `part_description` contains information pertaining to the part and block of the tissue sample, as well as information about staining and the date of procedure. The structured portion is split up into metadata fields depending on what is available. 

For example, take the following `part_description`:
```
 Liver, lateral  section (MSK:S29-2342/23-1-a, 20 USS and 1H&E, DOP:02/03/2029)
 ```
 In this case, the portion in parentheses is extracted and the following fields are extracted:
 ```
 s_number: S29-2342
 part_number: 23
 s_blkdesig_label: 1-a
 dop: 02/03/2029
 hne_count: 1
 uss_count: 20
 ```
 Not all `part_description` values are this easily parsed and there is variation that leads to some values being unavailable. 

 Of all available samples (186,786), 42,295  come from external sources, and of them, 2880 only have an external accession.


### Vocabulary <a name="vocab"></a>


| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| specnum_formatted | M accession number from DMP or Molecular Number | ID | string | |
| part_description | free text followed by machine readable form in parenthesis with link to Surgical accession ID, part number and block designator that can be used to link an IMPACT sample to a specific block | string  | string  | |
| s_number | surgical accession ID  | ID  | integer  | |
| part_number | surgical part number | ID  | integer  | |
| s_blkdesig_label | block label from surgical accession | ID | string  | |
| dop | date of procedure | Date | date | |
| uss_count | unstained slide count | integer | integer | |
| hne_count | H&E slide count | integer | integer | |
| has_only_external_s_number | True, if only an external (non-MSK) accession number is available | Binary  | bool  | |
| has_external_s_number | True, if there's an external (non-MSK) accession number | Binary  | bpp;  | |



## Notes <a name="notes"></a>

1. Not all `part_description` values contain a DOP, and in some cases there is no `DOP` label despite a date being indicated. These cases are not captured in the `DOP` column
2. If present, the `uss_count` and `hne_count` fields are typically structured where `uss_count` is in the 15-20 range, and the `hne_count` is usually 1. Sometimes, the field is clearly incorrect and `hne_count` is 20 and `uss_count` is 1 (for example), which is a user entry mistake. 
3. Often times, when neither `uss_count` or `hne_count` are present `part_description` field just says something like `1 paraffin block` and no other details on staining. 
4. Many cases that come from external sources often get internal accessions. In those cases, both the internal and external accession is available, but only the internal accession is pulled out. In order to flag these cases, use the `has_external_s_number`
5. Some external cases are also not given internal accessions. To flag these cases, use the `only_has_external_s_number`
6. Some internal and external accessions are formatted similarly (ie both are M\d+-[a set of digits])
7. Approximately 38,000 specnums do not have part_descriptions that contain structured data (for example: blood samples, normal samples, cfDNA, Nail, donor samples, )

8. The following columns contain missing values:
```
specnum_formatted: 0
part_description: 1
description:
s_number: 38,089 
part_number: 51,622
s_blk_desig_label: 98,946
dop: 122,429
uss_count: 55,879
hne_count: 58,043
only_has_external_s_number: 0
has_external_s_number: 0
```


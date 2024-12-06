# Table Name 

<b>Path:</b> `"pathology-data-mining"."copath_molecular_links_cleaned"` <br/>
<b>Table Type:</b> Live <br/>
<b>Last updated:</b> `2024-12-05` <br/>

<b>Lineage ([SQL](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/copath_molecular_links_cleaned.sql)): </b> 


["hobbit-poc"."molecular_cases"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/copath_molecular_links.md) (as t1) <br/>
|_"pathology-data-mining"."copath_molecular_links_cleaned" <br/>


<b>Summary Statistics:</b>

TODO: Update:  Shape and size of table, counts of key data elements and other statistics that may be useful for the user. 


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

TODO UPDATE: Explain the purpose for which the dataset was created.  This should include the motivation
for the dataset, its composition (any relationships between fields of the dataset),
the collection process (if applicable), expected uses of the data, and so on.  If the dataset was composed
from other datasets, its lineage should be clearly described, with references to the
parent datasets.

### Vocabulary <a name="vocab"></a>

TODO: Update: The vocabulary of a dataset is comprised of its variables, (or field names) the description (or semantics) of 
these variables, their field type, data type and format. An unambiguous field description
is very important for consistent interpretation of the field. The description must also include units where applicable. 
Equally important are the field types. The field type provides the semantics behind the variable. The data type specifies the encoding that should be used for the variable when the dataset is loaded into memory. The encoding is critical because the data may be presented in a file format like CSV, which carries no information about the encoding, forcing data loaders (like Pandas) to guess.  Writing a field in the wrong format can lead to terrible and unexpected errors, like the infamous MRN zero-padding error where the preceeding zeros in an MRN are stripped if the field is encoded as an integer instead of a string. The field format may be used to further describe or elaborate on categorical variables that have a finite set of possible values and semantics behind each value. 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| specnum_formatted | 'M' accession number from DMP or Molecular Number | ID | string | |
| specclass_id |  | string  | Categorical | [DMPN, DM, MPATH]|
| part_inst | part id from surgical accession | ID  | integer  | |
| part_type | tissue type | string | categorical  | See below |
| part_description | free text followed by machine readable form in parenthesis with link to Surgical accession ID, part number and block designator that can be used to link an IMPACT sample to a specific block | ID  | string  | |
| description | parsed out part description | ID  | integer  | |
| s_number | parsed out surgical accession ID | ID  | integer  | |
| part_number | parsed out surgical part number | ID  | integer  | |
| s_blkdesig_label | parsed out block label from surgical accession | ID | string  | |
| outside_number | parsed out non-MSK accession number | ID  | string  | |
| dop | parsed out date of procedure | Date | date | |
| uss | parsed out unstained slide count | integer | integer | |
| hne | parsed out h&E slide count | integer | integer | |



## Notes <a name="notes"></a>



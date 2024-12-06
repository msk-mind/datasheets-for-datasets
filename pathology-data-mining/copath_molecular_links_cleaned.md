# Table Name 

<b>Path:</b> <DREMIO_PATH_TO_TABLE> <br/>
<b>Table Type:</b> Live OR Static <br/>
<b>Date created or last updated:</b> <CREATION_DATE_FOR_STATIC_TABLES> OR <DATE_LAST_UPDATED_FOR_LIVE_TABLES> <br/>

<b>Lineage (<LINK_TO_SQL_FILE>): </b>

<BASE_TABLE> <br/>
|_ <DERIVED_TABLE> <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ <DERIVED_TABLE> etc. <br/>

<b>Summary Statistics:</b>

Shape and size of table, counts of key data elements and other statistics that may be useful for the user. 


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Explain the purpose for which the dataset was created.  This should include the motivation
for the dataset, its composition (any relationships between fields of the dataset),
the collection process (if applicable), expected uses of the data, and so on.  If the dataset was composed
from other datasets, its lineage should be clearly described, with references to the
parent datasets.

### Vocabulary <a name="vocab"></a>

The vocabulary of a dataset is comprised of its variables, (or field names) the description (or semantics) of 
these variables, their field type, data type and format. An unambiguous field description
is very important for consistent interpretation of the field. The description must also include units where applicable. 
Equally important are the field types. The field type provides the semantics behind the variable. The data type specifies the encoding that should be used for the variable when the dataset is loaded into memory. The encoding is critical because the data may be presented in a file format like CSV, which carries no information about the encoding, forcing data loaders (like Pandas) to guess.  Writing a field in the wrong format can lead to terrible and unexpected errors, like the infamous MRN zero-padding error where the preceeding zeros in an MRN are stripped if the field is encoded as an integer instead of a string. The field format may be used to further describe or elaborate on categorical variables that have a finite set of possible values and semantics behind each value. 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| field1 | field1 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary | YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field2 | field2 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field3 | field3 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |

## Notes <a name="notes"></a>
Verifiable invariants guarding the consistency of the data (or lack of, if data is noisy). Notes are intended to save the user a significant amount of time in querying and understanding the dataset.  

For example, a mention of a field that contains empty strings or null values may be presented as a rule. Conversely, if a field is guaranteed not to have empty or null values, this may also be presented as a rule if knowledge of this guarantee could be useful to the user of the dataset. 


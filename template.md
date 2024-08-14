# Table Name 

<b>Path:</b> <DREMIO_PATH_TO_TABLE> <br/>
<b>Table Type:</b> Live OR Static <br/>
<b>Date created or last updated:</b> <CREATION_DATE_FOR_STATIC_TABLES> OR <DATE_LAST_UPDATED_FOR_LIVE_TABLES> <br/>

<b>Lineage (<LINK_TO_SQL_FILE>): /b>

<BASE_TABLE> <br/>
|_ <DERIVED_TABLE> <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ <DERIVED_TABLE> etc. <br/>

<b>Summary Statistics:</b>

Shape and size of table, counts of key data elements and other statistics that may be useful for the user. 


# Table of contents
1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary](#vocab)
3. [Rules](#rules)

## Description <a name="description"></a>

Explain the purpose for which the dataset was created.  This should include the motivation
for the dataset, its composition (any relationships between fields of the dataset),
the collection process (if applicable), expected uses of the data, and so on.  If the dataset was composed
from other datasets, its lineage should be clearly described, with references to the
parent datasets.


## Assumptions <a name="assumptions"></a>

Describe any assumptions made about the data collection evironment or collection process that are not
verifiable (or inferable) from the data directly. This is very important because assumptions are made quite often
especially when a dataset is being cleaned. A cleaning step may be based on an assumption
about what is expected to be correct about the dataset, but it may be possible that the assumption
itself is incorrect. Stating this upfront therefore can help shape the context in which results from an analysis where
obtained.

For example, for a dataset that represents a cohort of slides, it may be assumed that not all slides represented in a dataset 
have tumor content in them. This information may not be verifiable from the dataset because there is not field or variable in 
the dataset that quantifies tumor content for each slide. 

### Vocabulary <a name="vocab"></a>

The vocabulary of a dataset is comprised of its variables, (or field names) the description (or semantics) of 
these variables, their field type, data type and format. An unambiguous field description
is very important for consistent interpretation of the field. The description must also include units where applicable. 
Equally important are the field types. The field type provides a high level overview of the type of each variable contained 
in the dataset. The data type is critical because the data may be presented in a file format like CSV, which carries no information about the
types of its data, forcing data loaders (like Pandas) to guess.  Writing a field in the wrong format can lead to terrible and unexpected errors, like the infamous MRN zero-padding error where the preceeding zeros in an MRN are stripped if the field is encoded as an integer instead of a string. The field format may be used to further describe or elaborate on categorical variables that have a finite set of possible values and semantics behind each value. 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| field1 | field1 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary | YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field2 | field2 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field3 | field3 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |

## Rules <a name="rules"></a>
Verifiable rules (or invariants) guarding the consistency of the data (or lack of, if data is noisy). The purpose of stating rules is to save the user a significant amount of time in studying and understanding the dataset. From reading the rules, the user should feel confident in her understanding of the dataset without having to put in the time to reach this level of understanding.  

For example, a mention of a field that contains empty strings or null values may be presented as a rule. Conversely, if a field is guaranteed not to have empty or null values, this may also be presented as a rule if knowledge of this guarantee could be useful to the user of the dataset. 


# Table Name 

<b>Path:</b> <DREMIO_PATH_TO_TABLE> <br/>
<b>Table Type:</b> Live OR Static <br/>
<b>Late updated:</b> <DATE> <br/>

<b>Lineage:</b>

Base Table <br/>
|_ Derived_Table <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ Derived Table etc. <br/>

<b>Summary Statistics:</b>

Typically, shape and size of table, counts of key data elements and other useful statistics. 


# Table of contents
1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Field Types(#vocabandtypes)
3. [Rules](#rules)

## Description <a name="description"></a>

Explain the purpose for which the dataset was created.  This should include the motivation
for the dataset, its composition (any relationships between components of the dataset),
the collection process, expected uses of the data, and so on.  If the dataset was composed
from other datasets, its lineage should be clearly described, with references to the
parent datasets.


## Assumptions <a name="assumptions"></a>

Describe any assumptions made about the collection evironment or collection process that are not
verifiable from the data directly. This is extremely important because assumptions are made quite often
especially when a dataset is being cleaned. A cleaning step may be based on an assumption
about what should be correct about the dataset but it may be possible that the assumption
itself is incorrect from the perspective of the collection environment and process. So
stating this upfront can help shape the context in which results from an analysis where
obtained.

### Vocabulary and Field Types <a name="vocabandtypes"></a>

Explain the vocabulary of the dataset - what variables (fields) does it present, what are
the semantics of those fields, how are the represented?  An unambiguous field description
is very important.  Equally important are the field type and data type. The field type
helps give a good high level overview of the type of variables contained in the dataset,
which can be a very informative view of the dataset. The data type is critical because the
data may be presented in a file format like CSV, which carries no information about the
types of its data, forcing data loaders (like Pandas) to guess.  Writing a field in the
wrong format can lead to terrible and unexpected errors, like the infamous MRN zero-padding error.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| field1 | field1 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary | YYYYMMDD, 0, 1, True, False etc. |
| field2 | field2 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. |
| field3 | field3 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. |

## Categorical Variables:

**Field1:**

Description of field 1

| **Field1** | **count** | **Description** |
|:---|---:|:---|
| variable1| 1000 | description |
| variable2| 100 | description |
| variable3| 1 | description |

## Rules <a name="rules"></a>
Verifiable rules (or invariants) guarding the consistency of the data (or lack of such rules if data is noisy)

Mention fields with empty or null values


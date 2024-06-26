# Table Name 

<b>Path:</b> <DREMIO_PATH_TO_TABLE> <br/>
<b>Table Type:</b> Live OR Static <br/>
<b>Late updated:</b> <DATE> <br/>

<b>Lineage:</b>

Base Table <br/>
|_ Derived_Table <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ Derived Table etc. <br/>

<b>Summary Statistics:</b>

Typically, shape and size of table, counts of key data elements and other useful distributions. 


# Table of contents
1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabandencoding)
3. [Rules](#rules)

## Description <a name="description"></a>

A description of the value behind the dataset (motivation, composition (description of relationships within the dataset, description of lineage if dataset was composed from other datasets), collection process, recommended uses, and so on).


## Assumptions <a name="assumptions"></a>

Any assumptions made about the collection evironment or collection process that is not verifiable. This section is extremely important because assumptions are made quite often especially when a dataset is being cleaned. A cleaning step may be based on an assumption about what should be correct about the dataset but it may be possible that the assumption itself is incorrect from the perspective of the collection environment and process. So stating this upfront can help shape the context in which results from an analysis where obtained. 

### Vocabulary and Encoding <a name="vocabandencoding"></a>

Vocabulary of the dataset. Clearly an unambiguous field description goes a long way. Equally important are the field type and encoding. The field type helps give a good high level overview of the type of variables contained in the dataset, which can be a very informative view of the dataset. The encoding is very important because often times the data is presented as a CSV where there is no information about whether a field should be considered as an integer or string when it is formatted into a Pandas dataframe for example. Encoding the field into the wrong format can lead to terrible errors like the infamous MRN zero-padding error. 

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| field1 | field1 description | ID or Categorical Variable or Continuous Variable or Mixed Field or Natural Language Description | integer or float or string or binary |
| field2 | field2 description | ID or Categorical Variable or Continuous Variable or Mixed Field or Natural Language Description | integer or float or string or binary |
| field3 | field3 description | ID or Categorical Variable or Continuous Variable or Mixed Field or Natural Language Description | integer or float or string or binary |

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

# Table Name 

<b>Path:</b> cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean <br/>
<b>Table Type:</b> Part Static (some table in lineagre tree are static and some are live) <br/>
<b>Date created or last updated:</b> 2025/10/08 <br/>

<b>[Lineage](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.sql#lineage)</b>

<b>Summary Statistics:</b>

<b>counts of key data elements</b> 

[sql](pathology-data-mining/sql/impact_block_matched_slides_clean.sql#sql14)
 42,066 distinct patients 
 45,373 distinct S-numbers 
 45,817 distinct M-numbers


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

Identify primary key(s). 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| field1 | field1 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary | YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field2 | field2 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field3 | field3 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |

## Notes <a name="notes"></a>
Verifiable invariants guarding the consistency of the data (or lack of, if data is noisy). Notes are intended to save the user a significant amount of time in querying and understanding the dataset.  

For example, a mention of a field that contains empty strings or null values may be presented as a rule. Conversely, if a field is guaranteed not to have empty or null values, this may also be presented as a rule if knowledge of this guarantee could be useful to the user of the dataset. 

Examples of consistency checks that one can run in order to generate meaningful notes. 

<b>one-one mapping guarantee</b>. To test for this guarantee, it is sufficient to test each id for uniquenes. i.e. there are no duplicates. For example, if ID1<-->ID2 is expected to have a one-one mapping, then all counts should be one for the following two queries. If there are violations to this guarantee, then it should be reported. 
  ```
    SELECT <ID1>, count(<ID1>) as ct FROM <TABLE> GROUP BY <ID1> ORDER BY ct DESC -- all counts should be 1
    SELECT <ID2>, count(<ID2>) as ct FROM <TABLE> GROUP BY <ID2> ORDER BY ct DESC -- all counts should be 1
  ```
<b>many-to-one relationship guarantee</b>. To test for this guarantee, it is sufficient to test the many-many relationship in both directions. For example, if ID1<-->ID2 has a many-many relationship such that many ID1s map to many ID2s, then the following queries should yeild the stated results. If there are violations to this guarantee, then it should be reported. 

   ```
   SELECT <ID1>, count(DISTINCT <ID2>) as ct FROM <TABLE> GROUP BY <ID1> HAVING ct > 1 ORDER BY ct DESC  -- at least one ID1 should match to many distinct ID2s 

   SELECT <ID2>, count(DISTINCT <ID1>) as ct FROM <TABLE> GROUP BY <ID2> HAVING ct > 1 ORDER BY ct DESC  -- at least one ID2 should match many distinct ID2s
   ```
If say ID1 matches to many non-disctinct ID2s, and vice versa with the query below, then the relationship between ID1 and ID2 is not a defining relationship. One or more identifiers or fields may need to be considered in conjuction with ID1 and ID2 for form a 'unique together relationship' that can then be formally defined as a one-many relationship. 

- <b>many-many relationship guarantee</b> <TBD>


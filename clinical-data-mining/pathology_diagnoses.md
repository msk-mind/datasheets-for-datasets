# Pathology Diagnosis

<b>Path:</b> `"phi_data_lake"."cdm-data".pathology."table_pathology_surgical_samples_parsed_specimen.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-07-10` <br/>

<b>Lineage:</b> 

`CDM NLP Processes` <br/>
|_ ["phi_data_lake"."cdm-data".pathology."table_pathology_surgical_samples_parsed_specimen.tsv"](https://tlvidreamcord1:9047/new_query?context=%22phi_data_lake%22&queryPath=%5B%22phi_data_lake%22%2C%22cdm-data%22%2C%22pathology%22%2C%22table_pathology_surgical_samples_parsed_specimen.tsv%22%5D) <br/>

<b>Summary Statistics:</b>

Total number of rows: 860,086 <br/>
Total number of accessions: 345,279 <br/>
Total number of unique parts: 860,086 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

NLP parsed data elements from pathology reports. Provides diagnosis notes for each part for each surgical accession.

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| `ACCESSION_NUMBER` |  Accession number | ID | string |
| `PATH_DX_SPEC_NUM` | Part Number of tissue examined | ID | string |
| `PATH_DX_SPEC_TITLE` | Brief description of the tissue from which this part was taken | description | string |
| `PATH_DX_SPEC_DESC` | The pathologists's detailed description of this tissue| description | string |



## Rules <a name="rules"></a>




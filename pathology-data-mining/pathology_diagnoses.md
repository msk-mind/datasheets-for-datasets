# Pathology Diagnosis (PDM)

<b>Path:</b> `"phi_data_lake"."pdm-data"."surgical_specimen_diagnoses.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-07-10` <br/>

<b>Lineage:</b> 

`CDM NLP Processes` <br/>
|_ ["phi_data_lake"."pdm-data"."surgical_specimen_diagnoses.tsv"](https://tlvidreamcord1:9047/new_query?context=%22phi_data_lake%22&queryPath=%5B%22phi_data_lake%22%2C%22pdm-data%22%2C%22surgical_specimen_diagnoses.tsv%22%5D) <br/>

<b>Summary Statistics:</b>

Total number of rows: 4,372,130 <br/>
Total number of accessions: 1,828,323 <br/>
Total number of unique parts: 4,372,130 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

NLP parsed data elements from pathology reports. Provides diagnosis notes for each part for each surgical accession.  This table differs from the corresponding CDM table in that it covers surgical pathology reports from all patients, while the [CDM table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_diagnoses.md) only covers patients who've had IMPACT sequencing.

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




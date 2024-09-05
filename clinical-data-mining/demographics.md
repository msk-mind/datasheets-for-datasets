# Demographics

<b>Path:</b> `"phi_data_lake"."cdm-data".demographics."ddp_demographics.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage: ([SQL](sql/demographics.sql))</b> 

`CDM NLP Processes` <br/>
|_ `"phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"` <br/>

<b>Summary Statistics:</b>

Total number of rows: 121,855 <br/>
Total number of unique patients: 121,855 <br/>

1. [Description ](#description)
2. [Assumptions ](#assumptions)
3. [Vocabulary \& Encoding ](#vocabulary--encoding)
4. [Notes ](#notes)

## Description <a name="description"></a>

Provides a mapping between MRN and the patient's demographics

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

Reference CDSI documentation - [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| `MRN` | Medical Record Number, a unique identifier per patient  | ID | string |
| `PT_BIRTH_DTE` | Date of patient's birth | date | string |
| `PT_DEATH_DTE` | Date of patient's death  | date | string |
| `MRN_CREATE_DTE` | Date MRN was assigned to patient(?)  | date | string |
| `GENDER` | Gender of the patient | `MALE` or `FEMALE` | string |
| `MARITAL STATUS` | Marital status of the patient | `SINGLE`, `MARRIED`, `DIVORCED`, or `WIDOWED` | string |
| `RELIGIION` | Religion of the patient |  | string |
| `RACE` | Race of the patient |  | string |
| `ETHNICITY` | Ethnicity of the patient |  | string |
| `CURRENT_AGE_DEID` | Age of the patient | age (in years) | string |


## Notes <a name="notes"></a>

1. If a date does not exist (for example, if the patient is alive) the field will contain empty text.
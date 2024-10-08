# DDP ID Mapping 

<b>Path:</b> `"phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

`CDM NLP Processes` <br/>
|_ ["phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"](https://tlvidreamcord1:9047/new_query?context=%22phi_data_lake%22&queryPath=%5B%22phi_data_lake%22%2C%22cdm-data%22%2C%22id-mapping%22%2C%22ddp_id_mapping_pathology.tsv%22%5D) <br/>

<b>Summary Statistics:</b>

Total number of rows: 199,989 <br/>
Total number of unique patients: 101,377 <br/>
Total number of unique IMPACT sample_ids: 199,986 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Provides a mapping between MRN, DMP_ID and IMPACT SAMPLE_ID. 

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

Reference CDSI documentation - [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| `MRN` | Medical Record Number, a unique identifier per patient  | ID | string |
| `DMP_ID` | MSK IMPACT Patient ID assigned by Department of Molecular Pathology  | ID | string |
| `SAMPLE_ID` | Identifies an IMPACT sample  | ID | string |


## Rules <a name="rules"></a>

1. MRNs must be zero padded to eight digits. (They are compared as strings, not integers.)
2. A single MRN can have multiple IMPACT samples associated with it.
3. A given MRN is expected to correspond to a unique DMP_ID, but there are rare exceptions.




# Pathology Reports 

<b>Path:</b> `"phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

`CDM NLP Processes` <br/>
|_ ["phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"](https://tlvidreamcord1:9047/new_query?context=%22phi_data_lake%22&queryPath=%5B%22phi_data_lake%22%2C%22cdm-data%22%2C%22pathology%22%2C%22table_pathology_impact_sample_summary_dop_anno.tsv%22%5D) <br/>

<b>Summary Statistics:</b>

Total number of rows: 200,451 <br/>
Total number of unique patients: 101,605 <br/>
Total number of unique IMPACT sample_ids: 200,448 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Notes](#notes)


## Description <a name="description"></a>

NLP parsed data elements from pathology reports. Provides source accession number and dates of procedures for a given IMPACT sample extracted from pathology reports.

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

Reference CDSI documentation - [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| `MRN` | Medical Record Number, which uniquely identifies a patient  | ID | string |
| `SAMPLE_ID` | Identifies an IMPACT sample  | ID | string |
| `ACCESSION_NUMBER_DMP` |  Accession number from a DMP report | ID | string |
| `SPECIMEN_NUMBER_DMP` | Specimen Number of IMPACT Sample indicated in molecular pathology report (DMP report)  | ID | string |
| `SOURCE_ACCESSION_NUMBER_0` | Original pathology report accession number containing specimen used for IMPACT sequencing  | ID | string |
| `SOURCE_SPEC_NUM_0` | Specimen Number (Part number) in Source Accession Number used for IMPACT sequencing    | ID | string |
| `SOURCE_ACCESSION_NUMBER_0b` | Original pathology report accession number containing specimen used for IMPACT sequencing   | ID | string |
| `SOURCE_SPEC_NUM_0b` | Specimen Number (Part number) in Source Accession Number used for IMPACT sequencing | ID | string |



## Notes <a name="notes"></a>

1. MRNs are not zero padded, so they should not be matched to MRNs in other tables.
2. A single MRN can have multiple IMPACT samples associated with it.
3. Multiple IMPACT samples can be collected from a single procedure.
4. Many samples may have both a regular accession number and a DMP accession number.




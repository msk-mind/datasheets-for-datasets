# CDM Pathology Report Accession Table

Late updated 2024-05-20


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

### Motivation
The purpose of this table is to associate pathology reports and surgeries with MSK-IMPACT samples. 

### How was this data put together? 
For patients that receive MSK-IMPACT sequencing, we check to see if there is a surgical pathology report reference in the DMP report via regex. If available, then we have
access to the surgical accession number (`SOURCE_ACCESSION_NUMBER`) and the tissue specimen number (`SOURCE_SPEC_NUM`) associated with each MSK-IMPACT sample. 

### Access
This data can be accessed here: `phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"` 

### How should this data be used?

This data should be used to associated pathology reports with MSK-IMPACT samples. 

### How often is this data updated
This data is updated nightly. 

### What does each row represent 
Each row represents an MSK-IMPACT sample, and contains the corresponding DMP report accession, the MRN and, if referenced in the DMP report, the surgical pathology report and part number associated with the IMPACT sample. 

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

See CDSI documentation

- [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)


## Rules <a name="rules"></a>

#### How many rows are there in total? 
There are 197,836 rows corresponding to 197,834 samples from 100,486 patients. 

```
-- Row count
select count(*)  FROM phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"

-- sample Count
select count(DISTINCT(SAMPLE_ID))  FROM phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"

-- patient Count
select count(DISTINCT(MRN))  FROM phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"
```
There are a few caveats:

- Two samples are refer to multiple MRNs. This is a known bug in the data that needs to be resolved before use. This explains the discrepency between the row and sample counts. 
- This data also contains patients who have received MSK ACCESS and patients partially consented to 12-245. This explains why the sample and patient count is higher than expected. 



# Pathology Reports 

<b>Path:</b> `"phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"` <br/>
<b>Table Type:</b> `Live` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

`CDM NLP Processes` <br/>
|_ `"phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"` <br/>

<b>Summary Statistics:</b>

Total number of rows: 6,295,662 <br/>
Total number of unique patients: 369,088 <br/>
Total number of unique slides: 6,192,174 <br/>

1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

Contains data elements extracted from the pathology reports. Each row represents an MSK-IMPACT sample.

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



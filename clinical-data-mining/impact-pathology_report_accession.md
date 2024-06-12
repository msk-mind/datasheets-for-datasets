# IMPACT Table - CDM Pathology Report Joined Table

Late updated 2024-05-20

1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

### Motivation
In order to match MSK IMPACT samples with pathology slides, we need to first associate each MSK IMPACT sample with its corresponding pathology report and part. In order to do this, we merge the table containing IMPACT samples (`"pathology-data-mining"."impact_slide".impact`) with the table containing the pathology report accessions and part for each IMPACT sample (`phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"`)

### Access

This data can be accessed here: `"pathology-data-mining"."impact_slide"."impact-path_report_accession"`

### How should this data be used?
This data should be used to associate MSK IMPACT samples with the surgical pathology report and part.

### How often is this data updated
This data is updated daily, as the source tables are updated.

### How was this data constructed
To put together this data, we first removed two samples from the pathology report table that correspond to multiple MRNs (see [ ]  for details). Then, after joining the two source tables, we exclude rows that don't have either `SOURCE_ACCESSION_NUMBER` or `SOURCE_SPEC_NUM`, meaning that the molecular pathology report did not reference the surgical pathology report. 

See below for the full query:

```
SELECT*
FROM (
  SELECT *
  FROM (
    select * from phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv" where SAMPLE_ID not in ( 'P-0000000-N-VR1','P-0032211-T02-IM6')
  ) nested_0
) nested_0
 INNER JOIN "pathology-data-mining"."impact_slide"."impact" AS "join_impact" ON nested_0.SAMPLE_ID = "join_impact".SAMPLE_ID where SOURCE_ACCESSION_NUMBER_0 <> '' and SOURCE_SPEC_NUM_0 <> ''
 ```

### What does each row represent 

Each row represents an IMPACT sample and the corresponding surgical pathology accession and part, along side the OncoKB alterations and other clinical data at the patient level.

## Assumptions <a name="assumptions"></a>
None

## Vocabulary & Encoding <a name="vocabulary"></a>

See CDSI documentation

- [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)


## Rules <a name="rules"></a>

#### How many rows are there in total? 

There are a total of 88,785 rows, corresponding to data from 88,785 samples from 75,842 patients. 

```
-- Row count
select count(*)  FROM "pathology-data-mining"."impact_slide"."impact-path_report_accession"

-- sample Count
select count(DISTINCT(SAMPLE_ID))  FROM "pathology-data-mining"."impact_slide"."impact-path_report_accession"

-- patient Count
select count(DISTINCT(PATIENT_ID))  FROM "pathology-data-mining"."impact_slide"."impact-path_report_accession"

```
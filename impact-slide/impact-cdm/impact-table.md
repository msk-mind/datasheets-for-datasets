# IMPACT - MSK IMPACT Table

Late updated 2024-05-20

Source code: 


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

This is a table that combines data sources from cBioPortal. It combines patient level information and sample level information for patients w/ tumors sequenced for MSK IMPACT.

### Motivation
This table serves as an intermediate table used to match IMPACT samples with pathology slides.  

### Access
This table can be accessed here: `"pathology-data-mining"."impact_slide".impact"`

### How should this data be used?

This data should be used if you need access to patient and sample level information. 

### How often is this data updated

This data is updated nightly via cron, pulled from two github sources that

- https://github.mskcc.org/cdsi/msk-impact/tree/master/msk_solid_heme`
- https://github.mskcc.org/cdsi/oncokb-annotated-msk-impact/blob/main/data_clinical_sample.oncokb.txt.gz


### What does each row represent 

Each row represents a single MSK-IMPACT sample w/ OncoKB annotated variants and the corresponding patient level clinical data. 

## Assumptions <a name="assumptions"></a>

#### Basic Filtering
This data was subject to basic filtering for the purposes of merging with pathology report data. Because the purposes of this dataset is to merge with pathology slides, we exclude cf-DNA samples from the main IMPACT cohort.

## Vocabulary & Encoding <a name="vocabulary"></a>

See cBioPortal/CDSI Documentation

- [CDM Codebook](https://docs.google.com/spreadsheets/d/1po0GdSwqmmXibz4e-7YvTPUbXpi0WYv3c2ImdHXxyuc/edit#gid=187767892)

## Rules <a name="rules"></a>

#### How many rows are there in total? 

There are 112676 rows, corresponding to data from 112,676 unique samples from  85,160 patients. 

```
-- Row count
select count(*)  FROM "pathology-data-mining"."impact_slide"."impact"

-- image_id Count
select count(DISTINCT(image_id))  FROM "pathology-data-mining"."impact_slide"."impact"

-- patient Count
select count(DISTINCT(mrn))  FROM "pathology-data-mining"."impact_slide"."impact"



```
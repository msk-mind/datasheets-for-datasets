
**NOTE: This datasheet/dataset is deprecated please use `slide_inventory.md`**

# Master Slide Inventory

Last updated 2024-07-08

1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)

## Description <a name="description"></a>

### Motivation

This dataset lists the WSI data that we have on our local storage systems.  (As of June
2024, that generally means `/gpfs/mskmind_emc/data_large/`)  Each row of this table represents a
single slide and includes data such as the slide's id, project, magnification, cancer
type, and its storage location.

### How was this data put together?

### How should this data be used?

### Access
This dataset is available in Dremio at
`"pathology-data-mining"."master_slide_inventory.md"`

### How often is this data updated
This table is updated manually when new slides are received from the pathology department.
Currently, that's about once a week.


## Assumptions <a name="assumptions"></a>


## Vocabulary & Encoding <a name="vocabulary"></a>


## Rules <a name="rules"></a>


## Statistics

There are a total of 469,703 rows, corresponding to data from 65,892 samples from 56,858 patients. In total, there are 461,184 slides. 

```
-- Row count
select count(*)  FROM "pathology-data-mining"."impact_slide"."impact_slide"

-- sample Count
select count(DISTINCT(SAMPLE_ID))  FROM "pathology-data-mining"."impact_slide"."impact_slide"

-- patient Count
select count(DISTINCT(PATIENT_ID))  FROM "pathology-data-mining"."impact_slide"."impact_slide"

-- slide Count
select count(DISTINCT(IMAGE_ID))  FROM "pathology-data-mining"."impact_slide"."impact_slide"


```





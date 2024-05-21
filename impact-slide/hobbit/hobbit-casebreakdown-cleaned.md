# HoBBIT - Cleaned

Late updated 2024-05-16

1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)

## Description <a name="description"></a>

### Motivation
One of the problems with working with the source HoBBIT table (`"hobbit-poc"."case_breakdown"`) directly is that multiple slides have duplicate entires. To fix this, we constructed a table that has been cleaned so that each row corresponds to a single slide. 

### How was this data put together?
There are  6,295,662 rows, coorresponding to data from 369,088 unique patients. There are 6,192,174 unique `image_id`s in total. A subset of the duplicates are entirely duplicated rows. However, in extreme minority of cases, the same `image_id` will have different collection and digitization metadata. These slides need to be removed entirely from the database prior to any use.

```
-- dropping entirely duplicated rows (keeping one)
select DISTINCT *  FROM "hobbit-poc"."case_breakdown"

-- dropping all duplicated rows (keeping one), and all rows that have the same image_id, but different digitization and collection metadata

select * from (select DISTINCT * from "hobbit-poc"."case_breakdown") where image_id not in 
(select image_id from (select DISTINCT * from "hobbit-poc"."case_breakdown") GROUP BY image_id having count(image_id) <> 1)

```
After performing the data cleaning operations, we are left with 6,191,382 rows, 6,191,382 slides from 369,072 patients. 

### How should this data be used?

The most immediate use of this data is to find pathology slides associated with a set of patients. More specifically, this data has been matched with IMPACT data to associate pathology slides with the closest corresponding IMPACT sample. In generally, researchers may use this table to search for slides of interested or slides that have been scanned while they build their patient cohorts.  


### Access
The table can be accessed via dremio here: `"pathology-data-mining"."impact_slide"."case_breakdown_cleaned"`

If you do not have permissions on this table, please contact the engineering team. 


### How often is this data updated?

This data is updated live, as new slides are digitized and entered into the source hobbit case breakdown (``"hobbit-poc"."case_breakdown"`)

## Assumptions

#### 
This process assumes the following:

- that entirely duplicated rows can be safely removed, and that their duplication doesn't indicate anything about issues related to the sample collection process
- That the slides duplicated slides that only have partially duplicated rows do indicate an issue related to the sample collection or data entry problem, and can not be used in analysis. 


## Vocabulary & Encoding <a name="vocabulary"></a>


The vocabulary and encoding is the same in the parent table, see See hobbit-casebreakdown.md for more details.


## Rules

#### How many rows are there in total?
There are 6,191,382 rows, corresponding to data from 369,072 unique patients. There are 6,191,382 unique `image_id`s in total.

```
-- Row count
select count(*)  FROM "pathology-data-mining"."impact_slide"."case_breakdown_cleaned"

-- image_id Count
select count(DISTINCT(image_id))  FROM "pathology-data-mining"."impact_slide"."case_breakdown_cleaned"

-- patient Count
select count(DISTINCT(mrn))  FROM "pathology-data-mining"."impact_slide"."case_breakdown_cleaned"



```

The removal of these patients does not drastically change the distribution of any of the fields.
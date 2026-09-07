# impact_patient_data

<b>Path:</b> cdsi_res_deid.pdm_mosaic.impact_patient_data <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> In progress <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

* There are 80,632 IMPACT samples in this cohort

* The number of samples associated with each race is:
  - White ...................................... 61826
  - Asian-Far East/Indian Subcont ..............  6458
  - Black or African American ..................  5630
  - American Indian or Alaska Native ...........   112
  - Native Hawaiian or Other Pacific Islander ..    43
  - Unknown ....................................  4066
  - Other ......................................  2497

* The number of samples associated with each ethnicity is:
  - Non-Spanish; Non-Hispanic ................ 70179
  - Spanish NOS; Hispanic NOS, Latino NOS ....  5737
  - Unknown ..................................  4708
  - Other ....................................     8

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This dataset reports some basic demographic data for the IMPACT patients in the mosaic study.

Patients are categorized into five races, and an "other" category.  If the race is not known, that's's recorded explicitly.

The ethnicity reported here is basically just Hispanic vs non-Hispanic.

The de-identified age is the patient's age in years, if they're between 18 and 90 years
old.  Ages outside that range are capped at 89 and 18 years.


### Vocabulary <a name="vocab"></a>

The SAMPLE_ID is the primary key, here.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| SAMPLE_ID | IMPACT sample ID | ID | string |   |
| RACE | the patient's race | categorical | string | (1) |
| ETHNICITY | Hispanic ethnicity | categorical | string | (2) |
| CURRENT_AGE_DEID | the patient's age | number | string |  |

(1) The RACE is recorded as one of White", "Asian-Far East/Indian Subcont", "Black or African American", "American Indian or Alaska Native", "Native Hawaiian or Other Pacific Islander", "Unknown", or "Other".

(2) The Ethnicity is recorded as one of "Non-Spanish; Non-Hispanic", "Spanish NOS; Hispanic NOS, Latino NOS", "Unknown", or "Other".



## Notes <a name="notes"></a>

1. The demographics data presented here are not mapped to patient IDs, but to IMPACT sample IDs.


## Queries for Summary Statistics

#### Breakdown by Race

    SELECT
      RACE,
      COUNT(*) as patients 
    FROM cdsi_demo.pollardw.impact_patient_data
    GROUP BY RACE
    ORDER BY patients DESC


## Breakdown by Ethnicity

    SELECT
      ETHNICITY,
      COUNT(*) as ethnicity_count 
    FROM cdsi_demo.pollardw.impact_patient_data
    GROUP BY ETHNICITY
    ORDER BY ethnicity_count DESC

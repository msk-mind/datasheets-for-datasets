# pre_post_treatment_slides_v2

<b>Path:</b> cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2 <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-12 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

* There are 1,696 distinct DMP_IDs, and 1.696 rows (triples)

* There are 176 distinct Oncotree codes.
* The ten most common Oncotree codes are
  - LUAD    275
  - BLCA    188
  - IDC     170
  - COAD    101
  - PAAD     86
  - PRAD     82
  - NBL      46
  - READ     42
  - BRCA     41
  - GBM      35

* Most samples are for primary tumors.  The breakdown of sample types is
  - Primary           1177
  - Metastasis         486
  - Local Recurrence    19
  - Unknown             14

* There are 5019 treatments in aggregate across this dataset,
  - 4483 treatments are chemotherapy
  - 537 treatments are biologic
* The ten most common treatment agents are
  - Carboplatin   464
  - Cisplatin     319
  - Gemcitabine   312
  - Fluorouracil  309
  - Paclitaxel    307
  - Leucovorin    283
  - Oxaliplatin   253
  - Pemetrexed    244
  - Irinotecan    236
  - Capecitabine  217

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This table differs from `pre_post_treatment_slides_v1` in two ways:

1. The sample type (primary vs metastatic) is now included in the sample STRUCTS
2. The sample ID is now named `sample_id`, rather than just `sample`.


This dataset was created to let researchers find slides of a tumor before and after it has
undergone treatment.

Cases are presented as "triplets", consisting of 

1. slides from an IMPACT-sequenced tissue part, obtained before treatment
2. a treatment regimen, and
3. slides from an IMPACT-sequenced tissue part, obtained after treatment.

The table reports surgical dates for the pre- and post-treatment accessions, and start and
stop dates for each treatment.  It lists sample ids the pre- and post-treatment samples,
and image ids for all H&E slides created from either of those samples.

Currently, only cases where the pre- and post-treatment tissue samples have the same
Oncotree code are included.

Treatments are grouped into "regimens", which are one or more treatments that start within
90 days of each other.  Typically, a triplet has only one treatment regimen, but any
number are supported.


### Vocabulary <a name="vocab"></a>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| DMP_ID | Patient ID | ID | string | string |
| samples_deid | pre and post-treatment samples | Mixed | Array of structs |  |
| treatment_regimens_deid | treatments administered to patient | Mixed | Array of arrays of structs |  |

The `DMP_ID` is (effectively) the primary key.

Each `samples_deid` value is an array of exactly two STRUCTs, representing the pre-treatment
sample and the post-treatment sample.

Each sample STRUCT has the keys,

    sample_id ............... the IMPACT sample ID (string)
    date_accession_offset ... the relative date for the surgery (integer)
    oncotree_code ........... the Oncotree code for the tumor (string)
    sample_type ............. the sample type (primary or metastatic) (string)
    images .................. an array of image_ids (strings)
    part_description ........ the part description from pathology (string)

Each `treatments_deid` value is an array of "regimens", and each regimen is an array of
STRUCTs, each representing treatment by a particular chemical or biological agent.

The treatment STRUCTs have the following keys:

    start_date_offset .... treatment start date, days after anchor (integer)
    stop_date_offset ..... treatment stop date, days after anchor (integer) 
    agent ................ agent name (string)
    subtype .............. "Chemo" or "Biologic" (string)


## Notes <a name="notes"></a>

1. This table only describes a single triplet for each patient.  In a more
   general form of this dataset, a single patient might have multiple triples.
   They could either have muultiple tumors, or multiple sequencing events for a
   single tumor, with additional treaments in between them.

2. Dates are presented as the number of days after an arbitrary anchor date,
   chosen separately for each patient.  This is how dates are de-identified.


## Queries for summary statistics <a name="queries"></a>

#### Count the Oncotree codes

    SELECT
      samples_deid[0].oncotree_code AS ONCOTREE_CODE,
      COUNT(*)
    FROM cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2
    GROUP BY samples_deid[0].oncotree_code
    ORDER BY COUNT(*) DESC


#### Count the sample types

    SELECT
      samples_deid[0].sample_type AS SAMPLE_TYPE,
      COUNT(*)
    FROM cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2
    GROUP BY samples_deid[0].sample_type
    ORDER BY COUNT(*) DESC


#### Count the treatment subtypes

    WITH 
    ct1 AS (
      SELECT a1
      FROM cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2 t1
      LATERAL VIEW explode(t1.treatment_regimens_deid) AS a1
    ),
    ct2 AS (
      SELECT a2.subtype AS SUBTYPE
      FROM ct1
      LATERAL VIEW explode(ct1.a1) AS a2
    )
    SELECT 
        SUBTYPE, COUNT(*) as count
        FROM ct2
        GROUP BY SUBTYPE
        ORDER BY count DESC


#### Count the treatment agents

    WITH ct1 AS (
      SELECT a1
      FROM cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2 t1
      LATERAL VIEW explode(t1.treatment_regimens_deid) AS a1
    ),
    ct2 AS (
      SELECT a2.agent AS AGENT
      FROM ct1
      LATERAL VIEW explode(ct1.a1) AS a2
    )
    SELECT AGENT, COUNT(*) as count
    FROM ct2
    GROUP BY AGENT
    ORDER BY count DESC


#### Days between pre-treatment and post-treatment accessions

    WITH t1 AS (
      SELECT
        DMP_ID,
        samples_deid[1].date_accession_offset - samples_deid[0].date_accession_offset AS accession_interval
      FROM cdsi_res_deid.pdm_mosaic.pre_post_treatment_slides_v2
      ORDER BY accession_interval DESC
    ),
    t2 AS (
      SELECT
        MIN(accession_interval) AS min_accession_interval,
        MEAN(accession_interval) AS mean_accession_interval,
        MAX(accession_interval) AS max_accession_interval,
        stddev(accession_interval) AS stddev_accession_interval
      FROM t1
    )
    SELECT * FROM t2


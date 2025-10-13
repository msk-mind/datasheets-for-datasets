# impact_block_matched_slides_clean

<b>Path:</b> cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean <br/>
<b>Table Type:</b> Part Static (some table in lineagre tree are static and some are live) <br/>
<b>Date created or last updated:</b> 2025/10/08 <br/>

<b>[Lineage](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#lineage)</b>

<b>Summary Statistics:</b>

<b>counts of key data elements</b> 

[[SQL14]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql14) <br/>
 42,066 distinct patients <br/>
 45,373 distinct S-numbers <br/>
 45,817 distinct M-numbers <br/>
 [todo: list distinct number of block matches and compare to about 87k sample ids that are part matched with sql]


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This dataset matches IMPACT samples to H&E images down to a [block](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/hobbit-casebreakdown.md#description). This table brings together 923,511 unique surgical events (represented as S-number) [[SQL2]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql2) in the [case_breakdown](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/hobbit-casebreakdown-cleaned.md) table with about 137,000 unique sample_ids in the [IMPACT table](https://github.com/msk-mind/datasheets-for-datasets/blob/main/impact/data_clinical_sample.oncokb.md). Each surgical event may result in the resection of a number of tissue parts from a number of sites within the patient’s body. Many tissue parts may be taken from the same site. The part number (part_inst) uniquely identifies the site for a single surgical event [[SQL3]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql3). The M-number uniquely identifies a molecular case sent for sequencing. In case breakdown_cleaned table, there is no association between S-number and M-number because both exist in the same column (`specnum_formatted`) and do not share common `datetime_accessions`. i.e. they cannot be related through any attribute like date of surgery for example. The case_breakdown table has 127,048 unique M-numbers in the case breakdown table [[SQL4]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql4). In order to find the association between S-number and M-number, and consequently image_id (from its S-number association) to sample_id (from its M-number association) at the block level, the S-number is mapped to the M-number via the [anno](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) table. The (copath)[https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/copath_molecular_links_cleaned.md] table provides a mapping from the S-number to block-ids. Together, the casebreakdown table, the anno table, the copath tablem, and the IMPACT table, bring together image_id, block-id, sample_id to make up the block matched dataset.  

### Vocabulary <a name="vocab"></a>

The vocabulary of a dataset is comprised of its variables, (or field names) the description (or semantics) of 
these variables, their field type, data type and format. An unambiguous field description
is very important for consistent interpretation of the field. The description must also include units where applicable. 
Equally important are the field types. The field type provides the semantics behind the variable. The data type specifies the encoding that should be used for the variable when the dataset is loaded into memory. The encoding is critical because the data may be presented in a file format like CSV, which carries no information about the encoding, forcing data loaders (like Pandas) to guess.  Writing a field in the wrong format can lead to terrible and unexpected errors, like the infamous MRN zero-padding error where the preceeding zeros in an MRN are stripped if the field is encoded as an integer instead of a string. The field format may be used to further describe or elaborate on categorical variables that have a finite set of possible values and semantics behind each value. 

Identify primary key(s). 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| field1 | field1 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary | YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field2 | field2 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |
| field3 | field3 description | ID *or* Categorical *or* Continuous *or* Mixed *or* Natural Language Description | integer *or* float *or* string *or* binary |YYYYMMDD, 0, 1, True, False etc. (and corresponding description of each value) |

## Notes <a name="notes"></a>

1. An M-number may be associated with multiple IMPACT sample_ids for the same S-number [[SQL6]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql6) for a small fraction of the surgical events (less than 100). For the large majority of IMPACT sample_ids, M-numbers and sample_ids have a 1:1 relationship for a given surgical event [[sql7]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql7).

2. An S-number (surgical even) may be associated with multiple M-numbers (molecular case) for about 11,000 cases. The majority of the cases show S-number to have a 1:1 relationship with M-number [[sql8]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql8)

<b>Anno Table</b><br/>
3. There are 97,000 distinct sample_ids associated with S-numbers and M-numbers in the anno table [[sql9]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql9)

4. There are 85,251 distinct S-numbers in the anno table [[sql10)]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql10)

5. There are 96,936 distinct M-numbers in the anno table [[sql11]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql11)

<b>Copath Table</b><br/>
6. There are 105,266 M-numbers associated with S_numbers in copath table [[sql12]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql12)

7. Most M-numbers have a 1:1 relationship with block_id in the copath table but a small fraction (<200) have multiple block ids [[sql13]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql13). These m-numbers are associated with different blocks (possibly also parts) from the same s-number.

<b>impact_block_matched_table</b><br/>

8. Every sample_id is associated with one and only one block_id, and there are a few blocks (64) that are used in more than one IMPACT sample [[slq15]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql15)

9. problem: There are only 45,817 distinct sample_ids associated with non-null block_ids from copath (~47% of sample_ids in anno table) 

10. There are 40,599 copath block ids that don’t match hobbit block ids as is needed to bring (image_id, M-number, block-id) together [[sql16]](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact_block_matched_slides_clean.md#sql16). The reason for this is because the block ids either don’t match or the copath M-number does not associate with an IMPACT M-number (i.e. the copath M-numbers are outside of the IMPACT cohort). There are a small fraction of exceptions though - for example these block ids and M_numbers match but don't feature in the matching. It is unclear why these block ids don’t match.
--S18-75876/1 M18-38538
--S17-4108/1  M17-10759


## Todos <a name="todos"></a>
1. Filter out IHCs from this data and update datasheet
2. Check filter for impact assays and update datasheet 
3. when whitespaces are replaced in the block_Id, there are fewer distinct sample_ids in the impact_block_match table - like 32,859 instead of 45,817. This implies that whitespace is creating noise and needs to be removed. Here is an example lineage that removes whitespace

```sql
WITH slide_dx AS (
  SELECT
    *,
    CASE
      WHEN
        BLOCK_LABEL IS NOT NULL
        AND REPLACE(BLOCK_LABEL, ' ', '') <> ''
        THEN
        REPLACE(ACCESSION_NUMBER, ' ', '') || '/' || REPLACE(PART_NUMBER, ' ', '') || '-' || REPLACE(BLOCK_LABEL, ' ', '')
      ELSE REPLACE(ACCESSION_NUMBER, ' ', '') || '/' || REPLACE(PART_NUMBER, ' ', '')
    END AS BLOCK_ID_HOBBIT
  FROM
    cdsi_prod.pathology_data_mining.slides_with_diagnosis where ACCESSION_NUMBER like 'S%'
),
copath AS (
  SELECT
    REPLACE(block_id, ' ', '') as BLOCK_ID_COPATH,
    *
  FROM
    cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned WHERE block_id like 'S%'
),
t5 AS (
  SELECT
    slide_dx.*,
    copath.m_number AS M_NUMBER_COPATH,
    copath.s_number AS S_NUMBER_COPATH,
    copath.part_number AS PART_NUMBER_COPATH,
    BLOCK_ID_COPATH
  FROM
    slide_dx
      INNER JOIN copath
        ON slide_dx.BLOCK_ID_HOBBIT = copath.BLOCK_ID_COPATH
),
t6 AS (
  SELECT
    MRN as MRN_PATH,
    SAMPLE_ID AS SAMPLE_ID_PATH,
    SOURCE_ACCESSION_NUMBER_0,
    CASE
      WHEN SOURCE_SPEC_NUM_0 IS NOT NULL THEN CAST(SOURCE_SPEC_NUM_0 AS INTEGER)
      ELSE NULL
    END AS SOURCE_SPEC_NUM_0,
    SOURCE_ACCESSION_NUMBER_0b,
    CASE
      WHEN SOURCE_SPEC_NUM_0b IS NOT NULL THEN CAST(SOURCE_SPEC_NUM_0b AS INTEGER)
      ELSE NULL
    END AS SOURCE_SPEC_NUM_0b,
    ACCESSION_NUMBER_DMP,
    CASE
      WHEN SPECIMEN_NUMBER_DMP IS NOT NULL THEN CAST(SPECIMEN_NUMBER_DMP AS INTEGER)
      ELSE NULL
    END AS SPECIMEN_NUMBER_DMP,
    DATE_SEQUENCING_REPORT,
    REPORT_CMPT_DATE_SOURCE_0,
    REPORT_CMPT_DATE_SOURCE_0b,
    DATE_OF_PROCEDURE_SURGICAL,
    DATE_OF_PROCEDURE_SURGICAL_EST,
    DOP_COMPUTE_SOURCE
  FROM
    cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean
  WHERE
    SAMPLE_ID not in ('P-0000000-N-VR1', 'P-0032211-T02-IM6')
),
t7a as (
  SELECT
    *
  FROM
    t5
      INNER JOIN t6
        ON t5.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0
        AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0
        AND t5.M_NUMBER_COPATH = t6.ACCESSION_NUMBER_DMP
),
t7b as (
  SELECT
    *
  FROM
    t5
      INNER JOIN t6
        ON t5.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0b
        AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0b
        AND t5.M_NUMBER_COPATH = t6.ACCESSION_NUMBER_DMP
),
t7c as (
  SELECT
    *
  FROM
    t5
      INNER JOIN t6
        ON t5.ACCESSION_NUMBER = t6.ACCESSION_NUMBER_DMP
        AND t5.PART_NUMBER = t6.SPECIMEN_NUMBER_DMP
        AND t5.M_NUMBER_COPATH = t6.ACCESSION_NUMBER_DMP
),
t7 AS (
  SELECT
    *
  FROM
    t7a
  UNION ALL
  SELECT
    *
  FROM
    t7b
  UNION ALL
  SELECT
    *
  from
    t7c
),
t8 AS (
  SELECT
    SAMPLE_ID AS SAMPLE_ID_IMPACT,
    PATIENT_ID AS PATIENT_ID_IMPACT,
    GLEASON_SAMPLE_LEVEL,
    PDL1_POSITIVE,
    MONTH_ADDED,
    WEEK_ADDED,
    CANCER_TYPE,
    SAMPLE_TYPE,
    SAMPLE_CLASS,
    METASTATIC_SITE,
    PRIMARY_SITE,
    CANCER_TYPE_DETAILED,
    GENE_PANEL,
    SO_COMMENTS,
    SAMPLE_COVERAGE,
    TUMOR_PURITY,
    ONCOTREE_CODE,
    MSI_COMMENT,
    MSI_SCORE,
    MSI_TYPE,
    INSTITUTE,
    SOMATIC_STATUS,
    ARCHER,
    CVR_TMB_COHORT_PERCENTILE,
    CVR_TMB_SCORE,
    CVR_TMB_TT_COHORT_PERCENTILE,
    PATH_SLIDE_EXISTS,
    MSK_SLIDE_ID,
    LEVEL_1,
    LEVEL_2,
    LEVEL_3A,
    LEVEL_3B,
    LEVEL_4,
    LEVEL_R1,
    LEVEL_R2,
    HIGHEST_LEVEL,
    HIGHEST_SENSITIVE_LEVEL,
    HIGHEST_RESISTANCE_LEVEL,
    LEVEL_Dx1,
    LEVEL_Dx2,
    LEVEL_Dx3,
    HIGHEST_DX_LEVEL,
    LEVEL_Px1,
    LEVEL_Px2,
    LEVEL_Px3,
    HIGHEST_PX_LEVEL,
    ONCOGENIC_MUTATIONS,
    `#ONCOGENIC_MUTATIONS`,
    RESISTANCE_MUTATIONS,
    `#RESISTANCE_MUTATIONS`,
    `#MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS`,
    `#MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS`,
    `#MUTATIONS`
  FROM
    cdsi_prod.pathology_data_mining.data_clinical_sample_oncokb
  WHERE
    SAMPLE_CLASS = 'Tumor'
    AND (
      GENE_PANEL = 'IMPACT341'
      OR GENE_PANEL = 'IMPACT410'
      OR GENE_PANEL = 'IMPACT505'
      OR GENE_PANEL = 'IMPACT468'
    )
),
t9 AS (
  SELECT
    *
  FROM
    t7
      INNER JOIN t8
        ON t7.SAMPLE_ID_PATH = t8.SAMPLE_ID_IMPACT
),
t10 AS (
  SELECT
    MRN AS MRN_CDM,
    MAX(DMP_ID) AS DMP_ID
  FROM
    cdsi_prod.cdm_idbw_impact_pipeline_prod.ddp_id_mapping_pathology
  GROUP BY
    MRN_CDM
  HAVING
    COUNT(DISTINCT DMP_ID) = 1
),
t11 AS (
  SELECT
    *
  FROM
    t9
      LEFT JOIN t10
        ON t9.PATIENT_ID_IMPACT = t10.DMP_ID
),
t12 as (
SELECT
   BLOCK_ID_HOBBIT, BLOCK_ID_HOBBIT RLIKE '^S[0-9]+-[0-9]+/[0-9]+-[0-9a-zA-Z-]+$' as result
FROM
  slide_dx 
),
t13 as (
SELECT
   BLOCK_ID_COPATH, BLOCK_ID_COPATH RLIKE '^S[0-9]+-[0-9]+/[0-9]+-[0-9a-zA-Z-]+$' as result
FROM
  copath 
)
select block_id_copath, m_number, s_number, part_number, s_blkdesig_label from copath
```
 
5. If there are normals, filter then out. Their sample_ids have an 'N' instead of a 'T' in them (they have M accession number, and dmp accession = dmp) and update datasheet.  

6. broken link https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/python/clean_copath.py
   
7. IM in the sample id stands for impact test - verify that the sample_ids in this dataset align with the assays chosen in the lineage - P-0106020-T01-IM7

8. Filter out any 'bsbsbs' mrns 

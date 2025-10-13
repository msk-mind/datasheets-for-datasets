##Lineage
WITH slide_dx AS (
  SELECT
    *,
    CASE
      WHEN
        BLOCK_LABEL IS NOT NULL
        AND TRIM(BLOCK_LABEL) <> ''
      THEN
        ACCESSION_NUMBER || '/' || PART_NUMBER || '-' || BLOCK_LABEL
      ELSE ACCESSION_NUMBER || '/' || PART_NUMBER
    END AS BLOCK_ID_HOBBIT
  FROM
    cdsi_prod.pathology_data_mining.slides_with_diagnosis
),
copath AS (
  SELECT
    *
  FROM
    cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned
),
t5 AS (
  SELECT
    slide_dx.*,
    copath.m_number AS M_NUMBER_COPATH,
    copath.s_number AS S_NUMBER_COPATH,
    copath.part_number AS PART_NUMBER_COPATH,
    copath.block_id AS BLOCK_ID_COPATH
  FROM
    slide_dx
      JOIN copath
        ON slide_dx.BLOCK_ID_HOBBIT = copath.block_id
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
    cdsi_prod.msk_impact_oncokb_annotated.data_clinical_sample_oncokb_raw
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
)
SELECT
  *
FROM
  t11

##SQL1
with t1 as (
  -- group S-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'S%' group by specnum_formatted, datetime_accession order by ct desc limit 100
)
-- check to see if there are any S-numbers that belong to more than one surgical date (ct>1). If not S-numbers identify a single surgical event
select specnum_formatted, count(specnum_formatted) as ct from t1 group by specnum_formatted order by ct desc

##SQL2
with t1 as (
  -- group S-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'S%' group by specnum_formatted, datetime_accession order by ct desc
)
select count(distinct specnum_formatted) from t1 

##SQL3
select mrn, specnum_formatted, part_inst, part_description, datetime_accession from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted = 'S15-23298'


##SQL4
with t1 as (
  -- group M-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'M%' group by specnum_formatted, datetime_accession order by ct desc
)
select count(distinct specnum_formatted) from t1 

##SQL5
select * from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where mrn = '35366573' and specnum_formatted LIKE 'S%' 

##SQL6
select * from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where ACCESSION_NUMBER_DMP ='M14-14980'

##SQL7
select SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP, count(SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP) as ct
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0
 like 'S%' and ACCESSION_NUMBER_DMP like 'M%' group by SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP order by ct desc

##SQL8
select SOURCE_ACCESSION_NUMBER_0, count(ACCESSION_NUMBER_DMP) as ct
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0
 like 'S%' group by SOURCE_ACCESSION_NUMBER_0 order by ct desc

##SQL9
select count(distinct SAMPLE_ID)
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

##SQL10
select count(distinct SOURCE_ACCESSION_NUMBER_0) from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

##SQL11
select count(distinct ACCESSION_NUMBER_DMP) from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

##SQL12
select count(distinct m_number) from cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned where s_number like 'S%' and isnotnull(block_id)


##SQL13
select m_number, count(block_id) as ct from cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned where s_number like 'S%' and isnotnull(block_id) group by m_number order by ct desc

##SQL14
select count(distinct MRN) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean
select count(distinct ACCESSION_NUMBER) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean
select count(distinct M_NUMBER_COPATH) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean 

##SQL15
-- every sample_id comes from a single block
with t1 as (
  select SAMPLE_ID_IMPACT, count(distinct BLOCK_ID_COPATH) as ct from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean group by SAMPLE_ID_IMPACT order by ct desc
)
select * from t1


-- There are a few blocks (64) that are used in multiple samples
with t1 as (
  select BLOCK_ID_COPATH, count(distinct SAMPLE_ID_IMPACT) as ct from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean group by BLOCK_ID_COPATH having ct > 1
)
select * from t1


## Sql16
select count(distinct block_id_copath) from copath left join cdsi_prod.pathology_data_mining.impact_matched_slides_clean as impact on copath.s_number = impact.ACCESSION_NUMBER WHERE isnull(impact.ACCESSION_NUMBER)

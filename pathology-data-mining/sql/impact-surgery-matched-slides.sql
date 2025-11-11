WITH t1 AS ( -- patients = 502,266
  SELECT
    mrn as MRN,
    specnum_formatted as ACCESSION_NUMBER,
    specclass_id,
    subspecialty,
    priority,
    reduced_priority,
    datetime_accession,
    signout_datetime,
    part_inst AS PART_NUMBER,
    part_designator,
    part_type,
    part_description,
    block_inst AS BLOCK_NUMBER,
    blkdesig_label AS BLOCK_LABEL,
    barcode,
    CASE
      WHEN stain_group IN ('H&E (Initial)', 'H&E (Other)') THEN 1
      ELSE 0
    END AS IS_HNE,
    CASE
      WHEN stain_group = 'IHC' THEN 1
      ELSE 0
    END AS IS_IHC,
    stain_inst,
    stain_name,
    stain_group,
    scanner_id,
    brand,
    model,
    image_id,
    magnification,
    status_id,
    file_size_bytes,
    captured_datetime
  FROM
    cdsi_prod.pathology_data_mining.case_breakdown_cleaned
),
t2 AS ( -- accession numbers = 1,828,303
  SELECT
    ACCESSION_NUMBER AS ACCESSION_NUMBER_PATH_DX,
    CAST(CAST(PATH_DX_SPEC_NUM AS FLOAT) AS INTEGER) AS PART_NUMBER_PATH_DX,
    PATH_DX_SPEC_TITLE,
    PATH_DX_SPEC_DESC
  FROM
    cdsi_prod.pathology_data_mining.surgical_specimen_diagnoses
),
t3 AS ( -- patients with diagnosis match through accession  = 416,482 (this attrition doesn't seem to affect downstream numbers)
  SELECT
    *
  FROM
    t1
      LEFT JOIN t2
        ON t1.ACCESSION_NUMBER = t2.ACCESSION_NUMBER_PATH_DX
        --AND t1.PART_NUMBER = t2.PART_NUMBER_PATH_DX
),
-----------------------------------
t6 AS ( -- patients = 110,636
  SELECT
    MRN as MRN_PATH,
    SAMPLE_ID AS SAMPLE_ID_PATH,
    SOURCE_ACCESSION_NUMBER_0,
    CASE
      WHEN SOURCE_SPEC_NUM_0 IS NOT NULL THEN FLOOR(CAST(SOURCE_SPEC_NUM_0 AS DECIMAL))
      ELSE NULL
    END AS SOURCE_SPEC_NUM_0,
    SOURCE_ACCESSION_NUMBER_0b,
    CASE
      WHEN SOURCE_SPEC_NUM_0b IS NOT NULL THEN FLOOR(CAST(SOURCE_SPEC_NUM_0b AS DECIMAL))
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
t7a as ( -- patients = 76,878
  SELECT
    *
  FROM
    t3
      INNER JOIN t6
        ON t3.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0
        --AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0
),
t7b as ( -- patients = 196
  SELECT 
    *
  FROM
    t3
      INNER JOIN t6
        ON t3.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0b
        -- AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0b
),
t7c as ( -- patients = 71,450
  SELECT
    *
  FROM
    t3
      INNER JOIN t6
        ON t3.ACCESSION_NUMBER = t6.ACCESSION_NUMBER_DMP
        --AND t5.PART_NUMBER = t6.SPECIMEN_NUMBER_DMP
),
t7 AS ( -- patients = 83,084
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
t8 AS ( -- patients = 83,568 (attrition from 104,440 from selecting certain gene panels)
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
    MSK_SLIDE_ID
  FROM
    cdsi_public.msk_impact.data_clinical_sample
    --cdsi_prod.pathology_data_mining.data_clinical_sample_oncokb
  WHERE
    SAMPLE_CLASS = 'Tumor'
    AND (
      GENE_PANEL = 'IMPACT341'
      OR GENE_PANEL = 'IMPACT410'
      OR GENE_PANEL = 'IMPACT505'
      OR GENE_PANEL = 'IMPACT468'
    )
),
t9 AS ( -- patients = 76,604
  SELECT
    *
  FROM
    t7
      INNER JOIN t8
        ON t7.SAMPLE_ID_PATH = t8.SAMPLE_ID_IMPACT
),
t10 AS ( -- patients = 110,940
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
t11 AS ( -- patients = 76,592
  SELECT
    *
  FROM
    t9
      LEFT JOIN t10
        ON t9.PATIENT_ID_IMPACT = t10.DMP_ID
),
t12 AS (
  SELECT
   image_id as IMAGE_ID_INVENTORY, 
   path as PATH_INVENTORY,
   source as SOURCE_INVENTORY,
   last_modified as LAST_MODIFIED_INVENTORY,
   size as SIZE_IMAGE_INVENTORY
  FROM
    cdsi_prod.pathology_data_mining.slide_inventory 
),
t13 AS ( -- patients = 76,604
  SELECT 
  patient_id_impact,
  sample_id_impact,
  accession_number,
  date_of_procedure_surgical,
  datetime_accession,
  date_sequencing_report,
  is_hne,
  is_ihc,
  stain_name,
  scanner_id,
  brand as scanner_brand,
  model as scanner_model,
  image_id,
  IMAGE_ID_INVENTORY,
  PATH_INVENTORY,
  SOURCE_INVENTORY,
  LAST_MODIFIED_INVENTORY,
  magnification,
  path_dx_spec_desc,
  path_dx_spec_title,
  GLEASON_SAMPLE_LEVEL,
  pdl1_positive,
  cancer_type,
  sample_class,
  metastatic_site,
  primary_site,
  cancer_type_detailed,
  gene_panel,
  so_comments,
  sample_coverage,
  tumor_purity,
  oncotree_code,
  msi_comment,
  msi_score,
  msi_type,
  institute,
  somatic_status,
  archer,
  cvr_tmb_cohort_percentile,
  cvr_tmb_score,
  cvr_tmb_tt_cohort_percentile
  from t11 left join t12 on t11.image_id = t12.IMAGE_ID_INVENTORY
)
SELECT
  *
FROM
  t13  

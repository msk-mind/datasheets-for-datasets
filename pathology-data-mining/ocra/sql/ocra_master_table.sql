WITH
  t1 AS (
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
      FROM "pathology-data-mining".impact_slide.case_breakdown_cleaned
  ),
  t2 AS (
      SELECT 
      MRN as MRN_PATH,
      SAMPLE_ID AS SAMPLE_ID_PATH,
      SOURCE_ACCESSION_NUMBER_0,
      CASE
          WHEN SOURCE_SPEC_NUM_0 <> '' THEN CAST(SOURCE_SPEC_NUM_0 AS INTEGER)
          ELSE NULL
      END AS SOURCE_SPEC_NUM_0,
      SOURCE_ACCESSION_NUMBER_0b,
      CASE
          WHEN SOURCE_SPEC_NUM_0b <> '' THEN CAST(SOURCE_SPEC_NUM_0b AS INTEGER)
          ELSE NULL
      END AS SOURCE_SPEC_NUM_0b,
      ACCESSION_NUMBER_DMP,
      CASE
          WHEN SPECIMEN_NUMBER_DMP <> '' THEN CAST(SPECIMEN_NUMBER_DMP AS INTEGER)
          ELSE NULL
      END AS SPECIMEN_NUMBER_DMP,
      DATE_SEQUENCING_REPORT,
      REPORT_CMPT_DATE_SOURCE_0,
      REPORT_CMPT_DATE_SOURCE_0b,
      DATE_OF_PROCEDURE_SURGICAL,
      DATE_OF_PROCEDURE_SURGICAL_EST,
      DOP_COMPUTE_SOURCE
      FROM "phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"
  ),
  t3a as (
      SELECT *
      FROM t1
      INNER JOIN t2 ON t1.ACCESSION_NUMBER = t2.SOURCE_ACCESSION_NUMBER_0 AND t1.PART_NUMBER = t2.SOURCE_SPEC_NUM_0
  ),
  t3b as (
      SELECT *
      FROM t1
      INNER JOIN t2 ON t1.ACCESSION_NUMBER = t2.SOURCE_ACCESSION_NUMBER_0b AND t1.PART_NUMBER = t2.SOURCE_SPEC_NUM_0b
  ),
  t3c as (
      SELECT *
      FROM t1
      INNER JOIN t2 ON t1.ACCESSION_NUMBER = t2.ACCESSION_NUMBER_DMP AND t1.PART_NUMBER = t2.SPECIMEN_NUMBER_DMP
  ),
  t3 AS (
      SELECT * FROM t3a
      UNION ALL 
      SELECT * FROM t3b
      UNION ALL
      SELECT * from t3c
  ),
  t4 AS (
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
      "#ONCOGENIC_MUTATIONS",
      RESISTANCE_MUTATIONS,
      "#RESISTANCE_MUTATIONS",
      "#MUTATIONS_WITH_SENSITIVE_THERAPEUTIC_IMPLICATIONS",
      "#MUTATIONS_WITH_RESISTANCE_THERAPEUTIC_IMPLICATIONS",
      "#MUTATIONS_WITH_DIAGNOSTIC_IMPLICATIONS",
      "#MUTATIONS_WITH_PROGNOSTIC_IMPLICATIONS",
      "#MUTATIONS"
      FROM "phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt"
  ),
  t5 AS (
      SELECT *
      FROM t3
      LEFT JOIN t4 ON t3.SAMPLE_ID_PATH = t4.SAMPLE_ID_IMPACT
  ),
  t6 AS (
      SELECT MRN AS MRN_CDM, MAX(DMP_ID) AS DMP_ID
      FROM "phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"
      GROUP BY MRN_CDM
      HAVING COUNT(DISTINCT DMP_ID) = 1
  ),
  t7 AS (
      SELECT *
      FROM t5
      LEFT JOIN t6 ON t5.PATIENT_ID_IMPACT = t6.DMP_ID
  ),
  t8 AS (
      SELECT
          1 AS IS_RG_MYRIAD,
          "Result",
          Result_Binary,
          "Date",
          MRN AS MRN_RG,
          DOB,
          Race,
          GIS,
          Histology_1,
          Prim_Inter,
          Spec_Source,
          Chemo_Naive,
          Stage,
          Residual_Disease,
          NA_Cycles,
          Adj_Cycles,
          TUF_Plat_Cycles,
          UF_Chemo_Regm,
          First_Treat,
          Diag_Date,
          Path_Date,
          UF_Start_Date,
          Last_Plat_Date,
          Maint_Regm,
          Maint_Disc_Reason,
          Bev_Start,
          Bev_End,
          PARP_Type,
          PARP_Start_Date,
          PARP_End_Date,
          Rad_Progr_Date,
          Total_Lines,
          Date_Death,
          Date_Followup
      FROM OCRA."HRD_RG_data"
  ),
  t9 AS (
      SELECT *
      FROM t7
      FULL JOIN t8 ON t7.MRN = t8.MRN_RG
  ),
  t10 AS (
      SELECT
        1 AS IS_RG_BRCA,
        MRN AS MRN_RG_BRCA,
        DOB,
            Race,
            Histology_1,
            Prim_Inter,
            Spec_Source,
            Chemo_Naive,
            Stage,
            Residual_Disease,
            NA_Cycles,
            Adj_Cycles,
            TUF_Plat_Cycles,
            UF_Chemo_Regm,
            Diag_Date,
            "Path_Date of tested sample" AS Path_Date,
            UF_Start_Date,
            Last_Plat_Date,
            Maint_Regm,
            Maint_Disc_Reason,
            Bev_Start,
            Bev_End,
            PARP_Type,
            PARP_Start_Date,
            PARP_Start_Dose,
            PARP_End_Date,
            PARP_End_Dose,
            PARP_Dose_Dec_Date,
            Rad_Progr_Date,
            Next_Tx_Regimen,
            Next_Start_Date,
            Total_Lines,
            Date_Death,
            Date_Followup
      FROM OCRA."HRD_Shah_cohort"
  ),
  t11 AS (
      SELECT *
      FROM t9
      FULL JOIN t10 ON t9.MRN = t10.MRN_RG_BRCA
  ) 
SELECT * FROM t11

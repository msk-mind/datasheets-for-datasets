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
    ACCESSION_NUMBER AS ACCESSION_NUMBER_PATH_DX,
    CAST(CAST(PATH_DX_SPEC_NUM AS FLOAT) AS INTEGER) AS PART_NUMBER_PATH_DX,
    PATH_DX_SPEC_TITLE,
    PATH_DX_SPEC_DESC
    FROM phi_data_lake."cdm-data".pathology."table_pathology_surgical_samples_parsed_specimen.tsv"
  ),
  t3 AS (
      SELECT *
      FROM t1
      LEFT JOIN t2 
      ON t1.ACCESSION_NUMBER = t2.ACCESSION_NUMBER_PATH_DX
      AND t1.PART_NUMBER = t2.PART_NUMBER_PATH_DX
  ),
  t4 AS (
    SELECT 
    id AS IMAGE_ID_INVENTORY,
    project_name,
    url AS SLIDE_URL
    FROM "pathology-data-mining"."master_slide_inventory"."master_slide_inventory"
  ),
  t5 AS (
      SELECT *
      FROM t3
      LEFT JOIN t4
      ON t3.image_id = t4.IMAGE_ID_INVENTORY
  )
  SELECT * FROM t5

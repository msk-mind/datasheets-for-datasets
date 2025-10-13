## Sql1
with t1 as (
  -- group S-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'S%' group by specnum_formatted, datetime_accession order by ct desc limit 100
)
-- check to see if there are any S-numbers that belong to more than one surgical date (ct>1). If not S-numbers identify a single surgical event
select specnum_formatted, count(specnum_formatted) as ct from t1 group by specnum_formatted order by ct desc

## Sql2
with t1 as (
  -- group S-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'S%' group by specnum_formatted, datetime_accession order by ct desc
)
select count(distinct specnum_formatted) from t1 

## Sql3
select mrn, specnum_formatted, part_inst, part_description, datetime_accession from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted = 'S15-23298'


## Sql4
with t1 as (
  -- group M-numbers by surgical date 
select specnum_formatted, datetime_accession, count(specnum_formatted, datetime_accession) as ct from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where specnum_formatted LIKE 'M%' group by specnum_formatted, datetime_accession order by ct desc
)
select count(distinct specnum_formatted) from t1 

## Sql5
select * from cdsi_prod.pathology_data_mining.case_breakdown_cleaned where mrn = '35366573' and specnum_formatted LIKE 'S%' 

## Sql6
select * from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where ACCESSION_NUMBER_DMP ='M14-14980'

## Sql7
select SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP, count(SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP) as ct
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0
 like 'S%' and ACCESSION_NUMBER_DMP like 'M%' group by SOURCE_ACCESSION_NUMBER_0, ACCESSION_NUMBER_DMP order by ct desc

## Sql8
select SOURCE_ACCESSION_NUMBER_0, count(ACCESSION_NUMBER_DMP) as ct
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0
 like 'S%' group by SOURCE_ACCESSION_NUMBER_0 order by ct desc

## Sql9
select count(distinct SAMPLE_ID)
  from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

## Sql10
select count(distinct SOURCE_ACCESSION_NUMBER_0) from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

## Sql11
select count(distinct ACCESSION_NUMBER_DMP) from cdsi_prod.pathology_data_mining.table_pathology_impact_sample_summary_dop_anno_clean where SOURCE_ACCESSION_NUMBER_0 like 'S%' and ACCESSION_NUMBER_DMP like 'M%'

## Sql12
select count(distinct m_number) from cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned where s_number like 'S%' and isnotnull(block_id)


## Sql13
select m_number, count(block_id) as ct from cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned where s_number like 'S%' and isnotnull(block_id) group by m_number order by ct desc

## Sql14
select count(distinct MRN) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean
select count(distinct ACCESSION_NUMBER) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean
select count(distinct M_NUMBER_COPATH) from cdsi_prod.pathology_data_mining.impact_block_matched_slides_clean 

## Sql15
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
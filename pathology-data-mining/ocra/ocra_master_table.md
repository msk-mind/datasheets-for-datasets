# OCRA Master Table

<b>Path:</b> `OCRA.<NEED_TO_ADD>` <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

["pathology-data-mining".impact_slide.case_breakdown_cleaned](https://github.com/msk-mind/datasheets-for-datasets/blob/main/hobbit/hobbit-casebreakdown-cleaned.md) (as t1) <br/>
["phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) (as t2) <br/>
&nbsp; |_ JOIN t2 ON t1.specnum_formatted = t2.SOURCE_ACCESSION_NUMBER_0 AND t1.part_inst = t2.SOURCE_SPEC_NUM_0 (as t3) <br/>
&nbsp; ["phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/impact/data_clinical_sample.oncokb.md) (as t4) <br/>
&nbsp;&nbsp;&nbsp; |_ FULL JOIN t4 ON t3.SAMPLE_ID = t4.SAMPLE_ID (as t5) <br/>
&nbsp;&nbsp;&nbsp;&nbsp; ["phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/ddp_id_mapping.md) (as t6) <br/>
&nbsp;&nbsp;&nbsp;&nbsp; |_ LEFT JOIN t6 ON t5.PATIENT_ID = t6.MRN (as t7) <br/>
&nbsp;&nbsp;&nbsp;&nbsp; [OCRA."HRD_RG_data"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/ocra/rachel_grisham_cohort.md) (as t8) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |_ FULL JOIN t7 ON t8.MRN = t7.MRN (as t9) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; OCRA.archive."wide_shape_features" (as t10) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; |_ FULL JOIN t10 ON t9.image_id = t10.slide_id (as t11) <br/>

<b>Summary Statistics:</b>

Total number of rows: <NEED_TO_ADD> <br/>
Total number of unique patients: <NEED_TO_ADD> <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

A master table that brings together pathology, genomics and clinical datasets. 

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

Most of the columns in the master table are described in datasheets from the lineage. 

A number of columns appeared in multiple base tables - these were re-named to record which
base table each value was taken from.

A number of columns were added to make common queries simpler

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| MRN | | string | |
| ACCESSION_NUMBER | |  | string | |
| PART_NUMBER | |  | integer  | |
| BLOCK_NUMBER | |  | integer  | |
| BLOCK_LABEL | |  | string  | |
| IS_HNE | Is the stain "H&E (Initial)" or "H&E (Other)" ? | integer | |
| IS_IHC | Is the stain "IHC"? | integer | |
| MRN_PATH | medical record number | string | |
| SAMPLE_ID_PATH | IMPACT sample ID | string | |
| SAMPLE_ID_IMPACT  |IMPACT sample id | string | |
| PATIENT_ID_IMPACT  |De-identified patient ID | string | |
| MRN_CDM | medical record number | string | |
| DMP_ID | DMP patient ID ("de-identified patient ID") | string |
| IS_RG_MYRIAD | Is this row linked to the Rachel Grisham Myriad cohort? | string | |
| MRN_RG | medical record number | string | |


## Rules <a name="rules"></a>



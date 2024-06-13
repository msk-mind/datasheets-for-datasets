# Rachel Grisham Cohort

<b>Path:</b> `OCRA.<NEED_TO_ADD>` <br/>
<b>Table Type:</b> `Static, but contains live datasets in lineage` <br/>
<b>Late updated:</b> `2024-05-17` <br/>

<b>Lineage:</b> 

"pathology-data-mining".impact_slide.case_breakdown_cleaned (t1) <br/>
"phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv" (t2) <br/>
&nbsp;<b>|_<\b> JOIN t2 ON t1.specnum_formatted = t2.SOURCE_ACCESSION_NUMBER_0 AND t1.part_inst = t2.SOURCE_SPEC_NUM_0 (t3) <br/>
&nbsp; "phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt" (t4) <br/>
&nbsp;&nbsp;&nbsp; <b>|_<\b> FULL JOIN t4 ON t3.SAMPLE_ID = t4.SAMPLE_ID <br/>
&nbsp;&nbsp;&nbsp;&nbsp; "phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv" (t6) <br/>
&nbsp;&nbsp;&nbsp;&nbsp; <b>|_<\b> LEFT JOIN t6 ON t5.PATIENT_ID = t6.MRN (t7) <br/>
&nbsp;&nbsp;&nbsp;&nbsp; OCRA."HRD_RG_data" (t8) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b>|_<\b> FULL JOIN t7 ON t8.MRN = t7.MRN (t9) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; OCRA.archive."wide_shape_features" (t10) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; <b>|_<\b> FULL JOIN t10 ON t9.image_id = t10.slide_id (t11) <br/>

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

See datasheets in the lineage. 


## Rules <a name="rules"></a>

1. An important field in the table is the GIS score obtained from the Myriad test. 


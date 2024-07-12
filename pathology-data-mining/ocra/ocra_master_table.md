# OCRA Master Table

<b>Path:</b> `OCRA."OCRA_Master_Table_2024-07-05"` <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Last updated:</b> `2024-07-06` <br/>

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
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [OCRA."HRD_Shah_cohort"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/ocra/rachel_grisham_brca_cohort.md) (as t10) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |_ FULL JOIN t10 ON t10.MRN = t9.MRN (as t11) <br/>


<b>Summary Statistics:</b>

Total number of rows: 670,712 <br/>
Total number of unique patients: 68,684 <br/>
Total number of IMPACT samples: 89,115 <br/>


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

A number of columns were added to make common queries simpler:

| **Field name** | **Description** | **Field Type** | **Encoding** |
|---|---|---|---|
| MRN | medical record number from Hobbit records | string | |
| ACCESSION_NUMBER | accession number from Hobbit records |  string | |
| PART_NUMBER | |  integer  | |
| BLOCK_NUMBER | | integer  | |
| BLOCK_LABEL | |  string  | |
| IS_HNE | Is the stain "H&E (Initial)" or "H&E (Other)" ? | integer | |
| IS_IHC | Is the stain "IHC"? | integer | |
| MRN_PATH | medical record number from pathology report | string | |
| SAMPLE_ID_PATH | IMPACT sample ID from pathology report | string | |
| SAMPLE_ID_IMPACT  |IMPACT sample id from IMPACT report | string | |
| PATIENT_ID_IMPACT  |De-identified patient ID from IMPACT report | string | |
| MRN_CDM | medical record number from CDM de-id table | string | |
| DMP_ID | DMP patient ID ("de-identified patient ID") | string |
| IS_RG_MYRIAD | Is this row linked to the Rachel Grisham Myriad cohort? | string | |
| MRN_RG | medical record number from RG_MYRIAD table| string | |
| IS_RG_BRCA | Is this row linked to the Rachel Grisham BRCA cohort? | string | |
| MRN_RG_BRCA | medical record number from RG_BRCA table| string | |

A number of columns that were unique to the Rachel Grisham BRCA table were also dropped:
1. The `A`, `Provider`, and `ID/Requisition` columns were dropped because the didn't appear to be medically relevant.
2. The `Name` column was dropped because patient names are PHI and unnecessary for research work.
3. The `Histology_M1`, `Histology_M2`, and `Hist_Grade` columns were dropped because we didn't also have them for the Myriad cohort.

## Rules <a name="rules"></a>

1. About 3% if the image_ids that map to IMPACT samples at the part level map to more than one IMPACT sample. In these cases, the most distinguishing data element between the mappings seems to be tumor purity. This may be because of the presence of multifocal lesions.
```
SELECT count(SAMPLE_ID_IMPACT) as ct, image_id
FROM OCRA."OCRA_Master_Table_2024-07-05"
WHERE image_id IS NOT NULL 
GROUP BY image_id ORDER BY ct DESC
```



# Impact-matched Slides

<b>Path:</b> `"pathology-data-mining"."impact-matched-slides"` <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Last updated:</b> `2024-08-06` <br/>

<b>Lineage: ([SQL](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact-matched-slides.sql)</b> 

["pathology-data-mining"."slides_with_diagnosis"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/slides_with_diagnosis.md) (as t5) <br/>
["phi_data_lake"."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) (as t6) <br/>
&nbsp; |_ t5 INNER JOIN t6 ON t5.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0 AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0 (as t7) <br/>
&nbsp; ["phi_data_lake"."pdm-data".impact."data_clinical_sample.oncokb.txt"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) (as t8) <br/>
&nbsp;&nbsp;&nbsp; |_ t7 INNER JOIN t8 ON t7.SAMPLE_ID_PATH = t8.SAMPLE_ID_IMPACT (as t9) <br/>
&nbsp;&nbsp;&nbsp; ["phi_data_lake"."cdm-data"."id-mapping"."ddp_id_mapping_pathology.tsv"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/ddp_id_mapping.md) (as t10) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |_ t9 LEFT JOIN t10 ON t9.PATIENT_ID_IMPACT = t10.DMP_ID (as t11) <br/>


<b>Summary Statistics:</b>

Total number of rows (slides): 572,811 <br/>
Total number of unique patients: 66,555 <br/>
Total number of IMPACT samples: 77,155 <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

A table listing all whole-slide-images for which we have matching IMPACT results.  

## Assumptions <a name="assumptions"></a>

None. 

## Vocabulary & Encoding <a name="vocabulary"></a>

Most of the columns in the master table are described in datasheets from the lineage.
The columns containing the IMPACT results, in particular, are not described here, but in the
[data_clinical_sample.oncokb.txt](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/pathology_reports.md) datasheet.
A number of columns were added to make common queries simpler.
In some cases, a columns that appeared in multiple base tables were renamed to reflect
which base table they came from.

Key columns include...

| **Field name** | **Description** | **Field Type** | **Data type** | **Format** |
|---|---|---|---|---|
| MRN | medical record number from HoBBIT records | ID | string | |
| ACCESSION_NUMBER | accession number from HoBBIT record | ID  | string | |
| PART_NUMBER | part number from HoBBIT record | ID  | integer  | |
| BLOCK_NUMBER | block number from HoBBIT record | ID | integer  | |
| BLOCK_LABEL | block label from HoBBIT record | ID  | string  | |
| stain_group | the type of stain used | | string | 'H&E (Initial)', 'IHC', ... |
| IS_HNE | Is the stain group  "H&E (Initial)" or "H&E (Other)" ? | boolean | integer | 0, 1 |
| IS_IHC | Is the stain group "IHC"? | boolean | integer | 0, 1 |
| MRN_PATH | medical record number from pathology report | ID | string | |
| PATH_DX_SPEC_TITLE | brief tissue diagnosis | description | string | |
| PATH_DX_SPEC_DESC | detailed tissue diagnosis | description | string | |
| image_id | slide ID for whole-slide image | ID | string | |
| magnification | slide magnification | | string | '20x', '40x', ... |
| SLIDE_URL | the file:// URL for the downloaded slide | URL | string | file://<pathname> |
| SAMPLE_ID_IMPACT | the IMPACT sample ID associated with the genomics results | ID | string | |
| SAMPLE_ID_PATH | the IMPACT sample ID associated with the slide | ID | string | |


## Rules <a name="rules"></a>

1. Slides and IMPACT samples are matched based on the accession number and part number for the tissue used to make those slides and those samples.  This generally works well, but in cases where multiple IMPACT samples are taken from the same part, *each slide from that part will be matched to all of the IMPACT samples taken from the same part.*  This could cause problems if the IMPACT samples represent different lesions in the same part, because you won't know which slide is associated with which lesion.  This could be corrected if we knew the block numbers for the IMPACT samples, but at present we don't.

In case it's helpful, the following query will list slides that are associated with more than one IMPACT sample.
```
SELECT image_id, count(SAMPLE_ID_IMPACT) as samples
FROM OCRA."OCRA_Master_Table_2024-07-05"
WHERE image_id IS NOT NULL 
GROUP BY image_id
HAVING samples > 1
ORDER BY samples DESC
```



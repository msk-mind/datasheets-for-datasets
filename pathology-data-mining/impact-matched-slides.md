# Impact-matched Slides

<b>Path:</b> [`"cdsi_prod.pathology_data_mining.impact_matched_slides"`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_prod/pathology_data_mining/impact_matched_slides) <br/>
<b>Table Type:</b> `contains live datasets in lineage` <br/>
<b>Last updated:</b> `2025-02-12` <br/>

<b>Lineage ([SQL](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/sql/impact-matched-slides.sql)): </b> 

["cdsi_prod.pathology_data_mining.slides_with_diagnosis"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/pathology-data-mining/slides_with_diagnosis.md) (as t5) <br/>
["cdsi_prod.cdm_impact_pipeline_prod.table_pathology_impact_sample_summary_dop_anno"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/table_pathology_impact_sample_summary_dop_anno.md) (as t6) <br/>
&nbsp; |_ t5 INNER JOIN t6 ON t5.ACCESSION_NUMBER = t6.SOURCE_ACCESSION_NUMBER_0 AND t5.PART_NUMBER = t6.SOURCE_SPEC_NUM_0 (as t7) <br/>
&nbsp; ["cdsi_prod.msk_impact_oncokb_annotated.data_clinical_sample_oncokb_raw"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/impact/data_clinical_sample.oncokb.md) (as t8) <br/>
&nbsp;&nbsp;&nbsp; |_ t7 INNER JOIN t8 ON t7.SAMPLE_ID_PATH = t8.SAMPLE_ID_IMPACT (as t9) <br/>
&nbsp;&nbsp;&nbsp; ["cdsi_prod.cdm_impact_pipeline_prod.ddp_id_mapping_pathology"](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/ddp_id_mapping.md) (as t10) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |_ t9 LEFT JOIN t10 ON t9.PATIENT_ID_IMPACT = t10.DMP_ID (as t11) <br/>


<b>Summary Statistics:</b>

Total number of rows (slides): 686,540 <br/>
Total number of unique patients: 75,181 <br/>
Total number of IMPACT samples: 86,887 <br/>


1. [Description](#description)
2. [Vocabulary](#vocabulary)
3. [Notes](#notes)


## Description <a name="description"></a>

A table listing all whole-slide-images for which we have matching IMPACT results.  


## Vocabulary <a name="vocabulary"></a>

Most of the columns in the master table are described in datasheets from the lineage.
The columns containing the IMPACT results, in particular, are not described here, but in the
[data_clinical_sample.oncokb.txt](https://github.com/msk-mind/datasheets-for-datasets/blob/main/clinical-data-mining/table_pathology_impact_sample_summary_dop_anno.md) datasheet.
A number of columns were added to make common queries simpler.
In some cases, a columns that appeared in multiple base tables were renamed to reflect
which base table they came from.  ***We retain these columns to make it easier to debug issues in the final table.***

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


## Notes <a name="notes"></a>

1. Slides and IMPACT samples are matched based on the accession number and part number for the tissue used to make those slides and those samples.  This generally works well, but in cases where multiple IMPACT samples are taken from the same part, *each slide from that part will be matched to all of the IMPACT samples taken from the same part.*  This could cause problems if the IMPACT samples represent different lesions in the same part, because you won't know which slide is associated with which lesion.  This could be corrected if we knew the block numbers for the IMPACT samples, but at present we don't.

In case it's helpful, the following query will list slides that are associated with more than one IMPACT sample.
```
SELECT image_id, count(SAMPLE_ID_IMPACT) as samples
FROM cdsi_prod.pathology_data_mining.impact_matched_slides 
WHERE image_id IS NOT NULL 
GROUP BY image_id
HAVING samples > 1
ORDER BY samples DESC
```

2. Matching slides and IMPACT results using the accession and part numbers depends on the accession numbers being correct.  We discovered that some pathology reports contain incorrect references to related accessions, and have even found cases where the same accession number was assigned to two different accessions for different patients!  This can lead to an IMPACT sample ID mapping to more than one MRN, which should never legitimately happen.  Samples that display this should probably be discarded.  To check for this, you can use the following query,
```
WITH
t1 AS (
  SELECT SAMPLE_ID_IMPACT
  FROM cdsi_prod.pathology_data_mining.impact_matched_slides 
  GROUP BY SAMPLE_ID_IMPACT
  HAVING COUNT(DISTINCT MRN) > 1
)
SELECT DISTINCT t1.SAMPLE_ID_IMPACT, ACCESSION_NUMBER, MRN, MRN_CDM, MRN_PATH, image_id
FROM cdsi_prod.pathology_data_mining.impact_matched_slides t2
INNER JOIN t1 ON t1.SAMPLE_ID_IMPACT = t2.SAMPLE_ID_IMPACT
ORDER BY t1.SAMPLE_ID_IMPACT ASC, MRN ASC;
```

3. Not all of the slides in HoBBIT can be used for research. In practice, roughly 1% of requested slides contain PHI on the slide itself and thus cannot be de-identified for research use. This cannot be determined via HoBBIT, and is only determined during data transfer.

4. The IMPACT samples have been filtered to include only solid tumors, using SAMPLE_CLASS = 'Tumor' AND GENE_PANEL = ['IMPACT341', 'IMPACT410', 'IMPACT505', 'IMPACT468']

## Todos <a name="todos"></a>

1. Either reference impact_matched_slides_clean here or renamed the table in databricks and remove the old one
2. The SQL here needs to be updated to look exactly like the SQL in the Databricks "Overview" tab so we can diff the two easily
3. Of 685,662 rows, 683,197 are unique. i.e. about 0.3% of the rows (1212 rows) are redundantly duplicated. Given the small size of these duplications, a possible explanation for this is that these are manual data entry errors where perhaps an image_id or sample_id was recorded twice. This needs to be further investigated and either we mention it in the Notes section or we clean these rows out. 
4. There are cases where a slide is used to generate many IMPACT samples (image_id='5544040' for example). This makes the otherwise assumed one-one relationship between slides and samples into a one-many relationship. There are 11,464 such cases. An explanation for this needs to be sought from the pathology dept and then documented in the Notes section.
5. A sample_id can exist in more than one row. There are 78,317 such rows. One explanation for this is because a sample can be derived from more than one slide (sample_id='“P-0059788-T02-IM7' for example). There may be other explanations for this as well which may need to be sought from the pathology dept. and then documended in the Notes section.




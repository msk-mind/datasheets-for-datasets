# impact_tumor_purity_variation

<b>Path:</b> cdsi_res_deid.pdm_mosaic.impact_tumor_purity_variation <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> In progress <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

* There are 5.430 rows in this table.

* There are 5,408 patients represented in this table.
* 22 of these patients have two different OncoTree codes with multiple samples having different tumor purity ratings. 

* For 4,390 of the 5,430 cases (patient/OncoTree pairs) reported here, there were only two qualifying samples for that OncoTree code.
* For 1 case, there were 10 qualifying samples.
* The number of cases for each sample count is
  - 10 ......    1
  -  8 ......    2
  -  7 ......    5
  -  6 ......   17
  -  5 ......   50
  -  4 ......  181
  -  3 ......  784
  -  2 ...... 4390

* There are 287 distinct OncoTree codes in this table
* The ten most common OncoTree codes here are
  - LUAD .... 1341
  - IDC .....  460
  - PRAD ....  456
  - BLCA ....  389
  - COAD ....  180
  - PAAD ....  160
  - BRCA ....  118
  - GIST ....  109
  - LUSC ....  108
  - ILC .....   99



# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

This dataset reports cases where a patient has multple IMPACT samples with pathology slides for a given tumor
type (OncoTree code), but different samples have different tumor purity ratings.

Each row in the table contains a list of IMPACT samples for a unique patient-ID/OncoTree-code pair.  At least two of the samples in each
of those lists have different tumor purity ratings.  If the list contains more than two
samples, it's possible that some have the same tumor purity rating.


### Vocabulary <a name="vocab"></a>

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| DMP_ID | Patient ID | ID | string |  |
| ONCOTREE_CODE | OncoTree code | categorical | string | (1) |
| samples | IMPACT samples | Mixed | Array of structs | (2) |

The DMP_ID and OncoTree code, together, constitute the primary key for this dataset.

(1) There are more than 800 OncoTree codes, defined in a hierarchy of cancer types.
See the [OncoTree portal](https://oncotree.mskcc.org/) for more information

(2) Each `samples` value is an array of two or more STRUCTs, each representing an IMPACT
sample.

Each sample STRUCT has the keys,

    SAMPLE_ID ............... the IMPACT sample ID (string)
    TUMOR_PURITY ............ the relative date for the surgery (integer)
    SURGICAL_DATE_DEID ...... the date of surgery for this tissue part (integer or NULL)
    slides .................. an array of image_ids (strings)


## Notes <a name="notes"></a>

1. The case with ten samples is for patient P-0081269 , who had LUAD cancer.  Seven of the
   ten samples here actually have different tumor purities, ranging from 10 to 50. 

2. The surgical date is NULL for some samples.

## Queries for Summary Statistics

#### OncoTree stats

    SELECT 
        ONCOTREE_CODE,
        COUNT(*) AS oncotree_count
    FROM cdsi_res_deid.pdm_mosaic.impact_tumor_purity_variation
    GROUP BY ONCOTREE_CODE
    SORT BY oncotree_count DESC

#### DMP_ID stats

    SELECT 
        DMP_ID,
        COUNT(*) AS patient_count
    FROM cdsi_res_deid.pdm_mosaic.impact_tumor_purity_variation
    GROUP BY DMP_ID
    SORT BY patient_count DESC


#### Sample-count stats

    WITH t1 AS (
        SELECT 
            DMP_ID,
            ONCOTREE_CODE,
            SIZE(samples) as sample_count
        FROM cdsi_res_deid.pdm_mosaic.impact_tumor_purity_variation
    )
    SELECT
        COUNT(*) AS cases,
        sample_count,
    FROM t1
    GROUP BY sample_count
    ORDER BY sample_count DESC



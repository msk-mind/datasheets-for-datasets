# noetik_slides_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_noetik.noetik_slides_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_noetik/noetik_slides_v1) <br/>
<b>Table Type:</b> Live (materialized view, manual refresh; the cohort is hard-coded in the defining SQL) <br/>
<b>Date created or last updated:</b> 2026-11-18 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows:                200,000 <br/>
Unique image_ids (slides): 200,000 <br/>
Unique patient_ids:         51,094 <br/>
Unique accessions:          96,795 <br/>
Unique sample_ids:          57,339 <br/>
Unique Oncotree codes:         612 <br/>

Total size on storage: 174.2 TB<br/>


#### Top 10 Oncotree codes (by slides)

| ONCOTREE_CODE | slides | patients | accessions | samples | total image size | 
| --- | --- | --- | --- | --- | --- | 
| IDC | 13280 | 3399 | 6821 | 3800 | 8.7 TB | 
| PRAD | 12360 | 3268 | 6284 | 3621 | 8.9 TB | 
| COAD | 11627 | 3088 | 5446 | 3209 | 11.9 TB | 
| LUAD | 11588 | 3171 | 4499 | 3714 | 8.7 TB | 
| BLCA | 8527 | 1841 | 3901 | 2178 | 7.6 TB | 
| HGSOC | 6223 | 1652 | 3097 | 1685 | 6.4 TB | 
| PAAD | 6033 | 1901 | 3089 | 1956 | 4.1 TB | 
| UEC | 5927 | 1547 | 2664 | 1580 | 8.1 TB | 
| BRCA | 5618 | 1468 | 2780 | 1567 | 2.9 TB | 
| READ | 4440 | 1199 | 2183 | 1239 | 3.0 TB | 


#### Accessions per patient

| accessions | patients | slides | 
| --- | --- | --- | 
|  1  | 12868 |  26899 | 
|  2  | 31528 | 128165 | 
|  3  |  2542 |  13279 | 
|  4+ |  4156 |  31657 | 


#### Tumor Purity

 | percentage_range | slides | 
 | --- | --- | 
 | 30-40% | 46754 | 
 | 40-50% | 36213 | 
 | 50-60% | 30575 | 
 | 60-70% | 34005 | 
 | 70-80% | 27362 | 
 | 80-90% | 19831 | 
 | 90-100% | 5260 | 


#### Magnification

| magnification | slides |
| --- | --- |
| 20x | 104303 |
| 40x | 95679 |
| NA | 18 |


# Table of contents
1. [Description](#description)
1. [Derivation](#derivation)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

A cohort of slides covering a wide range of cancer types, which Noetik can use to train models.  

The slides here were selected to represent a diverse collection of cancer types.
In the end 612 of the 652 Oncotree codes represented in our local slide repository are found in this dataset.  

All slides listed here are in our local object store, so no additional slide requests need to be made to the Pathology department.

All patients in this cohort accepted Part A for the 12-245 IRB, so all have `YES` for `PARTA_CONSENTED_12_245` 

## Derivation  <a name="derivation"></a>
This is a broad description of the query used to build this table.  See the SQL definition in Databricks for the actual query.

 1. Sources
   - cdsi_res_deid.pdm_product_cdsi.msk_slide_inventory_v1 supplies the slide inventory (local slides).
   - product_cdsi.msk_impact.data_clinical_sample supplies the IMPACT fields.
   - product_cdsi.msk_impact.data_clinical_patient supplies patient consent. It is filtered to PARTA_CONSENTED_12_245 = 'YES'.
   - cdsi_eng_phi.pdm_base_tables.case_breakdown_cleaned_v2 (from HoBBIT) supplies accession, block, stain and scanner details.
 2. Slide filters
   - The slide inventory is inner-joined to the clinical_sample table on sample_id and to the consent table on patient_id.
   - The case breakdown is inner-joined on image_id. It is limited to accessions starting with S or M, and IHC slides are excluded.
   - block_id is built as "accession / partnumber - blocklabel".
 3. Patients with more than one accession (group A)
   - For each accession, the images are sorted by tumor_purity descending, with nulls last and image_id as the tie-break.
   - The top 4 are kept, then anything with tumor_purity < 30 or an unparseable value is dropped.
 4. Patients with one accession (group B)
   - The top 3 images are kept, with the same purity filter.
   - The result is ordered by datetime_accession, with the most recent accessions first.
 5. Combine
   - Group A is unioned with group B, but only the first 200,000 slides are kept. (So, all of group A is kept, but only as much of group B as it takes to get 200,000 slides total.)

### Vocabulary <a name="vocab"></a>

Primary key: (`image_id`). 

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| patient_id                  | Patient DMP ID                              | ID          | string    | `P-XXXXXXX` |
| PARTA_CONSENTED_12_245      | Did patient consent to IRB 12-245 part A?   | Boolean     | string    |  'YES'      |
| accession_count_per_patient | Number of accessions                        | Count       | int       |             |
| accession_number            | Accession number (tissue extraction event)  | ID          | string    |             |
| datetime_accession          | Date of accession (tissue extraction event) | Date        | timestamp | YYYY-MM-DD  |
| image_id                    | Image ID                                    | ID          | string    |             |
| sample_id                   | IMPACT sample ID                            | ID          | string    | `P-XXXXXXX-{T,N}NN-IMn` |
| sample_type                 | Tissue type (primary, met, normal, etc.)    | categorical | string    |
| primary_site                | Organ for primary tumor                     | categorical | string    |             |
| metastatic_site             | Organ for metastatic tumor                  | categorical | string    |             |
| tumor_purity                | Percentage of tissue that is tumor          | percentage  | string    |             |
| oncotree_code               | A 4-letter code identifying cancer type     | categorical | string    |             |
| part_number                 | ID number for tissue part for slide         | ID          | string    |             |
| block_id                    | Full ID of tissue block for slide           | ID          | string    |             |
| stain_name                  | Name of slide stain                         | categorical | string    |             |
| scanner_id                  | ID for WSI scanner                          | ID          | string    |             |
| brand                       | brand of WSI scanner                        | categorical | string    | 'aperio'    |
| model                       | model of WSI scanner                        | categorical | string    | 'AT2', 'GT450', or 'CS2' |
| magnification               | Magnification of image                      | categorical | string    | '40x', '20x', or 'NA' |
| path                        | S3 pathname for local WSI file              | pathname    | string    | The S3:// pathname for a local copy of this WSI |
| size                        | Size (bytes) of image file                  | file size   | int       | The image size in bytes |


## Notes <a name="notes"></a>

1. <b>Stain uncertainty</b>  Some IHC slides could have leaked into this dataset because the stain labels we have are occasionally wrong.

2. <b>Accession date</b>  The accession date is the date that the tissue was received by the pathology department.  (For M-accessions, it's the date the tissue was received for
   sequencing.)  The date that a diagnosis is given will typically be a few days after this.

3. Tumor purity is just the percentage of the slide that is considered to be part of the tumor.  A purity >60% is considered high, and purity below 30% is considered low.

4. <b>One storage path per slide, all in the REEF bucket.</b> All 200,000 slides are stored in `s3://mskmind-bkt/reef-slides/`, and all are `.svs` files.
      
5. <b>Scanner info</b>  We have the scanner ID, brand, and model for each slide in this table.  We'll use these to get the microns-per-pixel for each slide from the pathology department.

6. <b>accession_number and sample_id to patient_id are both many-to-one.</b> The queries below both return 0 rows.

   ```
   SELECT accession_number, count(DISTINCT patient_id) AS ct FROM cdsi_eng_phi.pdm_noetik.noetik_slides_v1 GROUP BY accession_number HAVING ct > 1
   SELECT sample_id, count(DISTINCT patient_id) AS ct FROM cdsi_eng_phi.pdm_noetik.noetik_slides_v1 GROUP BY sample_id HAVING ct > 1
   ```

7. <b>Slide file sizes vary widely.</b> From ~11 GB to ~2.3 MB per slide, with a mean around 0.9 GB. 

# natera_slide_inventory_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_natera.natera_slide_inventory_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_natera/natera_slide_inventory_v1) <br/>
<b>Table Type:</b> Live (materialized view, manual refresh; the cohort is hard-coded in the defining SQL) <br/>
<b>Date created or last updated:</b> 2026-11-17 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 341 <br/>
Unique image_ids (slides): 341 <br/>
Unique patient_id: 20 <br/>
Unique sample_id: 45 <br/>
Unique (image_id, sample_id) pairs: 341 <br/>
Total size on storage: 349,200,181,385 bytes (~349 GB) <br/>
Slide `size` (bytes): min 11,333,671; mean ~1,024,047,453; max 2,816,767,096 <br/>

Breakdown by `cancer`:

| cancer | Rows (slides) | Patients | Samples |
|---|---|---|---|
| crc | 199 | 12 | 25 |
| nsclc | 90 | 5 | 14 |
| breast | 52 | 3 | 6 |

Breakdown by `stain_group`:

| stain_group | Rows (slides) | Samples |
|---|---|---|
| H&E (Initial) | 259 | 40 |
| H&E (Other) | 82 | 39 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

An inventory of H&E whole-slide images (WSIs) for a small, hand-selected cohort of 20 MSK-IMPACT patients (3 breast, 5 NSCLC, 12 colorectal) prepared for the Natera project. Each row is one slide matched to one IMPACT sample, with the slide's cancer-cohort label, stain group, S3 location, and file size.

The cohort is a hard-coded list of `(patient_id, cancer)` pairs inside the table's SQL definition; it is not derived from any clinical criterion. Patients are labelled `breast`, `nsclc`, or `crc`. Adding or removing a patient requires editing the pipeline SQL.

Derivation (see the SQL definition in Databricks):

1. Join the hard-coded cohort to [`impact_part_matched_slides_v2`](../pathology-data-mining/impact_part_matched_slides_v2.md) (`cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2`) on `patient_id` to get the IMPACT-matched slides and their `stain_group`.
2. Keep only H&E slides: `lower(stain_group) LIKE '%h&e%'`. IHC, frozen, and other stains are excluded.
3. Join to [`slide_inventory`](../pathology-data-mining/slide_inventory.md) (`cdsi_eng_phi.pdm_base_tables.slide_inventory`) on `image_id` to attach `path` and `size`.
4. De-duplicate per (`sample_id`, `image_id`). If a slide has multiple storage locations, keep the one under `s3://mskmind-bkt/reef-slides/`, otherwise the alphabetically first `path`.

This table lives in `cdsi_eng_phi`, not a de-identified catalog. It carries DMP identifiers and is PHI; access requires the appropriate approvals. The table is not restricted by Part A consent in its own SQL (the cohort is hard-coded); confirm consent status for the cohort before sharing data externally.

Expected use: resolve the cohort's H&E slides to S3 objects for transfer or processing.

### Vocabulary <a name="vocab"></a>

Primary key: (`image_id`, `sample_id`). In the current data `image_id` is also unique on its own (see Notes), but that is not guaranteed by the SQL.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| cancer | Cancer cohort label assigned to the patient in the hard-coded cohort list | Categorical | string | `breast`, `nsclc` (non-small cell lung cancer), `crc` (colorectal cancer) |
| patient_id | Patient-level DMP ID | ID | string | `P-XXXXXXX` |
| sample_id | Sample-level DMP ID of the IMPACT sample the slide is matched to | ID | string | `P-XXXXXXX-TNN-IMn` |
| image_id | Slide ID for the whole-slide image | ID | string | Numeric digits (e.g. `2805051`); range 416712 to 8538455. Stored as string; do not cast to integer for joins |
| stain_group | Stain category of the slide, inherited from `impact_part_matched_slides_v2`. Only H&E values appear because of the SQL filter | Categorical | string (varchar(18)) | `H&E (Initial)`, `H&E (Other)` |
| path | Full S3 path to the slide file | ID | string | `s3://mskmind-bkt/reef-slides/<image_id>.svs` |
| size | Size of the slide file in bytes | Continuous | long | bytes |

## Notes <a name="notes"></a>

1. <b>Hard-coded cohort.</b> Only 20 patients can ever appear, regardless of how `impact_part_matched_slides_v2` changes. Row counts can still change on refresh if upstream matches or slide inventory change.

2. <b>Patient count per cohort is small and uneven.</b> Slides per patient range from 2 (P-0008359) to 34 (P-0105358). Per-`cancer` statistics reflect only 3 breast and 5 NSCLC patients.

3. <b>H&E only.</b> `stain_group` is never NULL and takes only `H&E (Initial)` (259 rows) and `H&E (Other)` (82 rows). Samples can have only `H&E (Other)` slides: 5 of 45 samples have no `H&E (Initial)` slide.

4. <b>Multiple slides per sample.</b> 42 of 45 samples have more than one slide row (341 slides over 45 samples).

5. <b>Currently one row per slide.</b> 341 rows, 341 distinct `image_id`s, 341 distinct `path`s. Unlike other IMPACT-matched tables, no slide fans out across multiple samples in this cohort. The SQL only de-duplicates per (`sample_id`, `image_id`), so a future refresh could repeat an `image_id` if a slide matches more than one sample. Count `DISTINCT image_id` for slide counts.

6. <b>One storage path per slide, all in the REEF bucket.</b> All 341 paths are under `s3://mskmind-bkt/reef-slides/`, all `.svs`, and each equals `s3://mskmind-bkt/reef-slides/<image_id>.svs`. The preference for the REEF bucket in the SQL only matters if a slide has copies elsewhere.

7. <b>No nulls and consistent identifiers.</b> `cancer`, `patient_id`, `sample_id`, `image_id`, `stain_group`, `path`, and `size` have 0 nulls. All `sample_id`s begin with their row's `patient_id`. `size` is always positive.

8. <b>patient_id to cancer is many-to-one, sample_id to patient_id is many-to-one.</b> Each patient has exactly one `cancer` label, and each sample belongs to exactly one patient (both queries below return 0 rows).

   ```
   SELECT patient_id, count(DISTINCT cancer) AS ct FROM cdsi_eng_phi.pdm_natera.natera_slide_inventory_v1 GROUP BY patient_id HAVING ct > 1
   SELECT sample_id, count(DISTINCT patient_id) AS ct FROM cdsi_eng_phi.pdm_natera.natera_slide_inventory_v1 GROUP BY sample_id HAVING ct > 1
   ```

9. <b>Slide file sizes vary widely.</b> From ~11 MB to ~2.8 GB per slide, with a mean around 1.0 GB. Plan transfer volume (~349 GB total) and compute accordingly.

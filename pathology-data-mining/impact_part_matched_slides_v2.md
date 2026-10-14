# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_part_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_part_matched_slides_v2` (identical), `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (de-identified, see note 8) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md) and [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql)

<b>Summary Statistics</b> (2026-10-14):

Total rows: 841,468 <br/>
Unique image_ids (slides): 824,503 <br/>
IMPACT patients: 81,872 (89.3% of the 91,639 IMPACT341/410/468/505 patients in `pathology_dmp_genomics`) <br/>
IMPACT samples: 95,525 <br/>
Distinct specimen_ids: 94,773 <br/>
Distinct block_ids: 394,507 (84,499 rows have no block) <br/>
Slide capture dates: 2013-09-03 to 2026-10-13 <br/>

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 271,966 | 271,506 | 66,824 | 57,720 |
| inferred_single_block | 31,675 | 31,571 | 14,601 | 14,283 |
| part | 537,827 | 524,837 | 66,917 | 60,206 |

| match_type | Outside material: rows (patients) | MSK material: rows (patients) |
|---|---|---|
| block | 26,584 (4,070) | 245,382 (54,007) |
| inferred_single_block | 30,781 (14,011) | 894 (277) |
| part | 96,829 (23,604) | 440,998 (38,427) |

| label_era | Rows | Patients |
|---|---|---|
| copath | 661,832 | 71,587 |
| epic | 179,636 | 13,620 |

| stain_group | Rows |
|---|---|
| H&E (Initial) | 349,078 |
| IHC | 154,900 |
| (blank) | 152,634 |
| Surgical Submitted | 86,433 |
| H&E (Other) | 77,830 |
| Other | 10,321 |
| Frozen | 6,264 |
| SS | 4,008 |

Magnification: 40x 609,364; 20x 227,209; NA 3,789; 25x 1,100; other 6.


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (HOBBIT `image_id`) matched to MSK-IMPACT samples at the **part (specimen) level**, covering both pre-Epic (CoPath) and post-Epic data. It supersedes the part-level [impact-matched-slides](impact-matched-slides.md) (`impact_matched_slides_v1`): 81,872 patients here versus 75,477 in v1.

A slide matches a sample when the slide's HOBBIT specimen (`accession/part`) equals a specimen named in the sample's DMP `part_description`, and the DMP and HOBBIT MRNs agree. Each row also records how precisely the slide's block is known (`match_type`).
* `block`: the slide's block equals the block named in the DMP text.
* `inferred_single_block`: the DMP text names only the part, or a bare block number that matches nothing, and HOBBIT has exactly one distinct block label for that part.
* `part`: only the specimen matches.

Use [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md) when only block-level matches are wanted.

### Vocabulary <a name="vocab"></a>

Primary key: (`sample_id`, `image_id`)

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| patient_id | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| sample_id | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| m_accession_number | Molecular (M) accession; 1:1 with sample_id | ID (PHI) | string | |
| mrn | Patient MRN | ID (PHI) | string | 8 digits, zero-padded |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505 |
| specimen_id | Matched specimen, accession unpadded | ID (PHI) | string | `accession/part` |
| block_id | HOBBIT block of the slide; NULL when the slide has no block label | ID (PHI) | string | `accession/part-block_label` |
| is_block_match | Slide block equals a DMP block id for the sample | Categorical | boolean | true/false |
| match_type | Precision of the match | Categorical | string | `block`, `inferred_single_block`, `part` |
| dmp_block_ids | All DMP block ids for this sample and specimen | ID (PHI) | array&lt;string&gt; | empty when DMP named only the part |
| outside_accession_numbers | Outside accessions named in the DMP text | ID (PHI) | array&lt;string&gt; | |
| image_id | HOBBIT slide identifier | ID | string | |
| img_hid | HOBBIT image hash identifier | ID (PHI) | string | |
| barcode | Slide barcode; contains the accession | ID (PHI) | string | |
| accession_number | HOBBIT accession as recorded (Epic accessions zero-padded) | ID (PHI) | string | |
| part_number | HOBBIT part number | ID | string | |
| block_number | HOBBIT block instance | ID | string | |
| block_label | HOBBIT block label (whitespace removed) | ID (PHI) | string | may embed outside accessions |
| block_label_deid | block_label when it is a plain block label, else NULL | ID | string | e.g. `3GI`, `1CB-F`, `A` |
| label_era | Block label system by slide capture date | Categorical | string | `copath` (captured before 2025-03-31), `epic` |
| is_outside_material | Tissue came from another institution: submitted slides, or outside blocks recut at MSK | Categorical | boolean | true/false; see note 6 |
| part_type | HOBBIT part type | Categorical | string | |
| part_description | HOBBIT part description | Natural Language Description (PHI) | string | |
| stain_number | Stain instance | ID | string | |
| stain_name | Stain name | Categorical | string | |
| stain_group | Stain group | Categorical | string | see summary |
| scanner_id / brand / model | Scanner | Categorical | string | |
| magnification | Scan magnification | Categorical | string | `20x`, `40x`, … |
| file_size_bytes | Slide file size | Continuous | bigint | bytes |
| datetime_accession, signout_datetime, captured_datetime | Case accession, sign-out and slide capture times | Continuous | timestamp | PHI |
| CREATE_DATE, UPDATE_DATE | HOBBIT record timestamps | Continuous | timestamp | |

## Notes <a name="notes"></a>

1. <b>Primary key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT sample_id, image_id) FROM cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2  -- 0
   ```

2. <b>Mild multi-sample fan-out.</b> A slide repeats once per matching sample, for example when several IMPACT samples were sequenced from the same part. 810,565 slides map to 1 sample, 11,683 to 2, 1,769 to 3 and 486 to 4–7.
   ```sql
   SELECT n, count(*) FROM (SELECT image_id, count(DISTINCT sample_id) n FROM cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2 GROUP BY 1) GROUP BY 1
   ```

3. <b>Accession normalization.</b> Epic accessions are zero-padded in HOBBIT (`S25-012345`). `specimen_id` and `block_id` use the unpadded form (`S25-12345`); `accession_number` keeps the HOBBIT form.

4. <b>MRN guard.</b> Matches are dropped when the DMP MRN and the HOBBIT MRN differ. This affects 184 samples, mostly accession typos that point to another patient.

5. <b>Slides without a block label</b> (84,499 rows, `block_id` NULL) are always `part`. 82,447 are outside submitted slides (`is_outside_material`), which never had an MSK block; the remaining 2,052 are FNA or fluid cytology.

6. <b>is_outside_material</b> is derived from HOBBIT `part_type` / `stain_name`:
   * CoPath: `SURGICAL/CYTO/HEME SUBMITTED SLIDES`, `PRIVATE CONSULT`, stain `SLIDES SUBMITTED` / `BLOCK SUBMITTED`
   * Epic: `SSL …` part types and stains, `TYPE I/II … CONSULT`

   `inferred_single_block` is 98% outside material.

7. <b>label_era is by capture date.</b> Every `epic` row has an Epic-style label. 43k `copath` rows (scanned shortly before the cutover) also carry Epic-style labels. Matching does not depend on `label_era`.

8. <b>Research copies.</b>
   * `cdsi_res_phi`: identical copy.
   * `cdsi_res_deid`: drops mrn, m_accession_number, accession_number, specimen_id, block_id, dmp_block_ids, outside_accession_numbers, block_label, img_hid, barcode, part_description and all timestamps. `sample_id` / `patient_id` + `image_id` are the identifiers.
   * Product copy: [pdm_product_cdsi/impact_part_matched_slides_v2](../pdm_product_cdsi/impact_part_matched_slides_v2.md).

9. <b>Coverage gaps.</b> Of the 91,639 target patients, those not matched are mostly:
   * specimens that were never scanned in HOBBIT (7,404 samples);
   * liquid biopsies and blood (2,925 samples);
   * outside-only references with no MSK accession (2,074 samples).

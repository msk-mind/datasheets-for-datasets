# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_part_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_part_matched_slides_v2` (identical), `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (de-identified, see note 9) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`; gated by `validate_impact_matched_slides_v2`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md) and [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql)

<b>Summary Statistics</b> (dev build of pdm_databricks_pipelines #49–#51, 2026-10-14; refresh after the prod deploy):

Total rows: 926,803 (v1 `impact_matched_slides_v1` ∪ `impact_block_matched_slides_v1`: 709,573 sample–slide pairs) <br/>
Unique image_ids (slides): 909,505 <br/>
IMPACT patients: 89,339 (97.5% of the 91,639 IMPACT341/410/468/505 patients in `pathology_dmp_genomics`) <br/>
IMPACT samples: 104,415 <br/>
Rows without a HOBBIT block label (`block_id` NULL): 165,203 <br/>

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 353,127 | 352,664 | 98,629 | 84,876 |
| inferred_single_block | 32,345 | 32,216 | 14,868 | 14,531 |
| part | 541,331 | 528,100 | 67,599 | 60,751 |

| match_type | Outside material: rows (patients) | MSK material: rows (patients) |
|---|---|---|
| block | 26,453 (4,059) | 326,674 (81,206) |
| inferred_single_block | 31,134 (14,180) | 1,211 (361) |
| part | 97,935 (23,895) | 443,396 (38,720) |

Slides filed under the sample's own M accession (`link_sources = ['m_accession']`): 80,403 rows, 74,210 samples, 65,916 patients. All are `block`. 79,346 of them have no block label.

| label_era | Rows | Patients |
|---|---|---|
| copath | 748,169 | 79,111 |
| epic | 178,634 | 13,571 |

| stain_group | Rows |
|---|---|
| H&E (Initial) | 351,823 |
| IHC | 155,351 |
| (blank) | 152,350 |
| H&E (Other) | 150,956 |
| Surgical Submitted | 87,584 |
| Other | 18,376 |
| Frozen | 6,345 |
| SS | 4,018 |

`IS_HNE` = 1 on 502,779 rows; `IS_IHC` = 1 on 155,351 rows. Magnification: 40x 641,314; 20x 280,250; NA 4,112; 25x 1,121; other 6.


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (HOBBIT `image_id`) matched to MSK-IMPACT samples at the **part (specimen) level**, covering both pre-Epic (CoPath) and post-Epic data. It supersedes the part-level [impact-matched-slides](impact-matched-slides.md) (`impact_matched_slides_v1`) and keeps every v1 match except deliberate exclusions (note 3).

A slide matches a sample in either of two ways, provided the DMP and HOBBIT MRNs agree:
* the slide's HOBBIT specimen (`accession/part`) equals a specimen linked to the sample by any `link_source` in [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md);
* the slide is filed in HOBBIT under the sample's own M accession. These are DMP recuts of the sequenced material. Matched-normal material filed under the M accession (NORMAL / BLOOD) is excluded.

Each row records how precisely the sequenced block is known (`match_type`):
* `block`: the slide's block equals a linked block, or the slide is filed under the sample's M accession.
* `inferred_single_block`: the links name only the part, or a bare block number that matches nothing, and HOBBIT has exactly one distinct block label for that part.
* `part`: only the specimen matches.

Use [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md) when only block-level matches are wanted. Clinical annotations (cancer type, OncoTree, tumor purity, TMB, …) are deliberately not copied in; join `product_cdsi.msk_impact.data_clinical_sample` on `sample_id`.

### Vocabulary <a name="vocab"></a>

Primary key: (`sample_id`, `image_id`)

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| patient_id | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| sample_id | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| m_accession_number | Molecular (M) accession | ID (PHI) | string | |
| mrn | Patient MRN | ID (PHI) | string | 8 digits, zero-padded |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505 |
| specimen_id | Matched HOBBIT specimen, accession unpadded | ID (PHI) | string | `accession/part` |
| block_id | HOBBIT block of the slide; NULL when the slide has no block label | ID (PHI) | string | `accession/part-block_label` |
| is_block_match | `match_type = 'block'` | Categorical | boolean | true/false |
| match_type | Precision of the match | Categorical | string | `block`, `inferred_single_block`, `part` |
| link_sources | Link sources that connect the sample to this specimen | Categorical | array&lt;string&gt; | values of `impact_dmp_specimen_links_v1.link_source`; `['m_accession']` for M-accession slides |
| dmp_block_ids | All linked block ids for this sample and specimen | ID (PHI) | array&lt;string&gt; | empty when only the part is linked |
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
| is_outside_material | Tissue came from another institution (submitted slides, or outside blocks recut at MSK); false for M-accession slides | Categorical | boolean | see note 6 |
| part_type | HOBBIT part type | Categorical | string | |
| part_description | HOBBIT part description | Natural Language Description (PHI) | string | |
| PATH_DX_SPEC_TITLE | Surgical diagnosis title for the specimen (`surgical_specimen_diagnoses_combined`) | Natural Language Description (PHI) | string | NULL when absent or conflicting |
| PATH_DX_SPEC_DESC | Surgical diagnosis text for the specimen | Natural Language Description (PHI) | string | NULL when absent or conflicting |
| DATE_OF_PROCEDURE_SURGICAL | Recorded procedure date for the sample (DOP annotation, Epic/IDB combined) | Continuous (PHI) | date | NULL when absent or conflicting |
| DATE_OF_PROCEDURE_SURGICAL_EST | Estimated procedure date for the sample | Continuous (PHI) | date | |
| DOP_COMPUTE_SOURCE | Source of the procedure date estimate | Categorical | string | `Specimens Submitted`, `Surgical`, `Surgical & IR`, `IR` |
| block_dop | Procedure date for the block (`copath_molecular_links_cleaned_v2.dop`, CoPath only) | Continuous (PHI) | date | |
| stain_number | Stain instance | ID | string | |
| stain_name | Stain name | Categorical | string | |
| stain_group | Stain group | Categorical | string | see summary |
| IS_HNE | stain_group is `H&E (Initial)` or `H&E (Other)` | Categorical | int | 1/0 |
| IS_IHC | stain_group is `IHC` | Categorical | int | 1/0 |
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

2. <b>Mild multi-sample fan-out.</b> A slide repeats once per matching sample. 895,242 slides map to 1 sample, 12,000 to 2, 1,777 to 3 and 486 to 4–7.

3. <b>Parity with v1 is enforced.</b> `validate_impact_matched_slides_v2` fails `pdm_catalogs_job`, and blocks the research refresh, if more than 100 v1 (sample, slide) pairs are missing without an exclusion reason. The allowed exclusions are:
   * the sample is not on IMPACT341/410/468/505 in `pathology_dmp_genomics` (mostly IMPACT-HEME);
   * the slide is not in `case_breakdown_cleaned_v2` or has no part;
   * the HOBBIT MRN differs from the DMP MRN;
   * the slide is filed under another sample's M accession (e.g. extracted lysate);
   * the slide is matched-normal material under the M accession.

   33 pairs (12 samples) are currently unexplained: v1 `hobbit_copath_v1` accession-level rescues that no current source records.

4. <b>Accession normalization.</b> Epic accessions are zero-padded in HOBBIT (`S25-012345`). `specimen_id` and `block_id` use the unpadded form; `accession_number` keeps the HOBBIT form.

5. <b>Slides without a block label</b> (`block_id` NULL, 165,203 rows):
   * 79,346 are M-accession slides (`block`);
   * 83,636 are outside submitted slides, which never had an MSK block (`part`);
   * the rest are FNA or fluid cytology.

6. <b>is_outside_material</b> is derived from HOBBIT `part_type` / `stain_name`:
   * CoPath: `SURGICAL/CYTO/HEME SUBMITTED SLIDES`, `PRIVATE CONSULT`, stain `SLIDES SUBMITTED` / `BLOCK SUBMITTED`
   * Epic: `SSL …` part types and stains, `TYPE I/II … CONSULT`

   It is always false for M-accession slides, which are DMP recuts (`DM SUBMITTED SLIDES`).

7. <b>label_era is by capture date.</b> Every `epic` row has an Epic-style label. Some `copath` rows scanned shortly before the cutover also carry Epic-style labels. Matching does not depend on `label_era`.

8. <b>Procedure dates and diagnosis text are raw inputs.</b> A value that conflicts across duplicate source rows is NULL. Consumers apply their own precedence; for example, `wsi_canonical_associations_pipeline` uses `block_dop`, then `DATE_OF_PROCEDURE_SURGICAL`, then accession dates, then the verified estimate. Coverage: recorded surgical date on 94,207 samples, `block_dop` on 35,207 rows, diagnosis title and text on 813,279 rows.

9. <b>Research copies.</b>
   * `cdsi_res_phi`: identical copy.
   * `cdsi_res_deid`: drops mrn, m_accession_number, accession_number, specimen_id, block_id, dmp_block_ids, outside_accession_numbers, block_label, img_hid, barcode, part_description, PATH_DX_SPEC_TITLE, PATH_DX_SPEC_DESC, all dates and timestamps. `sample_id` / `patient_id` + `image_id` are the identifiers; `link_sources`, `IS_HNE`, `IS_IHC` are kept.
   * Product copy: [pdm_product_cdsi/impact_part_matched_slides_v2](../pdm_product_cdsi/impact_part_matched_slides_v2.md).

10. <b>Unmatched target samples.</b> 4,216 of the 108,631 target samples are unmatched:
    * 2,184 have no accession at all (liquid biopsy / blood);
    * 1,928 have a linked specimen with no slides for the patient in HOBBIT;
    * 52 have only an outside accession;
    * 52 are other.

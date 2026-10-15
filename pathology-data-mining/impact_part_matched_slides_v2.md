# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_part_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_part_matched_slides_v2` (without diagnosis text), `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (de-identified, see note 9) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`; gated by `validate_impact_matched_slides_v2`) <br/>
<b>Date created or last updated:</b> 2026-10-15 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md) and [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql)

<b>Summary Statistics</b> (prod, 2026-10-15):

Total rows: 928,499 (v1 `impact_matched_slides_v1` ∪ `impact_block_matched_slides_v1`: ~710k sample–slide pairs) <br/>
Unique image_ids (slides): 911,189 <br/>
IMPACT patients: 89,382 (97.5% of the 91,639 IMPACT341/410/468/505 patients in `pathology_dmp_genomics`) <br/>
IMPACT-HEME (from pdm_databricks_pipelines#59, prod 2026-10-15): +5,440 patients, 6,249 samples, 106,619 slides (25% of 21,394 IMPACT-HEME patients; most IMPACT-HEME samples are blood or marrow, and 89% of tissue samples match) <br/>
IMPACT samples: 104,472 <br/>
Rows without a HOBBIT block label (`block_id` NULL): 165,039 <br/>

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 354,033 | 353,570 | 98,685 | 84,920 |
| inferred_single_block | 32,350 | 32,221 | 14,867 | 14,530 |
| part | 542,116 | 528,879 | 67,665 | 60,805 |

| match_type | Outside material: rows (patients) | MSK material: rows (patients) |
|---|---|---|
| block | 26,722 (4,090) | 327,311 (81,222) |
| inferred_single_block | 31,139 (14,179) | 1,211 (361) |
| part | 98,063 (23,906) | 444,053 (38,768) |

Slides filed under the sample's own M accession (`link_sources = ['m_accession']`): 80,192 rows, 74,148 samples, 65,865 patients. All are `block`. 79,182 of them have no block label.

| label_era | Rows | Patients |
|---|---|---|
| copath | 747,958 | 79,090 |
| epic | 180,541 | 13,681 |

| stain_group | Rows |
|---|---|
| H&E (Initial) | 351,823 |
| IHC | 156,076 |
| (blank) | 153,399 |
| H&E (Other) | 150,886 |
| Surgical Submitted | 87,584 |
| Other | 18,360 |
| Frozen | 6,348 |
| SS | 4,023 |

Stain decision (`stain_label`, from [slide_stain_resolved_v1](slide_stain_resolved_v1.md)):

| stain_label | stain_classification_source | Rows |
|---|---|---|
| he | metadata | 621,506 |
| he | image_model_fallback | 51,910 |
| he | he (manual review) | 28 |
| ihc | metadata | 174,350 |
| ihc | image_model_fallback | 18,323 |
| ihc | image_model | 212 |
| other | metadata_fallback | 25,010 |
| unknown | metadata_fallback | 37,150 |

`IS_HNE` = 1 on 673,444 rows; `IS_IHC` = 1 on 192,895 rows. Magnification: 40x 643,134; 20x 280,101; NA 4,137; 25x 1,121; other 6.


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (HOBBIT `image_id`) matched to MSK-IMPACT samples at the **part (specimen) level**, covering both pre-Epic (CoPath) and post-Epic data. It supersedes the part-level [impact-matched-slides](impact-matched-slides.md) (`impact_matched_slides_v1`) and keeps every v1 match except deliberate exclusions (note 3). Samples on the IMPACT-HEME panels are included from pdm_databricks_pipelines#59; filter `gene_panel` for solid-tumor panels only.

A slide matches a sample in either of two ways, provided the DMP and HOBBIT MRNs agree:
* the slide's HOBBIT specimen (`accession/part`) equals a specimen linked to the sample by any `link_source` in [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md);
* the slide is filed in HOBBIT under the sample's own M accession, on the sequenced part when the DOP annotation records it. These are DMP recuts of the sequenced material. Matched-normal material filed under the M accession (NORMAL / BLOOD) is excluded.

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
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505, IMPACT-HEME-400, IMPACT-HEME-468, IMPACT-HEME-HS |
| specimen_id | Matched HOBBIT specimen, accession unpadded | ID (PHI) | string | `accession/part` |
| block_id | HOBBIT block of the slide; NULL when the slide has no block label | ID (PHI) | string | `accession/part-block_label` |
| is_block_match | `match_type = 'block'` | Categorical | boolean | true/false |
| match_type | Precision of the match | Categorical | string | `block`, `inferred_single_block`, `part` |
| link_sources | Link sources that connect the sample to this specimen | Categorical | array&lt;string&gt; | values of `impact_dmp_specimen_links_v1.link_source`; `['m_accession']` for M-accession slides |
| dmp_block_ids | All linked block ids for this sample and specimen | ID (PHI) | array&lt;string&gt; | empty when only the part is linked |
| outside_accession_numbers | Outside accessions named in the DMP text | ID (PHI) | array&lt;string&gt; | |
| accession_key | De-identified HOBBIT accession (note 11) | ID | string | 32 hex chars |
| accession_specimen_key | De-identified `specimen_id` | ID | string | `accession_key/part` |
| accession_block_key | De-identified `block_id`; NULL when `block_id` is NULL | ID | string | `accession_key/part-label` |
| dmp_accession_block_keys | `dmp_block_ids` in the same form | ID | array&lt;string&gt; | |
| outside_accession_keys | De-identified `outside_accession_numbers`, scoped to the patient | ID | array&lt;string&gt; | 32 hex chars |
| image_id | HOBBIT slide identifier | ID | string | |
| slide_key | De-identified slide identifier, identical to the WSI pipeline and cBioPortal `slide_key` (note 11) | ID | string | 32 hex chars |
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
| stain_label | Per-slide stain decision shared with the WSI pipeline (HOBBIT metadata + approved H-Optimus classifications + manual review) | Categorical | string | `he`, `ihc`, `other`, `unknown` |
| stain_classification_source | What decided `stain_label` | Categorical | string | `metadata`, `image_model`, `image_model_fallback`, `metadata_fallback`, `he` / `ihc` (manual review) |
| IS_HNE | `stain_label = 'he'` | Categorical | int | 1/0 |
| IS_IHC | `stain_label = 'ihc'` | Categorical | int | 1/0 |
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

2. <b>Mild multi-sample fan-out.</b> A slide repeats once per matching sample. 896,914 slides map to 1 sample, 12,012 to 2, 1,777 to 3 and 486 to 4–7.

3. <b>Parity with v1 is enforced.</b> `validate_impact_matched_slides_v2` fails `pdm_catalogs_job`, and blocks the research refresh, if more than 100 v1 (sample, slide) pairs are missing without an exclusion reason. The allowed exclusions are:
   * the sample is not on an IMPACT solid or IMPACT-HEME panel in `pathology_dmp_genomics` (e.g. ACCESS; before #59 this also excluded IMPACT-HEME);
   * the slide is not in `case_breakdown_cleaned_v2` or has no part;
   * the HOBBIT MRN differs from the DMP MRN;
   * the slide is filed under another sample's M accession (e.g. extracted lysate);
   * the slide is matched-normal material under the M accession.

   33 pairs (12 samples) are currently unexplained: v1 `hobbit_copath_v1` accession-level rescues that no current source records.

4. <b>Accession normalization.</b> Epic accessions are zero-padded in HOBBIT (`S25-012345`). `specimen_id` and `block_id` use the unpadded form; `accession_number` keeps the HOBBIT form.

5. <b>Slides without a block label</b> (`block_id` NULL, 165,039 rows):
   * 79,182 are M-accession slides (`block`);
   * 83,636 are outside submitted slides, which never had an MSK block (`part`);
   * the rest are FNA or fluid cytology.

6. <b>is_outside_material</b> is derived from HOBBIT `part_type` / `stain_name`:
   * CoPath: `SURGICAL/CYTO/HEME SUBMITTED SLIDES`, `PRIVATE CONSULT`, stain `SLIDES SUBMITTED` / `BLOCK SUBMITTED`
   * Epic: `SSL …` part types and stains, `TYPE I/II … CONSULT`

   It is always false for M-accession slides, which are DMP recuts (`DM SUBMITTED SLIDES`).

7. <b>label_era is by capture date.</b> Every `epic` row has an Epic-style label. Some `copath` rows scanned shortly before the cutover also carry Epic-style labels. Matching does not depend on `label_era`.

8. <b>Procedure dates and diagnosis text are raw inputs.</b> A value that conflicts across duplicate source rows is NULL. Consumers apply their own precedence; for example, `wsi_canonical_associations_pipeline` uses `block_dop`, then `DATE_OF_PROCEDURE_SURGICAL`, then accession dates, then the verified estimate. Coverage: recorded surgical date on 94,229 samples, `block_dop` on 35,207 rows, diagnosis title and text on 814,152 rows.

9. <b>Research copies.</b>
   * `cdsi_res_phi`: drops `PATH_DX_SPEC_TITLE` / `PATH_DX_SPEC_DESC` (no diagnosis text next to DMP IDs in res_phi); otherwise identical.
   * `cdsi_res_deid`: drops image_id, mrn, m_accession_number, accession_number, specimen_id, block_id, dmp_block_ids, outside_accession_numbers, block_label, img_hid, barcode, part_description, PATH_DX_SPEC_TITLE, PATH_DX_SPEC_DESC, all dates and timestamps. The identifiers are `sample_id` / `patient_id`, `slide_key` and the accession keys (note 11). `validate_impact_matched_slides_v2_res` fails the research job, and blocks the product job, unless the column list is exactly the expected one.
   * Product copy: [pdm_product_cdsi/impact_part_matched_slides_v2](../pdm_product_cdsi/impact_part_matched_slides_v2.md).

10. <b>Unmatched target samples.</b> 4,159 of the 108,631 target samples are unmatched:
    * 2,184 have no accession at all (liquid biopsy / blood);
    * 1,856 have a linked specimen with no slides for the patient in HOBBIT;
    * 67 have only an outside accession;
    * 52 are other.

11. <b>De-identified keys.</b> Each key is `SUBSTR(SHA2(salt || input, 256), 1, 32)`, salted with the WSI `slide_key` salt (`secret('pdm-wsi', 'slide_key_salt')`). Keys are stable from day to day while the salt is unchanged.
    * `slide_key` = hash of `':' || image_id`. It is byte-identical to the WSI pipeline and cBioPortal `slide_key`, so it joins to them directly. It is the only slide identifier in `cdsi_res_deid` and the product tier.
    * `accession_key` = hash of `':accession:' ||` the normalized HOBBIT accession (Epic zero padding removed). Specimen and block keys are built on it, so they nest: `accession_key` → `accession_key/part` → `accession_key/part-label`. A block label that is not a plain label (for example one that embeds an outside accession) is replaced by `h` + a salted hash scoped to the accession.
    * `outside_accession_keys` hash `':outside:' || patient_id || ':' ||` a canonical form of the outside accession. They are scoped to the patient because outside accession numbers are only unique within the issuing institution, which is not recorded.
    * These are not the WSI pipeline's `specimen_key` / `block_key`, which are derived from `slide_key`.
    * `validate_impact_matched_slides_v2` checks that the keys are well formed and one to one with the raw ids. It also checks that each exact block match's `accession_block_key` is among its `dmp_accession_block_keys`, and that `slide_key` equals the WSI value on every shared slide, with at least 50% of slides compared.


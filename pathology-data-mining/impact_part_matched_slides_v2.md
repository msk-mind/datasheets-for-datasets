# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_part_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_part_matched_slides_v2` (PHI ids, no de-identified ids), `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (de-identified ids only); see note 9 <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`; gated by `validate_impact_matched_slides_v2`) <br/>
<b>Date created or last updated:</b> 2026-11-16 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [impact_dmp_specimen_links_v1](impact_dmp_specimen_links_v1.md), [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md) and [slide_stain_resolved_v1](slide_stain_resolved_v1.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_part_matched_slides_v2.sql)

<b>Summary Statistics</b> (prod, 2026-11-16):

Total rows: 1,049,664 <br/>
Unique image_ids (slides): 1,030,647 <br/>
IMPACT patients / samples: 95,344 / 111,608 <br/>
Rows without a HOBBIT block label (`block_id` NULL): 185,318 <br/>

| Panels | Target patients / samples (`pathology_dmp_genomics`) | Matched patients | Matched samples | Slides |
|---|---|---|---|---|
| Solid (IMPACT341/410/468/505) | 92,305 / 109,453 | **90,037 (97.5%)** | 105,267 | 922,394 |
| IMPACT-HEME (-400/-468/-HS, from pdm_databricks_pipelines#59) | 21,709 / 44,899 | **5,513 (25%)** | 6,341 | 108,439 |

Most IMPACT-HEME samples are blood or marrow and have no surgical specimen; about 89% of IMPACT-HEME tissue samples match.

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 410,263 | 409,429 | 105,067 | 90,296 |
| inferred_single_block | 42,402 | 42,183 | 16,157 | 15,774 |
| part | 596,999 | 582,856 | 72,078 | 64,670 |

| match_type | Outside material: rows (patients) | MSK material: rows (patients) |
|---|---|---|
| block | 33,321 (4,665) | 376,942 (86,084) |
| inferred_single_block | 40,992 (15,403) | 1,410 (381) |
| part | 119,821 (25,519) | 477,178 (41,190) |

| label_era | Rows | Patients |
|---|---|---|
| copath | 830,539 | 83,336 |
| epic | 219,125 | 15,818 |

Stain decision (`stain_label`, from [slide_stain_resolved_v1](slide_stain_resolved_v1.md)):

| stain_label | stain_classification_source | Rows |
|---|---|---|
| he | metadata | 653,804 |
| he | image_model_fallback | 55,424 |
| he | image_model_downgrade | 9,515 |
| he | he (manual review) | 137 |
| ihc | metadata | 233,433 |
| ihc | image_model_fallback | 25,709 |
| ihc | image_model | 188 |
| ihc | ihc (manual review) | 53 |
| other | metadata_fallback | 26,800 |
| unknown | metadata_fallback | 44,601 |

`IS_HNE` = 1 on 718,880 rows; `IS_IHC` = 1 on 259,383 rows.


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
| image_id | HOBBIT slide identifier | ID | string | |
| image_deid | De-identified slide identifier, equal to the WSI / cBioPortal `slide_key` (note 11) | ID | string | 12 lower-case hex chars |
| img_hid | HOBBIT image hash identifier | ID (PHI) | string | |
| barcode | Slide barcode; contains the accession | ID (PHI) | string | |
| accession_number | HOBBIT accession as recorded (Epic accessions zero-padded) | ID (PHI) | string | |
| s_accession_deid | De-identified HOBBIT accession of the slide (note 11) | ID | string | 12 lower-case hex chars |
| part_number | HOBBIT part number | ID | string | |
| block_number | HOBBIT block instance | ID | string | |
| block_label | HOBBIT block label (whitespace removed) | ID (PHI) | string | may embed outside accessions |
| block_label_deid | block_label when it is a plain block label, else NULL; published as `block_label` in res_deid / product | ID | string | e.g. `3GI`, `1CB-F`, `A` |
| block_deid | De-identified block (note 11); NULL when the slide has no block label | ID | string | `s_accession_deid/part-label` |
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
| stain_classification_source | What decided `stain_label` | Categorical | string | `metadata`, `image_model`, `image_model_fallback`, `image_model_downgrade`, `metadata_fallback`, `he` / `ihc` (manual review) |
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

2. <b>Mild multi-sample fan-out.</b> A slide repeats once per matching sample (2026-10-15, solid panels: 896,914 slides map to 1 sample, 12,012 to 2, 1,777 to 3 and 486 to 4–7).

3. <b>Parity with v1 is enforced.</b> `validate_impact_matched_slides_v2` fails `pdm_catalogs_job`, and blocks the research refresh, if more than 100 v1 (sample, slide) pairs are missing without an exclusion reason. The allowed exclusions are:
   * the sample is not on an IMPACT solid or IMPACT-HEME panel in `pathology_dmp_genomics` (e.g. ACCESS; before #59 this also excluded IMPACT-HEME);
   * the slide is not in `case_breakdown_cleaned_v2` or has no part;
   * the HOBBIT MRN differs from the DMP MRN;
   * the slide is filed under another sample's M accession (e.g. extracted lysate);
   * the slide is matched-normal material under the M accession.

   33 pairs (12 samples) were unexplained on 2026-10-15: v1 `hobbit_copath_v1` accession-level rescues that no current source records.

4. <b>Accession normalization.</b> Epic accessions are zero-padded in HOBBIT (`S25-012345`). `specimen_id` and `block_id` use the unpadded form; `accession_number` keeps the HOBBIT form.

5. <b>Slides without a block label</b> (`block_id` NULL, 185,318 rows): mostly M-accession slides (`block`) and outside submitted slides, which never had an MSK block (`part`); the rest are FNA or fluid cytology. (On 2026-10-15, solid panels only: 79,182 M-accession and 83,636 outside submitted of 165,039.)

6. <b>is_outside_material</b> is derived from HOBBIT `part_type` / `stain_name`:
   * CoPath: `SURGICAL/CYTO/HEME SUBMITTED SLIDES`, `PRIVATE CONSULT`, stain `SLIDES SUBMITTED` / `BLOCK SUBMITTED`
   * Epic: `SSL …` part types and stains, `TYPE I/II … CONSULT`

   It is always false for M-accession slides, which are DMP recuts (`DM SUBMITTED SLIDES`).

7. <b>label_era is by capture date.</b> Every `epic` row has an Epic-style label. Some `copath` rows scanned shortly before the cutover also carry Epic-style labels. Matching does not depend on `label_era`.

8. <b>Procedure dates and diagnosis text are raw inputs.</b> A value that conflicts across duplicate source rows is NULL. Consumers apply their own precedence; for example, `wsi_canonical_associations_pipeline` uses `block_dop`, then `DATE_OF_PROCEDURE_SURGICAL`, then accession dates, then the verified estimate. Coverage (2026-10-15, solid panels): recorded surgical date on 94,229 samples, `block_dop` on 35,207 rows, diagnosis title and text on 814,152 rows.

9. <b>Research copies</b> (semantic layering, pdm_databricks_pipelines#60 and later). Only this eng_phi table holds both PHI ids and de-identified ids, so no research tier holds the crosswalk.
   * `cdsi_res_phi`: PHI ids (accessions, `specimen_id`, `block_id`, `image_id`, `barcode`, `img_hid`) with `patient_id` / `sample_id`. It drops `mrn`, every `*_deid` column and the diagnosis text.
   * `cdsi_res_deid`: `patient_id`, `sample_id`, `s_accession_deid`, `part_number`, `block_label` (= `block_label_deid`), `block_deid`, `image_deid` and the non-identifying slide, match and stain attributes. Every PHI id, free text and date is dropped. It is read from eng_phi. `validate_impact_matched_slides_v2_res` fails the research job, and blocks the product job, unless res_deid has exactly the expected columns and res_phi has no `*deid*` or diagnosis-text column.
   * Product copy: [pdm_product_cdsi/impact_part_matched_slides_v2](../pdm_product_cdsi/impact_part_matched_slides_v2.md).

10. <b>Unmatched target samples</b> (2026-10-15, solid panels). 4,159 of the 108,631 target samples were unmatched:
    * 2,184 have no accession at all (liquid biopsy / blood);
    * 1,856 have a linked specimen with no slides for the patient in HOBBIT;
    * 67 have only an outside accession;
    * 52 are other.

11. <b>De-identified ids</b> (pdm_databricks_pipelines#60, replacing #56's 32-character keys). Each is the first 12 lower-case hex characters of `SHA-256(salt || domain || input)`, with the salt from `secret('pdm-wsi', 'slide_key_salt')`, shared with the WSI pipeline. Ids are stable from day to day while the salt is unchanged.
    * `image_deid`: domain `':'`, input `image_id`. Equal to the WSI / cBioPortal `slide_key` (12 characters since 2026-10-20). A slide listed in `cdsi_prod.pathology_data_mining.slide_key_overrides` hashes `image_id || ':' || salt_suffix` instead, in both pipelines, which resolves a rare 12-character collision without changing any published key.
    * `s_accession_deid`: domain `':accession:'`, input the normalized HOBBIT accession of the slide (Epic zero padding removed; the M accession for DMP recuts).
    * `block_deid` = `s_accession_deid || '/' || part_number || '-' || block label`. A label that is not a plain label (e.g. embeds an outside accession) becomes `h` plus a salted hash scoped to the accession.
    * `validate_impact_matched_slides_v2` checks the id format, that every id is one to one with its PHI id (a deterministic id cannot be retried, so a collision fails the build), and that `image_deid` equals the WSI `slide_key` on every shared slide, with at least 50% of slides compared.
    * Accepted risk (2026-10-15): product inventories still publish `image_id` with `SAMPLE_ID_IMPACT`, so `image_deid` ↔ `image_id` can be recovered by joining them.

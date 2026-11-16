# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_part_matched_slides_v2) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_product_cdsi_job`) <br/>
<b>Date created or last updated:</b> 2026-11-16 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (see [pathology-data-mining/impact_part_matched_slides_v2](../pathology-data-mining/impact_part_matched_slides_v2.md)).

<b>Summary Statistics</b> (prod, 2026-11-16):

Total rows: 972,310 <br/>
Unique image_deids (slides): 955,640 <br/>
Unique PATIENT_ID_IMPACT: 88,050 (solid panels 83,607; IMPACT-HEME 4,643) <br/>
Unique SAMPLE_ID_IMPACT: 103,483 <br/>

| match_type | Rows | Patients | Samples |
|---|---|---|---|
| block | 379,593 | 83,755 | 97,825 |
| inferred_single_block | 37,279 | 14,476 | 14,831 |
| part | 555,438 | 60,156 | 67,162 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 797,595 | 80,585 |
| true | 174,715 | 29,443 |

| stain_label | Rows |
|---|---|
| he | 675,533 |
| ihc | 232,614 |
| unknown | 39,809 |
| other | 24,354 |

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (H&E and IHC) matched to MSK-IMPACT samples **at the part (specimen) level**, for both pre-Epic (CoPath) and post-Epic data. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent. It supersedes [impact_matched_slides_v1](impact_matched_slides_v1.md).

Every row carries a `match_type` that says how precisely the slide's block is known. Slides filed under the sample's own molecular (M) accession, which are DMP recuts of the sequenced material, count as `block`. For block-level matches only, use [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md). Samples on the IMPACT-HEME panels are included (pdm_databricks_pipelines#59); filter `gene_panel` for solid-tumor panels only. Clinical annotations are not included; join `product_cdsi.msk_impact.data_clinical_sample` on `SAMPLE_ID_IMPACT`.

### Vocabulary <a name="vocab"></a>

Primary key: (`SAMPLE_ID_IMPACT`, `image_deid`)

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_deid | De-identified slide ID; equal to the WSI viewer / cBioPortal `slide_key` | ID | string | 12 lower-case hex chars |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505, IMPACT-HEME-400, IMPACT-HEME-468, IMPACT-HEME-HS |
| is_block_match | `match_type = 'block'` | Categorical | boolean | true/false |
| match_type | Precision of the match | Categorical | string | `block`: exact block, or slide filed under the sample's M accession; `inferred_single_block`: only the part is known and it has one scanned block; `part`: specimen only |
| link_sources | How the sample was linked to the slide's specimen | Categorical | array&lt;string&gt; | `dmp_part_description`, `dop_anno`, `copath_molecular_links`, `m_accession` |
| s_accession_deid | De-identified accession of the slide's case | ID | string | 12 lower-case hex chars |
| block_deid | De-identified block (`s_accession_deid/part-label`); NULL when the slide has no block label | ID | string | |
| part_number | Part number within the surgical case | ID | string | |
| block_number | Block instance | ID | string | |
| block_label | Block label; NULL when absent or when the label embeds an outside accession | ID | string | CoPath e.g. `3GI`, Epic e.g. `A` |
| label_era | Block label system | Categorical | string | `copath` (slide captured before 2025-03-31), `epic` |
| is_outside_material | Tissue came from another institution (submitted slides, or outside blocks recut at MSK) | Categorical | boolean | true/false |
| part_type | Part type | Categorical | string | |
| stain_number | Stain instance | ID | string | |
| stain_name | Stain name | Categorical | string | |
| stain_group | Type of stain | Categorical | string | see summary |
| stain_label | Per-slide stain decision: HOBBIT metadata (including explicit antibody names), approved image classifications and manual review (same decision as the WSI viewer; see [slide_stain_resolved_v1](../pathology-data-mining/slide_stain_resolved_v1.md)) | Categorical | string | `he`, `ihc`, `other`, `unknown` |
| stain_classification_source | What decided `stain_label` | Categorical | string | `metadata`, `image_model`, `image_model_fallback`, `image_model_downgrade`, `metadata_fallback`, `he` / `ihc` (manual review) |
| IS_HNE | `stain_label = 'he'` | Categorical | int | 1/0 |
| IS_IHC | `stain_label = 'ihc'` | Categorical | int | 1/0 |
| scanner_id / brand / model | Scanner | Categorical | string | |
| magnification | Scan magnification | Categorical | string | `20x`, `40x`, … |
| file_size_bytes | Slide file size | Continuous | long | bytes |

## Notes <a name="notes"></a>

1. <b>Primary key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT SAMPLE_ID_IMPACT, image_deid) FROM cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2  -- 0
   ```

2. <b>Multi-sample fan-out.</b> A slide that matches several IMPACT samples appears once per `SAMPLE_ID_IMPACT`: 972,310 rows over 955,640 slides.

3. <b>Part A consent only.</b> 88,050 patients here versus 95,344 in the unrestricted `cdsi_res_deid.pdm_base_tables` copy.

4. <b>No accessions, image ids or dates.</b> Accession numbers, HOBBIT `image_id`, MRN, barcode, image hash, free-text part description and all timestamps are removed. Slides, accessions and blocks are identified by 12-character salted ids (`image_deid`, `s_accession_deid`, `block_deid`) that are stable from day to day; see note 11 of [the base datasheet](../pathology-data-mining/impact_part_matched_slides_v2.md#notes). `block_label` is NULL for labels that embed outside accessions.

5. <b>Outside material.</b> Slides with no block label are almost all outside submitted slides (`is_outside_material = true`, `match_type = 'part'`), which never had an MSK block.

6. <b>Use `stain_label` for stain.</b> `stain_group` is often blank or vague ("Surgical Submitted", "Other"). `stain_label` resolves most of these from explicit antibody names and the approved image classifier; 39,809 rows remain `unknown`, mostly slides with no image file to classify.

7. <b>Joining to other slide tables.</b> `image_deid` equals the WSI viewer / cBioPortal `slide_key` and joins to it directly. The product slide inventories (`msk_slide_inventory_v1`, `slides_with_diagnosis_v1`, the reef embedding inventories) still use `image_id`.

# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_part_matched_slides_v2) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_product_cdsi_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (see [pathology-data-mining/impact_part_matched_slides_v2](../pathology-data-mining/impact_part_matched_slides_v2.md)).

<b>Summary Statistics</b> (prod, 2026-10-15):

Total rows: 870,653 <br/>
Unique image_ids (slides): 855,597 <br/>
Unique PATIENT_ID_IMPACT: 83,033 <br/>
Unique SAMPLE_ID_IMPACT: 97,343 <br/>

| match_type | Rows | Patients | Samples |
|---|---|---|---|
| block | 331,322 | 79,164 | 92,268 |
| inferred_single_block | 29,781 | 13,500 | 13,814 |
| part | 509,550 | 56,909 | 63,393 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 725,892 | 76,348 |
| true | 144,761 | 27,565 |

| stain_label | Rows |
|---|---|
| he | 635,144 |
| ihc | 177,875 |
| unknown | 34,818 |
| other | 22,816 |

| stain_group | Rows |
|---|---|
| H&E (Initial) | 332,468 |
| IHC | 143,687 |
| H&E (Other) | 143,094 |
| (blank) | 142,860 |
| Surgical Submitted | 82,262 |
| Other | 16,735 |
| Frozen | 5,975 |
| SS | 3,572 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (H&E and IHC) matched to MSK-IMPACT samples **at the part (specimen) level**, for both pre-Epic (CoPath) and post-Epic data. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent. It supersedes [impact_matched_slides_v1](impact_matched_slides_v1.md).

Every row carries a `match_type` that says how precisely the slide's block is known. Slides filed under the sample's own molecular (M) accession, which are DMP recuts of the sequenced material, count as `block`. For block-level matches only, use [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md). Clinical annotations are not included; join `product_cdsi.msk_impact.data_clinical_sample` on `SAMPLE_ID_IMPACT`.

### Vocabulary <a name="vocab"></a>

Primary key: (`SAMPLE_ID_IMPACT`, `image_id`)

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | string | |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505 |
| is_block_match | `match_type = 'block'` | Categorical | boolean | true/false |
| match_type | Precision of the match | Categorical | string | `block`: exact block, or slide filed under the sample's M accession; `inferred_single_block`: only the part is known and it has one scanned block; `part`: specimen only |
| link_sources | How the sample was linked to the slide's specimen | Categorical | array&lt;string&gt; | `dmp_part_description`, `dop_anno`, `copath_molecular_links`, `m_accession` |
| part_number | Part number within the surgical case | ID | string | |
| block_number | Block instance | ID | string | |
| block_label_deid | Block label; NULL when absent or when the label embeds an outside accession | ID | string | CoPath e.g. `3GI`, Epic e.g. `A` |
| label_era | Block label system | Categorical | string | `copath` (slide captured before 2025-03-31), `epic` |
| is_outside_material | Tissue came from another institution (submitted slides, or outside blocks recut at MSK) | Categorical | boolean | true/false |
| part_type | Part type | Categorical | string | |
| stain_number | Stain instance | ID | string | |
| stain_name | Stain name | Categorical | string | |
| stain_group | Type of stain | Categorical | string | see summary |
| stain_label | Per-slide stain decision: HOBBIT metadata, approved H-Optimus image classifications and manual review (same decision as the WSI viewer) | Categorical | string | `he`, `ihc`, `other`, `unknown` |
| stain_classification_source | What decided `stain_label` | Categorical | string | `metadata`, `image_model`, `image_model_fallback`, `metadata_fallback`, `he` / `ihc` (manual review) |
| IS_HNE | `stain_label = 'he'` | Categorical | int | 1/0 |
| IS_IHC | `stain_label = 'ihc'` | Categorical | int | 1/0 |
| scanner_id / brand / model | Scanner | Categorical | string | |
| magnification | Scan magnification | Categorical | string | `20x`, `40x`, … |
| file_size_bytes | Slide file size | Continuous | long | bytes |

## Notes <a name="notes"></a>

1. <b>Primary key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT SAMPLE_ID_IMPACT, image_id) FROM cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2  -- 0
   ```

2. <b>Multi-sample fan-out.</b> A slide that matches several IMPACT samples appears once per `SAMPLE_ID_IMPACT`: 870,653 rows over 855,597 slides.

3. <b>Part A consent only.</b> 83,033 patients here versus 89,382 in the unrestricted `cdsi_res_deid.pdm_base_tables` copy.

4. <b>No accessions or dates.</b> Accession numbers, MRN, barcode, image hash, free-text part description and all timestamps are removed. `block_label_deid` is NULL for labels that embed outside accessions.

5. <b>Outside material.</b> Slides with no block label are almost all outside submitted slides (`is_outside_material = true`, `match_type = 'part'`), which never had an MSK block.

6. <b>Use `stain_label` for stain.</b> `stain_group` is blank for 142,860 rows and vague ("Surgical Submitted", "Other") for ~99k more. `stain_label` resolves most of these with the approved image classifier; 34,818 rows remain `unknown`.

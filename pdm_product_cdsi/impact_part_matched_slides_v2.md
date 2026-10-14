# impact_part_matched_slides_v2

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_part_matched_slides_v2) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_product_cdsi_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from `cdsi_res_deid.pdm_base_tables.impact_part_matched_slides_v2` (see [pathology-data-mining/impact_part_matched_slides_v2](../pathology-data-mining/impact_part_matched_slides_v2.md)).

<b>Summary Statistics</b> (dev build of pdm_databricks_pipelines #49–#51, 2026-10-14; refresh after the prod deploy):

Total rows: 869,150 <br/>
Unique image_ids (slides): 854,106 <br/>
Unique PATIENT_ID_IMPACT: 82,996 <br/>
Unique SAMPLE_ID_IMPACT: 97,292 <br/>

| match_type | Rows | Patients | Samples |
|---|---|---|---|
| block | 330,512 | 79,127 | 92,219 |
| inferred_single_block | 29,776 | 13,501 | 13,815 |
| part | 508,862 | 56,862 | 63,336 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 724,754 | 76,339 |
| true | 144,396 | 27,544 |

| stain_group | Rows |
|---|---|
| H&E (Initial) | 332,468 |
| H&E (Other) | 143,127 |
| IHC | 143,070 |
| (blank) | 141,935 |
| Surgical Submitted | 82,262 |
| Other | 16,749 |
| Frozen | 5,972 |
| SS | 3,567 |


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
| IS_HNE | stain_group is H&E (Initial or Other) | Categorical | int | 1/0 |
| IS_IHC | stain_group is IHC | Categorical | int | 1/0 |
| scanner_id / brand / model | Scanner | Categorical | string | |
| magnification | Scan magnification | Categorical | string | `20x`, `40x`, … |
| file_size_bytes | Slide file size | Continuous | long | bytes |

## Notes <a name="notes"></a>

1. <b>Primary key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT SAMPLE_ID_IMPACT, image_id) FROM cdsi_res_deid.pdm_product_cdsi.impact_part_matched_slides_v2  -- 0
   ```

2. <b>Multi-sample fan-out.</b> A slide that matches several IMPACT samples appears once per `SAMPLE_ID_IMPACT`: 869,150 rows over 854,106 slides.

3. <b>Part A consent only.</b> 82,996 patients here versus 89,339 in the unrestricted `cdsi_res_deid.pdm_base_tables` copy.

4. <b>No accessions or dates.</b> Accession numbers, MRN, barcode, image hash, free-text part description and all timestamps are removed. `block_label_deid` is NULL for labels that embed outside accessions.

5. <b>Outside material.</b> Slides with no block label are almost all outside submitted slides (`is_outside_material = true`, `match_type = 'part'`), which never had an MSK block.

6. <b>Stain ambiguity.</b> `stain_group` is blank for 141,935 rows. Use `stain_name` for those.

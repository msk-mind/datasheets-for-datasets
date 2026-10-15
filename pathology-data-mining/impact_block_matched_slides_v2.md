# impact_block_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_block_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_block_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_block_matched_slides_v2` (without diagnosis text), `cdsi_res_deid.pdm_base_tables.impact_block_matched_slides_v2` (de-identified) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`; gated by `validate_impact_matched_slides_v2`) <br/>
<b>Date created or last updated:</b> 2026-10-15 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Filtered from [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_block_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_block_matched_slides_v2.sql)

<b>Summary Statistics</b> (prod, 2026-10-15):

Total rows: 386,383 <br/>
Unique image_ids (slides): 385,738 <br/>
IMPACT patients: 86,537 (94.4% of the 91,639 IMPACT341/410/468/505 patients in `pathology_dmp_genomics`) <br/>
IMPACT-HEME (from pdm_databricks_pipelines#59, dev 2026-10-15): +5,175 patients, 59,739 slides <br/>
IMPACT samples: 100,781 <br/>
Distinct block_ids: 82,912 (79,182 rows have none: M-accession slides without a block label) <br/>

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 354,033 | 353,570 | 98,685 | 84,920 |
| inferred_single_block | 32,350 | 32,221 | 14,867 | 14,530 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 328,522 | 81,279 |
| true | 57,861 | 18,244 |

| label_era | Rows |
|---|---|
| copath | 304,122 |
| epic | 82,261 |

| stain_label | Rows |
|---|---|
| he | 250,258 |
| ihc | 102,951 |
| unknown | 19,829 |
| other | 13,345 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images matched to MSK-IMPACT samples at the **block level**, for pre-Epic (CoPath) and post-Epic data. It supersedes [impact_block_matched_slides_v1](impact_block_matched_slides_v1.md): 86,537 patients here versus 37,099 in v1.

It contains the rows of [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) where `match_type` is `block` or `inferred_single_block`.
* `block`: one of two cases.
  * The HOBBIT block id (`accession/part-block_label`) equals a linked block id, from the DMP `part_description` or the CoPath molecular links. CoPath block labels (e.g. `3GI`) and Epic block labels (e.g. `A`) both match.
  * The slide is filed under the sample's own M accession (`link_sources = ['m_accession']`): a DMP recut of the sequenced material.
* `inferred_single_block`: the links name only the part, and HOBBIT has exactly one distinct block label for that part. The block is inferred because unscanned blocks may exist. 96% of these rows are outside material.

For exact matches on MSK-cut tissue only, filter `match_type = 'block' AND NOT is_outside_material` (81,222 patients).

### Vocabulary <a name="vocab"></a>

Primary key: (`sample_id`, `image_id`)

Same columns as [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md#vocab), except `is_block_match`, `dmp_block_ids` and `dmp_accession_block_keys` are dropped. `match_type` takes only the values `block` and `inferred_single_block`.

## Notes <a name="notes"></a>

1. <b>Primary key holds, and the table equals the block-level part rows.</b> Both are enforced by `validate_impact_matched_slides_v2`.
   ```sql
   SELECT count(*) - count(DISTINCT sample_id, image_id) FROM cdsi_eng_phi.pdm_base_tables.impact_block_matched_slides_v2  -- 0
   ```

2. <b>block_id can be NULL.</b> The 79,182 such rows are M-accession slides, which HOBBIT files without a block label. Use `image_id` or `link_sources` rather than `block_id` to identify them.

3. <b>Mild multi-sample fan-out.</b> 386,383 rows over 385,738 slides.

4. <b>Why samples are not block-matched.</b> These samples still appear at part level:
   * all of the sample's slides lack a block label (2,741 samples, mostly outside submitted slides);
   * the named block was never scanned (728);
   * several blocks exist and none is named (222).

5. <b>De-identified copy.</b> `cdsi_res_deid` drops the same PHI columns as the part table, including `image_id`; use `slide_key` and the accession keys. Product copy: [pdm_product_cdsi/impact_block_matched_slides_v2](../pdm_product_cdsi/impact_block_matched_slides_v2.md).

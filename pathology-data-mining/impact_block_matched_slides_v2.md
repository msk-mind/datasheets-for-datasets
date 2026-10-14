# impact_block_matched_slides_v2

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_block_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_block_matched_slides_v2) <br/>
<b>Research copies:</b> `cdsi_res_phi.pdm_base_tables.impact_block_matched_slides_v2` (identical), `cdsi_res_deid.pdm_base_tables.impact_block_matched_slides_v2` (de-identified) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job` / `pdm_catalogs_res_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Filtered from [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_block_matched_slides_v2.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_block_matched_slides_v2.sql)

<b>Summary Statistics</b> (2026-10-14):

Total rows: 303,641 <br/>
Unique image_ids (slides): 303,057 <br/>
IMPACT patients: 70,224 (76.6% of the 91,639 IMPACT341/410/468/505 patients in `pathology_dmp_genomics`) <br/>
IMPACT samples: 81,425 <br/>
Distinct block_ids: 81,338 <br/>

| match_type | Rows | Slides | Samples | Patients |
|---|---|---|---|---|
| block | 271,966 | 271,506 | 66,824 | 57,720 |
| inferred_single_block | 31,675 | 31,571 | 14,601 | 14,283 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 246,276 | 54,242 |
| true | 57,365 | 18,056 |

| label_era | Rows |
|---|---|
| copath | 221,818 |
| epic | 81,823 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images matched to MSK-IMPACT samples at the **block level**, for pre-Epic (CoPath) and post-Epic data. It supersedes [impact_block_matched_slides_v1](impact_block_matched_slides_v1.md): 70,224 patients here versus 37,099 in v1.

It contains the rows of [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) where `match_type` is `block` or `inferred_single_block`.
* `block`: the HOBBIT block id (`accession/part-block_label`) equals a block id parsed from the DMP `part_description`. CoPath block labels (e.g. `3GI`) and Epic block labels (e.g. `A`) both match.
* `inferred_single_block`: the DMP text names only the part, and HOBBIT has exactly one distinct block label for that part. The block is inferred because unscanned blocks may exist. 98% of these rows are outside material.

For exact matches on MSK-cut tissue only, filter `match_type = 'block' AND NOT is_outside_material` (54,007 patients).

### Vocabulary <a name="vocab"></a>

Primary key: (`sample_id`, `image_id`)

Same columns as [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md#vocab), except `is_block_match` and `dmp_block_ids` are dropped. `match_type` takes only the values `block` and `inferred_single_block`, and `block_id` is never NULL.

## Notes <a name="notes"></a>

1. <b>Primary key holds; block_id is always populated.</b>
   ```sql
   SELECT count(*) - count(DISTINCT sample_id, image_id), sum(CASE WHEN block_id IS NULL THEN 1 ELSE 0 END)
   FROM cdsi_eng_phi.pdm_base_tables.impact_block_matched_slides_v2  -- 0, 0
   ```

2. <b>Mild multi-sample fan-out.</b> 303,641 rows over 303,057 slides. A block sequenced for more than one IMPACT sample repeats its slides once per sample.

3. <b>Why samples are not block-matched.</b> These samples still appear at part level:
   * the DMP gives only the part and HOBBIT has several blocks (12,003 samples);
   * the named block was never scanned (1,476);
   * Epic-style references on CoPath-era cases (544);
   * slides with no HOBBIT block label, almost all outside submitted slides.

4. <b>De-identified copy.</b> `cdsi_res_deid` drops the same PHI columns as the part table. Product copy: [pdm_product_cdsi/impact_block_matched_slides_v2](../pdm_product_cdsi/impact_block_matched_slides_v2.md).

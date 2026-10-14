# impact_block_matched_slides_v2

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_block_matched_slides_v2`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_block_matched_slides_v2) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_product_cdsi_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from `cdsi_res_deid.pdm_base_tables.impact_block_matched_slides_v2` (see [pathology-data-mining/impact_block_matched_slides_v2](../pathology-data-mining/impact_block_matched_slides_v2.md)).

<b>Summary Statistics</b> (2026-10-14):

Total rows: 282,900 <br/>
Unique image_ids (slides): 282,347 <br/>
Unique PATIENT_ID_IMPACT: 65,555 <br/>
Unique SAMPLE_ID_IMPACT: 76,153 <br/>

| match_type | Rows | Patients | Samples |
|---|---|---|---|
| block | 253,750 | 53,994 | 62,588 |
| inferred_single_block | 29,150 | 13,269 | 13,565 |

| is_outside_material | Rows | Patients |
|---|---|---|
| false | 230,325 | 50,852 |
| true | 52,575 | 16,684 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (H&E and IHC) matched to MSK-IMPACT samples **at the block level**, for both pre-Epic (CoPath) and post-Epic data. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent.

It supersedes [impact_block_matched_slides_v1](impact_block_matched_slides_v1.md): 76,153 samples here versus 38,983 in v1. It is the subset of [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) where the block is known.
* `block`: the slide's block is the block named in the molecular report.
* `inferred_single_block`: the report names only the part, and only one block of that part was scanned. These rows are almost all outside material.

For exact matches on MSK-cut tissue only, filter `match_type = 'block' AND NOT is_outside_material`.

### Vocabulary <a name="vocab"></a>

Primary key: (`SAMPLE_ID_IMPACT`, `image_id`)

Same columns as [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md#vocab) without `is_block_match`. `match_type` takes only the values `block` and `inferred_single_block`.

## Notes <a name="notes"></a>

1. <b>Primary key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT SAMPLE_ID_IMPACT, image_id) FROM cdsi_res_deid.pdm_product_cdsi.impact_block_matched_slides_v2  -- 0
   ```

2. <b>Multi-sample fan-out is mild.</b> 282,900 rows over 282,347 slides.

3. <b>Part A consent only.</b> 65,555 patients here versus 70,224 in the unrestricted `cdsi_res_deid.pdm_base_tables` copy.

4. <b>Not block-matched samples stay part-level.</b> Samples whose block cannot be determined appear only in [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) with `match_type = 'part'`. These include multi-block parts where the report names only the part, blocks that were never scanned, and outside submitted slides.

# slide_stain_resolved_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.slide_stain_resolved_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/slide_stain_resolved_v1) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job`) <br/>
<b>Date created or last updated:</b> 2026-10-15 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md) and `cdsi_prod.pathology_data_mining.slide_stain_classification` (published by the [stain_classifier](https://github.com/pathology-data-mining/stain_classifer) repo). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/slide_stain_resolved_v1.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/slide_stain_resolved_v1.sql)

<b>Summary Statistics</b> (prod, 2026-10-15):

Total rows: 10,928,191 (one per HOBBIT slide in `case_breakdown_cleaned_v2`) <br/>
Built: 2026-10-15 05:17 UTC <br/>

| stain_label | stain_classification_source | Slides |
|---|---|---|
| he | metadata | 7,223,987 |
| he | image_model_fallback | 54,190 |
| he | he (manual review) | 31 |
| ihc | metadata | 1,411,928 |
| ihc | image_model_fallback | 24,769 |
| ihc | image_model | 229 |
| ihc | ihc (manual review) | 14 |
| other | metadata_fallback | 326,636 |
| unknown | metadata_fallback | 1,886,407 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

One stain decision per HOBBIT slide: is it H&E, IHC, another stain, or unknown? The IMPACT match tables ([impact_part_matched_slides_v2](impact_part_matched_slides_v2.md), [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md)) and the WSI serving pipeline both read this table, so they answer the question the same way.

The decision combines HOBBIT stain metadata (`stain_group`, `stain_name`) with the approved H-Optimus stain classifications and manual review labels in `slide_stain_classification`. For each slide, the first rule that applies wins:

| Order | Rule | stain_classification_source |
|---|---|---|
| 1 | Approved manual review label | `he` / `ihc` |
| 2 | Metadata says IHC | `metadata` |
| 3 | Metadata says H&E, and the approved image model calls IHC at or above the release threshold (0.90) | `image_model` |
| 4 | Metadata says H&E | `metadata` |
| 5 | Metadata names no stain (e.g. `SLIDES SUBMITTED`), and the image model is confident (≥ 0.90 IHC or ≤ 0.10 H&E) | `image_model_fallback` |
| 6 | Otherwise | `metadata_fallback` |

Metadata IHC is never downgraded by the model. Stains that are positively identified as neither H&E nor IHC are `other`: FISH, histochemical special stains, cytology preparations.

The rules were moved here verbatim from `wsi_summary/src/wsi_canonical_associations_pipeline.sql`. On the slides both cover, the decision matched the previous WSI output on every slide.

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | HOBBIT slide identifier | ID | string | |
| stain_group / stain_name | HOBBIT stain metadata as recorded | Categorical | string | |
| stain_group_canonical / stain_name_canonical | Normalized metadata values | Categorical | string | e.g. `H&E (Initial)`, `IHC`, `DM H&E RECUT` |
| metadata_is_hne / metadata_is_ihc | Metadata identifies H&E / IHC | Categorical | boolean | |
| metadata_is_known_other | Metadata positively identifies a non-H&E/IHC stain | Categorical | boolean | |
| stain_model_version | Classifier release whose row was used, if any | Categorical | string | e.g. `hoptimus0-reef-v1-32tile-20260811` |
| stain_scored_at | When that classifier row was scored | Continuous | timestamp | |
| stain_image_probability | Classifier probability that the slide is IHC | Continuous | double | 0–1 |
| stain_classification_source | Rule that decided the stain | Categorical | string | see table above |
| resolved_is_hne / resolved_is_ihc / resolved_is_known_other | Final decision flags | Categorical | boolean | |
| stain_label | Final decision | Categorical | string | `he`, `ihc`, `other`, `unknown` |
| built_at | When this view was refreshed | Continuous | timestamp | |
| classification_max_scored_at | Newest approved classifier scoring time read (provenance only) | Continuous | timestamp | |
| classification_max_published_at | Newest classifier publish read; use this for freshness checks | Continuous | timestamp | added by pdm_databricks_pipelines#55 |

## Notes <a name="notes"></a>

1. <b>One row per slide, always.</b> Every `case_breakdown_cleaned_v2` image_id has exactly one row, including the slides with fully blank stain metadata. A slide missing here means the table is stale; treat it as `unknown`, never as H&E.
   ```sql
   SELECT count(*) - count(DISTINCT image_id) FROM cdsi_eng_phi.pdm_base_tables.slide_stain_resolved_v1  -- 0
   ```

2. <b>Freshness.</b> The classifier table is published separately. `published_at` is stamped on every row of each publish, so a consumer can fail closed when the classifier has a newer publish than this view consumed:
   ```sql
   SELECT (SELECT max(published_at) FROM cdsi_prod.pathology_data_mining.slide_stain_classification WHERE model_approved)
        > (SELECT max(classification_max_published_at) FROM cdsi_eng_phi.pdm_base_tables.slide_stain_resolved_v1)  -- true = stale
   ```
   Do not use `classification_max_scored_at` for this. `scored_at` is the scoring time and does not move for new manual labels or newly approved older scores.

3. <b>Always reads the prod classifier table.</b> This holds in every bundle target, so classifier experiments in dev schemas are not reflected here.

4. <b>Classifier coverage.</b> Only slides with approved classifier rows (reef-v1 and reef-v2 H-Optimus embeddings, about 589k slides) can be resolved by the image model. Most `unknown` slides have no stain metadata and no classifier score.

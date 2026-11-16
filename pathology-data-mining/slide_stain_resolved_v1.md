# slide_stain_resolved_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.slide_stain_resolved_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/slide_stain_resolved_v1) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job`) <br/>
<b>Date created or last updated:</b> 2026-11-16 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Built from [case_breakdown_cleaned_v2](case_breakdown_cleaned_v2.md), `cdsi_prod.pathology_data_mining.slide_stain_classification` (published by the [stain_classifier](https://github.com/pathology-data-mining/stain_classifer) repo), and two curated vocabularies in `pdm_catalogs` (`stain_detail_labels_v1`, `stain_name_ihc_labels_v1`; note 5). Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/slide_stain_resolved_v1.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/slide_stain_resolved_v1.sql)

<b>Summary Statistics</b> (prod, 2026-11-16, after the 2026-11-16 17:01 UTC classifier publish and pdm_databricks_pipelines#87):

Total rows: 11,099,442 (one per HOBBIT slide in `case_breakdown_cleaned_v2`) <br/>
Classifier releases read: `titan512-3class-20261111` (798,355 slides, downgrade threshold 0.10, 212 manual labels); `hoptimus0-reef-v1-32tile-20260811` (339 slides without a TITAN embedding, 4 manual labels) <br/>

| stain_label | stain_classification_source | Slides |
|---|---|---|
| he | metadata | 7,349,285 |
| he | image_model_fallback | 65,757 |
| he | image_model_downgrade | 10,566 |
| he | he (manual review) | 142 |
| ihc | metadata | 1,534,115 (104,874 of them from the stain-name map, note 6) |
| ihc | image_model_fallback | 30,155 |
| ihc | image_model | 237 |
| ihc | ihc (manual review) | 54 |
| other | metadata_fallback | 330,744 |
| unknown | metadata_fallback | 1,778,387 |

| stain_label | stain_detail_source | Slides | Distinct stain_detail |
|---|---|---|---|
| he | generic | 7,425,750 | 1 (`H&E`) |
| ihc | vocabulary | 1,329,152 | 533 markers |
| ihc | generic | 235,409 | 1 (`IHC`) |
| other | vocabulary | 330,573 | 22 kinds |
| other | generic | 171 | 1 (`Other`) |
| unknown | generic | 1,778,387 | 1 (`Unknown`) |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

One stain decision per HOBBIT slide: is it H&E, IHC, another stain, or unknown? The IMPACT match tables ([impact_part_matched_slides_v2](impact_part_matched_slides_v2.md), [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md)) and the WSI serving pipeline (`wsi_summary`) all read this table, so they answer the question the same way. It also carries a display label for the stain (`stain_detail`, e.g. `PD-L1 (SP263)`, `FISH`, `PAS`).

The decision combines HOBBIT stain metadata (`stain_group`, `stain_name`) with the approved image classifications and manual review labels in `slide_stain_classification`. For each slide, the first rule that applies wins:

| Order | Rule | stain_classification_source |
|---|---|---|
| 1 | Approved manual review label | `he` / `ihc` |
| 2 | Metadata says IHC, and the slide's release has an `image_he_downgrade_threshold` that its image score is at or below | `image_model_downgrade` (→ H&E) |
| 3 | Metadata says IHC | `metadata` |
| 4 | Metadata says H&E, and the approved image model calls IHC at or above the release threshold (0.90) | `image_model` |
| 5 | Metadata says H&E | `metadata` |
| 6 | Metadata names no H&E/IHC stain (e.g. `SLIDES SUBMITTED`), and the image model is confident (≥ 0.90 IHC or ≤ 0.10 H&E) | `image_model_fallback` |
| 7 | Otherwise | `metadata_fallback` |

"Metadata says IHC" means a stain group of IHC, or a blank stain group with an IHC stain name: a short set of name patterns, IHC negative controls, or one of the 216 explicit antibody names in `stain_name_ihc_labels_v1` (note 6). The downgrade (rule 2) is opt-in per classifier release (pdm_databricks_pipelines#67, first used 2026-10-22). It mostly relabels `IMMUNO RECUT` and `Unstained Normal` slides filed under the IHC group that the image model sees as H&E. Releases without a threshold never downgrade. Stains positively identified as neither H&E nor IHC are `other`: FISH, histochemical special stains, cytology preparations.

The rules originated in the WSI pipeline's `wsi_canonical_associations_pipeline.sql`; this view is now their single source, and the WSI pipeline reads it.

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | HOBBIT slide identifier | ID | string | |
| stain_group / stain_name | HOBBIT stain metadata as recorded | Categorical | string | |
| stain_group_canonical / stain_name_canonical | Normalized metadata values | Categorical | string | e.g. `H&E (Initial)`, `IHC`, `DM H&E RECUT` |
| metadata_is_hne / metadata_is_ihc | Metadata identifies H&E / IHC | Categorical | boolean | |
| metadata_is_known_other | Metadata positively identifies a non-H&E/IHC stain | Categorical | boolean | |
| metadata_ihc_from_name_map | The stain group is blank and the stain name is an explicit antibody in `stain_name_ihc_labels_v1` | Categorical | boolean | added by pdm_databricks_pipelines#87 |
| stain_model_version | Classifier release whose row was used, if any | Categorical | string | e.g. `titan512-3class-20261111` |
| stain_scored_at | When that classifier row was scored | Continuous | timestamp | |
| stain_image_probability | Classifier probability that the slide is IHC | Continuous | double | 0–1; 0.5 = published as no call |
| stain_classification_source | Rule that decided the stain | Categorical | string | see table above |
| resolved_is_hne / resolved_is_ihc / resolved_is_known_other | Final decision flags | Categorical | boolean | |
| stain_label | Final decision | Categorical | string | `he`, `ihc`, `other`, `unknown` |
| stain_detail | Display label from the same decision | Categorical | string | `H&E`; IHC marker (e.g. `HER2/neu`) or `IHC`; other kind (e.g. `FISH`, `Cytology`, `PAS`, `Molecular recut`) or `Other`; `Unknown` |
| stain_detail_source | Where `stain_detail` came from | Categorical | string | `vocabulary`, `rule`, `generic` |
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

4. <b>Classifier coverage.</b> About 798.7k slides have an approved classifier row, nearly all from the TITAN-512 three-class release. That release publishes slides it sees as a special stain or cytology prep, or on which it and H-Optimus-0 confidently disagree, as probability 0.5 (no call), so they stay `unknown` unless metadata decides them. Most `unknown` slides have no stain metadata and no image file in the slide inventory, so no classifier can score them.

5. <b>Curated vocabularies.</b> Both live as CSVs in `pdm_catalogs/src/cdsi_eng_phi/`, are rendered to tables by `render_stain_detail_sql.py` (`--check` runs in CI), and are keyed on `stain_name_key = REGEXP_REPLACE(LOWER(stain_name), '[^a-z0-9]+', '')`.
   * `stain_detail_labels.csv` → `stain_detail_labels_v1`: 830 (kind, name) → label rows for IHC markers and other-stain kinds (pdm_databricks_pipelines#65). Labels never contain `submitted` or `frozen`, which the WSI pathology timeline treats as placeholders. SNP / copy-number arrays (CG ARRAY CytoScan / OncoScan) are `Molecular recut`, not `Cytology`.
   * `stain_name_ihc_labels.csv` → `stain_name_ihc_labels_v1`: see note 6.

6. <b>Stain-name IHC map</b> (pdm_databricks_pipelines#87, 2026-11-16). When HOBBIT records no stain group, 216 explicit antibody names count as metadata IHC: CD markers, BCL2/6, MUM1, PAX5, Ki-67, CLDN18, STK11, FORL1, SOX10/11/17, MMR proteins, keratins, ER/PR/HER2, immunoglobulins, viral IHC (EBV LMP1, HHV-8, CMV) and dual stains, often with the `SSL` outside-slide prefix. The mapping was reviewed name by name. 73 names were deliberately left out and stay `unknown` (`stain_name_leave_unknown.csv`, enforced by a test): molecular test orders such as `MSK IMPACT SOLID`, recuts and levels, unstained, chromogenic ISH (EBER, kappa/lambda), special stains, cytology preps, placeholders and controls. The map moved 104,586 slides from `unknown` to `ihc` (6,842 of them in the v2 IMPACT match tables) and changed no other label.

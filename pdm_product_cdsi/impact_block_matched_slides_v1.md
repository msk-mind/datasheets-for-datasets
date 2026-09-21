# impact_block_matched_slides_v1

<b>Path:</b> [`cdsi_res_deid.pdm_product_cdsi.impact_block_matched_slides_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_res_deid/pdm_product_cdsi/impact_block_matched_slides_v1) <br/>
<b>Table Type:</b> Live <br/>
<b>Date created or last updated:</b> 2026-09-10 (updated: 2026-09-18) <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b>

<b>Summary Statistics:</b>

Total rows: 168,853 <br/>
Unique image_ids (slides): 168,712 <br/>
Unique PATIENT_ID_IMPACT: 35,254 <br/>
Unique SAMPLE_ID_IMPACT: 38,983 <br/>
Unique block_ids: 38,963 <br/>


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Whole-slide images (H&E and IHC) matched to MSK-IMPACT samples **at the block level**, a finer-grained match than [impact_matched_slides_v1](impact_matched_slides_v1.md), which matches at the part level. This dataset is IMPACT-scoped, de-identified, and limited to patients with Part A research consent.

The narrower scope is visible in the counts: 38,983 IMPACT samples here versus 81,707 in the part-level table (see note 4).

### Vocabulary <a name="vocab"></a>

Primary key: `image_id`

The first three columns are the IMPACT identifiers. `PATIENT_ID_IMPACT` and `SAMPLE_ID_IMPACT` are the IMPACT DMP patient/sample identifiers (the same concept as the identically named columns in the other product tables). Key columns include:

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| image_id | Slide ID for the whole-slide image | ID | string | |
| PATIENT_ID_IMPACT | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| SAMPLE_ID_IMPACT | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| block_id | Block identifier | ID | string | |
| block_label | Block label | ID | string | |
| outside_block_id | Block identifier for material accessioned from an outside institution | ID | string | |
| m_accession_number | Molecular (M) accession number | ID | string | |
| has_external_s_number | Whether the record has an external S-accession | Categorical | string | |
| has_only_external_s_number | Whether the record has *only* external S-accessions | Categorical | string | |
| img_hid | Hashed image identifier | ID | string | |
| part_description | Free-text description of the tissue part | Natural Language Description | string | |
| part_type | Part type | Categorical | string | |
| stain_name | Stain name | Categorical | string | |
| stain_group | The type of stain used | Categorical | string | 'H&E (Initial)', 'H&E (Other)', 'IHC', 'Other', 'SS', 'Frozen', 'Surgical Submitted' |
| brand / model | Scanner brand and model | Categorical | string | |
| magnification | Slide magnification | Categorical | string | '20x', '40x', ... |
| file_size_bytes | Slide file size in bytes | Continuous | long | bytes |
| CYCLE_THRESHOLD | Cycle threshold from the molecular assay | Continuous | string | numeric value stored as string |
| DNA_CONCENTRATION | DNA concentration from the molecular assay | Continuous | string | numeric value stored as string |
| PLASMA_USED_VOLUME | Plasma volume used | Continuous | string | numeric value stored as string |
| DNA_ELUTION_BUFFER_VOLUME | DNA elution buffer volume | Continuous | string | numeric value stored as string |
| ONCOKB_ANNOTATION_STATUS | OncoKB annotation status for the sample | Categorical | string | |
| ONCOKB_DATA_VERSION | OncoKB data version used for annotation | Categorical | string | |

*See the Databricks Catalog Overview tab for the complete 24-column schema.*

## Notes <a name="notes"></a>

1. <b>Multi-sample fan-out.</b> A slide that matches multiple IMPACT samples appears on multiple rows (one per `SAMPLE_ID_IMPACT`). The fan-out is mild here: 168,853 rows over 168,712 distinct `image_id`s.

2. <b>Block-level matching.</b> Contains slides for **solid tumors only**, obtained from S-accessions (surgery) that subsequently had M-accessions (molecular) generated for IMPACT sequencing. i.e. no 'C' cytology, 'H' heme etc. accessions included.

3. <b>Stain ambiguity.</b> The table generally contains H&E and IHC images, but the `stain_group` column does not clearly specify the stain for every `image_id`: 5,080 rows are NULL and a further ~5,900 fall into `Other`/`SS`/`Frozen`/`Surgical Submitted`.

4. <b>Block coverage is partial.</b> Block ID coverage for the IMPACT cohort is incomplete. This table reaches 38,983 IMPACT samples against 81,707 in the part-level [impact_matched_slides_v1](impact_matched_slides_v1.md), i.e. roughly 48%. This is partly because only ~66% of copath M-accession records that map to S-accessions overlap with the IMPACT cohort. There is some other attrition that still needs to be accounted for.

5. <b>Assay measurements are stored as strings.</b> `CYCLE_THRESHOLD`, `DNA_CONCENTRATION`, `PLASMA_USED_VOLUME`, and `DNA_ELUTION_BUFFER_VOLUME` are numeric quantities typed as `string` in the table and must be cast before use.

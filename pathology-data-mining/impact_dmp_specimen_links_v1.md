# impact_dmp_specimen_links_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_dmp_specimen_links_v1) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_dmp_specimen_links_v1.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_dmp_specimen_links_v1.sql)

<b>Summary Statistics</b> (2026-10-14):

Total rows: 103,635 <br/>
IMPACT patients: 88,415 <br/>
IMPACT samples: 103,632 <br/>
Distinct specimen_ids: 102,351 (491 rows have none) <br/>
Distinct block_ids: 72,724 (30,844 rows have none) <br/>
Rows with at least one outside accession: 32,220 <br/>

| msk_token_format | Rows | Samples |
|---|---|---|
| copath | 87,986 | 87,984 |
| epic | 15,158 | 15,158 |
| NULL (accession found, part not parseable) | 491 | 491 |

| gene_panel | Samples | Patients |
|---|---|---|
| IMPACT341 | 2,745 | 2,670 |
| IMPACT410 | 9,824 | 9,335 |
| IMPACT468 | 34,827 | 31,469 |
| IMPACT505 | 56,236 | 48,616 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Links each MSK-IMPACT sample to the MSK surgical or cytology specimen (S/C-accession, part and block) its DNA was extracted from. The links are parsed from the free-text `part_description` in `product_clinical_analytics.laboratory_pathology.pathology_dmp_genomics`.

This table is the DMP side of the image → sample mapping used by [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) and [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md). The M-accession (`m_accession_number`) is 1:1 with `sample_id` and is the PHI form of the sample identifier.

Scope: samples on the IMPACT341, IMPACT410, IMPACT468 and IMPACT505 panels. Samples whose `part_description` has no `MSK:` reference are not in this table, for example liquid biopsies (`BLOOD`, `CEREBROSPINAL FLUID (cfDNA)`) and material referenced only by an outside accession.

The `part_description` contains one or more `MSK:` references in one of two formats:

| Format | Example (synthetic) | Parsed |
|---|---|---|
| CoPath (pre 2025-03-31) | `Liver; biopsy (MSK:S20-12345/1-3 GI, Outside:AB20-0001/A2, 20 USS and 1 H&E)` | accession `S20-12345`, part `1`, block `3GI`, outside `AB20-0001` |
| CoPath, part only | `Colon (MSK:S19-12345/2, …)` | accession `S19-12345`, part `2`, no block |
| Epic | `Tissue, Lung (MSK: S25-012345-1B, …)` | accession `S25-12345`, part `1`, block `B` |

### Vocabulary <a name="vocab"></a>

Primary key: (`sample_id`, `msk_token`)

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| patient_id | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| sample_id | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| m_accession_number | Molecular (M) accession number; 1:1 with sample_id | ID (PHI) | string | `MYY-NNNNN` |
| mrn | Patient MRN, zero-padded to 8 digits | ID (PHI) | string | 8 digits |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505 |
| part_description | Raw DMP part description the links were parsed from | Natural Language Description (PHI) | string | |
| msk_token | One `MSK:` reference from part_description, upper-cased | Natural Language Description (PHI) | string | |
| accession_number | MSK accession with zero padding removed from the case number, so CoPath and Epic accessions share one key space | ID (PHI) | string | `SYY-N…` (e.g. Epic `S25-012345` → `S25-12345`) |
| msk_token_format | Format of the MSK reference | Categorical | string | `copath`, `epic`, NULL (part not parseable) |
| part_number | Part number | ID | string | digits |
| block_label | Block label, upper-cased, whitespace removed; NULL when the reference names only the part | ID | string | CoPath e.g. `3GI`, `1CB-F`; Epic e.g. `A` |
| outside_tokens | `Outside:` references from part_description (dates excluded) | Natural Language Description (PHI) | array&lt;string&gt; | |
| outside_accession_numbers | Outside accession part of each outside token (before `/`) | ID (PHI) | array&lt;string&gt; | |
| specimen_id | Join key for part-level matching | ID (PHI) | string | `accession_number/part_number` |
| block_id | Join key for block-level matching; NULL when block_label is NULL | ID (PHI) | string | `accession_number/part_number-block_label` |

## Notes <a name="notes"></a>

1. <b>PHI table.</b> Contains MRN, accessions and free text. It is not copied to `cdsi_res_phi` or `cdsi_res_deid`; only the match tables built from it are.

2. <b>Primary key holds.</b> (`sample_id`, `msk_token`) is unique.
   ```sql
   SELECT count(*) - count(DISTINCT sample_id, msk_token) FROM cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1  -- 0
   ```

3. <b>sample_id ↔ m_accession_number is one-to-one.</b>
   ```sql
   SELECT sample_id FROM cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1 GROUP BY 1 HAVING count(DISTINCT m_accession_number) > 1  -- 0 rows
   SELECT m_accession_number FROM cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1 GROUP BY 1 HAVING count(DISTINCT sample_id) > 1  -- 0 rows
   ```

4. <b>Most samples have exactly one MSK reference.</b> Rows exceed samples by 3. Descriptions listing several parts, or with a duplicated `MSK: MSK:` prefix, produce one row per reference.

5. <b>Part-only references are common.</b> 30,844 rows have no block (CoPath references such as `S19-12345/2`). These can match slides only at part level, or as `inferred_single_block` when the part has a single scanned block.

6. <b>Parsing limits.</b>
   * CoPath block text is cut at the first designator. `DOP`/`USS` are never treated as designators.
   * A bare block number (`S18-12345/1-1`) is kept as block `1`.
   * Ambiguous text such as `1-8 1A` is parsed as block `8`.
   * The misspelling `OUTISDE` is not captured as an outside accession.

# impact_dmp_specimen_links_v1

<b>Path:</b> [`cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1`](https://msk-mode-prod.cloud.databricks.com/explore/data/cdsi_eng_phi/pdm_base_tables/impact_dmp_specimen_links_v1) <br/>
<b>Table Type:</b> Live (materialized view, refreshed daily by `pdm_catalogs_job`) <br/>
<b>Date created or last updated:</b> 2026-10-14 <br/>

<b>Lineage: See table overview and lineage in Databricks->Catalog section, Overview tab for SQL definition of the table, and lineage tab for lineage.</b> Source SQL: [`pdm_catalogs/src/cdsi_eng_phi/impact_dmp_specimen_links_v1.sql`](https://github.com/pathology-data-mining/pdm_databricks_pipelines/blob/main/pathology_data_mining/pdm_catalogs/src/cdsi_eng_phi/impact_dmp_specimen_links_v1.sql)

<b>Summary Statistics</b> (prod, 2026-10-15):

Total rows: 384,789 <br/>
IMPACT patients: 91,639 (every IMPACT341/410/468/505 patient in `pathology_dmp_genomics`) <br/>
IMPACT samples: 108,631 <br/>
Rows with an outside accession: 32,242 <br/>

| link_source | Rows | Samples | Specimens | Blocks |
|---|---|---|---|---|
| dmp_part_description | 103,706 | 103,703 | 102,422 | 72,794 |
| dop_anno | 105,226 | 104,679 | 88,924 | 0 |
| copath_molecular_links | 67,226 | 67,196 | 66,760 | 42,379 |
| m_accession | 108,631 | 108,631 | 108,526 | 0 |

| gene_panel | Samples | Patients |
|---|---|---|
| IMPACT341 | 2,821 | 2,742 |
| IMPACT410 | 10,016 | 9,509 |
| IMPACT468 | 36,783 | 32,993 |
| IMPACT505 | 59,011 | 50,377 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)

## Description <a name="description"></a>

Links each MSK-IMPACT sample to the MSK specimens (S/C/H accession, part, and block when known) and to the M (molecular) accession its DNA came from. It is the sample side of the image → sample mapping used by [impact_part_matched_slides_v2](impact_part_matched_slides_v2.md) and [impact_block_matched_slides_v2](impact_block_matched_slides_v2.md). The M accession (`m_accession_number`) is the PHI form of the sample identifier.

Scope: every sample on the IMPACT341, IMPACT410, IMPACT468 and IMPACT505 panels in `product_clinical_analytics.laboratory_pathology.pathology_dmp_genomics`.

Links come from four sources (`link_source`):

| link_source | Source | Gives |
|---|---|---|
| `dmp_part_description` | `MSK:` references parsed from the DMP `part_description` | accession, part, block when written |
| `dop_anno` | `SOURCE_ACCESSION_NUMBER_0/0b` + `SOURCE_SPEC_NUM_0/0b` in the DMP DOP annotation tables (`cdsi_prod…table_pathology_impact_sample_summary_dop_anno` and the Epic/IDB combined table), excluding v1's blocklisted samples `P-0000000-N-VR1` and `P-0032211-T02-IM6` | S/C/H accession and part |
| `copath_molecular_links` | `copath_molecular_links_cleaned_v2` (M accession → S/C/H accession), excluding parts described as normal tissue | accession, part, block (CoPath era) |
| `m_accession` | the sample's own M accession, with the sequenced part (`SPECIMEN_NUMBER_DMP`) when the DOP annotation records it | slides filed under the M accession in HOBBIT; no block |

The last three are the sources the v1 match tables used. Including them means v2 keeps v1's matches.

`part_description` formats parsed for `dmp_part_description` (examples are synthetic):

| Format | Example | Parsed |
|---|---|---|
| CoPath (pre 2025-03-31) | `Liver; biopsy (MSK:S20-12345/1-3 GI, Outside:AB20-0001/A2, 20 USS and 1 H&E)` | accession `S20-12345`, part `1`, block `3GI`, outside `AB20-0001` |
| CoPath, part only | `Colon (MSK:S19-12345/2, …)` | accession `S19-12345`, part `2`, no block |
| Epic | `Tissue, Lung (MSK: S25-012345-1B, …)` | accession `S25-12345`, part `1`, block `B` |

### Vocabulary <a name="vocab"></a>

Unique key: (`sample_id`, `link_source`, `msk_token`, `accession_number`, `part_number`, `block_label`), with NULLs treated as empty strings.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** |
|---|---|---|---|---|
| patient_id | IMPACT DMP patient identifier | ID | string | `P-XXXXXXX` |
| sample_id | IMPACT DMP sample identifier | ID | string | `P-XXXXXXX-TNN-IMn` |
| m_accession_number | Molecular (M) accession of the sample | ID (PHI) | string | `MYY-NNNNN` |
| mrn | Patient MRN, zero-padded to 8 digits | ID (PHI) | string | 8 digits |
| gene_panel | IMPACT gene panel | Categorical | string | IMPACT341, IMPACT410, IMPACT468, IMPACT505 |
| part_description | Raw DMP part description | Natural Language Description (PHI) | string | |
| link_source | Where the link came from | Categorical | string | `dmp_part_description`, `dop_anno`, `copath_molecular_links`, `m_accession` |
| msk_token | One `MSK:` reference from part_description, upper-cased; NULL for other sources | Natural Language Description (PHI) | string | |
| accession_number | Linked accession, zero padding of the case number removed (Epic `S25-012345` → `S25-12345`); the M accession for `m_accession` rows | ID (PHI) | string | |
| msk_token_format | Format of the MSK reference; NULL for other sources or when the part cannot be parsed | Categorical | string | `copath`, `epic`, NULL |
| part_number | Part number; for `m_accession` rows the sequenced part when recorded, else NULL | ID | string | digits |
| block_label | Block label, upper-cased, whitespace removed; NULL when only the part is known | ID | string | CoPath e.g. `3GI`, `1CB-F`; Epic e.g. `A` |
| outside_tokens | `Outside:` references from part_description (dates excluded); empty for other sources | Natural Language Description (PHI) | array&lt;string&gt; | |
| outside_accession_numbers | Outside accession part of each outside token | ID (PHI) | array&lt;string&gt; | |
| specimen_id | Join key for part-level matching | ID (PHI) | string | `accession_number/part_number` |
| block_id | Join key for block-level matching | ID (PHI) | string | `accession_number/part_number-block_label` |

## Notes <a name="notes"></a>

1. <b>PHI table.</b> It is not copied to `cdsi_res_phi` or `cdsi_res_deid`; only the match tables built from it are.

2. <b>Unique key holds.</b>
   ```sql
   SELECT count(*) - count(DISTINCT sample_id, link_source, coalesce(msk_token,''), coalesce(accession_number,''), coalesce(part_number,''), coalesce(block_label,''))
   FROM cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1  -- 0
   ```

3. <b>sample_id → m_accession_number is one-to-one.</b> In the other direction, 3 M accessions are shared by two samples in `pathology_dmp_genomics`. Slides under those accessions match both samples.
   ```sql
   SELECT m_accession_number FROM cdsi_eng_phi.pdm_base_tables.impact_dmp_specimen_links_v1 GROUP BY 1 HAVING count(DISTINCT sample_id) > 1  -- 3 rows
   ```

4. <b>One sample, many links.</b> A sample typically has one row per source. Sources often agree on the same specimen; the match tables collapse them per specimen and keep the sources in `link_sources`.

5. <b>Parsing limits for `dmp_part_description`.</b>
   * CoPath block text is cut at the first designator. `DOP`/`USS` are never treated as designators.
   * A bare block number (`S18-12345/1-1`) is kept as block `1`.
   * Ambiguous text such as `1-8 1A` is parsed as block `8`.
   * The misspelling `OUTISDE` is not captured as an outside accession.

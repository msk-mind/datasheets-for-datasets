# Surgical Specimen Diagnoses — IDB (v2)

<b>Path:</b> `cdsi_prod.pathology_data_mining.table_pathology_surgical_samples_parsed_specimen_v2` <br/>
<b>Table Type:</b> Static (IDB is a frozen pre-Epic source) <br/>
<b>Date created:</b> 2026-05-22 <br/>
<b>Last updated:</b> 2026-06-17 <br/>

<b>Lineage:</b> Parsed from `src_idbdw_prod.dv.pathology_report_v` (IDB canonical surgical pathology source). Script: `/Workspace/Users/limr@mskcc.org/parse_all_msk_surgical.py` (Databricks). Four parser correctness fixes applied (range-notation headers, colon-delimiter headers, single-specimen fallback, whitespace/encoding edge cases). DMP linkage via `cdsi_eng_phi.cdm_eng_pathology_report_segmentation.table_pathology_impact_sample_summary_dop_anno_epic_idb_combined`.

See also: [Completeness Assessment](https://mskconfluence.mskcc.org/spaces/CDSI/pages/241638443) | [Parser Correctness](https://mskconfluence.mskcc.org/spaces/CDSI/pages/241638446) | [Project Plan](https://mskconfluence.mskcc.org/spaces/CDSI/pages/241637348)

<b>Summary Statistics:</b>

Total rows: 4,453,217 <br/>
Distinct S-accessions: 1,853,955 <br/>
Distinct MRNs: 839,601 <br/>
Avg specimens per accession: 2.40 (max: 99) <br/>
PROCEDURE_DATE range: 1990-01-01 – 2025-04-17 (valid; 2,163 rows have pre-1990 sentinel dates from IDB source) <br/>
REPORT_DATE range: 1992-01-01 – 2025-04-17 (0 nulls) <br/>
IMPACT rows (DMP_PATIENT_ID not null): 266,826 rows | 77,117 MRNs | 87,500 accessions <br/>

# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)
4. [Why an S-accession may be missing](#missing)

## Description <a name="description"></a>

This table provides the pathologist's diagnosis for each specimen (part) of each surgical pathology accession in IDB, parsed from the free-text `PRPT_REPORT` field in `pathology_report_v`. One row per (accession, specimen number).

The table covers **all surgical S-prefix accessions in IDB** (1,853,955 accessions, 839,601 MRNs, reporting years 1992–2025). This is a superset of earlier PDM parsing work, which only covered the IMPACT-scoped `ddp_pathology_reports` materialized table (~362k accessions).

Parsing extracts the `DIAGNOSIS:` section from each free-text report, then splits it on numbered specimen headers (e.g. `1.`, `2)`, `1-3.`, `1:`) to produce one row per specimen. Reports with no numbered header yield a single row with `PATH_DX_SPEC_NUM = 1` and `PATH_DX_SPEC_TITLE = ''` (single-specimen fallback). Reports with no parseable `DIAGNOSIS:` section yield a single row with `PATH_DX_SPEC_DESC = 'Diagnosis Not Available'`.

For the combined IDB + Epic table (all-MSK scope), see `cdsi_eng_phi.cdm_eng_pathology_report_segmentation.surgical_specimen_diagnoses_combined`.

### Vocabulary <a name="vocab"></a>

Primary key: `(ACCESSION_NUMBER, PATH_DX_SPEC_NUM)`

| **Field name** | **Description** | **Field Type** | **Data Type** | **Format / Values** |
|---|---|---|---|---|
| `ACCESSION_NUMBER` | IDB surgical pathology accession number | ID | string | `S{YY}-{NNNNN}`, e.g. `S17-42144`. Zero-padded year prefix. |
| `PATH_DX_SPEC_NUM` | Specimen (part) number within the accession | ID | int | 1-based integer. Range: 1–99. |
| `PATH_DX_SPEC_TITLE` | Brief specimen label from the numbered report header | Natural Language | string | E.g. `RIGHT COLON BIOPSY`. Empty string (`''`) for 124,476 single-specimen fallback rows (no numbered header in source). Never NULL. |
| `PATH_DX_SPEC_DESC` | Pathologist's detailed diagnosis for this specimen | Natural Language | string | Free text, typically 1–500 words. Set to `'Diagnosis Not Available'` for 2,924 accessions where no `DIAGNOSIS:` section could be identified. Never NULL or empty string. |
| `MRN` | Patient medical record number | ID | string | Zero-padded to 8 digits, e.g. `00123456`. Never NULL. |
| `PROCEDURE_DATE` | Date the surgical procedure was performed | Continuous | date | `YYYY-MM-DD`. 2,163 rows have pre-1990 sentinel dates (bad data in IDB source); valid range 1990-01-01 – 2025. |
| `REPORT_DATE` | Date the pathology report was finalized | Continuous | date | `YYYY-MM-DD`. Source: `PRPT_REPORT_DTE` in `pathology_report_v`. Range: 1992-01-01 – 2025-04-17. Never NULL. |
| `PRPT_REPORT_TYPE` | IDB internal report type code | Categorical | string | `S_R` (985,873 acc), `S_SSL` (516,966), `S_CO` (102,319), `S_BRSSL` (92,029), `S_R_Order` (74,234), `DS_R` (69,333), `S_OSSL` (11,505), `S_OFNA` (1,671), other (≤11 acc each). |
| `DMP_PATIENT_ID` | IMPACT DMP patient identifier | ID | string | Format `P-XXXXXXXX`. NULL for non-IMPACT patients (839,601 − 77,117 = 762,484 distinct MRNs). 266,826 rows have a value. |

## Notes <a name="notes"></a>

**Primary key guarantee.** `(ACCESSION_NUMBER, PATH_DX_SPEC_NUM)` is unique — confirmed 0 violations:
```sql
SELECT ACCESSION_NUMBER, PATH_DX_SPEC_NUM, COUNT(*) as ct
FROM cdsi_prod.pathology_data_mining.table_pathology_surgical_samples_parsed_specimen_v2
GROUP BY ACCESSION_NUMBER, PATH_DX_SPEC_NUM
HAVING ct > 1  -- returns 0 rows
```

**PATH_DX_SPEC_DESC is never NULL or empty.** Use `PATH_DX_SPEC_DESC = 'Diagnosis Not Available'` to identify the 2,924 accessions where the parser could not locate a `DIAGNOSIS:` section (typically administrative or non-standard report formats).

**PATH_DX_SPEC_TITLE is never NULL but is empty string for single-specimen fallback rows.** 124,476 rows have `PATH_DX_SPEC_TITLE = ''`; these are accessions whose report had no numbered specimen header. The full diagnosis text is in `PATH_DX_SPEC_DESC`. Filter `PATH_DX_SPEC_TITLE != ''` to exclude them if you only want multi-specimen reports.

**PROCEDURE_DATE has 2,163 pre-1990 sentinel values** (e.g. `1899-12-26`) inherited from IDB source. Filter `PROCEDURE_DATE >= '1990-01-01'` for valid dates.

**MRN is always populated.** Every row has a non-null 8-digit MRN inherited from `pathology_report_v`.

**DMP_PATIENT_ID covers IMPACT accessions only.** Linked via `SOURCE_ACCESSION_NUMBER_0` join to the IMPACT annotation table. 87,500 distinct IMPACT accessions matched; DMP_SAMPLE_ID is not included (use the combined `surgical_specimen_diagnoses_impact` table for IMPACT-scoped work).

**One-to-many: MRN → ACCESSION_NUMBER.** Each patient may have many accessions over time. Each accession belongs to exactly one MRN.

**Many-to-one: ACCESSION_NUMBER → PATH_DX_SPEC_NUM.** Each accession has 1–99 specimen rows (mean 2.40).

## Why an S-accession may be missing <a name="missing"></a>

If you have an S-accession that you expect to find but cannot, use this decision table:

| Check | Query hint | Interpretation |
|---|---|---|
| Is it in `pathology_report_v`? | `SELECT * FROM src_idbdw_prod.dv.pathology_report_v WHERE TRIM(PRPT_ACCESSION_NO) = '{acc}'` | If not found, the record was never entered in IDB. Check Epic. |
| Is `PRPT_REPORT_TYPE` surgical? | Check `PRPT_REPORT_TYPE` value | Cytology (`C_*`), molecular (`M_*`), flow (`F_*`) and hematopathology (`H_*`) accessions are **not** in this table. |
| Is there a `DIAGNOSIS:` section? | Read `PRPT_REPORT` for the accession | If absent, the row exists with `PATH_DX_SPEC_DESC = 'Diagnosis Not Available'`. |
| Is it an IMPACT accession after ~2019? | Check Epic consolidated table | IDB is frozen; recent accessions may only exist in Epic. See `cdsi_eng_phi.cdm_eng_pathology_report_segmentation.surgical_specimen_diagnoses_combined` (IDB + Epic union). |

# Surgical Specimen Diagnoses, IMPACT (v1)

<b>Paths:</b>

| Tier | Table | Access |
|---|---|---|
| Engineering PHI | `cdsi_eng_phi.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` | Engineers only |
| Research PHI | `cdsi_res_phi.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` | Researchers on IRB, cohort building |
| Research de-identified | `cdsi_res_deid.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` | Researchers on IRB |
| Product | `cdsi_res_deid.pdm_product_cdsi.surgical_specimen_diagnoses_impact_v1` | Part A consented patients only |

Each tier also has `surgical_specimen_diagnoses_sample_links_v1`, linking surgical parts to molecular
(M) accessions and IMPACT samples (see [Sample links](#links)).

<b>Table Type:</b> `Static` (frozen snapshot; see Lineage) <br/>
<b>Version:</b> `v1` <br/>
<b>Date created:</b> `2026-09-28` <br/>
<b>Data product owner:</b> Pathology Data Mining (PDM) team, CDSI <br/>

<b>Lineage</b> ([pdm_catalogs SQL](https://github.com/pathology-data-mining/pdm_databricks_pipelines/tree/main/pathology_data_mining/pdm_catalogs)):

`cdsi_eng_phi.cdm_eng_pathology_report_segmentation.surgical_specimen_diagnoses_impact` (legacy CDM table, Delta version 242) <br/>
|_ `cdsi_eng_phi.pdm_base_tables.surgical_specimen_diagnoses_impact` (legacy_impact_bridge copy, run `manual-20260924-prod`) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_eng_phi.pdm_base_tables.legacy_impact_identity_review` (MRN to DMP patient ID resolution) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_eng_phi.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_res_phi.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_res_deid.pdm_base_tables.surgical_specimen_diagnoses_impact_v1` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_ `cdsi_res_deid.pdm_product_cdsi.surgical_specimen_diagnoses_impact_v1` <br/>

<b>Summary Statistics</b> (prod, computed 2026-09-29 after the first refresh):

| Measure | Rows |
|---|---:|
| Source rows (eng_phi, res_phi) | 990,806 |
| Releasable rows | 986,160 |
| Distinct res_deid rows (identical duplicates collapsed) | 986,013 (118,225 patients) |
| Product rows (Part A consented at refresh) | 769,390 (91,373 patients) |
| Withheld: diagnosis text could not be edited safely | 4,056 |
| &nbsp;&nbsp;bare 8+ digit number / abbreviated address / signature marker / dotted date after a date word (rows can have several) | 2,570 / 1,343 / 165 / 11 |
| Withheld: identity not resolved (ambiguous MRN, conflicting patient ID, non-identical duplicate) | 590 |
| Rows with at least one placeholder substitution in text | 313,032 |
| Sample links: eng_phi / res_phi / res_deid / product | 116,179 / 116,173 / 95,826 / 88,107 |
| res_deid surgical parts with a sample link | 85,025 |


# Table of contents
1. [Description](#description)
2. [Vocabulary](#vocab)
3. [Notes](#notes)
4. [Sample links](#links)

## Description <a name="description"></a>

Diagnosis title and description for each part of each surgical pathology accession for IMPACT
patients, from the legacy CDM NLP parse (IDB and Epic sources). v1 is a frozen snapshot: the
source was copied once, pinned to Delta version 242, and is not refreshed. The canonical parser
(`surgical_specimen_parser`) will replace it in a later version.

The tiers follow the CDSI [cBioPortal Data Ingestion - Design](https://mskconfluence.mskcc.org/spaces/CDSI/pages/273580547)
governance rules. eng_phi holds everything, including the MRN to DMP patient ID mapping. res_phi
holds MRN, dates, and raw text but no DMP IDs, for cohort building. res_deid holds DMP patient IDs
and scrubbed text but no MRN or dates, for analysis. The product table is the res_deid table
restricted to Part A consented patients.

### Vocabulary <a name="vocab"></a>

Primary key: (`ACCESSION_NUMBER`, `PATH_DX_SPEC_NUM`, `SOURCE`).

| **Field name** | **Description** | **Field Type** | **Data Type** | **Field Format** | **Tiers** |
|---|---|---|---|---|---|
| `ACCESSION_NUMBER` | Surgical pathology accession | ID | string | e.g. `S19-12345` | all |
| `PATH_DX_SPEC_NUM` | Specimen part number within the accession | ID | integer | 1, 2, ... | all |
| `SOURCE` | Report source | Categorical | string | `IDB`, `EPIC` | all |
| `PRPT_REPORT_TYPE` | Pathology report type | Categorical | string | as in source | all |
| `PATH_DX_SPEC_TITLE` | Part title (tissue and procedure) | Natural Language Description | string | raw in eng_phi/res_phi; scrubbed in res_deid/product | all |
| `PATH_DX_SPEC_DESC` | Diagnosis for the part | Natural Language Description | string | raw in eng_phi/res_phi; scrubbed in res_deid/product | all |
| `MRN` | Medical record number | ID | string | 8 digits, zero padded | eng_phi, res_phi |
| `PROCEDURE_DATE` | Procedure date | Continuous | date | YYYY-MM-DD | eng_phi, res_phi |
| `REPORT_DATE` | Report date | Continuous | date | YYYY-MM-DD | eng_phi, res_phi |
| `DMP_PATIENT_ID` | IMPACT patient ID resolved from MRN | ID | string | `P-0000000` | eng_phi, res_deid, product |
| `DEID_TITLE`, `DEID_DESC` | Scrubbed title and description | Natural Language Description | string | see Notes | eng_phi |
| `DEID_WITHHOLD_REASONS` | Why the row is withheld from res_deid | Categorical | string | comma separated; empty when releasable | eng_phi |
| `RELEASABLE` | Row is published to res_deid | Categorical | boolean | true/false | eng_phi |
| `REVIEW_STATUS` | Identity and consent review outcome | Categorical | string | see Notes | eng_phi |

## Notes <a name="notes"></a>

- **Clinician names are not masked in v1.** Diagnosis text in every tier can contain pathologist,
  surgeon, or consultant names.
- **Known linkage.** `ACCESSION_NUMBER` is in both res_phi (with MRN) and res_deid (with
  `DMP_PATIENT_ID`), so a user with access to both tiers can join MRN to DMP patient ID. This was
  accepted for v1.
- **Placeholders in res_deid and product text.** Identifiers are replaced, not deleted:
  `[DATE]`, `[ACCESSION]` (accession and outside case numbers), `[PHONE]`, `[EMAIL]`, `[ADDRESS]`
  (spelled-out street suffixes), and `[MRN]` (the patient's own MRN, with or without zero
  padding). `[DATE]` covers `m/d/yy(yy)`, `m-d-yy(yy)`, `m.d.yyyy`, `yyyy-m-d`, `yyyy/m/d`,
  `m/yyyy`, and month names or abbreviations with a day and/or year (`Jan 5, 2019`, `5 Jan 19`,
  `Sept. 2019`, `May 2019`), including forms split across line breaks. A year on its own is kept.
  Dotted two-digit-year forms (`3.15.19`) are not replaced because they are usually section or
  measurement numbers; a row is withheld when one follows a date word such as `collected on`.
- **Withheld rows.** A row is not released when its scrubbed text still contains a signature
  marker (`SIGNED BY`, `PATHOLOGIST:`), an address with an abbreviated suffix (`DR`, `ST`, `CT`,
  ...), a bare run of 8 or more digits (possible MRN or compact date), a dotted two-digit-year date
  after a date word, or any residual identifier pattern. These rows remain in eng_phi and res_phi.
- **Identity.** `DMP_PATIENT_ID` comes from the unique MRN to DMP patient mapping in
  `t03_id_mapping_pathology_sample_xml_parsed`. Ambiguous or conflicting mappings and non-identical
  duplicate diagnosis keys are not released. `DMP_SAMPLE_ID` is not published because it is empty
  in the v1 source.
- **Consent.** res_deid base tables include patients without Part A consent; the product table
  keeps only `PARTA_CONSENTED_12_245 = 'YES'` in `product_cdsi.msk_impact.data_clinical_patient`.
- **Guarantees checked on every refresh** (the job fails otherwise): one eng_phi row per source row;
  every row has a current identity review; the primary key is unique among released rows; released
  patient IDs match `^P-[0-9]{7}$`; the row's own MRN never appears in released text; res_phi has
  no DMP ID columns; res_deid and product have no MRN or date columns; every product row has Part A
  consent.

## Sample links <a name="links"></a>

`surgical_specimen_diagnoses_sample_links_v1` holds one row per distinct surgical accession/part to
molecular accession/part to IMPACT sample relationship, from
`table_pathology_impact_sample_summary_dop_anno_epic_idb_combined` (both DOP source columns).
The DMP patient comes from `t03_id_mapping_pathology_sample_xml_parsed`, joined on the sample ID.
Join to the diagnoses on (`ACCESSION_NUMBER`, `PATH_DX_SPEC_NUM`); diagnosis rows are not multiplied.

| **Field name** | **Description** | **Field Type** | **Data Type** | **Tiers** |
|---|---|---|---|---|
| `ACCESSION_NUMBER`, `PATH_DX_SPEC_NUM` | Surgical accession and part (join key to the diagnoses) | ID | string, integer (string in res_phi) | all |
| `MOLECULAR_ACCESSION_NUMBER` | Molecular (M) accession of the sequenced sample | ID | string | all |
| `MOLECULAR_SPECIMEN_NUMBER` | Part number within the M accession | ID | string | all |
| `DMP_PATIENT_ID` | IMPACT patient ID | ID | string | eng_phi, res_deid, product |
| `DMP_SAMPLE_ID` | IMPACT sample ID, `P-#######-T##-XX#` | ID | string | eng_phi, res_deid, product |
| `LINK_STATUS` | `RESOLVED` (one sample), `MULTIPLE_SAMPLES` (part sequenced more than once), `MISSING_SAMPLE_ID`, `NON_NUMERIC_PART`, `CONFLICTING_MRNS`, `CONFLICTING_DMP_PATIENTS` | Categorical | string | all |

Notes:
- res_phi keeps every link with its status but no DMP IDs or MRN, so it cannot map MRN to DMP ID
  on its own. The accession linkage caveat above applies here too.
- res_deid and product keep only `RESOLVED` and `MULTIPLE_SAMPLES` links to an M accession whose
  surgical part is a released diagnosis row for the same DMP patient, so every link joins a
  diagnosis row. Conflicting identities, non-numeric parts, and links to unreleased diagnoses are
  excluded.
- Checked on every refresh: sample IDs are well formed and belong to their patient; a `RESOLVED`
  part has exactly one link; every released link joins a released diagnosis for the same patient;
  column sets match the tier rules.

### Changelog

- `v1` (2026-09-28): first research-tier release from the frozen legacy snapshot.
- `v1` (2026-09-29): added `surgical_specimen_diagnoses_sample_links_v1` (surgical part to M accession and IMPACT sample).

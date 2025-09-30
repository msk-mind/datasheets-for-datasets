# Pathology Reports for IMPACT Samples

<b>Path:</b> `cdsi_res_phi.pdm_base_tables.impact_pathology_reports` <br/>
<b>Table Type:</b>  <br/>
<b>Last updated:</b> `2025-09-29` <br/>

<b>Lineage:</b> 

<br/>

<b>Summary Statistics:</b>

Total number of rows: #,###,### <br/>
Total number of accessions: #,###,### <br/>
Total number of samples: #,###,### <br/>
Total number of patients: #,###,### <br/>


1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)


## Description <a name="description"></a>

This table provides the full text of pathology reports (surgical and molecular) associated
with IMPACT samples.  It is a subset of the IDB table `dv_pathology_reports_v`. 

## Assumptions <a name="assumptions"></a>

No known assumptions.


## Vocabulary & Encoding <a name="vocabulary"></a>

| **Field name** | **Description** | **Field Type** | **Format** |
|---|---|---|---|
| `PRPT_PATH_RPT_ID                BIGINT       | Report ID | ID | integer |
| `PRPT_PT_DEIDENTIFICATION_ID     BIGINT       | DMP_ID | ID | integer |
| `PRPT_MRN                        VARCHAR      | MRN | ID | string |
| `PRPT_PROCEDURE_DTE              VARCHAR      | Date of procedure | Date | string |
| `PRPT_REPORT_DTE                 VARCHAR      | Report date | Date | string |
| `PRPT_ACCESSION_NO               VARCHAR      | Accession number | ID | string |
| `PRPT_REPORT_TYPE                VARCHAR      | Report type | categorical | string |
| `PRPT_REPORT_TYPE_DESC           VARCHAR      | Report type | text | string |
| `PRPT_REPORT                     VARCHAR      | Report text | text | string |
| `PRPT_DEID_REPORT                VARCHAR      | Report text (DEID) | text | string |
| `PRPT_ORDERING_MEDPRO_ID         BIGINT       |  | ID | integer |
| `PRPT_ORD_DR_NO                  VARCHAR      | Doctor number | ID | string |
| `PRPT_ORD_DR_NAME                VARCHAR      |  |  | string |
| `PRPT_ORD_DR_SVC                 VARCHAR      |  |  | string |
| `PRPT_ORD_DR_SVC_DESC            VARCHAR      |  |  | string |
| `PRPT_CREATED_BY                 VARCHAR      | Report author | name | string |
| `PRPT_CREATED_DT                 VARCHAR      | Report creation date | date | string |
| `PRPT_MODIFIED_DT                VARCHAR      | Report modification date | date | string |
| `PRPT_CONTENT_CREATED_DT         VARCHAR      | Content creation date | date | string |
| `PRPT_CONTENT_MODIFIED_DT        VARCHAR      | Content modification date | date | string |
| `PRPT_DEID_DT                    VARCHAR      | De-identification date | date | string |
| `PRPT_PROCEDURE_DATE_ID          BIGINT       | Procedure date ID | ID | integer |
| `PRPT_REPORT_DATE_ID             BIGINT       | Report date ID  | ID | integer |
| `PRPT_MEDTAS_PROCESSED_FLAG      VARCHAR      | MEDTAS processed flag | boolean | string |
| `PRPT_MEDTAS_PROCESSED_DT        BIGINT       | MEDTAS processed date | date | integer |
| `PRPT_DV_PROCESS_DTE             VARCHAR      | DV processed date | date | integer |
| `SAMPLE_ID`                                   | IMPACT sample ID | ID | VARCHAR |

## Rules <a name="rules"></a>




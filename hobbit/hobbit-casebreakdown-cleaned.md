# hobbit_casebreakdown_cleaned

<b>Path:</b> "pathology-data-mining"."impact_slide"."case_breakdown_cleaned" <br/>
<b>Table Type:</b> Live <br/>
<b>Late updated:</b> 2024-05-17 <br/>

<b>Lineage:</b>

HoBBit SQL Server <br/>
|_ ["hobbit-poc"."case_breakdown"](hobbit-casebreakdown.md) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|_ "hobbit-poc"."case_breakdown_cleaned" <br/>

<b>Summary Statistics:</b>

Total number of rows: 6,235,731 <br/>
Total number of unique patients: 369,471 <br/>
Total number of unique slides: 6,235,731 <br/>

Last updated July 1, 2024.  (New slides are typically added weekly.)

1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabulary)
3. [Rules](#rules)

## Description <a name="description"></a>

Removes duplicate rows in "hobbit-poc"."case_breakdown". Also removes rows where `image_id` is duplicated but at least one other column has unique vaiues. 

## Assumptions

If two rows have the same image_id but different values in other columns, those rows and those image_ids are discarded in this dataset because it is assumed that a slide cannot have different attributes. 

For example, it is assumed there cannot be a slide with two different stain groups as shown below.

| **stain_group** | **image_id** |
|---|---|
| IHC | 2180122 |
| SS | 2180122 |

## Vocabulary & Encoding <a name="vocabulary"></a>

See base table in lineage. 
 
## Rules

See base table in lineage. 

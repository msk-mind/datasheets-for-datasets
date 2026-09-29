# CoPath Molecular Links

<b>Path:</b> `"hobbit-poc"."molecular_cases"` <br/>
<b>Last updated:</b> `2024-12-05` <br/>

<b>Lineage </b> 



<b>Summary Statistics:</b>

Total number of rows: 185,939 <br/>


1. [Description](#description)
2. [Vocabulary](#vocabulary)
3. [Notes](#notes)


## Description <a name="description"></a>

A table listing tissue descriptions to block ID for IMPACT samples.  The table maps
DMP (Molecular) accession numbers to a tissue description, and to the surgical accession and part
numbers.

The workflow that is used in Dept. of Pathology and Lab Medicine to generate this data is as follows:

A tumor part and a normal part is submitted for analysis. The normal part for a solid tumor is the blood that's collected and submitted to Pathology and Lab Medicine (PLM) for the solid. The tumor part is from recuts from Surgical Pathology (SP) or from slides submitted to Pathology and Lab Medicine. 

On receiving a request, PLM reviews samples to check if there is sufficient tissue or if a recut needs to be requested. The recut request is placed on a block that is determined to contain the tumor. This involves communication between PLM and SP. Once SP determines the block that contains tumor the slide(s) recut is/are made. The slide(s) is/are then accessioned in CoPath with the Molecular Number or M-Number and Part Description (which includes Surgical Case Number or S-Number plus the block designator label from which the recut was made). The section of the Part Description inside parenthesis is meant to be machine readable but it is hand typed and therefore may contain typos. If it is a tissue from an external source, then it is mentioned as an "outside" case. If there is a date of procedure provided it is mentioned as "DOP". Sometimes there is a "photo" number that is also added in the comments because an image may have also been submitted. The section of the part description that precedes the parenthesis portion is natural text that is copy-pasted from the pathology report. 

Once the slide is received and accessioned in CoPath, a Fellow reviews the slides and annotates the tumor percentage on the slide(s) and whether the slides requires micro-discection or if the whole slide needs to be scraped. The slide(s) are then sent for extraction. Based on the amount of tumor, the extraction team determines how many slides need to be scraped so as not to overload the extraction procedures. The slides are scraped and they are lysed overnight. They are then extracted the following day. The NGS team again verifies if there is a tumor with a corresponding normal tissue in order to create a batch for that sample. If not, the sample remains in queue until a missing normal or tumor is received. When the batch is created the true testing begins. The testing is a 4 day wet bench prep with sequencing on the 5th day which is a 24 hour event. An analysis pipeline is run which is then put through a manual review for corresponding mutations and it is signed out by the pathologist on the case. If the results of the analysis looks good, an official report is generated and signed out in CoPath. The report is sent to CBioportal. 

Things will change after EPIC is rolled out. With EPIC things like specimen source and type will be standardized based on a dictionary. EPIC data should be obtainable from Clarity and Caboodle (EPIC) databases in the future through Databricks.


## Vocabulary <a name="vocabulary"></a>


| **Field name** | **Description** | **Field Type** | **Data type** | **Format** |
|---|---|---|---|---|
| specnum_formatted | 'M' accession number from DMP or Molecular Number | ID | string | |
| specclass_id |  | string  | Categorical | [DMPN, DM, MPATH]|
| part_inst | part id from surgical accession | ID  | integer  | |
| part_type | tissue type | string | categorical  | See below |
| part_description | free text followed by machine readable form in parenthesis with link to Surgical accession ID, part number and block designator that can be used to link an IMPACT sample to a specific block | ID  | string  | |

|** part_type **|
| Cord Blood Donor |
| DM NK CELL |
| DM SUBMITTED SLIDES-NORMAL |
| BLOOD |
| BUCCAL CELL SCRAPE |
| DM DNA |
| FNA SMEAR |
| DM RNA |
| Fresh Tissue |
| Nail clipping |
| SALIVA |
| Sorted Cells |
| BIOP |
| Blood (Paxgene) |
| Cell Lysate |
| DM PERIPHERAL BLOOD STEM (HPC-A) |
| CEREBROSPINAL FLUID |
| DM Pleural Fluid |
| "Lymph nodes, regional resection." |
| cell pellet (SUP) |
| BONE MARROW - DM |
| Bone Marrow (Paxgene) |
| DM SUBMITTED SLIDES |
| Donor Blood |
| FROZEN TISSUE |
| Flow Cytometry |
| SMEAR |
| cfDNA |
| BUCCAL SWABS |
| Cytology Specimen |
| DM DONOR NK CELL |
| DM DONOR PERIPHERAL BLOOD STEM (HPC-A) |
| DM PARAFFIN CURLS |
| DM SUBMITTED SLIDES-TUMOR |
| Donor Bone Marrow |
| Extracted Lysate |
| PARAFFIN BLOCK |
| T-CELLS |



## Notes <a name="notes"></a>



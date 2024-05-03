# PDM Datasheet

## Objective:

Present a unified view of slides and their metadata that are currently spread out across multiple data sources. Unifying this into a single table would lead to more consistency in data engineering, cohort selection, and project upkeep as it would reduce the amount of data wrangling needed.

## Data Sources:

This datasheet pulls together data from three sources: HoBBIT, IMPACT, and CDM Accession Table.
Before describing how they are merged together, we'll describe each of these sources in more detail.

### HoBBIT Data:

- Owner: MSK Pathology Department / Luke Geneslaw

#### Description: 

A collection of the metadata for all digitized slides processed by the Pathology Department at MSK. To interface with this data we are using [Dremio](https://tlvidreamcord1:9047/login?redirect=%2F), since the metadata database was added as a source. 

In this table each row represents a slide, along with the metadata associated with that slide such as mrn, part_type, part_description, stain_name, stain_group, scanner_id, brand, model, image_id, magnification, and more.

The table in Dremio is a live table that is constantly being updated as new slides are scanned. This table may be used by researchers who are interested in using pathology images in their research. Researchers may use this table to search for slides of interest or slides that have been scanned while they build their patient cohorts.

#### Statistics

- Number of rows: 6100645
- Number of slides: 6100645
- Number of patients: 367079

### IMPACT Data:

- Owner: CDSI / Clinical Data Mining

#### Description

Combination of ONCOKB annotated data with solid heme patient data. Also removed CFDNA samples (i.e. only analyzed samples with SAMPLE_CLASS of 'Tumor')

#### Statistics

- Number of rows: 112676
- Number of patients: 85160
- Number of samples: 112676

#### ONCOKB sample level

- Source: [Git repo](https://github.mskcc.org/cdsi/oncokb-annotated-msk-impact)
    - Note: You will need access to view the above link
- Documentation: [CDSI Docs](https://github.mskcc.org/pages/cdsi/docs/cdsi-data/data-dictionary/cdm_md_project_sample_summary_data/)

##### Description

Sample-level clinical attributes alongside their OncoKB annotations. This table is updated daily by cbioportal and pulled into dremio via a cron script. Each row represents a sample and contains information such as date added, sample type, and metastatic site.

#### SOLID-HEME patient level

- Source: [Git repo](https://github.mskcc.org/cdsi/msk-impact/tree/master/msk_solid_heme)
    - Note: You will need access to view the above link
- Documentation: [CDSI Docs](https://github.mskcc.org/pages/cdsi/docs/cdsi-data/data-dictionary/cdm_md_project_patient_summary_data/)

##### Description

Patient-level clinical attributes. This table is updated daily by cbioportal and pulled into dremio via a cron script. Each row in this table represents a patient and contains information such as their gender, age, and ethnicity.

### CDM Accession Table

- Owner: Clinical Data Mining

#### Description

#### Statistics

## Data Flow Diagram:

Snakey/merges of various source tables

## Field Names:

## Outstanding Questions:

- Why do some samples have multiple entries linked back to different MRNs?
- Why are there duplicate entries in the hobbit data?
- Is the same specimen scanned at 20x and 40x?
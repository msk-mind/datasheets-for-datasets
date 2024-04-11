# Case Breakdown Table



# Table of contents
1. [Description](#description)
2. [Assumptions](#assumptions)
3. [Vocabulary and Encoding](#vocabandencoding)
3. [Rules](#rules)

## Description <a name="description"></a>

The CaseBreakdown table is a table in MSK’s [HoBBIT](https://pubmed.ncbi.nlm.nih.gov/34260720/) (Honest Broker for BioInformatics Technology) database that contains information about anonymized images. HoBBIT is a database in the Department of Pathology (DP) that is designed to compile and share large-scale DP research datasets including anonymized images, redacted pathology reports, and clinical data of patients with consent. 

The CaseBreakdown table in Dremio is a live table that is constantly being updated as new slides are scanned daily. This table may be used by researchers who are interested in using pathology images in their research. Researchers may use this table to search for slides of interest or slides that have been scanned while they build their patient cohorts.

![Lineage graph for case breakdown table](./images/hobbit_lineage.png)

Tissue that is resected from a patient during surgery is sent to DP where it is processed. Tissue may be resected from multiple anatomical sites from a single surgical procedure. Processing involves breaking up the tissue from each anatomical site into parts and blocks. A part can contain many blocks. Both parts and blocks are given designator labels called part number and block number. Certain blocks of interest are then selected to create slides. Tissue from these blocks is also sent for IMPACT sequencing. Typically 10 to 20 slides are created from the blocks and 1 or 2 samples of tissue from the same set of blocks as those that were selected for creating slides is sent for IMPACT sequencing. It is important to try to match the part number and block number from which the IMPACT tissue sample was taken, to the part and block number of the slides in order to find the slides closest to the IMPACT tissue sample. 

![Hierarchy of the identifiers in the data](./images/hobbit_image_id_hierarchy.png)

### Matching slide data to IMPACT data

In order to match the slides to IMPACT data, we need to ensure that the slides were created at least from the same part, if not block, as the tissue that was taken for IMPACT sequencing. i.e. we try to at least match at the part level. This association needs to be done through the IDs or designator labels that are assigned to each of these items through the accessioning process. The process of accessioning an item is simply to take inventory of the item by assigning it an ID with which it can be tracked in a database. The following database IDs are in play for this matching:

1. image id: ID given to a scanned slide.
2. Anatomical site: The site from which the tissue was resected. This information is usually presented in natural language and is found in the Hobbit casebreakdown table under the column part_description.
3. S Number: The S Number or surgical number is assigned to tissue that is accessioned from a surgery. Example format is S16-22222. The S number is considered PHI and is found in the case breakdown table for each slide under the column named specnum_formatted. The S number is also found in the CHORD table phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv" for each impact sample under the column SOURCE_ACCESSION_NUMBER_0.
4. M Number: The M number or molecular number is assigned to tissue that is sent for an IMPACT sequencing case. Example format is M19-22222. This ID is also considered PHI. The M number is associated with the part and block designator label in the pathology report through a suffix assigned to the ID. Example M19-22222/2:9M. Here the suffix indicates part instance 2 and block designator 9M. The part number from this suffix is extracted using NLP into the CHORD table phi_data_lake."cdm-data".pathology."table_pathology_impact_sample_summary_dop_anno.tsv" for each impact sample under the column SOURCE_SPEC_NUM_0.

Unfortunately, there is no direct link between this format of the M number and the S number that is maintained in any upstream database (at least to our knowledge). This link has to be built out indirectly as follows:

Join Hobbit Casebreakdown table's {slide_id, S number, part number, anatomical site} with the CHORD tables's {impact sample id, S number, part number} on part number to filter out {slide_id, anatomical site, impact sample id}. Through this process, we are now able to identify certain slides that map to IMPACT samples by anatomical site up to the level of a part. There is no known way to map a slide up to a block because the block number is not present in the CHORD tables. 

Incompleteness in this site matched data can arise from the following issues:

1. The M number association with part inst and block designator label may not be well formatted as it is in the case report so this may lead to some data misses
2. There may not be any h&e slides from the part inst and block designator from the M number.
3. There may not be a h&e image id because the slide was never scanned. This can be overcome by requesting for the slide to be scanned.

## Assumptions <a name="assumptions"></a>
None that are currently known by the data consumers about the environment in which this data was collected. 

### Vocabulary and Encoding <a name="vocabandencoding"></a>

<table>
  <tr>
   <td><b>Field nameE</b>
   </td>
   <td><b>Description</b>
   </td>
   <td><b>Field Type </b>
   </td>
   <td><b>Encoding<b/>
   </td>
  </tr>
  <tr>
   <td>specnum_formatted
   </td>
   <td>Identifies a surgical procedure
   </td>
   <td>ID
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>specclass_id
   </td>
   <td>Description is not known.
   </td>
   <td>ID
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>subspecialty
   </td>
   <td>Best guess at description.
<p>
Disease management team from which the (solid or liquid) tissue was sourced. 
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>priority
   </td>
   <td>Type of patient visit - a detailed list
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>reduced_priority
   </td>
   <td>Type of patient visit - a summary list
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>datetime_accession
   </td>
   <td>Date of procedure
   </td>
   <td>Date
   </td>
   <td>date
   </td>
  </tr>
  <tr>
   <td>signout_datetime
   </td>
   <td>Description is not known.
   </td>
   <td>Date
   </td>
   <td>date
   </td>
  </tr>
  <tr>
   <td>part_inst
   </td>
   <td>Part identifier
   </td>
   <td>ID
   </td>
   <td>integer
   </td>
  </tr>
  <tr>
   <td>part_designator
   </td>
   <td>Description is not known.
   </td>
   <td>ID
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>part_type
   </td>
   <td>Anatomical site; Tissue extraction method \
 \
Example:  \
TRACHEA; RESECTION
   </td>
   <td>Mixed Field
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>part_description
   </td>
   <td>Description of the anatomical site from which the part was obtained
   </td>
   <td>Natural Language Description
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>block_inst
   </td>
   <td>Block identifier
   </td>
   <td>ID
   </td>
   <td>integer
   </td>
  </tr>
  <tr>
   <td>blkdesig_label
   </td>
   <td>Description is not known.
   </td>
   <td>Mixed Field
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>barcode
   </td>
   <td>Description is not known.
   </td>
   <td>Mixed Field
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>stain_inst
   </td>
   <td>Description is not known.
   </td>
   <td>ID
   </td>
   <td>integer
   </td>
  </tr>
  <tr>
   <td>stain_name
   </td>
   <td>Specific name of the stain used on the slide
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>stain_group
   </td>
   <td>Broad category of stain name used to stain the slide
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>scanner_id
   </td>
   <td>Identifier for the scanner used to scan the slide
   </td>
   <td>ID
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>brand
   </td>
   <td>Brand name of the scanner
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>model
   </td>
   <td>Model name of the scanner
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>image_id
   </td>
   <td>Identifier for the image that was scanned from the slide
   </td>
   <td>ID_Primary_Key
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>magnification
   </td>
   <td>Magnification at which the slide was scanned
   </td>
   <td>Categorical Variable
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>status_id
   </td>
   <td>Description is not known.
   </td>
   <td>ID
   </td>
   <td>string
   </td>
  </tr>
  <tr>
   <td>file_size_bytes
   </td>
   <td>Size of the scanned image in bytes
   </td>
   <td>Continuous Variable
   </td>
   <td>integer
   </td>
  </tr>
  <tr>
   <td>captured_datatime
   </td>
   <td>Description is not known.
   </td>
   <td>Date
   </td>
   <td>date
   </td>
  </tr>
</table>

## Categorical Variables:

**Subspecialty**

Ordered in descending order of volume of images. 




## Rules <a name="rules"></a>
The second paragraph text

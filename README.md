# Data Sources:

Clinical Data Mining (CDM) - Datasets generated from abstracting data elements from clinical reports
IMPACT - MSK IMPACT cohorts
HoBBit - Pathology slide inventory datasets
Pathology Data Mining (PDM) - Datasets generated from abstracting data elements from pathology slides


# Datasheets for Datasets in Practice

The example datasheet and template provided here were inspired by Timnit Gebru's paper on [Datasheets for Datasets](https://dl.acm.org/doi/10.1145/3458723). The example dataset has been created by CDSI’s Pathology Data Mining (PDM) group to give data consumers an idea of what a datasheet could look like so they can assess its value. 

We think a datasheet should be owned and maintained by the data product owner and data consumers may contribute to it by identifying additional information they see necessary from the consumer point of view in order to make the datasheet richer and more valuable for other consumers. Given that this datasheet has been created entirely by data consumers to serve as an example, some parts of the datasheet are incomplete or may even be inaccurate. This datasheet therefore portrays the perspective of a data consumer who was given access to the data without the datasheet. As is normally the case, the information in this datasheet was obtained from the data product owner through verbal communication which is an ineffecient and ineffective way to communicate important details about a dataset. The incompleteness and the potential inaccuracies have been mentioned where it is known. This example datashet should therefore further strengthen in the mind of the reader the need to establish the practice of maintaining datasets for datasheets by data product owners in order to effectively and unambiguously communicate the details behind the dataset to data consumers.

## Datasheets Template
The template is made in Markdown. If users are not familiar with Markdown or find it cumbersome to edit, they may use the [Docs to Markdown converter](https://www.docstomarkdown.pro/) Google Docs Extension to convert the template to Google Docs format, then create the data sheet on Google Docs, and finally convert the datahseet back to Markdown format before committing to Github for version control. 

## Existing Datasheets implementations

The Cbioportal formatted file is the only known implementation of the concept of a datasheet and is a great effort to meet this need. It contains field descriptions and field encodings, but it is missing important contextual information that could go into the description and rules sections as shown in the template and example above. The cbioportal formatted file also seems to be designed more for machines to read the format than a human. Furthermore, categorical variables are not defined in the cbioportal format.

The example above decouples the datasheet from the dataset in order to make it more human readable (with images etc.) and at the same time, it is possible to keep the datasheet adjacent to a dataset through a tool like Dremio whose Wiki feature may be used to link out to the version controlled Markdown datasheet on github.


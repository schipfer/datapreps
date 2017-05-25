# Fetched Eurostat data preparation

To bind .rds data sets together and to correct following points:
(R file is updated for 2017 paper, this md not)

* dates to date format
* cuts out all EU values (Import to AT from EU28)
* produces a matrix that gives all specifications
* conversion of 100kg to 0.1t
* calculates specific import / export prices based on Eurostat data
* deletes all Reporter = Partner trade flows that are generated throughout the process

saves into working directory allflows(creationdate).rds
saves into working directory specification matrix of all data tables..

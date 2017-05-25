
then binds all data sets together and corrects following points:

* dates to date format
* cuts out all EU values (Import to AT from EU28)
* produces a matrix that gives all specifications
* conversion of 100kg to 0.1t
* calculates specific import / export prices based on Eurostat data
* deletes all Reporter = Partner trade flows that are generated throughout the process

saves into working directory allflows(creationdate).rds
saves into working directory specification matrix of all data tables

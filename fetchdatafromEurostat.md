# What to know about this chunk

### Eurostat SDMX identification
SDMX code /dat/DS-016893/M."REPORTER"...440131."FLOW"."UNIT"?startperiod=2012"

Wood pellets have the HS code 440131
all flows since Jan2012 reported by specified countries

Variables to be defined:
* FLOW == 1 for imports and 2 for exports
* UNIT="QUANTITY_IN_100KG" or "VALUE_IN_EUROS"
* REPORTER == A2 country codes as used in Eurostat

Output:
saves single data sets for physical imports, exports, and monetary imports, exports
should run 8min for each data set (depending on the internet connection).

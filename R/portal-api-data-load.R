# Hakai Data Portal API and data loading
## This script needs to be run independently, prior to
## `SeagrassSiteLevelProduction.Rmd` in order to connect to the
## data portal, and save the input data that will be used
## for the package
## NOTE: this script only needs to run once (or when the
##       datasets are updated) for each package version

# To install the hakaiApi package, visit the 
# [hakai-api-client-r](https://github.com/HakaiInstitute/hakai-api-client-r)
# github repository and follow the install instructions in the README.

# load hakaiApi package
library(hakaiApi)
library(magrittr)
library(dplyr)

Client$remove_old_credentials()  # cached credentials can sometimes cause problems
client <- hakaiApi::Client$new() # Follow stdout prompts to get an API token

# define density data database call
zmDensityCall <- sprintf("%s/%s", client$api_root,
                           "eims/views/output/mg_seagrass_density?limit=-1")

zmHabitatCall <- sprintf("%s/%s", client$api_root,
                         "eims/views/output/mg_seagrass_habitat?limit=-1")

# Pull data and store
zmDensity <- client$get(zmDensityCall) %T>% glimpse()
zmHabitat <- client$get(zmHabitatCall) %T>% glimpse()

# Once all data appears correct, save in /raw-data directory
write.csv(density, "raw-data/seagrass_density.csv")
write.csv(habitat, "raw-data/seagrass_habitat.csv")

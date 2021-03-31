# Seagrass site-level production data package
## Load, check, export
# ---
# This script loads, cleans, and combines the datasets required for the Hakai 
#   Nearshore: Seagrass site-level production data package
# All of this data is stored on the Hakai EIMS and accessed from the Data Portal,
#   using the HakaiApi R package

## Setup ##
# clear workspace prior to starting
rm(list = ls())

# load necessary packages
lapply(c("tidyverse",
         "lubridate", 
         "magrittr",
         "hakaiApi"),
       library,
       character.only = TRUE)

# create client for API client
client <- hakaiApi::Client$new()  # Follow stdout prompts to get an API token

# define density data database call
zmDensityCall <- sprintf("%s/%s", client$api_root,
                         "eims/views/output/mg_seagrass_density?limit=-1")

zmHabitatCall <- sprintf("%s/%s", client$api_root,
                         "eims/views/output/mg_seagrass_habitat?limit=-1")

# Pull data and store
zmDensity <- client$get(zmDensityCall) %T>% glimpse()
zmHabitat <- client$get(zmHabitatCall) %T>% glimpse()


## Data QC ##
# Before the data is ready to be packaged, this section will perform some
#   basic quality control checks, ensuring all the data is present,
#   and ensure all the values seem appropriate

### Density surveys
# Check all data is present:
#  - annual sites (Triquet, Goose, McMullin) have one set of data each year
#  - seasonal sites (Choked, Pruth, Koeye) have same number of summer visits
#  - Choked, Pruth have February and November visits starting 2017
#  - secondary annual sites (McMullin S, Goose SE, Triquet N) only have
#     3 observations transects in 2018

# Create a function for viewing all sites in a year, by month, for a 
#   given variable
viewYearContinuous <- function (data, year, yVar, xVar = "survey") {
  data %>%
    filter(year(date) == year) %>%
    ggplot(aes_string(x = xVar,
                      y = yVar)) +
    geom_boxplot(outlier.colour = "red") +
    facet_grid(~ month(date)) +
    labs(title = year) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Create a function for viewing number of observations at all sites,
#  in a year, by month
viewYearCounts <- function (data, year) {
  data %>%
    filter(year(date) == year) %>%
    ggplot(aes(x    = factor(transect_dist),
               fill = month(date))) +
    geom_histogram(stat = "count") +
    facet_grid(survey ~ factor(month(date))) +
    labs(title = year) +
    theme_classic()
}

# Plot each year of data, check correct number of values are present
viewYearCounts(zmDensity, "2015")
viewYearCounts(zmDensity, "2016")
viewYearCounts(zmDensity, "2017")
viewYearCounts(zmDensity, "2018")
viewYearCounts(zmDensity, "2019")
viewYearCounts(zmDensity, "2020")

# Plot each year of data, check for suspect values
viewYearContinuous(zmDensity, "2015", "density")
viewYearContinuous(zmDensity, "2016", "density")
viewYearContinuous(zmDensity, "2017", "density")
viewYearContinuous(zmDensity, "2018", "density")
viewYearContinuous(zmDensity, "2019", "density")
viewYearContinuous(zmDensity, "2020", "density")


# For suspect values (or number of observations), use the below chunk 
#  of code to "zoom in"
zmDensity %>% 
  filter(survey == "CHOKED_PASS",  # enter the survey name, in quotes
         year(date) == 2017,  # enter year here, no quotes needed
         month(date) == 11) %>%  # enter month here, no quotes
  ggplot(aes(x   = factor(transect_dist),
             y   = density)) +  # enter variable of choice here, 
  geom_boxplot(outlier.colour = "red") +
  facet_grid(~ site_id) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Once suspect values have been found, confirm value with hard copy datasheets.
#  If values have been incorrectly entered, fix value in database.
#  Repeat as necessary.

### Habitat surveys 
# Create a function for viewing all sites in a year. Because this data
#  is categorical (as opposed to the continuous density data), we won't
#  check the range of values, but we can confirm the correct number of
#  observations are present for each site visit.

# Plot each year of data, check correct number of values are present
viewYearCounts(zmHabitat, "2015")
viewYearCounts(zmHabitat, "2016")
viewYearCounts(zmHabitat, "2017")
viewYearCounts(zmHabitat, "2018")
viewYearCounts(zmHabitat, "2019")
viewYearCounts(zmHabitat, "2020")

## Data Subset ##
# Now all the data has been checked, the final step is to subset the
#  required variables for this dataset from each dataframe, and then 
#  save the 

metaVars <- c(organization,
              work_area,
              project,
              survey,
              site_id,
              date,
              sampling_bout,
              dive_superviosr,
              collector,
              hakai_id,
              sample_type,
              depth,
              transect_dist,
              collected_start,
              collected_end)

zmProductivityHabitat <-
  zmHabitat %>%
  select(metaVars,
         patchiness,
         substrate,
         adjacent_habitat_1,
         adjacent_habitat_2)

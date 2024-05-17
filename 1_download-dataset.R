library(tidyverse)
library(lubridate)
library(openxlsx)
library(stringr)
library(reshape2)
library(flextable)
library(ggthemes)
library(jsonlite)

LUNAR_DISTANCE <- 384402
ASTRONOMICAL_UNITS <- 149597900
AU_to_LD <- ASTRONOMICAL_UNITS / LUNAR_DISTANCE

# https://cneos.jpl.nasa.gov/ca/

t <- read_json("https://ssd-api.jpl.nasa.gov/cad.api?dist-max=1000LD&date-min=2010-01-01&diameter=true&fullname=true", simplifyVector = TRUE)
data.raw <- as.data.frame(t$data)
colnames(data.raw) <- t$fields
remove(t)

d <- data.raw
# %>%
#   mutate(
#     cd = ymd_hm(cd),
#     cd_date = as.Date(cd),
#     dist = as.numeric(dist),
#     dist_min = as.numeric(dist_min),
#     dist_max = as.numeric(dist_max),
#     dist_ld = dist * AU_to_LD,
#     v_rel = as.numeric(v_rel),
#     v_inf = as.numeric(v_inf),
#     diameter = as.numeric(diameter),
#     diameter_sigma = as.numeric(diameter_sigma),
#     h = as.numeric(h),
#     Is.Future = ifelse(cd >= today(), TRUE, FALSE),
#     m = month(cd),
#     y = year(cd)
#   )

write.xlsx(
  d,
  paste0(
    "data/neo-earth-close-approaches_LATEST.xlsx"
  ),
  asTable = TRUE,
  colWidths = "auto"
)

# Time-stamped archive
write.xlsx(
  d,
  paste0(
    "data/neo-earth-close-approaches_", as.character(now()), ".xlsx"
  ),
  asTable = TRUE,
  colWidths = "auto"
)

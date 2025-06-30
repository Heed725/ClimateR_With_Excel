# Load required packages
library(climateR)
library(terra)
library(tidyterra)
library(ggplot2)
library(sf)
library(colorspace)
library(showtext)
library(dplyr)
library(tidyr)
library(writexl)  # For writing Excel

# Load Barlow font (optional)
font_add(family = "Barlow", regular = "Barlow-Regular.ttf")
showtext_auto()

# Load shapefile
NORTH <- st_read("C:/Users/user/Desktop/Project_North_Outputs_2/North_Region.shp")

# Download TerraClimate precipitation data for 2021
test_data <- getTerraClim(
  AOI = NORTH,
  varname = "ppt",
  startDate = "2022-01-01",
  endDate   = "2022-12-01"
)

# Extract the ppt raster stack
ppt_stack <- test_data[[1]]

# Group into 4 seasons
season_index <- rep(1:4, each = 3)
seasonal_avg <- tapp(ppt_stack, season_index, mean)

# Mask and project
seasonal_avg <- mask(project(seasonal_avg, crs(NORTH)), vect(NORTH))

# Assign season names
season_names <- c(
  "Jan–Mar (Short Dry + Long Rains)",
  "Apr–Jun (Long Rains + Long Dry)",
  "Jul–Sep (Long Dry)",
  "Oct–Dec (Short Rains)"
)
names(seasonal_avg) <- season_names

# Extract mean precipitation per season for the region
mean_vals <- global(seasonal_avg, fun = "mean", na.rm = TRUE)

# Convert to data frame with year
precip_df <- data.frame(
  Year = 2022,
  Season = season_names,
  Mean_Precip_mm = round(mean_vals$mean, 2)
)

# Export to Excel
write_xlsx(precip_df, "C:/Users/user/Desktop/Seasonal_Precipitation_2022.xlsx")

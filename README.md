# ClimateR_With_Excel
Here is a **complete Markdown (.md) tutorial** file that includes multiple climate variables (not just precipitation) using `climateR`. It retrieves data, processes it seasonally, and plots them using `ggplot2`, styled with the Barlow font.

---

````markdown
# 🌦️ Seasonal Climate Mapping with `climateR` and TerraClimate in R

This tutorial demonstrates how to download and visualize **seasonal averages** of multiple TerraClimate variables (precipitation, temperature, vapor pressure) using the `climateR` package in R. The output is a clean, faceted map of seasonal climate patterns for your area of interest (AOI), using `ggplot2` and the custom **Barlow** font for styling.

---

## 📦 Required Packages

Install these packages if not already installed:

```r
install.packages(c("terra", "sf", "ggplot2", "colorspace", "showtext"))
# devtools::install_github("bluegreen-labs/climateR")
# devtools::install_github("dieghernan/tidyterra")
````

Then load them:

```r
library(climateR)    # Access to TerraClimate & MACA data
library(terra)       # Handle raster data
library(tidyterra)   # ggplot2 compatibility with terra
library(ggplot2)     # Visualization
library(sf)          # Vector data handling
library(colorspace)  # Color palettes
library(showtext)    # Custom font rendering
```

---

## 🔤 Load the Barlow Font (Optional for Styling)

```r
font_add(family = "Barlow", regular = "Barlow-Regular.ttf")  # Ensure the font file exists in working dir or provide path
showtext_auto()
```

---

## 🗺️ Load Area of Interest (Shapefile)

```r
NORTH <- st_read("C:/Users/user/Desktop/Project_North_Outputs_2/North_Region.shp")
```

---

## 📥 Download TerraClimate Data (Multiple Variables)

We'll retrieve **precipitation (ppt)**, **maximum temperature (tmax)**, and **vapor pressure (vp)** for the full year of 2021.

```r
variables <- c("ppt", "tmax", "vp")

# Retrieve for each variable
climate_data <- lapply(variables, function(var) {
  getTerraClim(
    AOI = NORTH,
    varname = var,
    startDate = "2021-01-01",
    endDate   = "2021-12-01"
  )[[1]]
})
names(climate_data) <- variables
```

---

## 📊 Seasonal Aggregation

Group months into 4 standard seasons and average values.

```r
# Define 4 seasons (each 3 months)
season_index <- rep(1:4, each = 3)

# Aggregate each variable into seasonal means
seasonal_means <- lapply(climate_data, function(stack) {
  tapp(stack, season_index, mean)
})
```

---

## 🗺️ Mask and Project to AOI

Ensure alignment with the shapefile's CRS and clip to the AOI.

```r
seasonal_means <- lapply(seasonal_means, function(stack) {
  projected <- project(stack, crs(NORTH))
  masked <- mask(projected, vect(NORTH))
  return(masked)
})
```

---

## 🏷️ Assign Season Names

```r
season_names <- c(
  "Jan–Mar (Short Dry + Long Rains)",
  "Apr–Jun (Long Rains + Long Dry)",
  "Jul–Sep (Long Dry)",
  "Oct–Dec (Short Rains)"
)

for (i in seq_along(seasonal_means)) {
  names(seasonal_means[[i]]) <- season_names
}
```

---

## 📈 Create Plots for Each Variable

We'll use a helper function to streamline plotting.

```r
plot_seasonal_variable <- function(rstack, varname, palette = "Blues 3", unit = "") {
  ggplot() +
    geom_spatraster(data = rstack) +
    geom_spatvector(data = NORTH, fill = NA, lwd = 1) +
    facet_wrap(~lyr, ncol = 2) +
    scale_fill_continuous_sequential(palette = palette, na.value = "transparent") +
    labs(
      title = paste("Seasonal Average", varname, "(2021)"),
      fill = paste(varname, unit)
    ) +
    theme_minimal(base_family = "Barlow") +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 10),
      strip.text = element_text(size = 12)
    )
}
```

Now, generate plots for each variable:

```r
plot_seasonal_variable(seasonal_means$ppt, "Precipitation", palette = "Blues 3", unit = "(mm)")
plot_seasonal_variable(seasonal_means$tmax, "Max Temperature", palette = "Reds 3", unit = "(°C)")
plot_seasonal_variable(seasonal_means$vp, "Vapor Pressure", palette = "Purples 3", unit = "(kPa)")
```

---

## 📌 Notes

* You can change the `palette` to match variable type (e.g. Blues for rain, Reds for temperature).
* Make sure the `.ttf` font file is accessible to use `Barlow`.
* If downloading data fails, check your internet connection or try reducing the AOI size.

---

## 📚 References

* 🌐 [TerraClimate Dataset Overview](https://www.climatologylab.org/terraclimate.html)
* 📦 [`climateR` GitHub](https://github.com/bluegreen-labs/climateR)
* 🧰 [`tidyterra` Documentation](https://dieghernan.github.io/tidyterra/)
* 🎨 [Colorspace Palettes](https://colorspace.r-forge.r-project.org/articles/colorspace.html)

---




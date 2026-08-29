# NASA NEO Earth Close Approaches

Analyzes near-Earth object (NEO) close approaches using data from NASA/JPL, producing a PDF report and a 3D model of close-approach frequency over time.

## Overview

This project pulls close-approach data from NASA's [Close Approach Data API](https://cneos.jpl.nasa.gov/ca/) and produces two reports:

- **PDF report** — a chart of close approaches since 2024, highlighting future approaches within 10 lunar distances.
- **3D model** — a polynomial regression of monthly close-approach counts, rendered as an interactive 3D visualization.

## Pipeline

The whole workflow is driven by the Makefile:

```
make all       # run the full pipeline (download → pdf → 3d)
make download  # download data from NASA
make pdf       # render the PDF report
make 3d        # fit the model and build the 3D visualization
```

| File | Purpose |
|------|---------|
| `1_download-dataset.R` | Calls the NASA/JPL API and writes the raw data to Excel |
| `2_pdf-report.R` | Renders `neo-earth-close-approaches.Rmd` to a PDF |
| `3_3d-report.R` | Fits the regression model and produces the 3D output |
| `neo-earth-close-approaches.Rmd` | R Markdown source for the PDF report |

## Prerequisites

- [R](https://www.r-project.org/) with the following packages:
  - `tidyverse`
  - `lubridate`
  - `openxlsx`
  - `stringr`
  - `reshape2`
  - `jsonlite`
  - `flextable`
  - `ggthemes`
  - `rgl`
  - `rmarkdown`

## Usage

```sh
make all
```

Outputs land in the `data/` and `output/` directories:

- `data/neo-earth-close-approaches_LATEST.xlsx` — most recent download (overwritten each run)
- `data/neo-earth-close-approaches_<timestamp>.xlsx` — time-stamped archive of each download
- `output/neo-earth-close-approaches.pdf` — the PDF report
- `output/neo-earth-close-approaches.png` — 3D model snapshot
- `output/neo-earth-close-approaches.html` — interactive 3D model

## Method

### Data

The [NASA Close Approach API](https://ssd-api.jpl.nasa.gov/cad.api) is queried for all close approaches from 1995 to the present within 1000 lunar distances, including object diameters.

### 3D model

Monthly close-approach counts (past approaches within 100 lunar distances) are modeled with a polynomial regression:

```
count ~ poly(year, 2) + poly(year * month, 4)
```

The current in-progress month is excluded to avoid a partial-month undercount. The fitted surface is plotted against the observed monthly counts.

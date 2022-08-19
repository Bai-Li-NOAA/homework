# The Assessment_Summary_Data.xlsx was downloaded from Stock SMART:
# https://www.st.nmfs.noaa.gov/stocksmart?app=download-data
# Years to include in the report: 2021
# All stocks and fields were selected
# Access date: Aug 19, 2022

# Load required packages
required_pkg <- c(
  "here", "XML", "tidyverse", "purrr"
)
pkg_to_install <- required_pkg[!(required_pkg %in%
  installed.packages()[, "Package"])]
if (length(pkg_to_install)) install.packages(pkg_to_install)
lapply(required_pkg, library, character.only = TRUE)

# Extract hyperlinks of stock assessments from the xlsx
# Inspired by this stackoverflow post:
# https://stackoverflow.com/questions/24149821/extract-hyperlink-from-excel-file-in-r

# rename file to .zip
xlsx_file <- here::here(
  "download_stock_smart_assessments",
  "Assessment_Summary_Data.xlsx"
)
zip_file <- sub("xlsx", "zip", xlsx_file)
file.copy(from = xlsx_file, to = zip_file)

# unzip the file
unzip_dir <- here::here(
  "download_stock_smart_assessments",
  "xml_files"
)
ifelse(!dir.exists(unzip_dir), dir.create(unzip_dir), FALSE)
unzip(zip_file, exdir = unzip_dir)

# Unzipping produces a bunch of files which we can read using the XML
# Assume sheet1 has our data
filename <- "sheet1.xml.rels"
rel_path <- file.path(unzip_dir, "xl", "worksheets", "_rels", filename)
rel <- XML::xmlParse(rel_path)
rel <- XML::xmlToList(rel)
rel <- purrr::map_dfr(rel, as.list)
rel <- rel[, c("Id", "Target")]

# Remove duplicate urls
rel <- rel[!duplicated(rel$Target), ]

# Download stock assessments
assessment_dir <- here::here("download_stock_smart_assessments", "StockAssessment")
ifelse(!dir.exists(assessment_dir), dir.create(assessment_dir), FALSE)

for (i in seq_along(rel$Target)) {
  download.file(rel$Target[i],
    destfile = file.path(
      assessment_dir,
      paste0(rel$Id[i], ".pdf")
    ),
    mode = "wb"
  )
}

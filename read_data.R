library(readxl)
library(data.table)
library(lubridate)

dir.create("data", showWarnings = FALSE)

raw_data <- read_xlsx("raw_data/Table_La_Vallee - Copie.xlsx")
setDT(raw_data)

melt_data <- melt(raw_data, 1:78, measure_vars = patterns("^[MS]LAI?"), variable.name = "index", value.name = "index_value")
melt_data[, c("index", "date") := tstrsplit(index, "_")]

# Fix typo
melt_data[index %chin% "MLA", index := "MLAI"]
melt_data[index == "SLA", index := "SLAI"]

date_map <- fread("raw_data/crop_dates.csv")
date_map[, bad_date := as.character(bad_date)]


full_data = date_map[melt_data, on = c("bad_date" = "date")]
full_data[, bad_date := NULL]

full_data[, date := ymd(as_date(date, format = "%d-%m-%Y"))]

cast_data = dcast(full_data, formula = ... ~ index, value.var = "index_value")

# Remove line of blank data
cast_data = cast_data[MLAI != 0, ]

fwrite(cast_data, "data/processed_data.csv")

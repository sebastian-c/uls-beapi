library(readxl)
library(data.table)
library(lubridate)

dir.create("data", showWarnings = FALSE)

raw_data <- read_xlsx("raw_data/Table_La_Vallee - Copie.xlsx")
setDT(raw_data)

melt_data <- melt(raw_data, 1:9, patterns("^[MS]LAI"), variable.name = "index", value.name = "index_value")
melt_data[, c("index", "date") := tstrsplit(index, "_")]

date_map <- fread("raw_data/crop_dates.csv")
date_map[, bad_date := as.character(bad_date)]


full_data = date_map[melt_data, on = c("bad_date" = "date")]
full_data[, date := NULL]
setnames(full_data, "dates", "date")

full_data[, date := ymd(as_date(date, format = "%d-%m-%Y"))]

cast_data = dcast(full_data, formula = ... ~ index, value.var = "index_value")

fwrite(cast_data, "data/LAI.csv")

library(readxl)
library(data.table)
library(lubridate)

dir.create("data", showWarnings = FALSE)

raw_data <- read_xlsx("raw_data/Table_La_Vallee - Copie.xlsx")
setDT(raw_data)

melt_data <- melt(raw_data, 1:9, patterns("^[MS]LAI"), variable.name = "index", value.name = "index_value")
melt_data[, c("index", "date") := tstrsplit(index, "_")]

date_map <- c('1854' = '05-04-2018',
'18519' = '05-19-2018',
'18623' = '06-23-2018',
'19514' = '05-14-2019',
'1968' = '06-08-2019',
'20518' = '05-18-2020',
'20528' = '05-28-2020',
'2062' = '06-02-2020',
'22324' = '03-24-2022',
'22612' = '06-12-2022',
'19419' = '04-19-2019',
'22212' = '02-12-2022',
'23227' = '02-27-2023',
'22518' = '05-18-2022',
'22617' = '06-17-2022')

date_map = data.table(date = names(date_map), dates = date_map)

full_data = date_map[melt_data, on = "date"]
full_data[, date := NULL]
setnames(full_data, "dates", "date")

full_data[, date := ymd(as_date(date, format = "%m-%d-%Y"))]

cast_data = dcast(full_data, formula = ... ~ index, value.var = "index_value")

fwrite(cast_data, "data/LAI.csv")

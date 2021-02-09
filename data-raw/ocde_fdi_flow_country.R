library(magrittr)
library(rsdmx)

get_inv_ocde <- function(ano_inicial) {

  url_inicial <- "https://stats.oecd.org/sdmx-json/data/FDI_FLOW_CTRY/all/all?"
  start <- paste0("startTime=", ano_inicial, "-Q1")
  end <- paste0("&endTime=", ano_inicial, "-Q4")

  url <- paste0(url_inicial, start, end)

  df <- rsdmx::readSDMX(url)

  df

}

anos <- 2010:2020

teste <- get_inv_ocde(2010)

teste

files <- fs::dir_ls(here::here("data-raw"), regexp = "json")

teste <- jsonlite::read_json(files[1], simplifyDataFrame = T)

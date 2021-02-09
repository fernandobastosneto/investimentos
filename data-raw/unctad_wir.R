# Dados retirados da UNCTAD Stat
## https://unctadstat.unctad.org/EN/BulkDownload.html
## https://unctad.org/webflyer/world-investment-report-2020

url <- "https://unctadstat.unctad.org/7zip/US_FdiFlowsStock.csv.7z"

httr::GET(url, httr::write_disk(here::here("data-raw", "unctad_wir.7z")))

unctad_wir <- vroom::vroom(archive::archive_read(here::here("data-raw", "unctad_wir.7z"))) %>%
  janitor::clean_names()

usethis::use_data(unctad_wir)

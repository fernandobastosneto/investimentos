library(magrittr)

# Dados de Investimento Externo no Brasil
# Banco Central
# Ingressos de investimentos diretos no país – Participação no capital
# dado de fluxo

url <- "https://www.bcb.gov.br/content/estatisticas/Documents/Tabelas_especiais/InvEstrp.xls"

httr::GET(url, httr::write_disk(here::here("data-raw", "bc_idp_pais_provisorio.xls"), overwrite = T))

bc_idp_pais_provisorio <- readxl::read_excel(here::here("data-raw", "bc_idp_pais_provisorio.xls"), skip = 4) %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "ano", values_to = "value") %>%
  tidyr::drop_na() %>%
  dplyr::rename(pais = Discriminação) %>%
  dplyr::mutate(value = value*1000000)

# Posição de Investimento Internacional
## dado de estoque
### infelizmente não foi possível automatizar esse dado em função do
### formato do excel disponibilizado pelo Banco Central

url <- "https://www.bcb.gov.br/content/estatisticas/Documents/Tabelas_especiais/PII_T.xlsx"

httr::GET(url, httr::write_disk(here::here("data-raw", "bc_idp_posicao.xlsx"), overwrite = T))

nomes <- c("indicador", rep(c(2002:2020), each = 4))

bc_idp_posicao_provisorio <- readxl::read_excel(here::here("data-raw", "bc_idp_posicao.xlsx"),
                                     skip = 4,
                                     sheet = 2) %>%
  janitor::remove_empty() %>%
  dplyr::select(-2)

names(bc_idp_posicao_provisorio) <- nomes

bc_idp_posicao_provisorio <- bc_idp_posicao_provisorio %>%
  janitor::clean_names() %>%
  dplyr::rename_with(~ stringr::str_remove_all(.x, "^x"))  %>%
  tidyr::drop_na() %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "ano", values_to = "value") %>%
  dplyr::mutate(value = as.integer(value),
                value = value*1000000) %>%
  dplyr::mutate(ano = dplyr::case_when(
    stringr::str_detect(ano, "_2$") ~ stringr::str_replace(ano, "_2$", "_06_01"),
    stringr::str_detect(ano, "_3$") ~ stringr::str_replace(ano, "_3$", "_09_01"),
    stringr::str_detect(ano, "_4$") ~ stringr::str_replace(ano, "_4$", "_12_01"),
    TRUE ~ paste0(ano, "_03_01")))

url <- "https://www.bcb.gov.br/content/estatisticas/Documents/Tabelas_especiais/TabelasCompletasPosicaoIDP.xlsx"

httr::GET(url, httr::write_disk(here::here("data-raw", "bc_idp_completo.xlsx"), overwrite = T))

bc_idp_pais_part_capital <- readxl::read_excel(here::here("data-raw", "bc_idp_completo.xlsx"), sheet = 6, skip = 4) %>%
  janitor::remove_empty() %>%
  dplyr::select(-dplyr::starts_with("..")) %>%
  dplyr::mutate(dplyr::across(2:tidyselect::last_col(), as.numeric)) %>%
  janitor::remove_empty() %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "ano", values_to = "value") %>%
  dplyr::rename_with(~ stringr::str_remove_all(.x, "`")) %>%
  janitor::clean_names() %>%
  dplyr::mutate(value = value*1000000)

bc_idp_pais_controlador <- readxl::read_excel(here::here("data-raw", "bc_idp_completo.xlsx"), sheet = 7, skip = 4) %>%
  janitor::remove_empty() %>%
  dplyr::select(-dplyr::starts_with("..")) %>%
  dplyr::mutate(dplyr::across(2:tidyselect::last_col(), as.numeric)) %>%
  janitor::remove_empty() %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "ano", values_to = "value") %>%
  dplyr::rename_with(~ stringr::str_remove_all(.x, "`")) %>%
  janitor::clean_names() %>%
  dplyr::mutate(value = value*1000000)

bc_idp_pais_setor_part_capital <- readxl::read_excel(here::here("data-raw", "bc_idp_completo.xlsx"),
                   sheet = 14, skip = 4,
                   range = readxl::cell_rows(5:20)) %>%
  tidyr::drop_na() %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "pais", values_to = "value") %>%
  dplyr::mutate(ano = names(.)[1],
                ano = stringr::str_remove_all(ano, "\\D*")) %>%
  dplyr::rename(setor = 1)

bc_idp_pais_setor_controlador <- readxl::read_excel(here::here("data-raw", "bc_idp_completo.xlsx"),
                                                  sheet = 15, skip = 4,
                                                  range = readxl::cell_rows(5:20)) %>%
  tidyr::drop_na() %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "pais", values_to = "value") %>%
  dplyr::mutate(ano = names(.)[1],
                ano = stringr::str_remove_all(ano, "\\D*")) %>%
  dplyr::rename(setor = 1)

usethis::use_data(bc_idp_pais_provisorio, bc_idp_posicao_provisorio,
                  bc_idp_pais_part_capital, bc_idp_pais_controlador,
                  bc_idp_pais_setor_part_capital, bc_idp_pais_setor_controlador, overwrite = T)

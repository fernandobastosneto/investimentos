library(magrittr)

# Desembolso Anual na Modalidade Pós-Embarque por Destino das Exportações

url <- "https://www.bndes.gov.br/wps/wcm/connect/site/cf017351-67bb-4bdf-93e4-33c32dd684c1/Desembolsos-BNDES-P%C3%B3s-embarque-por-pa%C3%ADses-2019.xlsx?MOD=AJPERES&amp;CACHEID=ROOTWORKSPACE.Z18_7QGCHA41LORVA0AHO1SIO51085-cf017351-67bb-4bdf-93e4-33c32dd684c1-m7pb-P6"

httr::GET(url, httr::write_disk(here::here("data-raw", "bndes_posembarque_bens_paises.xlsx")))

bndes_posembarque_bens_paises <- readxl::read_excel(here::here("data-raw", "bndes_posembarque_bens_paises.xlsx"),
                   skip = 5)  %>%
  dplyr::mutate(dplyr::across(2:tidyselect::last_col(), as.numeric)) %>%
  tidyr::pivot_longer(2:tidyselect::last_col(), names_to = "ano", values_to = "value") %>%
  tidyr::drop_na() %>%
  dplyr::mutate(value = value*1000) %>%
  dplyr::filter(value != 0) %>%
  janitor::clean_names() %>%
  dplyr::mutate(paises = abjutils::rm_accent(paises)) %>%
  dplyr::mutate(paises = stringr::str_to_lower(paises))

#Operações de Exportação Pós-Embarque - bens (de 2002 a 2020-12-31)

url <- "https://www.bndes.gov.br/wps/wcm/connect/site/9f635b82-df3e-4544-b567-3734c40522fa/pos-embarque-bens.xlsx?MOD=AJPERES&amp;CACHEID=ROOTWORKSPACE.Z18_7QGCHA41LORVA0AHO1SIO51085-9f635b82-df3e-4544-b567-3734c40522fa-m7pb-P6"

httr::GET(url, httr::write_disk(here::here("data-raw", "bndes_posembarque_bens_operacoes.xlsx")))

bndes_posembarque_bens_operacoes <- readxl::read_excel(here::here("data-raw", "bndes_posembarque_bens_operacoes.xlsx")) %>%
  janitor::clean_names() %>%
  dplyr::select(exportador, descricao_da_operacao, pais_destino_das_exportacoes,
                data_da_contratacao, setor_subsetor_de_atividade, area_operacional,
                categoria, situacao_da_operacao, tipo_de_garantia) %>%
  dplyr::mutate(data_da_contratacao = lubridate::ymd(data_da_contratacao)) %>%
  dplyr::mutate(pais_destino_das_exportacoes = abjutils::rm_accent(pais_destino_das_exportacoes)) %>%
  dplyr::mutate(pais_destino_das_exportacoes = stringr::str_to_lower(pais_destino_das_exportacoes))

# Operações de Exportação Pós-Embarque - Serviços de Engenharia (1998 a 2020-12-31)

url <- "https://www.bndes.gov.br/wps/wcm/connect/site/b8a8b0c7-1b77-44a8-b6f0-e97557fe742e/pos-embarque-servicos.xlsx?MOD=AJPERES&amp;CACHEID=ROOTWORKSPACE.Z18_7QGCHA41LORVA0AHO1SIO51085-b8a8b0c7-1b77-44a8-b6f0-e97557fe742e-m7pb-P6"

httr::GET(url, httr::write_disk(here::here("data-raw", "bndes_posembarque_servicos_operacoes.xlsx")))

bndes_posembarque_servicos_operacoes <- readxl::read_excel(here::here("data-raw", "bndes_posembarque_servicos_operacoes.xlsx")) %>%
  janitor::clean_names() %>%
  dplyr::select(exportador, descricao_da_operacao, pais_destino_das_exportacoes,
                data_da_contratacao, valor_da_operacao_em_um, valor_desembolsado_em_um,
                moeda_sigla, fonte_de_recursos_desembolsos, custo_financeiro,
                juros, prazo_total_meses,
                setor_subsetor_de_atividade, area_operacional,
                categoria, situacao_da_operacao, tipo_de_garantia) %>%
  dplyr::mutate(data_da_contratacao = lubridate::ymd(data_da_contratacao)) %>%
  dplyr::mutate(pais_destino_das_exportacoes = abjutils::rm_accent(pais_destino_das_exportacoes)) %>%
  dplyr::mutate(pais_destino_das_exportacoes = stringr::str_to_lower(pais_destino_das_exportacoes))


usethis::use_data(bndes_posembarque_bens_operacoes, bndes_posembarque_bens_paises, bndes_posembarque_servicos_operacoes)

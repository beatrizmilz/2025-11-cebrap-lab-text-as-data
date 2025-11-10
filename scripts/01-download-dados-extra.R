# Caso queira baixar dados de várias enquetes,
# o código a seguir pode ajudar:

# Dados abertos - Câmara dos deputados
# https://dadosabertos.camara.leg.br/swagger/api.html

# Carregando pacotes
library(tidyverse)
library(janitor)

# Buscando dados de projetos de lei
url_proposicoes_2023 <- "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2023.csv"

proposicoes <- read_csv2(url_proposicoes_2023)

projetos_de_lei <- proposicoes |> 
  filter(descricaoTipo == "Projeto de Lei")


# Para buscar os dados de enquete, podemos criar uma função simples:

baixar_enquete <- function(id_enquete) {
  url <- paste0(
    "https://www.camara.leg.br/enquetes/posicionamentos/download/todos-posicionamentos?idEnquete=",
    id_enquete,
    "&exibicao=undefined&ordenacao=undefined"
  )
  dados <- read_csv(url, skip = 1) |>
    clean_names() |>
    mutate(id = id_enquete, .before = everything()) |> 
    mutate(qtd_curtidas = as.numeric(qtd_curtidas))
  dados
}

# Experimentando a função:

baixar_enquete("2373385")

# Baixando dados de várias enquetes:

palavras_tema <- c("inteligência artificial")

projetos_tema <- projetos_de_lei |>
  filter(str_detect(str_to_lower(ementa), "inteligência artificial")) 


resultados_tema_lista <- map(projetos_tema$id, baixar_enquete) 

resultados_tema <- resultados_tema_lista |> 
  bind_rows()


fs::dir_create("dados-brutos")


resultados_tema |> 
  write_rds("dados-brutos/resultados_enquetes-IA.rds")

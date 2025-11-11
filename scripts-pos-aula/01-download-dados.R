# Vamos usar os dados de enquetes da Câmara dos deputados
# onde a população pode votar a favor ou contra determinado
# projeto de lei, e deixar um comentário.

# Carregando pacotes
library(tidyverse)
library(janitor)

# Vamos buscar a enquete mais comentada nos últimos 6 meses!
# Site das enquetes: https://www.camara.leg.br/enquetes/

# https://www.camara.leg.br/enquetes/2576168
# https://www.camara.leg.br/propostas-legislativas/2576168

# ID da enquete é o numero que aparece no final da URL
id_enquete <- "2576168"

# URL para baixar os dados
# Conseguimos entender o link usando o botão baixar

# https://www.camara.leg.br/enquetes/posicionamentos/download/todos-posicionamentos?idEnquete=2576168&exibicao=undefined&ordenacao=undefined

url <- paste0(
  "https://www.camara.leg.br/enquetes/posicionamentos/download/todos-posicionamentos?idEnquete=",
  id_enquete,
  "&exibicao=undefined&ordenacao=undefined"
)


# Baixando os dados, limpando o nome das colunas,
# salvando o id da enquete como uma coluna
resultados_enquete <- read_csv(url, skip = 1) |>
  clean_names() |>
  mutate(id = id_enquete, .before = everything())


# criando pasta para guardar resultados
fs::dir_create("dados-brutos")

# Salvando os dados
write_rds(resultados_enquete, "dados-brutos/resultados_enquete.rds")

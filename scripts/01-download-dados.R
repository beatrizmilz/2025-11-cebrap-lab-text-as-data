# Vamos usar os dados de enquetes da Câmara dos deputados
# onde a população pode votar a favor ou contra determinado
# projeto de lei, e deixar um comentário.

# Carregando pacotes
library(tidyverse)
library(janitor)

# Vamos buscar a enquete mais votada nos últimos 6 meses!
# https://www.camara.leg.br/enquetes/2373385
# https://www.camara.leg.br/propostas-legislativas/2373385

# Descrição:
# Altera o Decreto Lei nº 1.804, de 3 de setembro de 1980, 
# para aumentar o valor de minimis na importação de USD 50,00 
# para USD 100,00, reduzir a alíquota do imposto de importação 
# de 60% para 20% e aumentar o valor máximo das remessas expressas 
# de USD 3.000,00 para USD 5.000,00.

# Proposto por
# Luiz Philippe de Orleans e Bragança (PL-SP) 

# ID da enquete é o numero que aparece no final da URL
id_enquete <- "2373385"

# URL para baixar os dados
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

fs::dir_create("dados-brutos")

# Salvando os dados
write_rds(resultados_enquete, "dados-brutos/resultados_enquete.rds")

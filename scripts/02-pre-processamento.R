# Carragando os pacotes
library(tidyverse)
library(tidytext)
library(stopwords)
# devtools::install_github("dfalbel/ptstem")
library(ptstem)


# importando os dados
resultados_enquete_raw <- read_rds("dados-brutos/resultados_enquete.rds")

# Conhecendo um pouco a base
resultados_enquete <- resultados_enquete_raw |>
  # separar a coluna data em data e hora
  separate(data, into = c("data", "hora"), sep = " ") |> 
  # converter a data que está em texto na classe data
  mutate(data = lubridate::dmy(data)) |> 
  # gerar um id para o comentário
  rowid_to_column("id_comentario")

# espiando os dados
glimpse(resultados_enquete)


# quantidade de comentários
# cada linha é um comentário
nrow(resultados_enquete)

# quantidade de curtidas nos comentários
sum(resultados_enquete$qtd_curtidas)

# quantidade de curtidas por posicionamento
resultados_enquete |> 
  group_by(posicionamento) |> 
  summarise(total_curtidas = sum(qtd_curtidas)) |> 
  mutate(porc_curtidas = total_curtidas / sum(total_curtidas),
         porc_curtidas = scales::percent(porc_curtidas)) 

resultados_enquete |> 
  count(data, posicionamento) |> 
  ggplot() +
  aes(x = data, y = n) +
  geom_line(aes(color = posicionamento)) 

# Vamos começar a explorar o texto dos comentários ---------------------------

# Vamos usar o pacote tidytext para fazer a tokenização
tokens_enquete <- resultados_enquete  |> 
  unnest_tokens(output = palavra, input = conteudo) 

# Palavras mais frequentes

tokens_enquete |> 
  count(palavra, sort = TRUE) 

# tem muitas palavras que não são relevantes para a análise
# chamamos de STOP WORDS!

# Removendo stopwords ------------------------

# Ir para arquivo : scripts/stop-words.R

source("scripts/stop-words.R")


tokens_sem_stopwords <- tokens_enquete |> 
  filter(!palavra %in% stop_words_completo) |> 
  # Removendo números
  filter(!str_detect(palavra, "[0-9]"))

# Palavras mais frequentes sem stopwords

tokens_sem_stopwords |> 
  count(palavra, sort = TRUE) 

# Problemas:
# - palavras com a mesma raiz são contadas separadamente
# ex: "votar", "votou", "votando", "votaram"
# - palavras singular/plural são contadas separadamente
# ex: imposto, impostos

# Erros de português

# Stemming ------------------------

# Stemming é o processo de reduzir palavras flexionadas 
# (ou às vezes derivadas) ao seu tronco (stem), base ou raiz,
# geralmente uma forma da palavra escrita.

# Vamos usar o pacote ptstem para fazer o stemming
# É um processo que pode demorar
# Vamos buscar os tokens únicos, e depois unir com os dados

length(tokens_arrumados$palavra)
length(unique(tokens_arrumados$palavra))

stems <- tokens_arrumados |> 
  distinct(palavra) |> 
  mutate(stem = ptstem::ptstem(palavra))

tokens_stem <- tokens_arrumados |>
  left_join(stems, by = "palavra")

tokens_stem |> 
  count(stem, sort = TRUE) 

fs::dir_create("dados")


# Agora sim!
tokens_stem |> 
  write_rds("dados/tokens_preparados.rds")

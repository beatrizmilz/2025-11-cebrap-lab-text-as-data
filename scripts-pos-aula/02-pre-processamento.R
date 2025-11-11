# Carragando os pacotes
library(tidyverse)
library(tidytext)
library(stopwords)
# devtools::install_github("dfalbel/ptstem")
library(ptstem)


# importando os dados
resultados_enquete_raw <- read_rds("dados-brutos/resultados_enquete.rds")

# exemplo tidyr
# tidyr::nest(resultados_enquete_raw, .by = posicionamento)

glimpse(resultados_enquete_raw)
# Rows: 1,838
# Columns: 6
# $ id             <chr> "2576168", "2576168", "2576168", "2576168", "257616…
# $ posicionamento <chr> "negativo", "positivo", "negativo", "positivo", "ne…
# $ autor          <chr> "STEFFANO PARCELLI GOMES DA SILVA", "STEFFANO PARCE…
# $ data           <chr> "10/11/2025 17:15", "10/11/2025 17:13", "10/11/2025…
# $ qtd_curtidas   <dbl> 2, 1, 2, 2, 2, 3, 1, 3, 4, 2, 0, 3, 0, 0, 0, 0, 12,…
# $ conteudo       <chr> "Deixará o serviço público a mercê de indicação mer…

mtcars |> View()


# Conhecendo um pouco a base
resultados_enquete <- resultados_enquete_raw |>
  # separar a coluna data em data e hora
  separate(data, into = c("data", "hora"), sep = " ") |>
  # converter a data que está em texto na classe data
  mutate(data = lubridate::dmy(data)) |>
  # gerar um id para o comentário
  rowid_to_column("id_comentario") |>
  # substituir o . por espaço
  mutate(
    conteudo = str_replace_all(conteudo, pattern = "\\.", replacement = "\\. ")
  )

# espiando os dados
glimpse(resultados_enquete)


# quantidade de comentários
# cada linha é um comentário
nrow(resultados_enquete)

# quantidade de curtidas nos comentários
sum(resultados_enquete$qtd_curtidas)


# quantidade de curtidas por posicionamento
# tabela de frequenca
resultados_enquete |>
  group_by(posicionamento) |>
  summarise(total_curtidas = sum(qtd_curtidas)) |>
  mutate(
    porc_curtidas = total_curtidas / sum(total_curtidas),
    porc_curtidas = scales::percent(porc_curtidas)
  )

# gráfico simples
resultados_enquete |>
  count(data, posicionamento) |>
  arrange(desc(n)) |>
  ggplot() +
  aes(x = data, y = n) +
  geom_line(aes(color = posicionamento))

# Vamos começar a explorar o texto dos comentários ---------------------------

# Vamos usar o pacote tidytext para fazer a tokenização
tokens_enquete <- resultados_enquete |>
  unnest_tokens(
    output = palavra,
    input = conteudo,
    # o token é a palavra
    token = "words"
  )

?unnest_tokens()

# Palavras mais frequentes

tokens_enquete |>
  count(palavra, sort = TRUE) |>
  View()

# tem muitas palavras que não são relevantes para a análise
# chamamos de STOP WORDS!

# Removendo stopwords ------------------------

# Ir para arquivo : scripts/stop-words.R

source("scripts/stop-words.R")

tokens_sem_stopwords <- tokens_enquete |>
  # removendo stop words
  filter(!palavra %in% stop_words_completo) |>
  # Removendo números
  filter(!str_detect(palavra, "[0-9]"))

# Palavras mais frequentes sem stopwords

tokens_sem_stopwords |>
  count(palavra, sort = TRUE) |>
  View()

# Problemas:
# - palavras com a mesma raiz são contadas separadamente
# ex: "votar", "votou", "votando", "votaram"
# - palavras singular/plural são contadas separadamente
# ex: imposto, impostos

# FINAL DA AULA 1!

# Stemming ------------------------

# Stemming é o processo de reduzir palavras flexionadas
# (ou às vezes derivadas) ao seu tronco (stem), base ou raiz,
# geralmente uma forma da palavra escrita.

# Vamos usar o pacote ptstem para fazer o stemming
# É um processo que pode demorar
# Vamos buscar os tokens únicos, e depois unir com os dados

# rm(resultados_enquete_raw)

length(tokens_sem_stopwords$palavra)
length(unique(tokens_sem_stopwords$palavra))

# pode demorar
stems <- tokens_sem_stopwords |>
  distinct(palavra) |>
  mutate(stem = ptstem::ptstem(palavra)) # isso é meio demorado!

tokens_stem <- tokens_sem_stopwords |>
  left_join(stems, by = "palavra")

tokens_stem |>
  count(stem, sort = TRUE)

# checando os termos mais frequentes
tokens_stem |>
  count(stem, sort = TRUE) |>
  head(30) |>
  View()


fs::dir_create("dados")


# Agora sim!
tokens_stem |>
  write_rds("dados/tokens_preparados.rds")

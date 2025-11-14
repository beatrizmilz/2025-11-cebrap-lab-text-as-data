library(tidyverse)
library(tidytext)
library(stopwords)

resultados_enquete <- read_rds("dados-brutos/resultados_enquete.rds")

# Vamos usar o pacote tidytext para fazer a tokenização
# a função é a mesma que usavamos antes,
# mas agora vamos informar os argumentos
# token e n (número de palavras por token)
tokens_bigram <- resultados_enquete |>
  # gerar um id para o comentário
  rowid_to_column("id_comentario") |>
  # substituir ponto e _ por espaço
  mutate(
    conteudo = stringr::str_replace_all(conteudo, "\\.", " "),
    conteudo = stringr::str_replace_all(conteudo, "_", " "),
  ) |>
  unnest_tokens(
    output = bigram,
    input = conteudo,
    token = "ngrams",
    n = 2
  )

# wordcloud2::wordcloud2(
#   tibble::tribble(
#     ~word, ~freq,
#     "Beatriz", 32,
#     "Flora", 5,
#     "Victor", 40
#   )
# )

# preparando os dados

tokens_bigram_separados <- tokens_bigram |>
  filter(!is.na(bigram)) |>
  separate(bigram, into = c("palavra1", "palavra2"), sep = " ", remove = FALSE)

tokens_bigram_separados |> View()

# Removendo stopwords ------------------------
# Carregando as stopwords em português
source("scripts/stop-words.R")

# Removendo stopwords e números
tokens_sem_stopwords <- tokens_bigram_separados |>
  filter(!palavra1 %in% stop_words_completo) |>
  filter(!palavra2 %in% stop_words_completo) |>
  filter(!bigram %in% stop_words_bigram) |>
  filter(!str_detect(bigram, "[0-9]"))

tokens_sem_stopwords |> View()

tokens_sem_stopwords_reclassificado <- tokens_sem_stopwords |>
  mutate(
    bigram = case_when(
      bigram %in% c("serviço público", "serviços públicos", "serviço publico") ~
        "serviço público",
      bigram %in% c("servidores públicos", "servidor público") ~
        "servidor público",

      # ...
      .default = bigram
    )
  )


bigrams_freq <- tokens_sem_stopwords_reclassificado |>
  count(bigram, posicionamento, sort = TRUE) |>
  group_by(posicionamento) |>
  slice_max(n, n = 30) |>
  ungroup()

bigrams_freq |> View()

bigrams_freq |>
  filter(posicionamento == "negativo") |>
  mutate(bigram = forcats::fct_reorder(bigram, n)) |>
  ggplot(aes(x = n, y = bigram)) +
  geom_segment(aes(y = bigram, yend = bigram, x = 0, xend = n)) +
  geom_point()


bigrams_freq |>
  filter(posicionamento == "positivo") |>
  mutate(bigram = forcats::fct_reorder(bigram, n)) |>
  ggplot(aes(x = n, y = bigram)) +
  geom_segment(aes(y = bigram, yend = bigram, x = 0, xend = n)) +
  geom_point()


bigrams_freq |>
  filter(posicionamento == "negativo") |>
  select(word = bigram, freq = n) |>
  # cuidado! tirei as palavras com frequencia maior de 250
  # pois nesse caso elas ficavam muito grandes e dificultavam
  # ler as outras palavras
  filter(freq < 250) |>
  wordcloud2::wordcloud2()


# Visualizando o tf-idf ------------------------

# tf - term frequency
# idf - inverse document frequency

# Calculando o tf-idf por documento (posicionamento)
tf_idf <- tokens_sem_stopwords_reclassificado |>
  count(bigram, posicionamento, sort = TRUE, name = "freq") |>
  bind_tf_idf(term = bigram, document = posicionamento, n = freq) |>
  arrange(desc(tf_idf))

# Visualizando os resultados
tf_idf |>
  group_by(posicionamento) |>
  slice_max(tf_idf, n = 10, with_ties = FALSE) |>
  mutate(bigram = reorder(bigram, tf_idf)) |>
  ungroup() |>
  ggplot() +
  aes(x = tf_idf, y = bigram) +
  geom_col() +
  facet_wrap(~posicionamento, scales = "free")

library(tidyverse)
library(wordcloud2)

tokens <- read_rds("dados/tokens_preparados.rds")

quantidade_comentarios_posicionamento <- tokens |>
  count(posicionamento)


tokens |>
  count(stem, sort = TRUE)

# 10 palavras mais frequentes por posicionamento
mais_frequentes <- tokens |>
  count(posicionamento, stem, sort = TRUE)

stems_mais_frequentes <- mais_frequentes |>
  group_by(posicionamento) |>
  slice_max(n, n = 15) |>
  ungroup() |>
  distinct(stem) |>
  pull(stem)


mais_frequentes |>
  filter(stem %in% stems_mais_frequentes) |>
  mutate(stem = fct_reorder(stem, n)) |>
  ggplot() +
  aes(y = stem, x = n) +
  geom_col(aes(fill = posicionamento), show.legend = FALSE) +
  facet_wrap(~posicionamento)



# Nuvem de palavras por posicionamento -----
# wordcloud2 recebe 2 colunas:
# palavra (word)
# frequencia da palavra/tamanho que ela aparece (freq)

library(wordcloud2)

stems_por_posicionamento <- tokens |>
  group_by(stem, posicionamento) |>
  summarise(freq = n(), soma_curtidas = sum(qtd_curtidas)) |>
  ungroup() |>
  rename(word = stem)


stems_por_posicionamento |>
  filter(posicionamento == "positivo") |>
  select(-posicionamento) |>
  wordcloud2()


stems_por_posicionamento |>
  filter(posicionamento == "negativo") |>
  select(-posicionamento) |>
  wordcloud2()

# Considerando o número de curtidas

stems_por_posicionamento |>
  filter(posicionamento == "positivo") |>
  select(word, freq = soma_curtidas) |>
  wordcloud2()


stems_por_posicionamento |>
  filter(posicionamento == "negativo") |>
  select(word, freq = soma_curtidas) |>
  wordcloud2()

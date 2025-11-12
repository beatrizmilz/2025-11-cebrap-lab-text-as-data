# Carregar pacotes
library(tidyverse)
library(wordcloud2)

# importar os tokens preparados em 02-pre-processamento
tokens <- read_rds("dados/tokens_preparados.rds")

# Conhecendo os dados
tokens |>
  count(posicionamento)

# stems mais frequentes, independente do posicionamento
tokens |>
  count(stem, sort = TRUE)

# 10 palavras mais frequentes por posicionamento
mais_frequentes <- tokens |>
  count(posicionamento, stem, sort = TRUE, name = "frequencia")

View(mais_frequentes)

stems_mais_frequentes <- mais_frequentes |>
  group_by(posicionamento) |>
  slice_max(frequencia, n = 15) |>
  ungroup() |>
  distinct(stem) |>
  pull(stem)


mais_frequentes |>
  filter(stem %in% stems_mais_frequentes) |>
  arrange(desc(frequencia)) |>
  mutate(stem = fct_reorder(stem, frequencia)) |>
  ggplot() +
  aes(y = stem, x = frequencia) +
  geom_col(aes(fill = posicionamento), show.legend = FALSE) +
  # cuidado, é uma escolha de visualização,
  # mas pode dar uma ideia errada pra quem for ver
  # facet_wrap(~posicionamento, scales = "free_x")
  facet_wrap(~posicionamento)

# outra forma mais simples: fazer os gráficos separadamente
# e unir com patchwork
plot_positivo <- mais_frequentes |>
  filter(posicionamento == "negativo") |>
  mutate(stem = fct_reorder(stem, frequencia)) |>
  head(10) |>
  ggplot() +
  geom_col(aes(x = frequencia, y = stem)) +
  labs(title = "Negativo") +
  theme_light()

plot_negativo <- mais_frequentes |>
  filter(posicionamento == "positivo") |>
  mutate(stem = fct_reorder(stem, frequencia)) |>
  head(10) |>
  ggplot() +
  geom_col(aes(x = frequencia, y = stem)) +
  labs(title = "Positivo") +
  theme_light()

library(patchwork)

plot_positivo + plot_negativo

# Nuvem de palavras por posicionamento --------------------------------
# wordcloud2 recebe 2 colunas:
# palavra (word)
# frequencia da palavra/tamanho que ela aparece (freq)

library(wordcloud2)

# precisamos preparar a tabela que vamos usar com a função wordcloud2
stems_por_posicionamento <- tokens |>
  group_by(palavra, posicionamento) |>
  summarise(freq = n(), soma_curtidas = sum(qtd_curtidas)) |>
  ungroup() |>
  rename(word = palavra)

# Nuvem de palavras - stem de posicionamento positivo
palavras_positivo <- stems_por_posicionamento |>
  # filtrando só o que é posicionamento positivo
  filter(posicionamento == "positivo") |>
  # exemplo de como remover palavras específicas
  filter(!word %in% c("pontos", "nenhum", "positivos", "ponto", "positivo")) |>
  # exemplo de como tirar palavras que aparecem com pouca frequencia
  filter(freq >= 5) |>
  # removendo colunas que não serão utilizadas
  select(-posicionamento, -soma_curtidas)


wordcloud2(palavras_positivo)

# também podemos configurar algumas coisas na nuvem de palavras

wordcloud2(
  palavras_positivo,
  fontFamily = "Arial" #,
  # shape = "triangle"
  # color = "random-dark"
  # color = "red"
)


# recomendo olhar a documentação. é interessante instalar
# o webshot e o phamtomjs para conseguir ver os exemplos
# da documentação
# install.packages("webshot")
# webshot::install_phantomjs()
?wordcloud2()

# wordcloud2(demoFreq)

# Nuvem de palavras - stem de posicionamento negativo
stems_por_posicionamento |>
  filter(posicionamento == "negativo", freq >= 20) |>
  select(-posicionamento) |>
  wordcloud2()

# Nuvem de palavras - Considerando o número de curtidas -----

stems_por_posicionamento |>
  filter(posicionamento == "positivo") |>
  select(word, freq = soma_curtidas) |>
  filter(freq >= 50) |>
  wordcloud2()


stems_por_posicionamento |>
  filter(posicionamento == "negativo", word != "especialmente") |>
  select(word, freq = soma_curtidas) |>
  filter(freq >= 50) |>
  wordcloud2()

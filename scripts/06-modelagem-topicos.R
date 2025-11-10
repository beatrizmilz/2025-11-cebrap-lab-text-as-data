# ------------------------------------------------------------
# Modelagem de tópicos (LDA) com tidytext + topicmodels
# ------------------------------------------------------------

# Instalação (caso necessário):
# install.packages(c("tidyverse", "tidytext", "topicmodels"))
# Leitura recomendada: https://www.tidytextmining.com/topicmodeling

library(tidyverse)
library(tidytext)
library(topicmodels)


# 1) Importação: tokens pré-processados (um token por linha)
# Espera-se ao menos: id_comentario, posicionamento, palavra, stem
tokens <- readr::read_rds("dados/tokens_preparados.rds")


# 2) Construção da Document-Term Matrix (DTM)
#    - 'document' é a unidade de análise (aqui, cada classe de posicionamento).
#    - 'term' são os stems (tokens normalizados).
#    - 'value' é a contagem.
document_term_matrix <- tokens |>
  dplyr::count(posicionamento, stem) |>
  tidytext::cast_dtm(term = stem, document = posicionamento, value = n)


# 3) Reprodutibilidade - semente
set.seed(1234)

# 4) Ajuste do modelo LDA
#    - k = número de tópicos a extrair (aqui, 2 para fins didáticos).
#    - 'control' com semente fixa a aleatoriedade interna do Gibbs/EM.
agrupamentos <- topicmodels::LDA(
  document_term_matrix,
  # número de tópicos
  k = 2,
  control = list(seed = 1234)
)

# 5) Extração das probabilidades por termo dentro de tópico (β)

# a função tidytext::tidy() usa uma função do pacote reshape2
# install.packages("reshape2")

# beta: method for extracting the per-topic-per-word probabilities
topicos_tidy <- tidytext::tidy(agrupamentos, matrix = "beta")


# 6) Selecionar os termos mais prováveis por tópico
termos_topicos <- topicos_tidy |>
  group_by(topic) |>
  slice_max(beta, n = 10) |>
  ungroup() |>
  arrange(topic, -beta)


# 7) Visualização dos termos característicos por tópico
#    - reorder_within/scale_y_reordered permitem facetar mantendo a ordem local.

termos_topicos |>
  mutate(term = reorder_within(x = term, by = beta, within = topic)) |>
  ggplot(aes(x = beta, y = term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free") +
  scale_y_reordered()

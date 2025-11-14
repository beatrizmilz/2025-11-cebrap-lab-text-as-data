# Importar dados textuais podem ser um desafio!
# Nesse exemplo, queremos chegar até o token,
# que é a menor unidade de texto que faz sentido para a análise.
# A partir do token, podemos usar os conceitos usados nas aulas anteriores.

# Pacote readtext é útil
# https://cran.r-project.org/web/packages/readtext/vignettes/readtext_vignette.html

# Importar texto de sites: técnicas de web scraping, como
# rvest::html_text() (mais avançado)

# Carregar pacotes ------------------
library(tidyverse)
library(tidytext)
library(readtext)

# Ler o arquivo PDF de exemplo ------------------
arquivo_pdf <- readtext::readtext(
  "referencias/1859-Texto do artigo-3971-2-10-20210608.pdf"
)

# Preparar tabela ------------------
df_texto_estruturado <- arquivo_pdf |>
# adicionar o número da linha como uma coluna nova, chamada n_pagina
  rowid_to_column("n_pagina") |>
# quebrar o texto sempre que houver uma quebra de linha ("\n" representa quebra de linha)
  mutate(text = str_split(text, "\n")) |>
# "desaninhar" tabela, teremos uma tabela mais longa
  unnest(text) |>
# agrupar pelo número da página
  group_by(n_pagina) |>
# adicionar uma coluna de número da linha
  mutate(n_linha = row_number()) |>
# desagrupar
  ungroup() |>
# tirar os espaços extras no começo e final
  mutate(text = str_trim(text)) |>
# remover linhas que estão sem texto nenhum na coluna `text`
  filter(text != "")


# Iniciar as técnicas de pré-processamento ------------------
# A partir deste ponto, usamos as técnicas vistas nas aulas anteriores

contagem_tokens <- df_texto_limpo |>
  unnest_tokens(input = text, output = "word") |>
  count(word, sort = TRUE)

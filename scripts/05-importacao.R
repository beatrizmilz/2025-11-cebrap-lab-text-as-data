# Importar dados textuais podem ser um desafio!
# Nesse exemplo, queremos chegar até o token, 
# que é a menor unidade de texto que faz sentido para a análise.
# A partir do token, podemos usar os conceitos usados nas aulas anteriores.

# Pacote readtext é útil
# https://cran.r-project.org/web/packages/readtext/vignettes/readtext_vignette.html

# Importar texto de sites: técnicas de web scraping, como 
# rvest::html_text() (mais avançado)

library(readtext)
arquivo_pdf <- readtext::readtext("referencias/1859-Texto do artigo-3971-2-10-20210608.pdf")

df_texto_estruturado <- arquivo_pdf |>
  rowid_to_column("n_pagina") |>
  mutate(text = str_split(text, "\n")) |> 
  unnest(text) |> 
  group_by(n_pagina) |> 
  mutate(n_linha = row_number()) |> 
  ungroup()

df_texto_estruturado |> View()


df_texto_limpo <- df_texto_estruturado |> 
  mutate(text = str_trim(text)) |> 
  filter(text != "") 

df_texto_limpo |>
  unnest_tokens(input = text, output = "word") |> 
  count(word, sort = TRUE) 
    

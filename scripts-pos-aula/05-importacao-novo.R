# Importar dados textuais podem ser um desafio!
# Nesse exemplo, queremos chegar até o token,
# que é a menor unidade de texto que faz sentido para a análise.
# A partir do token, podemos usar os conceitos usados nas aulas anteriores.

# Pacote readtext é útil
# https://cran.r-project.org/web/packages/readtext/vignettes/readtext_vignette.html

# Importar texto de sites: técnicas de web scraping, como
# rvest::html_text() (mais avançado)

library(tidyverse)
library(tidytext)
library(readtext)


# Fazer download dos dados ----
# Dados brutos de Umich
# https://deepblue.lib.umich.edu/data/concern/data_sets/sn009x784?locale=en

# Salvar o arquivo `.zip` com os arquivos
# copiar/mover para a pasta dados
# descompactar

# link da copia que está no repositório
url_umich_github <- "https://github.com/beatrizmilz/2025-11-cebrap-lab-text-as-data/raw/refs/heads/main/dados/Developing_Writers_Interview_Transcripts.zip"

# nome do arquivo para salvar
arquivo_umich_zip <- "dados/Developing_Writers_Interview_Transcripts.zip"

# criar pasta, caso ela não exista ainda
fs::dir_create("dados/")

# download do arquivo
download.file(url_umich_github, destfile = arquivo_umich_zip)

# descompactar a pasta
zip::unzip(arquivo_umich_zip, exdir = "dados")


# Exemplo 1 - Importar entrevistas em PDF --------

diretorio_arquivos_pdf <- "dados/Developing Writers Interview Transcripts/"

# A função dir_ls retorna a lista do caminho dos arquivos
arquivos_umich <- fs::dir_ls(diretorio_arquivos_pdf)
arquivos_umich

# quantos arquivos temos?
length(arquivos_umich)

# É muito difícil importar um por um!!

# O melhor é usar um for loop ou purrr::map().
# Porém a função readtext() permite receber um conjunto de
# caminhos, então nesse caso não precisamos fazer iteração manual

# Como ler um arquivo?
um_arquivo_lido <- readtext::readtext(arquivos_umich[1])

glimpse(um_arquivo_lido)


varios_arquivos_lidos <- readtext::readtext(arquivos_umich)
glimpse(varios_arquivos_lidos)


"CREAS1_P2_KKKK.pdf"

varios_arquivos_lidos |>
  separate(
    col = nome_da_coluna_original,
    sep = "_",
    into = c("cod_creas", "cod_pessoa", "extra")
  )


# arquivos_umich[1:50]
# parte1 <- ...
# parte2 <- ...
# todos <- bind_rows(parte1, parte2)

# Podemos remover os arquivos que não são desejados

arquivos_suplementares <- c(
  "Appendix_04a_InterviewProtocols.pdf",
  "WDS Consent Survey NonMinors.pdf"
)

entrevistas <- varios_arquivos_lidos |>
  filter(!doc_id %in% arquivos_suplementares)
# até aqui, cada entrevista está "guardada" em uma linha da base de dados.
# se for necessário, podemos deixar cada linha da entrevista
# em uma linha na base de dados.

entrevistas_longo <- entrevistas |>
  # deixar nesse formato "longo":
  # \n significa quebra de linha
  mutate(text = str_split(text, "\n")) |>
  tidyr::unnest(text) |>
  # o que é uma pergunta e o que é uma resposta?
  # identificar onde aparece quem fala
  mutate(
    quem_diz = case_when(
      str_starts(text, "Interviewer:") ~ "Entrevistador",
      str_starts(text, "Interviewee:") ~ "Respondente",
      .default = NA
    )
  ) |>
  # preencher "para baixo"
  tidyr::fill(quem_diz, .direction = "down") |>
  # remover textos vazios (quebra de linha)
  filter(text != "")

# se quiser apenas as respostas
respostas <- entrevistas_longo |>
  # filtrar por respondente
  filter(quem_diz == "Respondente") |>
  # remover a palavra "interviewee" do início das respostas
  mutate(text = stringr::str_remove(text, "^Interviewee: "))

# Daqui pra frente podemos usar as técnicas vistas anteriormente :)

# Sources que tem pt: "snowball", "stopwords-iso", "nltk"

library(stopwords)
# Vamos usar o snowball
snowball <-
  stopwords::stopwords(source = "snowball", language = "pt")

# também dá para buscar no pacote tm
stopwords_tm <- tm::stopwords("pt")

# Vamos adicionar algumas palavras que não estão no snowball
# Mas que olhando os resultados, aparecem muito
# e não são relevantes para a análise
extra_stop_words <- c(
  "é",
  "ser",
  "pra",
  "vai",
  "portanto",
  "quase",
  "pois",
  "algo",
  "assim",
  "ai",
  "ainda",
  "algum",
  "sendo",
  "existe",
  "disso",
  "disso",
  "á",
  "ter",
  "pode",
  "sobre"
)

stop_words_completo <- unique(c(snowball, stopwords_tm, extra_stop_words))


stop_words_bigram <- c(
  "muitas vezes",
  "ponto positivo",
  "pontos positivos",
  "faz sentido",
  "único ponto",
  "nenhum ponto"
)

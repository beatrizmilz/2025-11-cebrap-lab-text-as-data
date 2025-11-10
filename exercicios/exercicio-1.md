
- [Exercícios para terça-feira](#exercícios-para-terça-feira)
  - [Ver o vídeo:](#ver-o-vídeo)
  - [Praticando o uso do pacote
    stringr](#praticando-o-uso-do-pacote-stringr)
  - [Praticando conceitos vistos na parte de
    pré-processamento](#praticando-conceitos-vistos-na-parte-de-pré-processamento)

# Exercícios para terça-feira

## Ver o vídeo:

- [Como organizar seu banco de dados para análises
  estatísticas](https://www.youtube.com/watch?v=wzfPR2oQ61A), por
  Fernanda Peres

------------------------------------------------------------------------

## Praticando o uso do pacote stringr

``` r
library(stringr)
```

    ## Warning: package 'stringr' was built under R version 4.2.3

``` r
# https://www.camara.leg.br/enquetes/2373385
texto_exemplo <- "   Altera o Decreto Lei nº 1.804, de 3 de setembro de 1980, para aumentar o valor de minimis na importação de USD 50,00 para USD 100,00, reduzir a alíquota do imposto de importação de 60% para 20% e aumentar o valor máximo das remessas expressas de USD 3.000,00 para USD 5.000,00.   "
```

1)  Use a função `str_to_lower()` para deixar todas as letras do texto
    em minúsculo.

2)  Use a função `str_to_upper()` para deixar todas as letras do texto
    em maiúsculo.

3)  Use a função `str_trim()` para remover os espaços em branco no
    início e no final do texto.

4)  Use a função `str_detect()` para verificar se o texto contém a
    palavra “importação”.

5)  Use a função `str_count()` para contar quantas vezes a palavra
    “importação” aparece no texto.

6)  Use a função `str_replace()` para substituir a palavra “importação”
    por “exportação”.

7)  Use a função `str_replace_all()` para substituir a palavra
    “importação” por “exportação” e a palavra “Decreto Lei” por “Lei”.

8)  Use a função `str_split()` para separar o texto em duas partes:
    antes e depois da vírgula “,”.

9)  Nesse exemplo, usamos a função ver `str_view()` onde estão
    localizados os valores monetários.

``` r
# SIM, PARECE QUE UM GATO ANDOU NO TECLADO!
str_view(texto_exemplo, "USD \\d+?[.]?\\d+[,]?\\d+")
```

    ## [1] │    Altera o Decreto Lei nº 1.804, de 3 de setembro de 1980, para aumentar o valor de minimis na importação de <USD 50,00> para <USD 100,00>, reduzir a alíquota do imposto de importação de 60% para 20% e aumentar o valor máximo das remessas expressas de <USD 3.000,00> para <USD 5.000,00>.

Agora tente usar essa função para localizar as porcentagens:

------------------------------------------------------------------------

## Praticando conceitos vistos na parte de pré-processamento

O site da Câmara dos deputados tem uma página de temas:
<https://www.camara.leg.br/temas/>

- Agropecuária

- Cidades e transportes

- Ciência, tecnologia e comunicações

- Consumidor

- Coronavírus

- Direitos humanos

- Economia

- Educação, cultura e esportes

- Meio ambiente e energia

- Política e administração pública

- Reforma da Previdência

- Relações exteriores

- Saúde

- Segurança

- Trabalho, previdência e assistência

Escolha um tema de interesse, e na página do tema, é possível ver as
enquetes mais votadas. Escolha alguma enquete de interesse (de
preferência que tenha respostas para conseguirmos analisar), e tente
explorar os conceitos vistos na parte de pré-processamento usando esses
dados.

Anote as dúvidas. De preferência, anote também suas dúvidas no arquivo
que estamos usando no Google Drive, para que seja fácil de encontrar e
conversar sobre durante a aula.

Coloque o link para a enquete que você escolheu lá no arquivo do Google
drive, ao lado do seu nome! Assim, podemos ver as enquetes que cada um
escolheu.

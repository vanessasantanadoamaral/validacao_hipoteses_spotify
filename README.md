# Validação de Hipóteses - Spotify
Projeto de análise de dados e validação de hipóteses "Spotify".

  <details>
  <summary><strong style="font-size: 16px;">Ferramentas e Tecnologias</strong></summary>
   
  - BigQuery (Google Cloud)
  - SQL
  - Power BI
  - Python
  - Trello para gestão das etapas do projeto
  - SMART para gerenciamento de metas
 
  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Objetivo</strong></summary>
    
  Validar, por meio da análise de dados do Spotify, um conjunto de hipóteses levantadas por uma gravadora sobre os fatores que influenciam o sucesso de uma música, definido pelo número de streams. O intuito da análise é oferecer insights estratégicos que permitam à gravadora e ao novo artista tomar decisões informadas, aumentando as chances de sucesso do lançamento no mercado musical global.
  
  As hipóteses testadas foram:
  
- **Hipótese 1:** Músicas com BPM (Batidas Por Minuto) mais altos fazem mais sucesso em termos de número de streams no Spotify.
- **Hipótese 2:** As músicas mais populares no ranking do Spotify também possuem um comportamento semelhante em outras plataformas, como a Deezer.
- **Hipótese 3:** A presença de uma música em um maior número de playlists está correlacionada com um maior número de streams.
- **Hipótese 4:** Artistas com um maior número de músicas no Spotify têm mais streams.
- **Hipótese 5:** As características da música influenciam o sucesso em termos de número de streams no Spotify.
 </details>

 <details>
 <summary><strong style="font-size: 16px;">Equipe</strong></summary>
   
  - Cassia Silva
  - Vanessa Santana do Amaral
  
   </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Processamento dos Dados</strong></summary>
  
  ### Importação da base de dados
  
  A primeira etapa consistiu na importação das bases de dados no ambiente do Google Cloud “BigQuery”. Foi criado um projeto chamado “validacaohipotesesprojeto02” e, dentro dele, o dataset “spotify”. Nele, foram carregadas as tabelas em formato CSV: “competition”, “technical_info” e “track_spotify”.

  ### Dados nulos
  
 Utilizou-se comandos SQL como SELECT, COUNT, WHERE e IS NULL para identificar e tratar valores nulos das três tabelas. A variável “in_shazam_charts” continha 50 nulos, substituídos por “0”, enquanto os 95 valores nulos da variável “key” foram ignorados por não serem utilizados na análise final.

### Dados duplicados

 Com os comandos SQL COUNT, GROUP BY e HAVING, identificaram-se quatro artistas com músicas duplicadas na tabela “track_spotify”. Nesses casos, foi utilizada a média das variáveis repetidas para garantir equilíbrio nas análises.

### Tratamento de dados fora do escopo de análise e discrepantes em variáveis categóricas e numéricas

As variáveis “key” e “mode” da tabela “technical_info” foram removidas com o uso de SELECT e EXCEPT, pois entende-se que não seriam relevantes para a análise.

A padronização de nomes foi feita com REGEXP_REPLACE e LIKE. 

Também foi identificado e excluído um track_id com características fora do padrão e informações insuficientes, por não atender aos critérios mínimos de análise.

No caso das variáveis numéricas, utilizou-se os comandos MAX, MIN, AVG e GROUP BY para identificar valores discrepantes. Durante esse processo, foi identificado um track_id com erro evidente no campo “streams”. Para esse caso específico, foi atribuído um novo valor com base na média geral de streams, preservando as demais informações dos dados.

###  Alteração do tipo de dados

 A variável “streams” foi convertida de string para variação númerica com a função SAFE_CAST.

###  Criação de novas variáveis

Foram criadas duas novas variáveis:
- "_release_date_": obtida pela junção de “released_year”, “released_month” e “released_day” com uso de CONCAT, CAST e DATE.
- "_total_playlists_": soma do número de playlists em que a música aparece (Spotify, Deezer, Apple Music) com SUM, LEFT JOIN e GROUP BY.

###  União das tabelas e construção de tabelas auxiliares

Após a conclusão das etapas de limpeza em cada uma das tabelas, foram criadas três novas views denominadas “competition_nova”, “technical_info_nova” e “track_spotify_nova”. Em seguida, foi realizada a criação da tabela “base_unificada” por meio dos comandos CREATE OR REPLACE TABLE e LEFT JOIN, consolidando as informações de todas as fontes em uma estrutura única e integrada para análise.

Embora não tenha sido utilizada diretamente na análise final, foi criada uma tabela auxiliar chamada “total_artista”, a partir do uso da função WITH e do comando LEFT JOIN. Essa tabela teve como objetivo contabilizar a quantidade de músicas por artista solo, sendo útil como apoio para verificações e testes intermediários durante o desenvolvimento do projeto.

</details>

<details>
 <summary><strong style="font-size: 16px;">Análise Exploratória</strong></summary>

###  Comportamento e visualização dos dados

Após a importação da tabela “base_unificada” no Power BI, foram realizadas análises iniciais com o objetivo de explorar o comportamento das variáveis. Primeiramente, agrupou-se a quantidade de streams por artista e o total de músicas por ano de lançamento, permitindo a criação de gráficos de barras e de linhas para facilitar a visualização dessas variáveis categóricas ao longo do tempo.
Além disso, por meio das funcionalidades do Power BI, foram calculadas medidas de tendência central — média e mediana — para as variáveis “presença em playlists” e “streams”, oferecendo uma compreensão inicial sobre a distribuição desses dados.
Complementando a análise, utilizou-se Python para gerar histogramas, possibilitando uma visualização clara da distribuição das variáveis mencionadas. 

###  Cálculo de quartis, percentis e correlação entre variáveis

Após a análise visual inicial, foi realizada a etapa de cálculo dos quartis e percentis das variáveis numéricas. Utilizamos as funções PERCENTILE_CONT, COALESCE, CASE WHEN e CROSS JOIN para criar variáveis categorizadas a partir desses valores, permitindo uma análise mais detalhada dos dados.
Com isso, foi possível classificar as faixas em diferentes categorias. Por exemplo, para a variável “bpm”, foram definidos como "muito lento" (1º quartil), "lento" (2º quartil), "rápido" (3º quartil) e "muito rápido" (4º quartil).

Esse mesmo processo foi aplicado a todas as variáveis de características da música. Além disso, foi criada uma variável de popularidade, baseada na quantidade de vezes que a música foi adicionada a playlists, com o objetivo de explorar sua relação com o número de streams.

###  Teste de correlação e validação das hipóteses

Com base nas variáveis criadas e categorizadas, realizamos a validação das hipóteses por meio do cálculo da correlação de Pearson, utilizando a função SELECT CORR para verificar a existência de relações lineares entre as variáveis numéricas.

Complementando essa análise, no Power BI, foram desenvolvidos gráficos de dispersão para ilustrar visualmente as correlações identificadas. Essa abordagem permitiu observar tendências e padrões, além de reforçar ou refutar as hipóteses inicialmente levantadas sobre o comportamento das variáveis, como o impacto da presença em playlists sobre o número de streams, entre outras relações analisadas.

Além disso, no Power BI, criamos gráficos simples e intuitivos, visuais e scorecards, para representar de forma clara os dados gerais do negócio. Também foram adicionados filtros, permitindo as análises de maneira dinâmica.
</details>

<details>
<summary><strong style="font-size: 16px;">Resultados</strong></summary>

  Com base nas análises e validações de correlação, as hipóteses foram definidas da seguinte maneira:

- **_Hipótese 1_ - Relação entre BPM e Streams:** A hipótese inicial de que músicas com BPM (batidas por minuto) mais elevadas estariam associadas a um maior número de streams não foi confirmada pela análise. O teste de correlação apontou um valor de 0,0023, evidenciando uma correlação extremamente fraca entre as variáveis "BPM" e "streams", o que indica que a velocidade da música, por si só, não influencia significativamente a quantidade de reproduções.
  
- **_Hipótese 2_ - Popularidade no Spotify e Outras Plataformas:** A hipótese inicial de que as músicas mais populares no ranking do Spotify também apresentam bom desempenho nas plataformas Deezer e Apple foi confirmada pelos testes realizados. As análises de correlação indicaram valores de 0.7092 entre Spotify e Apple, e 0.8264 entre Spotify e Deezer, demonstrando uma correlação positiva entre essas plataformas. Esses resultados sugerem que o sucesso de uma faixa no Spotify tende a se refletir também em outras plataformas, validando a hipótese proposta.

- **_Hipótese 3_ - Presença em Playlists e Streams:** A hipótese de que a presença de uma música em um maior número de playlists está associada a um aumento no número de streams foi confirmada pelas análises realizadas. A correlação identificada foi de 0.7832, o que indica uma relação positiva e significativa entre essas variáveis. Esse resultado reforça a importância das playlists como um dos principais impulsionadores do sucesso das músicas nas plataformas de streaming, validando a hipótese proposta.
 
- **_Hipótese 4_ - Número de Músicas de um Artista e Streams:** Os resultados indicaram uma correlação positiva entre o número de músicas disponíveis de um artista no Spotify e o total de streams acumulados, com um coeficiente de 0.7786. Isso demonstra que, em média, quanto maior o número de faixas lançadas, maior tende a ser a quantidade de streams, validando a hipótese de que um catálogo mais extenso contribui para o aumento da popularidade do artista na plataforma.

- **_Hipótese 5_ - Características da Música e Streams:** A última hipótese buscava verificar se as características das músicas influenciam significativamente o sucesso em termos de número de streams. No entanto, os testes de correlação mostraram que todas as variáveis analisadas apresentaram correlação negativa com a quantidade de streams. Diante disso, concluiu-se que essas características não exercem impacto relevante sobre o desempenho das faixas, especialmente quando comparadas a outros fatores analisados. Assim, a hipótese foi refutada.

</details>

<details>
<summary><strong style="font-size: 16px;">Conclusões</strong></summary>

Os resultados da análise evidenciam uma relação expressiva entre a inclusão de músicas em playlists e o aumento no número de streams, ressaltando a relevância de estratégias voltadas à inserção das faixas em listas de reprodução nas principais plataformas de streaming.

Diante disso, é interessante que a gravadora direcione seus esforços para garantir a presença das músicas do novo artista em playlists relevantes, visto que essa ação contribui diretamente para ampliar seu alcance e visibilidade. Em paralelo, fomentar a criação de um catálogo musical diversificado pode aumentar as chances de múltiplas faixas se destacarem, ampliando a exposição do artista e facilitando sua entrada em playlists populares.

Outro ponto relevante identificado foi a correlação positiva entre o bom desempenho das músicas no Spotify e seu sucesso em outras plataformas, como Deezer e Apple Music. Isso indica que ações eficazes aplicadas em uma plataforma podem ser replicadas com êxito em outras, promovendo maior abrangência e presença digital. 
Ao colocar essas recomendações em prática, com base nos dados analisados, a gravadora terá melhores condições de impulsionar a trajetória do novo artista no competitivo cenário do streaming musical.


</details>

<details>
<summary><strong style="font-size: 16px;">Links</strong></summary>

[Video - Apresentação](https://drive.google.com/file/d/1QioYW9oOS9xU7kyGWUXgmGs0qZQvsTdG/view?usp=drive_link)

[Apresentação slides](https://www.canva.com/design/DAGmrlpxeh8/UjQffDh3Tw_jOiMg0YrKjw/edit)

</details>

-- Identificar e tratar valores nulos
select count (*)
from spotify.competition
where in_shazam_charts is null

select count (*)
from `spotify.technical_info`
where key is null

-- Identificar e tratar valores duplicados
select track_name,artist_s__name,
count (*)
from `spotify.track_spotify`
group by track_name, artist_s__name
having count (*) > 1 

-- Identificar e tratar dados fora do escopo de análise
select 
*
except (key,mode)
from `spotify.technical_info`

-- Identificar e tratar dados discrepantes em variáveis categóricas
SELECT
track_name, artist_s__name,
REGEXP_REPLACE(track_name, r'[^a-zA-Z0-9\\s]', ' ') as nome_musica,
REGEXP_REPLACE(artist_s__name, r'[^a-zA-Z0-9\\s]', ' ') as nome_artista
FROM `spotify.track_spotify`

-- Identificar e tratar dados discrepantes em variáveis numéricas
select *
from `spotify.track_spotify`
where track_id = '4061483'

select *
from `spotify.technical_info`
where track_id = '4061483'

SELECT
track_id,
MAX (streams),
MIN (streams),
AVG (SAFE_CAST(streams AS INT64)),
from `spotify.track_spotify`
group by track_id

--  Verificar e alterar o tipo de dados
SELECT
SAFE_CAST(streams AS INT64) AS streams_corrigido
FROM
`spotify.track_spotify`

-- Criar novas variáveis 
--RELEASED_DATE:
SELECT track_id,
DATE(CONCAT(CAST(released_year AS STRING),'-',
CAST(released_month AS STRING),'-',
CAST(released_day AS STRING))) AS release_date
FROM spotify.track_spotify

--TOTAL_PLAYLISTS:
SELECT
track_spotify.track_id,
SUM(competition.in_apple_playlists + competition.in_deezer_playlists + track_spotify.in_spotify_playlists) AS total_playlists
FROM
validacaohipotesesprojeto02.spotify.track_spotify AS track_spotify

LEFT JOIN
validacaohipotesesprojeto02.spotify.competition AS competition
ON track_spotify.track_id = competition.track_id
GROUP BY track_spotify.track_id

  -- View tabela competition tratada
SELECT IFNULL(in_shazam_charts,0) AS in_shazam_charts_nova,
comp.*
FROM `spotify.competition` comp
  
-- View tabela technical_info tratada
SELECT
track_id,
bpm,
`danceability_%` AS danceability,
`valence_%` AS valence,
`energy_%` AS energy,
`acousticness_%` AS acousticness,
`instrumentalness_%` AS instrumentalness,
`liveness_%` AS liveness,
`speechiness_%` AS speechiness,
from `spotify.technical_info`


-- View tabela track_spotify tratada
SELECT
  MIN(ts.track_id) AS track_id,
  REGEXP_REPLACE(ts.track_name, r'[^a-zA-Z0-9\\s]', ' ') AS track_name_corrigido,
  REGEXP_REPLACE(ts.artist_s__name, r'[^a-zA-Z0-9\\s]', ' ') AS artist_s__name_corrigido,
  AVG(ts.artist_count) AS artist_count,
  MIN(ts.released_year) AS released_year,
  MIN(ts.released_month) AS released_month,
  MIN(ts.released_day) AS released_day,
  AVG(ts.in_spotify_playlists) AS in_spotify_playlists_corrigido,
  AVG(ts.in_spotify_charts) AS in_spotify_charts_corrigido,
  IFNULL(
    AVG(SAFE_CAST(ts.streams AS INT64)),
    (SELECT AVG(SAFE_CAST(streams AS INT64)) FROM `validacaohipotesesprojeto02.spotify.track_spotify`)
  ) AS streams_corrigido,
  DATE(
    CONCAT(
      CAST(MIN(ts.released_year) AS STRING), '-',
      CAST(MIN(ts.released_month) AS STRING), '-',
      CAST(MIN(ts.released_day) AS STRING)
    )
  ) AS release_date,
  SUM(IFNULL(c.in_apple_playlists, 0) + IFNULL(c.in_deezer_playlists, 0) + IFNULL(ts.in_spotify_playlists, 0)) AS total_playlists
FROM
  `validacaohipotesesprojeto02.spotify.track_spotify` AS ts
LEFT JOIN
  `validacaohipotesesprojeto02.spotify.competition` AS c
ON
  ts.track_id = c.track_id
GROUP BY
  REGEXP_REPLACE(ts.track_name, r'[^a-zA-Z0-9\\s]', ' '),
  REGEXP_REPLACE(ts.artist_s__name, r'[^a-zA-Z0-9\\s]', ' ')

-- Criação de tabela temporária
  WITH total_artista AS (
SELECT
COUNT(artist_s__name_corrigido) AS total_musicas,
artist_s__name_corrigido
FROM
`validacaohipotesesprojeto02.spotify.track_spotify_nova`
WHERE artist_count = 1
GROUP BY artist_s__name_corrigido
)


SELECT
track.*,
total.total_musicas
FROM
`validacaohipotesesprojeto02.spotify.track_spotify_nova` AS track
LEFT JOIN total_artista AS total ON track.artist_s__name_corrigido = total.artist_s__name_corrigido

-- Unir tabelas
CREATE OR REPLACE TABLE `spotify.base_unificada` AS (
  SELECT
comp.in_shazam_charts_nova,
comp.track_id,
comp.in_apple_playlists,
comp.in_apple_charts,
comp.in_deezer_playlists,
comp.in_deezer_charts,
comp.in_shazam_charts,
info.bpm,
info.danceability,
info.valence,
info.energy,
info.acousticness,
info.instrumentalness,
info.liveness,
info.speechiness,
track.track_name_corrigido,
track.artist_s__name_corrigido,
track.artist_count,
track.release_date,
track.released_year,
track.released_month,
track.released_day,
track.in_spotify_playlists_corrigido,
track.in_spotify_charts_corrigido,
track.streams_corrigido,
track.total_playlists

FROM
  `spotify.track_spotify_nova` AS track
  LEFT JOIN
  `spotify.technical_info_nova` AS info
  ON track.track_id = info.track_id
  LEFT JOIN
  `spotify.competition_nova`AS comp
  ON track.track_id = comp.track_id
  where comp.track_id not like '%:%'
)

-- Calcular quartis, decis ou percentis
CREATE OR REPLACE TABLE spotify.novas_variaveis AS
WITH quartis AS (
  SELECT
    PERCENTILE_CONT(streams_corrigido, 0.25) OVER() AS streams_q1,
    PERCENTILE_CONT(streams_corrigido, 0.5) OVER() AS streams_q2,
    PERCENTILE_CONT(streams_corrigido, 0.75) OVER() AS streams_q3,

    PERCENTILE_CONT(bpm, 0.25) OVER() AS bpm_q1,
    PERCENTILE_CONT(bpm, 0.5) OVER() AS bpm_q2,
    PERCENTILE_CONT(bpm, 0.75) OVER() AS bpm_q3,

    PERCENTILE_CONT(danceability, 0.25) OVER() AS danceability_q1,
    PERCENTILE_CONT(danceability, 0.5) OVER() AS danceability_q2,
    PERCENTILE_CONT(danceability, 0.75) OVER() AS danceability_q3,

    PERCENTILE_CONT(valence, 0.25) OVER() AS valence_q1,
    PERCENTILE_CONT(valence, 0.5) OVER() AS valence_q2,
    PERCENTILE_CONT(valence, 0.75) OVER() AS valence_q3,

    PERCENTILE_CONT(energy, 0.25) OVER() AS energy_q1,
    PERCENTILE_CONT(energy, 0.5) OVER() AS energy_q2,
    PERCENTILE_CONT(energy, 0.75) OVER() AS energy_q3,

    PERCENTILE_CONT(acousticness, 0.25) OVER() AS acousticness_q1,
    PERCENTILE_CONT(acousticness, 0.5) OVER() AS acousticness_q2,
    PERCENTILE_CONT(acousticness, 0.75) OVER() AS acousticness_q3,

    PERCENTILE_CONT(instrumentalness, 0.25) OVER() AS instrumentalness_q1,
    PERCENTILE_CONT(instrumentalness, 0.5) OVER() AS instrumentalness_q2,
    PERCENTILE_CONT(instrumentalness, 0.75) OVER() AS instrumentalness_q3,

    PERCENTILE_CONT(liveness, 0.25) OVER() AS liveness_q1,
    PERCENTILE_CONT(liveness, 0.5) OVER() AS liveness_q2,
    PERCENTILE_CONT(liveness, 0.75) OVER() AS liveness_q3,

    PERCENTILE_CONT(speechiness, 0.25) OVER() AS speechiness_q1,
    PERCENTILE_CONT(speechiness, 0.5) OVER() AS speechiness_q2,
    PERCENTILE_CONT(speechiness, 0.75) OVER() AS speechiness_q3
  FROM
    `spotify.base_unificada`
  LIMIT 1
)
SELECT
  b.track_id,
  b.track_name_corrigido,
  b.artist_s__name_corrigido,
  b.artist_count,
  b.release_date,
  b.released_year,
  b.released_month,
  b.released_day,
  b.in_shazam_charts_nova,
  b.in_apple_charts,
  b.in_deezer_charts,
  b.in_spotify_charts_corrigido,
  b.in_apple_playlists,
  b.in_deezer_playlists,
  b.in_spotify_playlists_corrigido,
  (COALESCE(b.in_apple_playlists, 0) + COALESCE(b.in_deezer_playlists, 0) + COALESCE(b.in_spotify_playlists_corrigido, 0)) AS total_playlists,
  b.streams_corrigido,
  b.bpm,
  b.danceability,
  b.valence,
  b.energy,
  b.acousticness,
  b.instrumentalness,
  b.liveness,
  b.speechiness,
  CASE
    WHEN b.streams_corrigido <= q.streams_q1 THEN 'Muito Baixo'
    WHEN b.streams_corrigido <= q.streams_q2 THEN 'Baixo'
    WHEN b.streams_corrigido <= q.streams_q3 THEN 'Alto'
    ELSE 'Muito Alto'
  END AS categoria_streams,
  CASE
    WHEN b.bpm <= q.bpm_q1 THEN 'Muito Lento'
    WHEN b.bpm <= q.bpm_q2 THEN 'Lento'
    WHEN b.bpm <= q.bpm_q3 THEN 'Rápido'
    ELSE 'Muito Rápido'
  END AS categoria_bpm,
  CASE
    WHEN b.danceability <= q.danceability_q1 THEN 'Pouco Dançante'
    WHEN b.danceability <= q.danceability_q2 THEN 'Moderado'
    WHEN b.danceability <= q.danceability_q3 THEN 'Dançante'
    ELSE 'Muito Dançante'
  END AS categoria_danceability,
  CASE
    WHEN b.valence <= q.valence_q1 THEN 'Muito Triste'
    WHEN b.valence <= q.valence_q2 THEN 'Triste'
    WHEN b.valence <= q.valence_q3 THEN 'Feliz'
    ELSE 'Muito Feliz'
  END AS categoria_valence,
  CASE
    WHEN b.energy <= q.energy_q1 THEN 'Muito Suave '
    WHEN b.energy <= q.energy_q2 THEN 'Suave'
    WHEN b.energy <= q.energy_q3 THEN 'Energético)'
    ELSE 'Muito Energético'
  END AS categoria_energy,
  CASE
    WHEN b.acousticness <= q.acousticness_q1 THEN 'Pouco Acústico'
    WHEN b.acousticness <= q.acousticness_q2 THEN 'Acústico Moderado'
    WHEN b.acousticness <= q.acousticness_q3 THEN 'Acústico'
    ELSE 'Muito Acústico'
  END AS categoria_acousticness,
  CASE
    WHEN b.instrumentalness <= q.instrumentalness_q1 THEN 'Pouco Instrumental'
    WHEN b.instrumentalness <= q.instrumentalness_q2 THEN 'Instrumental Moderado'
    WHEN b.instrumentalness <= q.instrumentalness_q3 THEN 'Instrumental'
    ELSE 'Muito Instrumental'
  END AS categoria_instrumentalness,
  CASE
    WHEN b.liveness <= q.liveness_q1 THEN 'Pouco ao Vivo'
    WHEN b.liveness <= q.liveness_q2 THEN 'Moderadamente ao Vivo)'
    WHEN b.liveness <= q.liveness_q3 THEN 'Ao Vivo'
    ELSE 'Muito ao Vivo'
  END AS categoria_liveness,
  CASE
    WHEN b.speechiness <= q.speechiness_q1 THEN 'Pouco Falada'
    WHEN b.speechiness <= q.speechiness_q2 THEN 'Moderadamente Falada'
    WHEN b.speechiness <= q.speechiness_q3 THEN 'Falada'
    ELSE 'Muito Falada'
  END AS categoria_speechiness,
  CASE
    WHEN (COALESCE(b.in_apple_playlists, 0) + COALESCE(b.in_deezer_playlists, 0) + COALESCE(b.in_spotify_playlists_corrigido, 0)
          + COALESCE(b.in_apple_charts, 0) + COALESCE(b.in_deezer_charts, 0) + COALESCE(b.in_shazam_charts_nova, 0)
          + COALESCE(b.in_spotify_charts_corrigido, 0)) = 0 THEN 'Não Popular'
    WHEN (COALESCE(b.in_apple_playlists, 0) + COALESCE(b.in_deezer_playlists, 0) + COALESCE(b.in_spotify_playlists_corrigido, 0)
          + COALESCE(b.in_apple_charts, 0) + COALESCE(b.in_deezer_charts, 0) + COALESCE(b.in_shazam_charts_nova, 0)
          + COALESCE(b.in_spotify_charts_corrigido, 0)) <= 5 THEN 'Pouco Popular'
    WHEN (COALESCE(b.in_apple_playlists, 0) + COALESCE(b.in_deezer_playlists, 0) + COALESCE(b.in_spotify_playlists_corrigido, 0)
          + COALESCE(b.in_apple_charts, 0) + COALESCE(b.in_deezer_charts, 0) + COALESCE(b.in_shazam_charts_nova, 0)
          + COALESCE(b.in_spotify_charts_corrigido, 0)) <= 15 THEN 'Moderadamente Popular'
    ELSE 'Muito Popular'
  END AS categoria_popularidade
FROM
  `spotify.base_unificada` b
CROSS JOIN
  quartis q

-- Calcular correlação entre variáveis
SELECT CORR (streams_corrigido, total_playlists) as correlacao
FROM `spotify.base_unificada`

SELECT CORR (streams_corrigido, danceability) as correlacao
FROM `spotify.base_unificada`

-- Validação das hipóteses
-- Hipótese 1: Músicas com BPM (Batidas Por Minuto) mais altos fazem mais sucesso em termos de streams no Spotify;
--Resultado: hipótese refutada, muito próximo de 0,não existe correlação entre o BPM da música e o número de streams no Spotify
SELECT CORR(streams_corrigido,bpm)
from `spotify.base_unificada`
--0,0023

--Hipótese 2: As músicas mais populares no ranking do Spotify também possuem um comportamento semelhante em outras plataformas como Deezer;
--Resultado: hipótese confirmada, todos acima de 0,7, o que indica uma forte correlação positiva entre o número de streams nas plataformas
SELECT CORR(in_spotify_playlists_corrigido,in_apple_playlists)
from `spotify.base_unificada`
--0.7092 

SELECT CORR(in_spotify_playlists_corrigido,in_deezer_playlists)
from `spotify.base_unificada`
--0.8264

--Hipótese 3: A presença de uma música em um maior número de playlists é relacionada a um maior número de streams;
--Resultado: hipótese confirmada, valor de total_playlits correlacionando com streams, é próximo de 1
SELECT CORR (streams_corrigido,total_playlists)
FROM `spotify.base_unificada`
--0,7832

SELECT CORR(streams_corrigido,in_apple_playlists)
FROM `spotify.base_unificada`
--0,7736 

SELECT CORR(streams_corrigido,in_deezer_playlists)
FROM `spotify.base_unificada`
--0,5982

SELECT CORR(streams_corrigido,in_spotify_playlists_corrigido)
FROM `spotify.base_unificada`
--0.7901

--Hipótese 4:Artistas com maior número de músicas no Spotify têm mais streams;
--Resultado: hipótese validada
WITH dados_artistas AS (
  SELECT 
    artist_s__name_corrigido,
    COUNT(track_id) AS num_musicas,
    SUM(streams_corrigido) AS total_streams
  FROM `spotify.base_unificada`
  GROUP BY artist_s__name_corrigido
)

SELECT 
  CORR(num_musicas, total_streams) AS corr_artista_musicas_streams
FROM dados_artistas
--0.7786

--Hipótese 5: As características da música influenciam no sucesso em termos de streams no Spotify.
--Resultado: hipótese refutada, os valores estão muito abaixo para terem alguma relação
SELECT 
CORR(streams_corrigido,bpm),-- -0.002312
CORR(streams_corrigido,liveness),-- -0.04982
CORR(streams_corrigido,speechiness),-- -0.1124
CORR(streams_corrigido,danceability),-- -0.1055
CORR(streams_corrigido,acousticness),-- -0.00469
CORR(streams_corrigido,energy),-- -0.02616
CORR(streams_corrigido,valence),-- -0.0413
CORR(streams_corrigido,instrumentalness) -- -0.0441
FROM `spotify.base_unificada`

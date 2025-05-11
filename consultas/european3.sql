-- Listar a quantidade de gols prevista na próxima temporada da premier
-- league

WITH ultimas_seasons AS (
	SELECT DISTINCT
	       season AS seasons
	  FROM games
	 WHERE competition_id = 'GB1'
	 ORDER BY season DESC
	 LIMIT 3
),

total_gols_club AS (
SELECT clu.club_id,
	   SUM(clg.own_goals) AS total_gols
  FROM clubs clu
 INNER JOIN club_games clg
    ON clu.club_id = clg.club_id
 INNER JOIN games gam
    ON clg.game_id = gam.game_id
 WHERE season IN (SELECT seasons FROM ultimas_seasons)
 GROUP BY clu.club_id
)

SELECT clu.name,
       ROUND(AVG(tlg.total_gols)) AS qntd_gols_prevista
  FROM clubs clu
 INNER JOIN total_gols_club tlg
    ON clu.club_id = tlg.club_id
 GROUP BY clu.name, clu.club_id
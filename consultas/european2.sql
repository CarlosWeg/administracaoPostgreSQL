-- Classificar os clubes com acima abaixo e na média na última temporada
-- na premier league

WITH ultima_temporada_premier AS (
    SELECT MAX(season) AS ano_ultima_temporada
    FROM games
    WHERE competition_id = 'GB1'
),

media_ultima_temporada AS(
SELECT AVG(media_gols_clube) AS media_gols
  FROM (SELECT SUM(clg.own_goals) AS media_gols_clube
		  FROM club_games clg
		 INNER JOIN games gam2
		    ON clg.game_id = gam2.game_id
		 WHERE gam2.competition_id = 'GB1'
	 	   AND gam2.season = (SELECT ano_ultima_temporada
		   		 		       FROM ultima_temporada_premier)
		 GROUP BY clg.club_id) subquery
)

SELECT clu.name,
       CASE WHEN SUM(clg.own_goals) > (SELECT media_gols FROM media_ultima_temporada) THEN 'Acima da média'
			WHEN SUM(clg.own_goals) < (SELECT media_gols FROM media_ultima_temporada) THEN 'Abaixo da média'
			ELSE 'Igual a média'
		END AS classificacao
  FROM clubs clu
 INNER JOIN club_games clg
    ON clg.club_id = clu.club_id
 INNER JOIN games gam
    ON clg.game_id = gam.game_id
 WHERE gam.competition_id = 'GB1'
   AND gam.season = (SELECT ano_ultima_temporada
		   		 	  FROM ultima_temporada_premier)
 GROUP BY clu.name, clu.club_id
 ORDER BY classificacao
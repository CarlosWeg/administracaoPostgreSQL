-- Elaborar uma consulta para apurar os clubes vencedores de cada partida em
-- cada rodada na premier league na última temporada.

SELECT clb.name,
       gam.game_id,
	   gam.season,
	   gam.round,
	   gam.date
  FROM clubs clb
 INNER JOIN club_games clg
    ON clb.club_id = clg.club_id
 INNER JOIN games gam
    ON clg.game_id = gam.game_id
 WHERE clg.is_win = 1
   AND gam.competition_id = 'GB1'
   AND gam.season = (SELECT MAX(season)
                       FROM games gam2
					  WHERE gam2.competition_id = 'GB1')
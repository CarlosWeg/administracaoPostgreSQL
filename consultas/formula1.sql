--Resultado por Equipes nas últimas 5 temporadas (2024 inclusive)

SELECT rac.year AS ano,
       con.name AS nome_equipe,
       SUM(cnr.points) AS pontos
  FROM constructors con
 INNER JOIN constructor_results cnr
    ON con.constructorid = cnr.constructorid
 INNER JOIN races rac
    ON cnr.raceid = rac.raceid
 WHERE rac.year IN (SELECT DISTINCT rac2.year
                      FROM races rac2
					 ORDER BY rac2.year DESC
					 LIMIT 5)
 GROUP BY con.name, rac.year
 ORDER BY rac.year ASC
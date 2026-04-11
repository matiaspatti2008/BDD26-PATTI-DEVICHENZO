USE videojuegos2026;

#1
-- Listar todos los jugadores de Argentina, ordenados alfabéticamente por apellido.
SELECT *
FROM jugador
WHERE pais = 'Argentina'
ORDER BY apellido ASC;



#2
-- Mostrar los videojuegos con edad mínima mayor o igual a 16 años.
SELECT nombre
FROM videojuego
WHERE clasificacionEdad >= 16;



#3
-- Listar el nombre de cada equipo junto con el nombre y apellido de su capitán.
SELECT e.nombre, concat(j.nombre, " ", j.apellido) AS capitan
FROM equipo e
JOIN jugador j ON e.idCapitan = j.idJugador;



#4
-- Obtener todas las inscripciones mostrando: nombre del equipo, nombre del torneo, fecha de inscripción y posición final.
SELECT e.nombre as equipo, t.nombre as torneo, et.fechaInscripcion, et.posicion
FROM equipo e
JOIN equipo_has_torneo et ON e.idEquipo = et.Equipo_idEquipo
JOIN torneo t ON et.Torneo_idTorneo = t.idTorneo;



#5
-- Calcular cuántos jugadores hay por país.
SELECT pais, COUNT(idJugador) as cantidad_de_jugadores
FROM jugador
GROUP BY pais
ORDER BY pais ASC;



#6
-- Calcular el premio total ofrecido por todos los torneos de cada videojuego.
SELECT v.nombre AS juego, SUM(t.premio) AS premio_total
FROM videojuego v
JOIN torneo t ON v.idVideojuego = t.Videojuego_idVideojuego
GROUP BY juego;



#7
-- Obtener el promedio de edad mínima de los videojuegos por género.
SELECT genero, AVG(clasificacionEdad) as prom_edadMinima
FROM videojuego v
GROUP BY genero;



#8
-- Listar los equipos que participaron en más de 5 torneos.
SELECT e.nombre as EQUIPO
FROM equipo e
WHERE e.idEquipo IN(
	SELECT et.Equipo_idEquipo AS equipoT
    FROM equipo_has_torneo et
	GROUP BY equipoT
    HAVING COUNT(equipoT) >= 5 );



#9
-- Hacer un top 5 de los torneos con mayor premio ofrecido.
SELECT nombre, premio
FROM torneo
ORDER BY premio DESC
LIMIT 5;



#10
-- Listar los jugadores que están en equipos que ganaron al menos un torneo.
-- CON EXISTS
SELECT CONCAT(j.nombre, " ", j.apellido) as Jugadores_campeones
FROM jugador j
JOIN jugador_has_equipo je ON j.idJugador = je.Jugador_idJugador
WHERE EXISTS ( 
	SELECT 1  -- tambien puede funcionar 'et.Equipo_idEquipo'
    FROM equipo_has_torneo et
    WHERE et.Equipo_idEquipo = je.Equipo_idEquipo
    AND posicion = 1 );
-- -------------------------
-- CON IN
SELECT CONCAT(j.nombre, " ", j.apellido) as Jugadores_campeones
FROM jugador j
JOIN jugador_has_equipo je ON j.idJugador = je.Jugador_idJugador
WHERE je.Equipo_idEquipo IN (
	SELECT et.Equipo_idEquipo
    FROM equipo_has_torneo et
    WHERE et.posicion = 1 );
-- --------------------------
-- este ejemplo está mal porque me trae todos los jugadores (fue para probar algo)
SELECT CONCAT(j.nombre, " ", j.apellido) as Jugadores_campeones
FROM jugador j
JOIN jugador_has_equipo je ON j.idJugador = je.Jugador_idJugador
WHERE EXISTS (
	SELECT 1 
    FROM equipo_has_torneo et, jugador_has_equipo je1
    WHERE et.Equipo_idEquipo = je1.Equipo_idEquipo
    AND posicion = 1 );



#11
-- Mostrar el videojuego más popular (con más torneos organizados).
SELECT v.nombre, COUNT(t.Videojuego_idVideojuego) AS participacion
FROM videojuego v
JOIN torneo t ON v.idVideojuego = t.Videojuego_idVideojuego
GROUP BY v.nombre
ORDER BY participacion DESC
LIMIT 1;



#12
-- Listar los jugadores más jóvenes de cada país.
SELECT j.pais, CONCAT(j.nombre, " ", j.apellido) as JUGADOR
FROM jugador j
WHERE (j.pais, j.fechaNacimiento) IN (
	SELECT j.pais, MAX(j.fechaNacimiento)
    FROM jugador j
    GROUP BY j.pais );



#13
-- Duplicar el premio de los torneos que tienen menos de 3 equipos inscritos.
UPDATE torneo t SET t.premio = t.premio*2
WHERE t.idTorneo IN (
	SELECT et.Torneo_idTorneo
    FROM equipo_has_Torneo et
    GROUP BY et.Torneo_idTorneo
    HAVING COUNT(et.Torneo_idTorneo) <= 3 );



#14
-- Actualizar el nombre de todos los videojuegos agregándoles el prefijo "[Popular]" si tienen más de 2 torneos asociados.
UPDATE videojuego SET nombre = CONCAT("[Popular] ", nombre)
WHERE idVideojuego IN (
	SELECT Videojuego_idVideojuego
    FROM torneo
    GROUP BY Videojuego_idVideojuego
    HAVING COUNT(*) >= 2 );



#15
-- Actualizar la edad mínima de todos los videojuegos al promedio de edades mínimas de su mismo género.
UPDATE videojuego v
JOIN (
	SELECT genero, AVG(clasificacionEdad) AS promedio
    FROM videojuego 
    GROUP BY genero ) v1 ON v.genero = v1.genero
SET clasificacionEdad = v1.promedio;



#16
-- Eliminar a los jugadores que no pertenecen a ningún equipo.
-- CON NOT IN
DELETE FROM jugador j
WHERE j.idJugador NOT IN(
	SELECT je.Jugador_idJugador
    FROM jugador_has_equipo je );
-- --------------------------
-- CON NOT EXISTS
DELETE FROM jugador j
WHERE NOT EXISTS (
	SELECT 1  -- tambien puede funcionar usar 'je.Jugador_idJugador'
    FROM jugador_has_equipo je
    WHERE je.Jugador_idJugador = j.idJugador );
    
    
    
#17
-- Eliminar los equipos que no salieron en el top 3 de ningún torneo.
-- CON NOT IN
DELETE FROM equipo e
WHERE e.idEquipo NOT IN (
	SELECT et.Equipo_idEquipo
    FROM equipo_has_torneo et
    WHERE posicion BETWEEN 1 AND 3 );
-- --------------------------
-- CON NOT EXISTS
DELETE FROM equipo e
WHERE NOT EXISTS (
	SELECT 1
    FROM equipo_has_torneo et
    WHERE et.Equipo_idEquipo = e.idEquipo
    AND posicion BETWEEN 1 AND 3 );
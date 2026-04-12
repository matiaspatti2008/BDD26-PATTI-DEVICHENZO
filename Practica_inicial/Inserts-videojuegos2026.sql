USE videojuegos2026;
 
-- JUGADOR
INSERT INTO Jugador VALUES
(1,'Juan','Perez','juan1@mail.com','1998-05-14','Argentina'),
(2,'Maria','Lopez','maria2@mail.com','1997-08-21','Chile'),
(3,'Carlos','Gomez','carlos3@mail.com','2000-02-10','Uruguay'),
(4,'Ana','Martinez','ana4@mail.com','1999-11-03','Argentina'),
(5,'Pedro','Sanchez','pedro5@mail.com','1996-07-19','Peru'),
(6,'Lucia','Fernandez','lucia6@mail.com','2001-01-30','Mexico'),
(7,'Diego','Ramirez','diego7@mail.com','1998-12-12','Colombia'),
(8,'Sofia','Torres','sofia8@mail.com','2002-03-05','Argentina'),
(9,'Martin','Castro','martin9@mail.com','1995-09-17','Chile'),
(10,'Valentina','Rojas','valen10@mail.com','2000-06-22','Uruguay'),
(11,'Lucas','Diaz','lucas11@mail.com','1999-01-10','Argentina'),
(12,'Camila','Silva','camila12@mail.com','2001-02-18','Chile'),
(13,'Mateo','Acosta','mateo13@mail.com','1997-03-25','Uruguay'),
(14,'Julia','Morales','julia14@mail.com','2000-04-11','Peru'),
(15,'Tomas','Herrera','tomas15@mail.com','1998-06-09','Argentina'),
(16,'Daniel','Suarez','daniel16@mail.com','1996-07-07','Colombia'),
(17,'Paula','Vega','paula17@mail.com','2002-08-14','Chile'),
(18,'Andres','Molina','andres18@mail.com','1997-09-20','Mexico'),
(19,'Florencia','Cruz','flor19@mail.com','1999-10-30','Argentina'),
(20,'Nicolas','Ortiz','nico20@mail.com','2001-11-05','Uruguay'),
(21,'Agustin','Navarro','agus21@mail.com','1998-12-01','Argentina'),
(22,'Daniela','Reyes','dani22@mail.com','2000-01-16','Chile'),
(23,'Bruno','Rivas','bruno23@mail.com','1997-02-27','Peru'),
(24,'Carla','Mendez','carla24@mail.com','1999-03-18','Argentina'),
(25,'Jorge','Ibarra','jorge25@mail.com','1996-04-04','Colombia'),
(26,'Marina','Campos','marina26@mail.com','2002-05-21','Chile'),
(27,'Leandro','Paz','lean27@mail.com','1998-06-12','Argentina'),
(28,'Rocio','Soto','rocio28@mail.com','2001-07-08','Uruguay'),
(29,'Ivan','Luna','ivan29@mail.com','1997-08-19','Peru'),
(30,'Micaela','Flores','mica30@mail.com','2000-09-23','Argentina');
 
-- EQUIPO
INSERT INTO Equipo VALUES
(1,'Team Alpha',1),
(2,'Team Beta',4),
(3,'Team Gamma',7),
(4,'Team Delta',10),
(5,'Team Omega',13),
(6,'Team Nova',16),
(7,'Team Titan',19),
(8,'Team Shadow',22),
(9,'Team Phoenix',25),
(10,'Team Dragon',28);
 
-- JUGADOR_HAS_EQUIPO
INSERT INTO Jugador_has_Equipo VALUES
(1,1),(2,1),(3,1),
(4,2),(5,2),(6,2),
(7,3),(8,3),(9,3),
(10,4),(11,4),(12,4),
(13,5),(14,5),(15,5),
(16,6),(17,6),(18,6),
(19,7),(20,7),(21,7),
(22,8),(23,8),(24,8),
(25,9),(26,9),(27,9),
(28,10),(29,10),(30,10);
 
-- VIDEOJUEGO
INSERT INTO Videojuego VALUES
(1,'League of Legends','MOBA',12),
(2,'Counter Strike 2','FPS',16),
(3,'Valorant','FPS',16),
(4,'Fortnite','Battle Royale',12),
(5,'Dota 2','MOBA',12),
(6,'Rocket League','Deportes',3),
(7,'Overwatch 2','FPS',12),
(8,'EA Sports FC 24','Deportes',3),
(9,'Call of Duty Warzone','Battle Royale',18),
(10,'Minecraft','Sandbox',7);
 
-- TORNEO
INSERT INTO Torneo VALUES
(1,'LoL Apertura','2025-03-01','2025-03-10',5000,1),
(2,'CS2 Masters','2025-04-05','2025-04-12',8000,2),
(3,'Valorant Cup','2025-05-01','2025-05-07',6000,3),
(4,'Fortnite Championship','2025-06-10','2025-06-15',7000,4),
(5,'Dota Pro Series','2025-07-01','2025-07-10',10000,5),
(6,'Rocket League Series','2025-08-03','2025-08-06',4000,6),
(7,'Overwatch Clash','2025-09-10','2025-09-15',5000,7),
(8,'FC Pro Cup','2025-10-05','2025-10-07',3000,8),
(9,'Warzone Battle','2025-11-12','2025-11-18',9000,9),
(10,'Minecraft Build Battle','2025-12-01','2025-12-05',2000,10);
 
-- EQUIPO_HAS_TORNEO
INSERT INTO Equipo_has_Torneo VALUES
(1,1,'2025-02-20',1),
(2,2,'2025-03-20',2),
(3,3,'2025-04-20',3),
(4,4,'2025-05-20',NULL),
(5,5,'2025-06-20',1),
(6,6,'2025-07-20',NULL),
(7,7,'2025-08-20',2),
(8,8,'2025-09-20',1),
(9,9,'2025-10-20',NULL),
(10,10,'2025-11-20',3);
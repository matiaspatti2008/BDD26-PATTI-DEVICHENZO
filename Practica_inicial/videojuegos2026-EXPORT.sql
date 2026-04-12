create database videojuegos2026;
use videojuegos2026;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Jugador` (
  `idJugador` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `apellido` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `fechaNacimiento` DATE NOT NULL,
  `pais` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idJugador`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Equipo` (
  `idEquipo` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `idCapitan` INT NOT NULL,
  PRIMARY KEY (`idEquipo`),
  INDEX `fk_Equipo_Jugador_idx` (`idCapitan` ASC) VISIBLE,
  CONSTRAINT `fk_Equipo_Jugador`
    FOREIGN KEY (`idCapitan`)
    REFERENCES `videojuegos2026`.`Jugador` (`idJugador`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Jugador_has_Equipo` (
  `Jugador_idJugador` INT NOT NULL,
  `Equipo_idEquipo` INT NOT NULL,
  PRIMARY KEY (`Jugador_idJugador`, `Equipo_idEquipo`),
  INDEX `fk_Jugador_has_Equipo_Equipo1_idx` (`Equipo_idEquipo` ASC) VISIBLE,
  INDEX `fk_Jugador_has_Equipo_Jugador1_idx` (`Jugador_idJugador` ASC) VISIBLE,
  CONSTRAINT `fk_Jugador_has_Equipo_Jugador1`
    FOREIGN KEY (`Jugador_idJugador`)
    REFERENCES `videojuegos2026`.`Jugador` (`idJugador`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Jugador_has_Equipo_Equipo1`
    FOREIGN KEY (`Equipo_idEquipo`)
    REFERENCES `videojuegos2026`.`Equipo` (`idEquipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Videojuego` (
  `idVideojuego` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `genero` VARCHAR(45) NOT NULL,
  `clasificacionEdad` INT NOT NULL,
  PRIMARY KEY (`idVideojuego`))
ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Torneo` (
  `idTorneo` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `fechaInicio` DATE NOT NULL,
  `fechaFin` DATE NOT NULL,
  `premio` INT NOT NULL,
  `Videojuego_idVideojuego` INT NOT NULL,
  PRIMARY KEY (`idTorneo`),
  INDEX `fk_Torneo_Videojuego1_idx` (`Videojuego_idVideojuego` ASC) VISIBLE,
  CONSTRAINT `fk_Torneo_Videojuego1`
    FOREIGN KEY (`Videojuego_idVideojuego`)
    REFERENCES `videojuegos2026`.`Videojuego` (`idVideojuego`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `videojuegos2026`.`Equipo_has_Torneo` (
  `Equipo_idEquipo` INT NOT NULL,
  `Torneo_idTorneo` INT NOT NULL,
  `fechaInscripcion` DATE NOT NULL,
  `posicion` INT NULL,
  PRIMARY KEY (`Equipo_idEquipo`, `Torneo_idTorneo`),
  INDEX `fk_Equipo_has_Torneo_Torneo1_idx` (`Torneo_idTorneo` ASC) VISIBLE,
  INDEX `fk_Equipo_has_Torneo_Equipo1_idx` (`Equipo_idEquipo` ASC) VISIBLE,
  CONSTRAINT `fk_Equipo_has_Torneo_Equipo1`
    FOREIGN KEY (`Equipo_idEquipo`)
    REFERENCES `videojuegos2026`.`Equipo` (`idEquipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipo_has_Torneo_Torneo1`
    FOREIGN KEY (`Torneo_idTorneo`)
    REFERENCES `videojuegos2026`.`Torneo` (`idTorneo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
USE tp_ecommerce;

-- Stored Functions
-- 1)
delimiter // 
CREATE FUNCTION tiempo_prom_vender(idVendedor INT) returns decimal(10,2) DETERMINISTIC
begin
	DECLARE promedio_dia DECIMAL(10,2);
    SELECT AVG(timestampdiff(DAY, p.fecha_inicio, t.fecha_transaccion)) INTO promedio_dia
    FROM publicaciones p
    JOIN transacciones t ON p.publicacion_id = t.publicacion_id
    WHERE p.vendedor_id = idVendedor
    AND t.es_concretada = TRUE;
    
    RETURN IFNULL(promedio_dia, 0.00);
end //


-- 2)
delimiter //
CREATE FUNCTION comision_nivel(monto DECIMAL(15,2), nivel VARCHAR(20)) returns decimal(15,2) DETERMINISTIC
begin
	DECLARE comision DECIMAL(15,2);
	IF nivel = 'Normal' THEN
		SET comision = monto * 0.08;
	ELSEIF nivel = 'Platinum' THEN
		SET comision = monto * 0.05;
    ELSEIF nivel = 'Gold' THEN
		SET comision = monto * 0.03;
	ELSE
		SET comision = -1;
	END IF;
    
    RETURN comision;
end //


-- 3)
delimiter //
CREATE FUNCTION porcentaje_ventas(idVendedor INT) returns decimal(5,2) DETERMINISTIC
begin
    DECLARE total_publicaciones INT DEFAULT 0;
    DECLARE ventas_concretadas INT DEFAULT 0;

    SELECT COUNT(*) INTO total_publicaciones 
    FROM publicaciones 
    WHERE vendedor_id = idVendedor;

    IF total_publicaciones = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(DISTINCT p.publicacion_id) INTO ventas_concretadas
    FROM publicaciones p
    JOIN transacciones t ON p.publicacion_id = t.publicacion_id
    WHERE p.vendedor_id = idVendedor
	AND t.es_concretada = TRUE;

    RETURN (ventas_concretadas * 100) / total_publicaciones;
end //


-- 4)
delimiter //
CREATE FUNCTION mayor_precio_ofertado(idPublicacion INT) returns decimal(15,2) DETERMINISTIC
BEGIN
    DECLARE v_modalidad VARCHAR(20);
    DECLARE max_oferta DECIMAL(15,2);

    SELECT modalidad INTO v_modalidad 
    FROM publicaciones 
    WHERE publicacion_id = idPublicacion;

    IF v_modalidad IS NULL OR v_modalidad != 'Subasta' THEN
        RETURN -1;
    END IF;

    SELECT MAX(monto_ofertado) INTO max_oferta 
    FROM ofertas_subasta 
    WHERE publicacion_id = idPublicacion;

    RETURN IFNULL(max_oferta, 0);
end //


-- 5)
delimiter //
CREATE FUNCTION precio_prom_categoria(idCategoria INT) returns decimal(15,2) deterministic
begin
	DECLARE promedio decimal(15, 2);
    SELECT AVG(p.precio_base) INTO promedio
    FROM publicacion p
    JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE prod.categoria_id = idCategoria;
    
	RETURN IFNULL(promedio, 0);
end //


-- 6)
delimiter //
CREATE FUNCTION ultima_compra(idComprador INT) returns datetime DETERMINISTIC
begin
	DECLARE ultima_fecha DATETIME;
    SELECT MAX(fecha_transaccion) INTO ultima_fecha
    FROM transacciones
    WHERE comprador_id = idComprador
    AND es_concretada = TRUE;
    
    RETURN ultima_fecha;
end //



-- STORED PROCEDURES
-- 1)
delimiter //
CREATE PROCEDURE buscar_publicaciones(IN busqueda VARCHAR(150), OUT resultado VARCHAR(255))
begin
    IF busqueda IS NULL OR busqueda = '' THEN
        SET resultado = 'ERROR: El término de búsqueda no puede estar vacío';
    ELSE
        SELECT p.publicacion_id, pr.nombre, pr.precio_actual
        FROM publicaciones p
        JOIN productos pr ON p.producto_id = pr.producto_id
        WHERE pr.nombre LIKE CONCAT('%', busqueda, '%')
		OR pr.descripcion LIKE CONCAT('%', busqueda, '%');
        
        SET resultado = 'EXITO: Búsqueda realizada correctamente';
    END IF;
end //


-- 2)
delimiter //
CREATE PROCEDURE pujar_subasta(IN idPublicacion INT, IN idComprador INT, IN monto_of DECIMAL(15,2), OUT resultado VARCHAR(255))
begin
    DECLARE v_modalidad VARCHAR(20);
    DECLARE v_estado VARCHAR(20);
    DECLARE idVendedor INT;
    DECLARE v_precio_actual DECIMAL(15,2);

    SELECT modalidad, estado, vendedor_id, precio_actual 
    INTO v_modalidad, v_estado, idVendedor, v_precio_actual
    FROM publicaciones 
    WHERE publicacion_id = idPublicacion;

    IF v_modalidad IS NULL THEN
        SET resultado = 'ERROR: La publicación no existe';
    ELSEIF v_modalidad != 'Subasta' THEN
        SET resultado = 'ERROR: La publicación no es de modalidad Subasta';
    ELSEIF v_estado = 'Finalizada' THEN
        SET resultado = 'ERROR: La subasta ya se encuentra finalizada';
    ELSEIF v_vendedor_id = idComprador THEN
        SET resultado = 'ERROR: El vendedor no puede pujar en su propia subasta';
    ELSEIF monto_of <= v_precio_actual THEN
        SET resultado = 'ERROR: El monto ofertado debe ser mayor al precio actual ofertado';
    ELSE
        INSERT INTO ofertas_subasta (publicacion_id, comprador_id, monto_ofertado)
        VALUES (idPublicacion, idComprador, monto_of);

        UPDATE publicaciones SET precio_actual = monto_of 
        WHERE publicacion_id = idPublicacion;

        SET resultado = 'EXITO: Puja registrada correctamente';
    END IF;
end //


-- 3)
delimiter //
CREATE PROCEDURE pausar_publicacion(IN idPublicacion INT, IN idVendedor INT, OUT resultado VARCHAR(255))
begin
    DECLARE v_modalidad VARCHAR(20);
    DECLARE v_estado VARCHAR(20);
    DECLARE idVendedorReal INT;

    SELECT modalidad, estado, vendedor_id 
    INTO v_modalidad, v_estado, idVendedorReal
    FROM publicaciones 
    WHERE publicacion_id = idPublicacion;

    IF v_modalidad IS NULL THEN
        SET resultado = 'ERROR: La publicación no existe';
    ELSEIF idVendedorReal != idVendedor THEN
        SET resultado = 'ERROR: Solo el vendedor de la publicación puede pausarla';
    ELSEIF v_modalidad != 'Venta Directa' THEN
        SET resultado = 'ERROR: Solo se pueden pausar publicaciones de Venta Directa';
    ELSEIF v_estado = 'Finalizada' THEN
        SET resultado = 'ERROR: No se puede pausar una publicación finalizada';
    ELSE
        UPDATE publicaciones SET estado = 'Pausada' 
        WHERE publicacion_id = idPublicacion;

        SET resultado = 'EXITO: Publicación pausada correctamente.';
    END IF;
end //


-- 4)
delimiter //
CREATE PROCEDURE actualizar_nivel_usuario(IN idUsuario INT, OUT nuevo_nivel VARCHAR(20), OUT resultado VARCHAR(255))
begin
    DECLARE ventas_totales INT DEFAULT 0;
    DECLARE facturacion_total DECIMAL(15,2) DEFAULT 0;
    DECLARE idNivel INT;
    DECLARE existe_usuario INT DEFAULT 0;

    SELECT COUNT(*) INTO existe_usuario
    FROM usuarios
    WHERE usuario_id = idUsuario;

    IF existe_usuario = 0 THEN
        SET nuevo_nivel = NULL;
        SET resultado = 'ERROR: El usuario ingresado no existe.';
    ELSE
        SELECT COUNT(*), IFNULL(SUM(monto), 0) INTO ventas_totales, facturacion_total
        FROM transacciones
        WHERE vendedor_id = idUsuario
        AND es_concretada = TRUE;

        IF ventas_totales >= 11 OR facturacion_total >= 1000000 THEN
            SET nuevo_nivel = 'Gold';
        ELSEIF ventas_totales >= 6 OR facturacion_total >= 100000 THEN
            SET nuevo_nivel = 'Platinum';
        ELSEIF ventas_totales >= 1 THEN
            SET nuevo_nivel = 'Normal';
        ELSE
            SET nuevo_nivel = NULL;
        END IF;

        IF nuevo_nivel IS NOT NULL THEN
            SELECT nivel_id INTO idNivel
            FROM niveles_usuario WHERE nombre = nuevo_nivel;
        ELSE
            SET idNivel = NULL;
        END IF;

        UPDATE usuarios SET nivel_usuario_id = idNivel 
        WHERE usuario_id = idUsuario;

        SET resultado = 'EXITO: Nivel de usuario actualizado correctamente.';
    END IF;
end //


-- 5)
delimiter //
CREATE PROCEDURE calificar_usuario( IN idTransaccion INT, IN idUsuarioEvaluador INT, IN idUsuarioEvaluado INT, IN v_puntaje INT, IN v_comentario TEXT, OUT resultado VARCHAR(255))
begin
    DECLARE idVendedor INT;
    DECLARE idComprador INT;
    DECLARE v_es_concretada BOOLEAN;
    DECLARE promedio_puntaje DECIMAL(5,2);

    SELECT vendedor_id, comprador_id, es_concretada 
    INTO idVendedor, idComprador, v_es_concretada
    FROM transacciones 
    WHERE transaccion_id = idTransaccion;

    IF idVendedor IS NULL THEN
        SET resultado = 'ERROR: La transacción ingresada no existe';
    ELSEIF v_es_concretada = FALSE THEN
        SET resultado = 'ERROR: No se puede calificar una transacción no concretada';
    ELSEIF v_puntaje < 1 OR v_puntaje > 5 THEN
        SET resultado = 'ERROR: El puntaje debe estar comprendido entre 1 y 5';
    ELSEIF idUsuario_evaluador NOT IN (idVendedor, idComprador) THEN
        SET resultado = 'ERROR: El usuario evaluador no participó de la transacción';
    ELSEIF idUsuario_evaluado NOT IN (idVendedor, idComprador) THEN
        SET resultado = 'ERROR: El usuario evaluado no participó de la transacción.';
    ELSEIF idUsuario_evaluador = idUsuario_evaluado THEN
        SET resultado = 'ERROR: Un usuario no puede calificarse a sí mismo';
    ELSE
        INSERT INTO calificaciones (transaccion_id, usuario_evaluado_id, puntaje, comentario)
        VALUES (idTransaccion, idUsuario_evaluado, v_puntaje, v_comentario);

        SELECT AVG(puntaje) INTO promedio_puntaje
        FROM calificaciones
        WHERE usuario_evaluado_id = idUsuario_evaluado;

        UPDATE usuarios
        SET reputacion_actual = (promedio_puntaje * 100) / 5
        WHERE usuario_id = idUsuario_evaluado;

        SET resultado = 'EXITO: Calificación registrada y reputación actualizada';
    END IF;
end //


-- 6)
delimiter //
CREATE PROCEDURE ganador_subasta( IN idPublicacion INT, OUT resultado VARCHAR(255))
begin
    DECLARE v_modalidad VARCHAR(20);
    DECLARE cant_ofertas INT DEFAULT 0;

    SELECT modalidad INTO v_modalidad FROM publicaciones WHERE publicacion_id = idPublicacion;

    IF v_modalidad IS NULL THEN
        SET resultado = 'ERROR: La publicación no existe';
    ELSEIF v_modalidad != 'Subasta' THEN
        SET resultado = 'ERROR: La publicación no es una subasta';
    ELSE
        SELECT COUNT(DISTINCT comprador_id) INTO cant_ofertas
        FROM ofertas_subasta
        WHERE publicacion_id = idPublicacion;

        IF cant_ofertas = 0 THEN
            SET resultado = 'ERROR: La subasta no tuvo ninguna oferta';
        ELSE
            SELECT u.nombre AS usuario_ganador, u.email, pr.nombre AS nombre_producto, cant_ofertas,
				   p.precio_base AS valor_inicial, p.precio_actual AS valor_ganador
            FROM publicaciones p
            INNER JOIN productos pr ON p.producto_id = pr.producto_id
            INNER JOIN ofertas_subasta o ON p.publicacion_id = o.publicacion_id
            INNER JOIN usuarios u ON o.comprador_id = u.usuario_id
            WHERE pub.publicacion_id = idPublicacion
            ORDER BY o.monto_ofertado DESC, o.fecha_oferta ASC
            LIMIT 1;

            SET resultado = 'EXITO: Ganador obtenido correctamente';
        END IF;
    END IF;
end //


-- 7)
delimiter //
CREATE PROCEDURE crear_pregunta( IN idPublicacion INT, IN idUsuario_pregunta INT, IN v_pregunta TEXT, OUT resultado VARCHAR(255))
begin
    DECLARE v_estado VARCHAR(20);
    DECLARE idVendedor INT;

    SELECT estado, vendedor_id INTO v_estado, idVendedor
    FROM publicaciones
    WHERE publicacion_id = idPublicacion;

    IF v_estado IS NULL THEN
        SET resultado = 'ERROR: La publicación no existe';
    ELSEIF v_estado != 'Activa' THEN
        SET resultado = 'ERROR: La publicación no se encuentra activa';
    ELSEIF v_pregunta IS NULL OR v_pregunta = '' THEN
        SET resultado = 'ERROR: La pregunta no puede estar vacía';
    ELSEIF idUsuario_pregunta = idVendedor THEN
        SET resultado = 'ERROR: El vendedor no puede hacer preguntas en su propia publicación';
    ELSE
        INSERT INTO preguntas (publicacion_id, usuario_pregunta_id, pregunta)
        VALUES (idPublicacion, idUsuario_pregunta, v_pregunta);

        SET resultado = 'EXITO: Pregunta creada correctamente';
    END IF;
end //


-- 8)
delimiter //
CREATE PROCEDURE estadisticas_vendedor( IN idVendedor INT, OUT resultado VARCHAR(255))
begin
    DECLARE existe INT DEFAULT 0;

    SELECT COUNT(*) INTO existe
    FROM usuarios
    WHERE usuario_id = idVendedor;

    IF existe = 0 THEN
        SET resultado = 'ERROR: El usuario vendedor no existe';
    ELSE
        SELECT (SELECT COUNT(*)
				FROM publicaciones
				WHERE vendedor_id = idVendedor
                AND estado = 'Activa') AS publicaciones_activas,
               (SELECT COUNT(*)
				FROM publicaciones 
				WHERE vendedor_id = idVendedor
				AND estado = 'Finalizada') AS publicaciones_finalizadas,
               (SELECT COUNT(*)
				FROM transacciones
                WHERE vendedor_id = idVendedor
                AND es_concretada = TRUE) AS ventas_totales,
               (SELECT IFNULL(SUM(monto), 0.00)
				FROM transacciones
                WHERE vendedor_id = idVendedor
                AND es_concretada = TRUE) AS facturacion_total,
               (SELECT IFNULL(AVG(p.precio_actual), 0.00)
				FROM publicaciones p
                WHERE p.vendedor_id = idVendedor) AS precio_promedio_productos,
               (SELECT COUNT(*)
				FROM preguntas pr
                JOIN publicaciones p ON pr.publicacion_id = p.publicacion_id
                WHERE p.vendedor_id = idVendedor) AS preguntas_recibidas,
               (SELECT IFNULL(AVG(TIMESTAMPDIFF(DAY, p.fecha_inicio, t.fecha_transaccion)), 0)
               FROM publicaciones p
               JOIN transacciones t ON pub.publicacion_id = t.publicacion_id
               WHERE p.vendedor_id = idVendedor
               AND t.es_concretada = TRUE) AS tiempo_promedio_venta_dias;

        SET resultado = 'EXITO: Estadísticas generadas correctamente';
    END IF;
end //


-- 9)
delimiter //
CREATE PROCEDURE top_vendedores_mes( IN fecha_desde DATETIME, IN fecha_hasta DATETIME, OUT resultado VARCHAR(255))
begin
    IF fecha_desde > fecha_hasta THEN
        SET resultado = 'ERROR: La fecha inicial no puede ser mayor a la fecha final';
    ELSE
        SELECT u.usuario_id, u.nombre, u.email, COUNT(t.transaccion_id) AS cantidad_ventas, SUM(t.monto) AS facturacion_total
        FROM usuarios u
        JOIN transacciones t ON u.usuario_id = t.vendedor_id
        WHERE t.es_concretada = TRUE 
		AND t.fecha_transaccion BETWEEN fecha_desde AND fecha_hasta
        GROUP BY u.usuario_id, u.nombre, u.email
        ORDER BY cantidad_ventas DESC, facturacion_total DESC
        LIMIT 10;

        SET resultado = 'EXITO: Top 10 generado correctamente.';
    END IF;
end //
delimiter ;



-- VISTAS
-- 1)
CREATE VIEW preguntas_sin_respuesta AS
	SELECT pr.pregunta_id, pr.pregunta AS descripcion, p.publicacion_id, prod.nombre AS nombre_producto, u.nombre AS usuario_respondio
	FROM preguntas pr
	JOIN publicaciones p ON pr.publicacion_id = p.publicacion_id
	JOIN productos prod ON p.producto_id = prod.producto_id
	LEFT JOIN respuestas resp ON pr.pregunta_id = resp.pregunta_id
	LEFT JOIN usuarios u ON resp.usuario_respuesta_id = u.usuario_id
	WHERE p.estado = 'Activa' 
	AND resp.respuesta_id IS NULL;


-- 2)
CREATE VIEW top10_categorias_semana AS
	SELECT c.categoria_id, c.nombre, COUNT(p.publicacion_id) AS cantidad_publicaciones
	FROM categorias c
	JOIN productos prod ON c.categoria_id = prod.categoria_id
	JOIN publicaciones p ON prod.producto_id = p.producto_id
	WHERE p.fecha_inicio >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
	GROUP BY c.categoria_id, c.nombre
	ORDER BY cantidad_publicaciones DESC
	LIMIT 10;


-- 3)
CREATE VIEW publicaciones_tendencia AS
	SELECT p.publicacion_id, prod.nombre AS nombre_producto, COUNT(pr.pregunta_id) AS cantidad_preguntas
	FROM publicaciones p
	JOIN productos prod ON p.producto_id = prod.producto_id
	JOIN preguntas pr ON p.publicacion_id = pr.publicacion_id
	WHERE DATE(pr.fecha_pregunta) = CURRENT_DATE()
	GROUP BY p.publicacion_id, prod.nombre
	ORDER BY cantidad_preguntas DESC;


-- 4)
CREATE VIEW vendedor_mayor_reputacion_cat AS
	SELECT u.nombre AS nombre_vendedor, c.nombre AS nombre_categoria
	FROM categorias c
	JOIN productos prod ON c.categoria_id = prod.categoria_id
	JOIN publicaciones p ON prod.producto_id = p.producto_id
	JOIN usuarios u ON p.vendedor_id = u.usuario_id
	WHERE u.reputacion_actual = (
		SELECT MAX(u2.reputacion_actual)
		FROM publicaciones p2
		JOIN productos prod2 ON p2.producto_id = prod2.producto_id
		JOIN usuarios u2 ON p2.vendedor_id = u2.usuario_id
		WHERE prod2.categoria_id = c.categoria_id
	)
	GROUP BY c.categoria_id, c.nombre, u.usuario_id, u.nombre;
    
    

-- TRIGGERS
-- 1)
delimiter //
CREATE TRIGGER before_delete_pregunta BEFORE DELETE ON preguntas FOR EACH ROW
begin
    DELETE FROM respuestas WHERE pregunta_id = OLD.pregunta_id;
end //


-- 2)
delimiter //
CREATE TRIGGER after_insert_actualizar_nivel AFTER INSERT ON transacciones FOR EACH ROW
begin
    DECLARE idVendedor INT;

    IF NEW.es_concretada = TRUE THEN
        SET idVendedor = NEW.vendedor_id;
        CALL actualizar_nivel_usuario(idVendedor, @nuevo_nivel, @resultado);
    END IF;
end //


-- 3)
delimiter //
CREATE TRIGGER after_insert_reputacion AFTER INSERT ON calificaciones FOR EACH ROW
begin
    DECLARE idUsuario_evaluado INT;
    DECLARE promedio DECIMAL(5,2);

    SET idUsuario_evaluado = NEW.usuario_evaluado_id;

    SELECT AVG(puntaje) INTO promedio
    FROM calificaciones
    WHERE usuario_evaluado_id = idUsuario_evaluado;

    UPDATE usuarios SET reputacion_actual = (promedio * 100) / 5
    WHERE usuario_id = idUsuario_evaluado;
end //


-- 4)
delimiter //
CREATE TRIGGER before_insert_puja BEFORE INSERT ON ofertas_subasta FOR EACH ROW
begin
    DECLARE v_estado VARCHAR(20);
    DECLARE idVendedor INT;
    DECLARE v_precio_actual DECIMAL(15,2);
    DECLARE v_fecha_fin DATETIME;

    SELECT estado, vendedor_id, precio_actual, fecha_fin
    INTO v_estado, idVendedor, v_precio_actual, v_fecha_fin
    FROM publicaciones
    WHERE publicacion_id = NEW.publicacion_id;

    IF v_estado != 'Activa' OR v_fecha_fin < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La publicación se encuentra vencida o no está activa';
    ELSEIF NEW.comprador_id = idVendedor THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El vendedor no puede pujar en su propia subasta';
    ELSEIF NEW.monto_ofertado <= v_precio_actual THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El monto ofertado debe ser mayor al precio actual';
    END IF;
end //
delimiter ;



-- EVENTS
-- 1)
CREATE EVENT eliminar_publicaciones_pausadas ON SCHEDULE EVERY 1 WEEK DO
    DELETE FROM publicaciones
    WHERE estado = 'Pausada'
	AND fecha_inicio < DATE_SUB(NOW(), INTERVAL 90 DAY);


-- 2)
CREATE EVENT observar_publicaciones_sin_medio_pago ON SCHEDULE EVERY 1 DAY DO
    UPDATE publicaciones SET estado = 'Observada'
    WHERE estado = 'Activa'
	AND modalidad = 'Venta Directa'
    AND medio_pago_id IS NULL;


-- 3)
CREATE EVENT notificar_preguntas_sin_responder ON SCHEDULE EVERY 1 DAY STARTS (TIMESTAMP(CURDATE(), '10:00:00')) DO
    INSERT INTO notificaciones (usuario_id, mensaje, fecha_envio)
    SELECT p.vendedor_id, CONCAT('La publicación sobre ', prod.nombre, ' tiene ', COUNT(preg.pregunta_id), ' preguntas sin responder'), NOW()
    FROM preguntas pr
    JOIN publicaciones p ON pr.publicacion_id = p.publicacion_id
    JOIN productos prod ON p.producto_id = prod.producto_id
    LEFT JOIN respuestas resp ON pr.pregunta_id = resp.pregunta_id
    WHERE resp.respuesta_id IS NULL
	AND p.estado = 'Activa'
    GROUP BY p.vendedor_id, p.publicacion_id, prod.nombre;


-- 4)
CREATE EVENT generar_estadisticas_diarias ON SCHEDULE EVERY 1 DAY STARTS (TIMESTAMP(CURDATE(), '00:00:00')) DO
    INSERT INTO estadisticas_diarias (fecha, total_vendedores_activos, total_compradores_activos, total_productos_vendidos, facturacion_dia)
    SELECT CURDATE(), COUNT(DISTINCT vendedor_id), COUNT(DISTINCT comprador_id), COUNT(transaccion_id), SUM(monto)
    FROM transacciones
    WHERE es_concretada = TRUE
	AND DATE(fecha_transaccion) = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
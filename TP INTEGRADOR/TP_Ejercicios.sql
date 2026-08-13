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

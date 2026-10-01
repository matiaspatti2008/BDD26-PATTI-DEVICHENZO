USE examen2;

#1-
-- Crear un Stored Procedure que, dado un empleado, muestre el porcentaje de piezas defectuosas en el día de hoy.
delimiter //
CREATE PROCEDURE Piezas_Defectuosas(in idEmp int, out porcentaje float)
BEGIN
	SELECT (SUM(do.defectuosos) * 100 / SUM(do.cantidad)) INTO porcentaje
    FROM DetalleOrden do
    JOIN OrdenProduccion op ON do.id_orden = op.id_orden
    WHERE op.id_empleado = idEmp
    AND op.fecha = CURRENT_DATE();
END //
delimiter ;

call Piezas_Defectuosas(3, @PORCENTAJE);
select @PORCENTAJE;



#2-
-- Crear un Stored Procedure que actualice el reporte de los empleados que tuvieron órdenes para el día de hoy.
-- Si no existe un reporte para ese empleado hay que crearlo. Utilizar cursores.
delimiter //
CREATE PROCEDURE Actualizar_Reporte()
begin
    declare v_id_empleado INT;
    declare v_producido_hoy INT;
    declare v_defectuosos_hoy INT;
    declare fin_cursor INT DEFAULT 0;
    declare v_existe_reporte INT;

    declare cursor_produccion cursor for
        SELECT op.id_empleado, SUM(do.cantidad), SUM(do.defectuosos)
        FROM DetalleOrden do
        INNER JOIN OrdenProduccion op ON do.id_orden = op.id_orden
        WHERE op.fecha = CURDATE()
        GROUP BY op.id_empleado;
    declare continue handler for NOT FOUND SET fin_cursor = 1;
    OPEN cursor_produccion;
    bucle_reporte: LOOP
        FETCH cursor_produccion INTO v_id_empleado, v_producido_hoy, v_defectuosos_hoy;
        IF fin_cursor = 1 THEN
            LEAVE bucle_reporte;
        END IF;

        SELECT COUNT(*) INTO v_existe_reporte 
        FROM ReporteProduccion 
        WHERE id_empleado = v_id_empleado;

        IF v_existe_reporte > 0 THEN
            UPDATE ReporteProduccion
            SET total_producido = total_producido + v_producido_hoy,
                total_defectuosos = total_defectuosos + v_defectuosos_hoy
            WHERE id_empleado = v_id_empleado;
        ELSE
            INSERT INTO ReporteProduccion (id_empleado, total_producido, total_defectuosos)
            VALUES (v_id_empleado, v_producido_hoy, v_defectuosos_hoy);
        END IF;
    END LOOP bucle_reporte;
    CLOSE cursor_produccion;
end //
delimiter ;

call Actualizar_Reporte();



#3-
-- Crear un Stored Procedure que devuelva, en un parámetro de salida, los nombres de los productos
-- que no se han revisado en el último año y el año en que fueron revisados por última vez.
-- Si no se revisaron nunca indicar “-sin revisión-”. Utilizar cursores.
delimiter //
CREATE PROCEDURE Productos_Sin_Revision(out productos text)
begin
    declare nombreProd varchar(100);
    declare ultimoAnio varchar(20);
    declare fin_cursor int;
    declare lista_productos TEXT DEFAULT '';

    declare cursorRevision cursor for
        SELECT p.nombre, 
               IFNULL(YEAR(MAX(op.fecha)), '-sin revisión-') AS ultimo_Anio
        FROM Producto p
        LEFT JOIN DetalleOrden do ON p.id_producto = do.id_producto
        LEFT JOIN OrdenProduccion op ON do.id_orden = op.id_orden
        WHERE p.requiere_revision = 1
        GROUP BY p.id_producto, p.nombre
        HAVING MAX(op.fecha) < (CURRENT_DATE() - INTERVAL 1 YEAR) 
		OR MAX(op.fecha) IS NULL;
    declare continue handler for NOT FOUND SET fin_cursor = 0;
    OPEN cursorRevision;
    bucle_revision: LOOP
        FETCH cursorRevision INTO nombreProd, ultimoAnio;
        IF fin_cursor = 0 THEN
            LEAVE bucle_revision;
        END IF;

        SET lista_productos = CONCAT(lista_productos, 'Producto: ', nombreProd, ' | Último Año: ', ultimoAnio, CHAR(10));
    END LOOP bucle_revision;
    CLOSE cursorRevision;

    IF lista_productos = '' THEN
        SET productos = 'Todos los productos obligatorios han sido revisados en el último año.';
    ELSE
        SET productos = lista_productos;
    END IF;
end //
delimiter ;

call Productos_Sin_Revision (@productos);
SELECT @productos;



#4-
-- Crear un stored procedure que devuelva el id del producto con mayor porcentaje de no defectuosos el día de hoy.
-- No confundir cantidad de no defectuosos con porcentaje de no defectuosos.
delimiter //
CREATE PROCEDURE Producto_Mas_Eficiente(out idProd_max int)
BEGIN
    SET idProd_max = NULL;

    SELECT do.id_producto INTO idProd_max
    FROM DetalleOrden do
    JOIN OrdenProduccion op ON do.id_orden = op.id_orden
    WHERE op.fecha = CURRENT_DATE()
    GROUP BY do.id_producto
    HAVING SUM(do.cantidad) > 0
    ORDER BY ((SUM(do.cantidad) - SUM(do.defectuosos)) * 100) / SUM(do.cantidad) DESC
    LIMIT 1;
end //
delimiter ;

call Producto_Mas_Eficiente(@prod_max);
SELECT @prod_max;
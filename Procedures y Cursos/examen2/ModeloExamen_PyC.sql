USE examen2;

#1-
-- Crear un Stored Procedure que, dado un empleado, muestre el porcentaje de piezas
-- defectuosas en el día de hoy.
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

call Piezas_Defectuosas(5, @PORCENTAJE);
select @PORCENTAJE;



#2-
-- Crear un Stored Procedure que actualice el reporte de los empleados que tuvieron órdenes
-- para el día de hoy. Si no existe un reporte para ese empleado hay que crearlo. Utilizar cursores.




#3-
-- Crear un Stored Procedure que devuelva, en un parámetro de salida, los nombres de los productos
-- que no se han revisado en el último año y el año en que fueron revisados por última vez.
-- Si no se revisaron nunca indicar “-sin revisión-”. Utilizar cursores.




#4-
-- Crear un stored procedure que devuelva el id del producto con mayor porcentaje de no defectuosos
-- el día de hoy. No confundir cantidad de no defectuosos con porcentaje de no defectuosos.

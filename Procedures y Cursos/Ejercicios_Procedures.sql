USE classicmodels;

#1.
-- Crear un SP que liste todos los productos que tengan un precio de compra mayor al precio
-- promedio y que devuelva la cantidad de productos que cumplan con esa condición.
delimiter //
CREATE PROCEDURE PRECIO_MAYOR_AL_PROMEDIO(out cantidad_Prod int)
begin
	declare promedio float;
    SELECT AVG(p.buyPrice) INTO promedio FROM products p;

	SELECT COUNT(*) INTO cantidad_Prod FROM products p
    WHERE p.buyPrice > promedio;
end //
delimiter ;

call PRECIO_MAYOR_AL_PROMEDIO (@cantidad_de_productos);
SELECT @cantidad_de_productos;



#2.
-- Crear un SP que reciba un orderNumber y la borre. Previamente debe eliminar todos los
-- ítems de la tabla orderDetails asociados a él. Tiene que devolver 0 si no encontró filas para
-- ese orderNumber, o la cantidad ítems borrados si encontró el orderNumber.
delimiter //
CREATE PROCEDURE BORRAR_ORDEN(in numeroOrden int, out colAfectadas int)
begin
	SELECT 0 INTO colAfectadas;
	
	DELETE FROM orderdetails
	WHERE orderNumber = numeroOrden;

	SELECT ROW_COUNT() INTO colAfectadas;

	DELETE FROM orders 
	WHERE orderNumber = numeroOrden;
end //
delimiter ;

call BORRAR_ORDEN(10179, @afected_Rows);
SELECT @afected_Rows AS Filas_Eliminadas;


#3.
-- Crear un SP que borre una línea de productos de la tabla Productlines. Tenga en cuenta que
-- la línea de productos no podrá ser borrada si tiene productos asociados. El procedure debe
-- devolver un mensaje que contenga una de las siguientes leyendas:
-- “La línea de productos fue borrada”
-- “La línea de productos no pudo borrarse porque contiene productos asociados”.
-- Utilizar la función del punto 4.



#4.
-- Realizar un SP que liste la cantidad de órdenes que hay por estado.



#5.
-- Realice un SP que liste para cada empleado con gente subordinada, cuántos empleados tiene a cargo.



#6.
-- Realice un SP que liste el número de orden y su precio total.



#7.
-- Crear un SP que liste el número de cliente y nombre, junto con las órdenes asociadas a ese
-- cliente y el total por orden.



#8.
-- Realizar un SP que modifique el campo comments de la tabla orders. El procedimiento
-- recibe un orderNumber y el comentario. El procedimiento devuelve 1 si se encontró la
-- orden y se modificó, y 0 en caso contrario.

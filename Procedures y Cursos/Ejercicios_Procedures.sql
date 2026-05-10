USE classicmodels;

#1
-- Crear un SP que liste todos los productos que tengan un precio de compra mayor al precio
-- promedio y que devuelva la cantidad de productos que cumplan con esa condición
delimiter //
CREATE PROCEDURE Productos_Mayor(out cantidad int)
begin
	SELECT COUNT(*) INTO cantidad
    FROM products
    WHERE buyPrice > 
		( SELECT AVG(buyPrice)
		  FROM products );
end//
delimiter ;

call Productos_Mayor(@cantidad);
SELECT @cantidad;



#2.
-- Crear un SP que reciba un orderNumber y la borre. Previamente debe eliminar todos los ítems de la tabla orderDetails asociados a él.
-- Tiene que devolver 0 si no encontró filas para ese orderNumber, o la cantidad ítems borrados si encontró el orderNumber
delimiter //
CREATE PROCEDURE Eliminar_Orden(in nOrden int, out cantidad int)
begin
	SET cantidad = (
		SELECT COUNT(*)
        FROM orderdetails
        WHERE orderNumber = nOrden);
        
	IF (cantidad = 0) THEN
		SET cantidad = 0;
	ELSE
		DELETE FROM orderdetails
        WHERE orderNumber = nOrden;
        DELETE FROM orders
        WHERE orderNumber = nOrden;
	END IF;
end //
delimiter ;

call Eliminar_Orden(10117, @cant);
SELECT @cant AS cantidad_items_borrados;



#3.
-- Crear un SP que borre una línea de productos de la tabla Productlines. Tenga en cuenta que
-- la línea de productos no podrá ser borrada si tiene productos asociados. El procedure debe
-- devolver un mensaje que contenga una de las siguientes leyendas:
-- “La línea de productos fue borrada”
-- “La línea de productos no pudo borrarse porque contiene productos asociados”.
-- Utilizar la función del punto 4.
delimiter //
CREATE PROCEDURE Eliminar_LineaProducto(in linea varchar(50), out leyenda varchar(100))
begin
	DECLARE cantProductos int;
    SELECT STOCK(linea) INTO cantProductos;
    
    IF (cantProductos = 0) THEN
		DELETE FROM productLines
        WHERE productLine = linea;
		SET leyenda = "La línea de productos fue borrada";
	ELSE
		SET leyenda = "La línea de productos no pudo borrarse porque contiene productos asociados";
	END IF;
end //
delimiter ;

-- Ejemplo que borra
INSERT INTO productlines(productLine, textDescription) VALUE ("Barcos de papel", "Son barquitos de papel de gran calidad");
call Eliminar_LineaProducto("Barcos de papel", @leyenda);
SELECT @leyenda AS mensaje;

-- Ejemplo que no borra
call Eliminar_LineaProducto("Classic Cars", @leyenda);
SELECT @leyenda AS mensaje;



#4.
-- Realizar un SP que liste la cantidad de órdenes que hay por estado.
delimiter //
CREATE PROCEDURE Ordenes_porEstado()
begin
	SELECT status, COUNT(*)
    FROM orders
    GROUP BY status;
end //
delimiter ;

call Ordenes_porEstado();



#5.
-- Realice un SP que liste para cada empleado con gente subordinada, cuántos empleados tiene a cargo.
delimiter //
CREATE PROCEDURE Cantidad_Empleados_a_Cargo()
begin
	SELECT e.employeeNumber AS Numero_empleado,
		   CONCAT(e.firstName, " ", e.lastName) AS empleado,
           COUNT(r.employeeNumber) AS cantidad_subordinados
	FROM employees e
    JOIN employees r ON e.employeeNumber = r.reportsTo
    GROUP BY e.employeeNumber;
end //
delimiter ;

call Cantidad_Empleados_a_Cargo();



#6.
-- Realice un SP que liste el número de orden y su precio total.
delimiter //
CREATE PROCEDURE Orden_Precio_Total()
begin
	SELECT orderNumber AS Numero_orden,
		   SUM(quantityOrdered * priceEach) as Precio_total
    FROM orderdetails
    GROUP BY Numero_orden;
end //
delimiter ;

call Orden_Precio_Total();



#7.
-- Crear un SP que liste el número de cliente y nombre, junto con las órdenes asociadas a ese cliente y el total por orden.
delimiter //
CREATE PROCEDURE Cliente_Ordenes_Total()
begin
	SELECT c.customerNumber AS Numero_cliente,
		   c.customerName AS Nombre,
           o.orderNumber AS Numero_orden,
           SUM(od.quantityOrdered * od.priceEach) AS total_orden
	FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY Numero_cliente, Nombre, Numero_orden;
end //
delimiter ;

call Cliente_Ordenes_Total();



#8.
-- Realizar un SP que modifique el campo comments de la tabla orders. El procedimiento recibe un orderNumber y el comentario.
-- El procedimiento devuelve 1 si se encontró la orden y se modificó, y 0 en caso contrario.
delimiter //
CREATE PROCEDURE Modificar_Comment(in nOrden int, in comentario text, out funciona bool)
begin 
	IF EXISTS (
		SELECT orderNumber FROM orders
        WHERE orderNumber = nOrden ) THEN
			
		UPDATE orders
        SET comments = comentario
        WHERE orderNumber = nOrden;
        SET funciona = true;
	
    ELSE
		SET funciona = false;
	END IF;
end //
delimiter ;

-- Ejemplo que 'funciona'
call Modificar_Comment(10104, "Buena calidad", @funciona);
SELECT @funciona;

-- Ejemplo que 'no funciona'
call Modificar_Comment(202, "Buena calidad", @funciona);
SELECT @funciona;
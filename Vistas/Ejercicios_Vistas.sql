USE classicmodels;

#1
-- Crear una vista que muestre para todas las órdenes, los códigos de producto que la componen, indicando del producto:
-- código, nombre, descripción, cantidad ordenada, precio unitario y el precio total por producto.
CREATE VIEW Detalles_Ordenes AS
	SELECT od.orderNumber AS NUMERO_DE_ORDEN,
		   p.productCode AS CODIGO_PRODUCTO,
           p.productName AS NOMBRE_PRODUCTO,
           p.productDescription AS DESCRIPCION,
           od.quantityOrdered AS CANTIDAD_ORDENADO,
           od.priceEach AS PRECIO_INDIVIDUAL,
           (od.quantityOrdered * od.priceEach) AS PRECIO_TOTAL
	FROM orderdetails od
    JOIN products p ON od.productCode = p.productCode
    ORDER BY od.orderNumber ASC;
    
    SELECT * FROM Detalles_Ordenes;



#2
-- Crear una vista que muestre el total por orden.




#3
-- Crear una vista que liste todos los productos que tengan precio mayor al precio promedio.




#4
-- Crear una vista que liste todos los productos con precio menor al precio promedio.




#5
-- Crear una vista que liste para todas las oficinas, el código de oficina y la ciudad junto con el código de empleado y nombre y apellido de estos,
-- ordenado por código de oficina y código de empleado.




#6
-- Crear una vista que refleje todos los clientes que aún no hayan registrado pagos.




#7
-- Crear una vista que liste todas las órdenes para todos los clientes.




#8
-- Crear una vista que liste para cada cliente: el número de cliente y el nombre, el número y fecha de orden de todas las órdenes del cliente,
-- y de cada orden el código de producto, la cantidad ordenada, el precio y nombre del producto.




#9
-- Crear una vista que muestre la cantidad de productos que hay por cada línea de producto.




#10
-- Crear una vista que liste el nombre, el teléfono y la dirección de los clientes que hicieron una compra hace más de 2 años y de más de $30000.




#11
-- Crear una vista que muestre todas las órdenes que se entregaron con demora o aquellas que no se llegaron a entregar.




#12
-- Crear una vista que seleccione las oficinas que no tienen asignadas a ningún empleado.




#13
-- Crear una vista que muestre el cliente que compró más productos históricamente.



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
CREATE VIEW PrecioTotal_Por_Orden AS
	SELECT od.orderNumber AS NUMERO_DE_ORDEN,
		   SUM(od.quantityOrdered * od.priceEach) AS TOTAL
	FROM orderdetails od
    GROUP BY NUMERO_DE_ORDEN;

SELECT * FROM PrecioTotal_Por_Orden;



#3
-- Crear una vista que liste todos los productos que tengan precio mayor al precio promedio.
CREATE VIEW Precio_Mayor_Al_Promedio AS
	SELECT p.productName AS NOMBRE_PRODUCTO,
		   p.buyPrice AS PRECIO
	FROM products p
    WHERE p.buyPrice > (
		SELECT AVG(p1.buyPrice) AS PROMEDIO
        FROM products p1 );

SELECT * FROM Precio_Mayor_Al_Promedio;



#4
-- Crear una vista que liste todos los productos con precio menor al precio promedio.
CREATE VIEW Precio_Menor_Al_Promedio AS
	SELECT p.productName AS NOMBRE_PRODUCTO,
		   p.buyPrice AS PRECIO
	FROM products p
    WHERE p.buyPrice < (
		SELECT AVG(p1.buyPrice) AS PROMEDIO
        FROM products p1 );

SELECT * FROM Precio_Menor_Al_Promedio;



#5
-- Crear una vista que liste para todas las oficinas, el código de oficina y la ciudad junto con el código de empleado y nombre y apellido de estos,
-- ordenado por código de oficina y código de empleado.
CREATE VIEW Oficinas_Y_Empleados AS
	SELECT o.officeCode AS CODIGO_OFICINA,
		   o.city AS CIUDAD,
		   e.employeeNumber AS CODIGO_EMPLEADO,
           CONCAT(e.firstName, " ", lastName) AS EMPLEADO
	FROM offices o
	JOIN employees e ON o.officeCode = e.officeCode
	ORDER BY CODIGO_OFICINA, CODIGO_EMPLEADO;

SELECT * FROM Oficinas_Y_Empleados;



#6
-- Crear una vista que refleje todos los clientes que aún no hayan registrado pagos.
CREATE VIEW Clientes_Sin_Pagos AS
	SELECT c.customerNumber AS NUMERO_CLIENTE,
		   c.customerName AS NOMBRE_CLIENTE
	FROM customers c
    WHERE NOT EXISTS (
		SELECT 1
        FROM payments p
        WHERE p.customerNumber = c.customerNumber);

SELECT * FROM Clientes_Sin_Pagos;



#7
-- Crear una vista que liste todas las órdenes para todos los clientes.
CREATE VIEW Ordenes_Clientes AS
	SELECT c.customerNumber AS CODIGO_CLIENTE,
		   c.customerName AS NOMBRE_CLIENTE,
           ord.orderNumber AS NUMERO_ORDEN
	FROM customers c
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    ORDER BY CODIGO_CLIENTE;
    
SELECT * FROM Ordenes_Clientes;



#8
-- Crear una vista que liste para cada cliente: el número de cliente y el nombre, el número y fecha de orden de todas las órdenes del cliente,
-- y de cada orden el código de producto, la cantidad ordenada, el precio y nombre del producto.
CREATE OR REPLACE VIEW Cliente_Orden_Producto AS
	SELECT c.customerNumber AS NUMERO_CLIENTE,
		   c.customerName AS NOMBRE_CLIENTE,
           ord.orderNumber AS NUMERO_ORDEN,
           ord.orderDate AS FECHA_ORDEN,
           od.productCode AS CODIGO_PRODUCTO,
		   p.productName AS NOMBRE_PRODUCTO,
		   p.buyPrice AS PRECIO_PRODUCTO,
		   od.quantityOrdered AS CANTIDAD_ORDENADO
	FROM customers c
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.OrderNumber
    JOIN products p ON od.productCode = p.productCode
    ORDER BY NUMERO_CLIENTE, NUMERO_ORDEN, CODIGO_PRODUCTO;
    
SELECT * FROM Cliente_Orden_Producto;



#9
-- Crear una vista que muestre la cantidad de productos que hay por cada línea de producto.
CREATE VIEW Cantidad_Por_Linea AS
	SELECT p.productLine AS LINEA_PRODUCTO,
		   SUM(p.quantityInStock) AS CANTIDAD_DISPONIBLE
	FROM products p
    GROUP BY LINEA_PRODUCTO;
    
SELECT * FROM Cantidad_Por_Linea;



#10
-- Crear una vista que liste el nombre, el teléfono y la dirección de los clientes que hicieron una compra hace más de 2 años y de más de $30000.
CREATE VIEW Clientes_Compra AS
	SELECT c.customerName AS NOMBRE_CLIENTE,
		   c.phone AS TELEFONO_CLIENTE,
           c.addressLine1 AS DIRECCION_CLIENTE
	FROM customers c
    WHERE c.customerNumber IN (
		SELECT p.customerNumber
        FROM payments p
        WHERE TIMESTAMPDIFF(YEAR, p.paymentDate, CURRENT_DATE()) > 2
        AND p.amount > 30000)
	ORDER BY NOMBRE_CLIENTE;

SELECT * FROM Clientes_Compra;



#11
-- Crear una vista que muestre todas las órdenes que se entregaron con demora o aquellas que no se llegaron a entregar.
CREATE VIEW  Demora_Y_No_Entregados AS
	SELECT *
    FROM orders
    WHERE shippedDate > requiredDate
    OR shippedDate IS NULL; 
    
SELECT * FROM Demora_Y_No_Entregados;



#12
-- Crear una vista que seleccione las oficinas que no tienen asignadas a ningún empleado.
CREATE VIEW Oficinas_Sin_Empleados AS
	SELECT *
    FROM offices o
    WHERE officeCode NOT IN (
		SELECT e.officeCode
        FROM employees e );
        
SELECT * FROM Oficinas_Sin_Empleados;



#13
-- Crear una vista que muestre el cliente que compró más productos históricamente.
CREATE VIEW Cliente_Historico AS
	SELECT c.customerNumber AS NUMERO_CLIENTE,
		   c.customerName AS NOMBRE_CLIENTE,
           SUM(od.quantityOrdered) AS CANTIDAD_TOTAL
    FROM customers c
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.orderNumber
    GROUP BY NUMERO_CLIENTE, NOMBRE_CLIENTE
    ORDER BY CANTIDAD_TOTAL DESC
    LIMIT 1;
    
SELECT * FROM Cliente_Historico;
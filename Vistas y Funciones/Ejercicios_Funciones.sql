USE classicmodels;

#1)
-- Crear una función que devuelva la cantidad de órdenes con determinado estado en el rango de dos fechas (orderDate).
-- La función recibe por parámetro las fechas desde, hasta y el estado.
delimiter //
CREATE FUNCTION ORDENES_ESPECIFICAS(desde date, hasta date, estado varchar(15)) returns int deterministic
begin
	declare cantOrdenes int default 0;
    SELECT COUNT(*) INTO cantOrdenes FROM orders o WHERE estado = o.status AND o.orderDate BETWEEN desde AND hasta;
    return cantOrdenes;
end//
delimiter ;

SELECT ORDENES_ESPECIFICAS("2003-2-20", "2003-10-8", "Shipped");



#2)
-- Crear una función que reciba por parámetro dos fechas de envío (shippedDate) desde, hasta y devuelve la cantidad de órdenes entregadas.
delimiter //
CREATE FUNCTION ORDENES_ENTREGADAS(desde date, hasta date) returns int deterministic
begin
	declare cantEntregado int default 0;
    SELECT COUNT(*) INTO cantEntregado FROM orders o WHERE o.shippedDate BETWEEN desde AND hasta;
    return cantEntregado;
end//
delimiter ;

SELECT ORDENES_ENTREGADAS("2004-11-15", "2005-4-28");



#3)
-- Crear una función que reciba un número de cliente y devuelva la ciudad a la que corresponde el empleado que lo atiende.
delimiter //
CREATE FUNCTION CIUDAD_DEL_EMPLEADO(numCliente int) returns varchar(30) deterministic
begin
    declare ciudad varchar(30);
    SELECT o.city INTO ciudad
    FROM customers c 
    JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
    JOIN offices o ON e.officeCode = o.officeCode
    WHERE c.customerNumber = numCliente;
    return ciudad;
end//
delimiter ;

SELECT CIUDAD_DEL_EMPLEADO(121);



#4)
-- Crear una función que reciba una productline y devuelva la cantidad de productos existentes en esa línea de producto.
delimiter //
CREATE FUNCTION STOCK(pLinea varchar(30)) returns int deterministic
begin
	declare cantDispo int default 0;
    SELECT SUM(p.quantityInStock) INTO cantDispo
    FROM products p
    WHERE p.productLine = pLinea
    GROUP BY pLinea;
    return cantDispo;
end//
delimiter ;

SELECT STOCK("Classic Cars");



#5)
-- Crear una función que reciba un officeCode y devuelva la cantidad de clientes que tiene la oficina.
delimiter //
CREATE FUNCTION CANTIDAD_CLIENTES(codigoOf int) returns int deterministic
begin
	declare cantClientes int default 0;
    SELECT COUNT(*) INTO cantClientes
    FROM customers c
    JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
    WHERE e.officeCode = codigoOf
    GROUP BY codigoOf;
    return cantClientes;
end//
delimiter ;

SELECT CANTIDAD_CLIENTES(3);



#6)
-- Crear una función que reciba un officeCode y devuelva la cantidad de órdenes que se hicieron en esa oficina.
delimiter //
CREATE FUNCTION CANTIDAD_ORDENES(codigoOf int) returns int deterministic
begin
	declare cantOrdenes int default 0;
    SELECT COUNT(*) INTO cantOrdenes
    FROM orders ord
    JOIN customers c ON ord.customerNumber = c.customerNumber
    JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
    WHERE e.officeCode = codigoOf
    GROUP BY codigoOf;
    return cantOrdenes;
end//
delimiter ;

SELECT CANTIDAD_ORDENES(3);



#7)
-- Crear una función que reciba un nro de orden y un nro de producto, y devuelva el beneficio obtenido con ese producto.
-- El beneficio debe calcularse como priceEach – buyPrice.
delimiter //
CREATE FUNCTION BENEFICIO_OBTENIDO(nOrden int, nProducto varchar(15)) returns decimal(10,2) deterministic
begin
	declare beneficio decimal(10,2);
    SELECT (od.priceEach - p.buyPrice) INTO beneficio
    FROM orderdetails od
	JOIN products p ON od.productCode = p.productCode
    WHERE od.orderNumber = nOrden
    AND p.productCode = nProducto;
	return beneficio;
end//
delimiter ;

SELECT BENEFICIO_OBTENIDO(10112, "S10_1949");



#8)
-- Crear una función que reciba un orderNumber y si el mismo está en estado cancelado devuelva -1, sino 0.
delimiter //
CREATE FUNCTION CANCELADO(nOrden int) returns int deterministic
begin
	declare estado varchar(15);
	declare resultado int;
    SELECT status INTO estado FROM orders WHERE orderNumber = nOrden;
    if estado = "Cancelled" then
		SET resultado = -1;
	else
		SET resultado = 0;
    end if;
    return resultado;
end//
delimiter ;

SELECT CANCELADO(10167);
SELECT CANCELADO(10112);



#9)
-- Crear una función que devuelva la fecha de la primera orden hecha por ese cliente. Recibe el nro de cliente por parámetro.
delimiter //
CREATE FUNCTION PRIMERA_COMPRA(nCliente int) returns date deterministic
begin
	declare fecha date;
    SELECT MIN(o.orderDate) INTO fecha
    FROM orders o
    WHERE o.customerNumber = nCliente;
    return fecha;
end//
delimiter ;

SELECT PRIMERA_COMPRA(187);



#10)
-- La columna MSRP en la tabla de productos significa manufacturer's suggested retail price (precio de venta sugerido por el fabricante).
-- Crear una SF que reciba un código de producto y devuelva el porcentaje de veces que el producto se vendió por debajo de dicho precio.
delimiter //
CREATE FUNCTION PORCENTAJE_MSRP(cProducto varchar(15)) returns decimal(10,2) deterministic
begin
	declare valorMSRP decimal(10,2);
    declare ventaTotal int;
    declare ventaMenorMSRP int;
    declare porcentaje decimal(10,2);
    
    SELECT p.MSRP INTO valorMSRP
    FROM products p
    WHERE p.productCode = cProducto;
    
    SELECT COUNT(*) INTO ventaTotal
    FROM orderdetails o
    WHERE o.productCode = cProducto;
    
    SELECT COUNT(*) INTO ventaMenorMSRP
    FROM orderdetails o
    WHERE o.productCode = cProducto
    AND o.priceEach < valorMSRP;
    
    if ventaTotal > 0 then
		SET porcentaje = (ventaMenorMSRP * 100) / ventaTotal;
	end if;
    return porcentaje;
end//
delimiter ;

SELECT PORCENTAJE_MSRP("S18_4409");



#11)
-- Crear una función que reciba un código de producto y devuelva la última fecha en la que fue pedido el mismo.
delimiter //
CREATE FUNCTION ULTIMO_PEDIDO(cProducto varchar(15)) returns date deterministic
begin
	declare fecha date;
    SELECT MAX(o.orderDate) INTO fecha
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE od.productCode = cProducto;
	return fecha;
end//
delimiter ;

SELECT ULTIMO_PEDIDO("S12_3148");



#12)
-- Crear una SF que reciba dos fechas desde, hasta y un código de producto. Si el producto fue ordenado en alguna orden 
-- entre esas fechas que devuelva el mayor precio. Si el producto no fue ordenado en esas fechas que devuelva 0.
delimiter //
CREATE FUNCTION PRODUCTO_FECHAS(desde date, hasta date, cProducto varchar(15)) returns decimal(10,2) deterministic
begin
	declare precioMayor decimal(10,2);
    SELECT MAX(priceEach) INTO precioMayor
    FROM orderdetails od
    JOIN orders o ON od.orderNumber = o.orderNumber
    WHERE od.productCode = cProducto
    AND o.orderDate BETWEEN desde AND hasta;
    
    if precioMayor IS NULL then
		return 0;
	else
		return precioMayor;
	end if;
end//
delimiter ;

SELECT PRODUCTO_FECHAS("2003-05-29", "2003-07-15", "S18_2949");
SELECT PRODUCTO_FECHAS("2004-08-20", "2004-11-28", "S18_2949");


#13)
-- Crear una SF que reciba el número de empleado y devuelva la cantidad de clientes que atiende.
delimiter //
CREATE FUNCTION ...() returns ... deterministic
begin



end//
delimiter ;

SELECT ...();



#14)
-- Crear una SF que reciba un número de empleado y devuelva el apellido del empleado al que reporta.
delimiter //
CREATE FUNCTION ...() returns ... deterministic
begin



end//
delimiter ;

SELECT ...();
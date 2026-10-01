USE classicmodels;

#9
-- Crear un SP que utilice un cursor para recorrer la tabla de offices y que genere una lista con las ciudades en las cuales hay oficinas.
-- La lista tendrá que devolverse en un parámetro de salida VARCHAR(4000) que contenga todas las ciudades separadas por coma.
-- getCiudadesOffices()
delimiter //
CREATE PROCEDURE getCiudadesOffices(out listaCiudades varchar(4000))
begin
	declare hayFilas int;
    declare ciudad varchar(75);
    declare ciudadCursor cursor for SELECT city FROM offices;
    declare continue handler for NOT FOUND set hayFilas = 0;
    SET listaCiudades = "";
    OPEN ciudadCursor;
    bucleCiudad:LOOP
		FETCH ciudadCursor INTO ciudad;
        IF hayFilas = 0 THEN
			LEAVE bucleCiudad;
		END IF;
		SET listaCiudades = CONCAT(ciudad, ", ", listaCiudades);
	END LOOP bucleCiudad;
    CLOSE ciudadCursor;
end //
delimiter ;

call getCiudadesOffices(@listaCiudades);
SELECT @listaCiudades;



#10
-- Agregar una tabla llamada CancelledOrders con el mismo diseño que la tabla de Orders.
-- Crear un SP que recorra la tabla de orders y que cuente la cantidad de órdenes en estado cancelled.
-- El procedimiento debe insertar una fila en la tabla CancelledOrders por cada orden cancelada y tiene que devolver la cantidad de órdenes canceladas.
-- insertCancelledOrders()
CREATE TABLE CancelledOrders (
	orderNumber INT PRIMARY KEY NOT NULL,
	orderDate DATE NOT NULL,
	requiredDate DATE NOT NULL,
	shippedDate DATE,
	status VARCHAR(15),
	comments TEXT,
	customerNumber INT NOT NULL,
	FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber), 
	FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

delimiter //
CREATE PROCEDURE insertCancelledOrders(out cantCancelled int)
begin
	declare orderNumber_v int;
    declare orderDate_v date;
    declare requiredDate_v date;
    declare shippedDate_v date;
    declare status_v varchar(15);
    declare comments_v text;
    declare customerNumber_v int;
    declare contador int default 0;
    declare hayOrdenes int;
    
	declare ordenesCursor cursor for SELECT * FROM orders WHERE status = 'Cancelled';
    declare continue handler for NOT FOUND SET hayOrdenes = 0;
    OPEN ordenesCursor;
    bucleOrdenes:LOOP
		FETCH ordenesCursor INTO orderNumber_v, orderDate_v, requiredDate_v, shippedDate_v, status_v, comments_v, customerNumber_v;
        IF hayOrdenes = 0 THEN
			LEAVE bucleOrdenes;
		END IF;
        INSERT INTO cancelledorders(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
        VALUES (orderNumber_v, orderDate_v, requiredDate_v, shippedDate_v, status_v, comments_v, customerNumber_v);
        SET contador = contador + 1;
	END LOOP bucleOrdenes;
    CLOSE ordenesCursor;
    
    SELECT contador INTO cantCancelled;
end //
delimiter ;

call insertCancelledOrders(@cantidad);
SELECT @cantidad AS cantidad_ordenes_canceladas; 



#11
-- Realizar un SP que reciba el customerNumber y para todas las órdenes de ese customerNumber, si el campo comments esta vacío que lo complete con
-- el siguiente comentario: “El total de la orden es … “ Y el total de la orden tendrá que calcularlo el procedimiento sumando
-- todos los productos incluidos en la orden de la tabla OrderDetails.
-- alterCommentOrder()
delimiter //
CREATE PROCEDURE alterCommentOrder(in numCliente int)
begin
	declare numOrden int;
    declare totalOrden decimal(10,2);
    declare hayOrdenes int;

    declare numOrdenCursor cursor for SELECT orderNumber FROM orders WHERE customerNumber = numCliente AND comments IS NULL;
    declare continue handler for NOT FOUND SET hayOrdenes = 0;
    
    OPEN numOrdenCursor;
    buclenumOrden:LOOP
		FETCH numOrdenCursor INTO numOrden;
        IF hayOrdenes = 0 THEN
			LEAVE buclenumOrden;
		END IF;
        
        SELECT SUM(quantityOrdered * priceEach) INTO totalOrden
		FROM orderdetails
		WHERE orderNumber = numOrden;
        
        UPDATE orders
        SET comments = CONCAT("El total de la orden es $", totalOrden)
        WHERE ordernumber = numOrden;  
    END LOOP buclenumOrden;
	CLOSE numOrdenCursor;
end //
delimiter ;

call alterCommentOrder(181);



#12
-- Crear un SP que devuelva en un parámetro de salida los telefonos de los clientes que cancelaron una orden y no volvieron a comprar.
delimiter //
CREATE PROCEDURE obtenerNumTelefono(out telefono varchar(50))
begin
	declare 


end //
delimiter ;



#13
-- Agregar una columna comisión en la tabla employees. Crear un SP que actualice la comisión de cada empleado.
-- Si el empleado tiene ventas mayores a $100,000, su comisión es del 5%, si tiene ventas entre $50,000 y $100,000, su comisión es del 3%.
-- Si tiene menos de $50,000 en ventas, no recibe comisión.
-- actualizarComision().
ALTER TABLE employees
ADD comision decimal(10,2);

delimiter //
CREATE PROCEDURE actualizarComision()
begin
	declare numEmpleado int;
    declare ventas decimal(10,2);
    declare porcentaje decimal(4,2);
    declare hayEmpleado int;
    
    declare empleadoCursor cursor for SELECT employeeNumber FROM employees;
    declare continue handler for NOT FOUND SET hayEmpleado = 0;
    OPEN empleadoCursor;
    bucleEmpleado:LOOP
		FETCH empleadoCursor INTO numEmpleado;
        IF hayEmpleado = 0 THEN
			LEAVE bucleEmpleado;
		END IF;
        
        SELECT SUM(p.amount) INTO ventas
        FROM payments p
        JOIN customers c ON p.customerNumber = c.customerNumber
        WHERE c.salesRepEmployeeNumber = numEmpleado;
        
        IF ventas > 100000 THEN
			SET porcentaje = 5.00;
		ELSE IF ventas < 50000 THEN
			SET porcentaje = 0.00;
		ELSE
			SET porcentaje = 3.00;
		END IF;
        END IF;
        
        UPDATE employees SET comision = porcentaje
        WHERE employeeNumber = numEmpleado;
	END LOOP bucleEmpleado;
    CLOSE empleadoCursor;
end //
delimiter ;

call actualizarComision();



#14
-- Crear un stored procedure que le asigne un empleado a los clientes que no tengan ninguno asignado.
-- El empleado asignado debe ser el que actualmente atienda a la menor cantidad de clientes.
-- asignarEmpleados()
delimiter //
CREATE PROCEDURE asignarEmpleados()
begin
	declare numCliente int;
    declare numEmpleado int;
    declare hayCliente int;
    
    declare clienteCursor cursor for SELECT customerNumber FROM customers WHERE salesRepEmployeeNumber IS NULL;
    declare continue handler for NOT FOUND SET hayCliente = 0;
    OPEN clienteCursor;
    bucleCliente:LOOP
		IF hayCliente = 0 THEN
			LEAVE bucleCliente;
		END IF;
        
        SELECT e.employeeNumber INTO numEmpleado
        FROM employees e
        LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
        WHERE e.jobTitle = 'Sales Rep'
        GROUP BY e.employeeNumber
        ORDER BY COUNT(c.customerNumber) ASC
        LIMIT 1;
        
        IF numEmpleado IS NOT NULL THEN
			UPDATE customers SET salesRepEmployeeNumber = numEmpleado
			WHERE customerNumber = numCliente;
        END IF;
	END LOOP bucleCliente;
    CLOSE clienteCursor;
end //
delimiter ;

call asignarEmpleados();
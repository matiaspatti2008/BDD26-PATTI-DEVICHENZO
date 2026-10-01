use classicmodels;

#1.
-- Crear un evento que se ejecute diariamente y cambie el estado de los pedidos cuya
-- fecha de entrega ya pasó pero aún están marcados como "In Process" a "Delayed".
delimiter //
CREATE PROCEDURE actualizarEstadoOrden()
begin
	declare idpedido int;
    SELECT orderNumber INTO idpedido
    FROM orders
    WHERE shippedDate < CURRENT_DATE()
    AND status = 'In Process';
    
    UPDATE orders SET status = 'Delayed'
    WHERE orderNUmber = idpedido;
end //

CREATE EVENT actualizarEstado on schedule EVERY 1 DAY starts now() do
begin
	call actualizarEstadoOrden();
end //
delimiter ;



#2.
-- Crear un evento que cada mes elimine los pagos realizados hace más de 5 años
delimiter //
CREATE PROCEDURE eliminarPagosViejos()
begin
	declare idcliente int;
    SELECT customerNumber INTO idcliente
    FROM payments
    WHERE DATEDIFF(YEAR, paymentDate, now()) > 5;

	DELETE FROM payments
    WHERE customerNUmber = idcliente;
end //

CREATE EVENT eliminarPagos on schedule EVERY 1 MONTH starts now() do
begin
	call eliminarPagosViejos();
end //



#3.
-- Crea un evento que cada mes identifique a los clientes que han realizado más de 10
-- pedidos en el último año y les agregue un 10% de crédito extra en creditLimit.
-- Esto se debe realizar hasta el año que viene.
delimiter //
CREATE PROCEDURE clientesPedidosAños()
begin
	UPDATE customers c
    SET c.creditLimit = c.creditLimit * 1.10
    WHERE (
        SELECT COUNT(o.orderNumber)
        FROM orders o
        WHERE o.customerNumber = c.customerNumber 
		AND o.orderDate >= NOW() - INTERVAL 1 YEAR ) > 10;
end //

CREATE EVENT clientesPedidos on schedule EVERY 1 MONTH starts now() ends (CURRENT_DATE() - INTERVAL 1 YEAR) do
begin
	call clientesPedidosAños();
 end //
 delimiter ;
 
 
 
#4.
-- Crear un evento que a partir del día de mañana a las 7AM y una vez por semana, revise
-- si hay clientes sin un empleado asignado (salesRepEmployeeNumber).
-- Debe asignarles un id de empleado priorizando aquellos que tienen menos clientes a cargo.
delimiter //
CREATE PROCEDURE Asignar_Emp_Eventos()
begin
    declare v_customerNumber int;
    declare fin_cursor int;
    declare v_id_empleado int;

    declare cursor_clientes cursor for
        SELECT customerNumber 
        FROM customers 
        WHERE salesRepEmployeeNumber IS NULL;
    declare continue handler for NOT FOUND SET fin_cursor = 0;

    OPEN cursor_clientes;
    bucle_asignacion: LOOP
        FETCH cursor_clientes INTO v_customerNumber;
        IF fin_cursor = 1 THEN
            LEAVE bucle_asignacion;
        END IF;

        SELECT e.employeeNumber INTO v_id_empleado
        FROM employees e
        LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
        WHERE e.jobTitle = 'Sales Rep'
        GROUP BY e.employeeNumber
        ORDER BY COUNT(c.customerNumber) ASC
        LIMIT 1;
        
        IF v_id_empleado IS NOT NULL THEN
            UPDATE customers
            SET salesRepEmployeeNumber = v_id_empleado
            WHERE customerNumber = v_customerNumber;
        END IF;
    END LOOP bucle_asignacion;
    CLOSE cursor_clientes;
end//

DROP EVENT IF EXISTS CLIENTES_SIN_EMPLEADO;
CREATE EVENT CLIENTES_SIN_EMPLEADO on schedule EVERY 1 WEEK STARTS now() + interval 1 day + interval 7 hour do
begin
	call Asignar_Emp_Eventos();
end //
delimiter ;



#5.
-- Crear un evento que realice un reporte diario de ventas. Para esto se debe crear una
-- tabla de reportes que contenga, id del reporte, fecha del mismo y total de ventas.
-- El evento debe generar un reporte de ventas todos los días a las 23:59, pero solo durante el próximo trimestre
CREATE TABLE IF NOT EXISTS sales_reports (
  reportId INT NOT NULL AUTO_INCREMENT,
  reportDate DATE NOT NULL,
  totalSales DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (reportId)
);

delimiter //
CREATE EVENT REPORTE_VENTAS on schedule EVERY 1 DAY STARTS now() + INTERVAL '23:59:00' hour_second + INTERVAL 3 MONTH do
begin
	INSERT INTO sales_reports(reportDate, totalSales)
    SELECT CURRENT_DATE() AS fecha,
		   IFNULL(SUM(od.quantityOrdered * priceEach), 0.00)
	FROM orders o
    LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.orderDate = current_date();
end//
delimiter ;



#6.
-- Crear un evento que cada 6 meses reduzca un 5% el precio de los productos que no tengan ventas recientes.
-- Debe iniciar el 1 de julio de 2025.
delimiter //
CREATE EVENT REDUCIR_PRECIO on schedule EVERY 6 MONTH STARTS '2025-07-01' do
begin
	UPDATE products SET buyPrice = buyPrice * 0.95
    WHERE productCode NOT IN (
		SELECT od.productCode
        FROM orderdetails od
        JOIN orders o ON od.productCode = o.productCode
        WHERE o.orderDate >= now() - INTERVAL 6 MONTH );
end //
delimiter ;
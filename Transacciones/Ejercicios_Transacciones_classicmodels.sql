USE classicmodels;
-- SET SQL_SAFE_UPDATES = 0;

#1.
-- Crear una transacción que permita realizar una compra de manera segura. Se debe crear un procedure que
-- reciba id de cliente, id de producto, cantidad y fecha esperada de envío. Se debe chequear que
-- haya stock disponible para esa cantidad, de no ser el caso se debe mostrar “Error, stock insuficiente”.
delimiter //
CREATE PROCEDURE realizar_compra(in id_cliente int, in cod_producto varchar(15), in cantidad int, in fecha_envio date)
begin
	declare total_stock int;
    declare precio float;
    declare numOrden int;
    
	start transaction;
    SELECT buyPrice, quantityInStock INTO precio, total_stock
    FROM products
    WHERE productCode = cod_producto FOR UPDATE;
    
    SELECT IFNULL(MAX(orderNumber), 0)+1 INTO numOrden
    FROM orders;
    
    INSERT INTO orders(orderNumber, orderDate, requiredDate, status, customerNumber)
    VALUES(numOrden, date(now()), fecha_envio, 'In Process', id_cliente);
    INSERT INTO orderdetails VALUES(numOrden, cod_producto, cantidad, precio, 1);
    
    UPDATE products SET quantityInStock = quantityInStock - cantidad
    WHERE productCode = cod_producto;
    
    IF (total_stock - cantidad) < 0 THEN
		rollback;
        signal sqlstate '45000'
        SET MESSAGE_TEXT = "Error, stock insuficiente";
	END IF;
    commit;
end //
delimiter ;

call realizar_compra(278, 'S24_1937', 200, date(now()));



#2.
-- Crear una transacción que luego de que el cliente realice un pago mayor a $800000, aumente su creditLimit a $1500000.
-- Asumir que existe una función llamada “simular_pago_tarjeta” que recibe el id de cheque
-- y devuelve un bool relacionado con el pago aprobado o rechazado del mismo.
delimiter //
CREATE PROCEDURE pago_tarjeta(in id_cliente int, in num_check varchar(10), in monto float)
begin
	declare pago boolean;
    declare v_credito float;
    
	start transaction;
    SELECT creditLimit INTO v_credito
    FROM customers
    WHERE customerNumber = p_customerNumber FOR UPDATE;
    
    INSERT INTO payments VALUES(id_cliente, num_check, date(now()), monto);
    
    SET pago = simular_pago_tarjeta(num_check);
    
    IF pago = TRUE THEN
		IF monto > 800000 THEN
			UPDATE customers SET creditLimit = 1500000
            WHERE customerNumber = id_cliente;
		END IF;
		commit;
    ELSE 
		rollback;
	END IF;    
end //
delimiter ;



#3.
-- Crear una transacción usando un procedimiento que reciba como parámetro el número
-- de pedido y cambie el estado del pedido a 'Cancelled'. Debe buscar todos los productos
-- y cantidades que formaban parte de ese pedido en la tabla orderdetails, y devolver esas
-- cantidades al stock de cada producto. Se debe chequear que el pedido no esté ya en
-- estado Shipped, si ya fue enviado no se puede cancelar y debe lanzar el mensaje: 
-- "Error: No se puede cancelar un pedido que ya fue enviado"
delimiter //
CREATE PROCEDURE cambiar_estado(in num_pedido int)
begin
	declare estado varchar(15);

	start transaction;
    SELECT status INTO estado
    FROM orders
    WHERE orderNumber = num_pedido FOR UPDATE;
    
    UPDATE orders SET status = 'Cancelled'
    WHERE orderNumber = num_pedido;
    
    UPDATE products p
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber
    SET p.quantityInStock = p.quantityInStock + od.quantityOrdered
    WHERE orderNumber = num_pedido;
    
    IF estado = 'Shipped' THEN
		rollback;
        signal sqlstate '45000'
        SET MESSAGE_TEXT = "Error: No se puede cancelar un pedido que ya fue enviado";
	END IF;
    commit;
end //
delimiter ;

call cambiar_estado(10101);



#4.
-- Crear una transacción utilizando un procedimiento que reciba el id del vendedor que
-- se borró y el id del vendedor que toma el puesto. Se debe actualizar la tabla customers
-- modificando el campo salesRepEmployeeNumber para todos los clientes que eran
-- atendidos por el vendedor viejo. Debe verificar que el nuevo id realmente exista en la
-- tabla employees y que pertenezca a la misma oficina. Si el nuevo vendedor es de otra
-- oficina o no existe, debe lanzar el mensaje:"Error: Vendedor no apto para esta zona".
delimiter //
CREATE PROCEDURE Reemplazar_Empleado_Transaccion(in idViejo int, in idNuevo int)
begin
	declare existe bool;
    declare oficinaV int;
    declare oficinaN int;
    
    start transaction;
    SELECT officeCode INTO oficinaV
    FROM employees
    WHERE employeeNumber = idViejo;
    
    SELECT officeCode INTO oficinaN
    FROM employees
    WHERE employeeNumber = idNuevo FOR UPDATE;
    
    SELECT 1 FROM employees
    WHERE employeeNumber = idNuevo;
    
    IF (existe = 0) or (oficinaN != oficinaV) THEN
		rollback;
        signal sqlstate '45000' SET MESSAGE_TEXT = "Error: Vendedor no apto para esta zona";
	ELSE
		UPDATE customers SET salesRepEmployeeNumber = idNuevo
		WHERE salesRepEmployeeNumber = idViejo;
        commit;
	END IF;
end //
delimiter ;

call Reemplazar_Empleado_Transaccion(1501, 1323);
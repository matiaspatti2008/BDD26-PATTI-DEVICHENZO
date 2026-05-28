USE classicmodels;
-- SET SQL_SAFE_UPDATES = 0;

#1.
-- Crear una transacción que permita realizar una compra de manera segura. Se debe crear un procedure que
-- reciba id de cliente, id de producto, cantidad y fecha esperada de envío. Se debe chequear que
-- haya stock disponible para esa cantidad, de no ser el caso se debe mostrar “Error, stock insuficiente”.
delimiter //
CREATE PROCEDURE Compra_Segura(in idcliente int, in idproducto varchar(15),
								in cantidad int, in fecha_esperada date)
begin
	declare precio float;
    declare stockActual int;
    declare numOrden int;
    
	start transaction;
    SELECT buyPrice, quantityInStock INTO precio, stockActual
    FROM products
    WHERE productCode = idproducto FOR UPDATE;
    
    SELECT IFNULL(MAX(orderNumber), 0)+1 INTO numOrden
    FROM orders;
    
    INSERT INTO orders (orderNumber, orderDate, requiredDate, status, customerNumber)
    VALUE (numOrden, date(now()), fecha_esperada, "In Process", idcliente);
    INSERT INTO orderdetails VALUES (numOrden, idproducto, cantidad, precio, 1);
    
    UPDATE products SET quantityInStock = quantityInStock - cantidad
    WHERE productCode = idproducto;
    IF (stockActual - cantidad) < 0 THEN
		rollback;
		signal sqlstate '45000' SET MESSAGE_TEXT = "ERROR, stock insuficiente";
    ELSE
		commit;
    END IF;
end //
delimiter ;

call Compra_Segura(278, 'S24_1937', 200, date(now()));



#2



#3.
-- Crear una transacción usando un procedimiento que reciba como parámetro el número
-- de pedido y cambie el estado del pedido a 'Cancelled'. Debe buscar todos los productos
-- y cantidades que formaban parte de ese pedido en la tabla orderdetails, y devolver esas
-- cantidades al stock de cada producto. Se debe chequear que el pedido no esté ya en
-- estado Shipped, si ya fue enviado no se puede cancelar y debe lanzar el mensaje: "Error:
-- No se puede cancelar un pedido que ya fue enviado".
delimiter //
CREATE PROCEDURE Cambiar_Estado_Transaccion(in idOrden int)
begin
	declare estadoActual text;
    
    start transaction;
    SELECT status INTO estadoActual
    FROM orders
    WHERE orderNUmber = idOrden FOR UPDATE;
    
    UPDATE orders SET status = 'cancelled'
    WHERE orderNumber = idOrden;
    
    UPDATE products p 
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber    
    SET p.quantityInStock = p.quantityInStock + od.quantityOrdered
    WHERE o.orderNumber = idOrden;
    
    IF estadoActual = 'Shipped' THEN
		rollback;
        signal sqlstate '45000' SET MESSAGE_TEXT = "Error: No se puede cancelar un pedido que ya fue enviado";
	ELSE
		commit;
	END IF;
end //
delimiter ;

call Cambiar_Estado_Transaccion(10101);



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
    WHERE employeeNumber = idNuevo;
    
    SELECT 1 FROM employees
    WHERE employeeNUmber = idNuevo;
    
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
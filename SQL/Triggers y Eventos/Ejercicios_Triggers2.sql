use stock;

#1.
-- Crear un trigger que ante cada fila insertada en la tabla Pedido_Producto modifique la tabla
-- IngresoStock_Producto restando de la columna cantidad de esta tabla la cantidad informada en Pedido_Producto.
delimiter //
CREATE TRIGGER after_insert_restar_cantidad after insert on pedido_producto for each row
begin
	UPDATE ingresostock_producto
    SET cantidad = cantidad - new.cantidad
    WHERE Producto_codProducto = new.Producto_codProducto; 
end //
delimiter ;



#2.
--  Crear un trigger que antes de borrar en la tabla IngresoStock borre todas las filas de la tabla IngresoStock_Producto.
delimiter //
CREATE TRIGGER before_delete_tablas_ingresostock before delete on ingresostock for each row
begin
	DELETE FROM ingresostock_producto
    WHERE IngresoStock_idIngreso = old.idIngreso;
end //
delimiter ;



#3.
-- Imaginando que agregamos una columna categoría en la tabla de clientes, hacer un trigger que, cada vez que se agrega un pedido,
-- se calcule el monto total gastado por ese cliente en los últimos dos años y actualice la categoría del cliente.
-- Las categorías son “bronce” hasta $50.000 inclusive, “plata” de $50.000 a $100.000 inclusive y “oro” más de $100.000.
delimiter //
CREATE PROCEDURE categoria_trigger(in id_cliente varchar(20))
begin
	declare total float;
    declare v_categoria varchar(20);
    
	SELECT SUM(pp.cantidad * pp.precioUnitario) INTO total
    FROM pedido_producto pp
    JOIN pedido p ON pp.Pedido_idPedido = p.idPedido
    WHERE p.Cliente_codCliente = id_cliente
    AND p.fecha > DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
    
    IF total <= 50000 THEN
		UPDATE cliente SET v_categoria = 'bronce';
	ELSE IF total > 100000 THEN
		SET v_categoria = 'oro';
	ELSE
		SET v_categoria = 'plata';
	END IF;
    END IF;
    
    UPDATE cliente SET categoria = v_categoria;
end //


CREATE TRIGGER before_insert_categoria_cliente before insert on pedido for each row
begin
	call categoria_trigger(new.Cliente_codCliente);
end //
delimiter ;



#4.
-- Realizar un trigger que después de insertar una fila en la tabla de IngresoStock_Producto incremente la
-- columna stock de la tabla de productos con la cantidad ingresada de la tabla IngresoStock_Producto.
delimiter //
CREATE TRIGGER after_insert_incrementa_stock after insert on ingresostock_producto for each row
begin
	UPDATE producto
    SET stock = stock + new.cantidad
    WHERE codProducto = new.Producto_codProducto;
end //
delimiter ;



#5.
-- Si las tablas de la base de datos estuvieran todas definidas con claves foráneas con restricción delete no action
-- ¿qué sucedería si quisiera borrar un pedido? Traten de solucionar esta situación mediante un trigger que me permita llevar a cabo
-- la acción de borrado en la tabla de pedidos. Planteen y desarrollen cuáles serían otras alternativas de solución que se les ocurra,
-- como por ejemplo utilizando una función o definiendo cambio de restricciones, alguna otra característica que le parezca contemplar.
-- Tener en cuenta si en algún caso conviene crear un SP que sea llamado por un trigger.
delimiter //
CREATE TRIGGER before_Delete_borrar_pedido before delete on pedido for each row
begin
	DELETE FROM pedido_producto
    WHERE Pedido_idPedido = new.idPedido;
end //
delimiter ;

-- No se me ocurren más alternativas. Quizás alterando las restricciones de la tabla. El problema es que si
-- se ejecuta cualquier tipo de delete accidental borrará TODO lo relacionado sin pedir una confirmación
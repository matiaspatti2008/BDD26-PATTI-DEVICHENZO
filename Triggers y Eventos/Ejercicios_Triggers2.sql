use stock;

#1
--  Crear un trigger que ante cada fila insertada en la tabla Pedido_Producto modifique la tabla
-- IngresoStock_Producto restando de la columna cantidad de esta tabla la cantidad informada en Pedido_Producto.
delimiter //
CREATE TRIGGER AI_pedido_producto AFTER INSERT ON pedido_producto FOR EACH ROW
BEGIN
    UPDATE ingresostock_producto
    SET cantidad = cantidad - new.cantidad
    WHERE Producto_codProducto = new.Producto_codProducto;
END //
delimiter ;


#3
--  Imaginando que agregamos una columna categoría en la tabla de clientes, hacer un trigger que, cada vez
-- que se agrega un pedido, se calcule el monto total gastado por ese cliente en los últimos dos años y
-- actualice la categoría del cliente. Las categorías son “bronce” hasta $50.000 inclusive, “ plata”de $50.000 a
-- $100.000 inclusive y “oro” más de $100.000.
delimiter //
CREATE PROCEDURE actualizar_categoria(IN p_codCliente VARCHAR(20))
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(pp.cantidad * pp.precioUnitario)
    INTO total
    FROM pedido_producto pp
    JOIN pedido p ON pp.Pedido_idPedido = p.idPedido
    WHERE p.Cliente_codCliente = p_codCliente
	AND p.fecha >= DATE_SUB(NOW(), INTERVAL 2 YEAR);

	IF total IS NULL THEN
		SET total = 0;
	END IF;

    UPDATE cliente
    SET categoria = CASE
        WHEN total <= 50000 THEN 'bronce'
        WHEN total <= 100000 THEN 'plata'
        ELSE 'oro'
    END
    WHERE codCliente = p_codCliente;
END //


CREATE TRIGGER AI_pedido AFTER INSERT ON pedido FOR EACH ROW
BEGIN
    CALL actualizar_categoria(new.Cliente_codCliente);
END //
delimiter ;


#5
-- Si las tablas de la base de datos estuvieran todas definidas con claves foráneas con restricción delete no
-- action ¿qué sucedería si quisiera borrar un pedido? Traten de solucionar esta situación mediante un
-- trigger que me permita llevar a cabo la acción de borrado en la tabla de pedidos. Planteen y desarrollen
-- cuáles serían otras alternativas de solución que se les ocurra, como por ejemplo utilizando una función o
-- definiendo cambio de restricciones, alguna otra característica que le parezca contemplar.
delimiter //
CREATE TRIGGER borrar_productos before delete on pedido FOR EACH ROW
BEGIN
	declare cantidad_productos int;
    SELECT COUNT(*) INTO cantidad_productos
    FROM pedido_producto
    WHERE Pedido_idPedido = old.idPedido;
    
    DELETE FROM pedido_producto
    WHERE Pedido_idPedido = old.idPedido;
END //
delimiter ;

delete from pedido
where idPedido = 2;
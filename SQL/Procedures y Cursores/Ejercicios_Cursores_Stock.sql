USE stock;

#1.
-- Crear un Stored Procedure que actualice el stock de los productos teniendo en cuenta los ingresos de esta semana.
delimiter //
CREATE PROCEDURE actualizarStock()
begin
    declare cant int;
    declare codProd int;
    declare hayProducto int;
    declare fecha_inicio date;
	declare fecha_fin date;
    
    declare productoCursor cursor for
		SELECT isp.Producto_codProducto, SUM(isp.cantidad)
		FROM ingresostock_producto isp
		JOIN ingresostock i ON isp.IngresoStock_IdIngreso = i.IdIngreso
		WHERE i.fecha BETWEEN fecha_inicio AND fecha_fin
        GROUP BY isp.Producto_codProducto;
    declare continue handler for NOT FOUND SET hayProducto = 0;

    SET fecha_inicio = CURRENT_DATE() - INTERVAL 7 DAY;
    SET fecha_fin = CURRENT_DATE();

    OPEN productoCursor;
    bucleProducto:LOOP
		FETCH productoCursor INTO codProd, cant;
        IF hayProducto = 0 THEN
			LEAVE bucleProducto;
		END IF;
        
        UPDATE producto SET stock = stock + cant
        WHERE codProducto = codProd;
	END LOOP bucleProducto;
    CLOSE productoCursor;
end //
delimiter ;

call actualizarStock();



#2.
-- Crear un Stored Procedure que reduzca el precio de los productos en un 10% si no se vendieron más de 100 unidades en la semana.
delimiter //
CREATE PROCEDURE reducirPrecio()
begin
	declare descuento double default 0;
    declare codProd, cant, hayProducto int;
    declare precioTotal double;
    declare fecha_inicio, fecha_fin date;
    
    declare productoCursor cursor for
		SELECT pep.Producto_codProducto, SUM(pep.cantidad), pr.precio
        FROM pedido_producto pep
        JOIN pedido p ON pep.Pedido_IdPedido = p.IdPedido
        JOIN producto pr ON pep.Producto_codProducto = pr.codProducto
        WHERE p.fecha BETWEEN fecha_inicio AND fecha_fin
        GROUP BY Producto_codProducto;
	declare continue handler for NOT FOUND SET hayProducto = 0;
    
    SET fecha_inicio = CURRENT_DATE() - INTERVAL 7 DAY;
    SET fecha_fin = CURRENT_DATE();
    
    OPEN productoCursor;
    bucleProducto:LOOP
		FETCH productoCursor INTO codProd, cant, precioTotal;
        IF hayProducto = 0 THEN
			LEAVE bucleProducto;
		END IF;
        
        IF cant < 100 THEN
			SET descuento = (precioTotal * 0.1);
		END IF;
        
        UPDATE producto SET precio = precio - descuento
        WHERE codProducto = codProd;
        UPDATE pedido_producto SET precioUnitario = precioUnitario - descuento
        WHERE Producto_codProducto = codProd;
	END LOOP bucleProducto;
    CLOSE productoCursor;
end //
delimiter ;

call reducirPrecio();



#3.
-- Crear un Stored Procedure que actualice el precio de los productos. Debe ser un 10% más que el mayor precio al que lo proveen los proveedores.
delimiter //
CREATE PROCEDURE aumentarPrecio()
begin
	declare cProducto, hayProducto int;
    declare precioProv, porcentaje double;
    
    declare productoCursor cursor for
		SELECT prp.Producto_codProducto, MAX(prp.precio)
        FROM producto_proveedor prp
        GROUP BY prp.Producto_codProducto;
	declare continue handler for NOT FOUND SET hayProducto = 0;
    OPEN productoCursor;
    buclePrecio:LOOP
		FETCH productoCursor INTO cProducto, precioProv;
        IF hayProducto = 0 THEN
			LEAVE buclePrecio;
		END IF;
        SET porcentaje = (precioProv * 0.1);
        
        UPDATE producto SET precio = precio + porcentaje
        WHERE codProducto = cProducto;
	END LOOP buclePrecio;
    CLOSE productoCursor;
end //
delimiter ;

call aumentarPrecio();



#4.
-- Suponiendo que agregamos una columna llamada “nivel” en la tabla de proveedores, se pide realizar un procedimiento que calcule
-- la cantidad de ingresos por proveedor en los últimos 2 meses y actualice el nivel del proveedor. Los niveles son “Bronce” hasta 50 ingresos inclusive,
-- “Plata” de 50 a 100 ingresos inclusive y “Oro” más de 100.
ALTER TABLE proveedor
ADD nivel varchar(15);

delimiter //
CREATE PROCEDURE nivelarProveedor()
begin
	declare provId, cant, hayProveedor int;
    declare v_nivel varchar(15);
    declare fecha_inicio, fecha_fin date;
    
    declare ingresosCursor cursor for
		SELECT i.Proveedor_idProveedor, COUNT(i.idIngreso)
        FROM ingresostock i
        WHERE i.fecha BETWEEN fecha_inicio AND fecha_fin
        GROUP BY i.Proveedor_idProveedor;
	declare continue handler for NOT FOUND SET hayProveedor = 0;
    
    SET fecha_inicio = CURRENT_DATE() - INTERVAL 2 MONTH;
    SET fecha_fin = CURRENT_DATE(); 
    
    OPEN ingresosCursor;
    bucleProveedores:LOOP
		FETCH ingresosCursor INTO provId, cant;
        IF hayProveedor = 0 THEN
			LEAVE bucleProveedores;
		END IF;
		
        IF cant <= 50 THEN
			SET v_nivel = "Bronce";
		ELSE IF cant > 50 AND cant <= 100 THEN
			SET v_nivel = "Plata";
		ELSE
			SET v_nivel = "Oro";
		END IF;
        END IF;
        
        UPDATE proveedor SET nivel = v_nivel
        WHERE idProveedor = provId;
	END LOOP bucleProveedores;
    CLOSE ingresosCursor;
end //
delimiter ;

call nivelarProveedor()



#5.
-- Realice un procedimiento que actualice el precio unitario de los productos que están en pedidos pendientes de pago, al precio actual del producto
delimiter //
CREATE PROCEDURE actualizarPrecioUnitario()
begin
	declare pedidoId, cProducto, hayProducto int;
	declare precioActual double;
    
    declare productoCursor cursor for
		SELECT pep.Producto_codProducto, pep.Pedido_idPedido, pr.precio
        FROM pedido_producto pep
        JOIN producto pr ON pep.Producto_codProducto = pr.codProducto
        JOIN pedido p ON pep.Pedido_idPedido = p.idPedido
        JOIN estado e ON p.Estado_idEstado = e.idEstado
        WHERE e.nombre = 'Pendiente';
	declare continue handler for NOT FOUND SET hayProducto = 0;
    OPEN productoCursor;
    buclePrecio:LOOP
		FETCH productoCursor INTO cProducto, pedidoId, precioActual;
        IF hayProducto = 0 THEN
			LEAVE buclePrecio;
		END IF;
        
        UPDATE pedido_producto SET precioUnitario = precioActual
        WHERE Producto_codProducto = cProducto
        AND Pedido_idPedido = pedidoId;
	END LOOP buclePrecio;
    CLOSE productoCursor;
end //
delimiter ;

call actualizarPrecioUnitario();
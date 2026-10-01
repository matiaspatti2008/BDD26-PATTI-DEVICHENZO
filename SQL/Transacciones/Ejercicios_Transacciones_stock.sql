USE stock;

#1.
-- Crear una transacción utilizando un procedimiento que reciba el id de un producto, una estantería y una cantidad que se desea retirar.
-- Se debe modificar la cantidad presente en la estantería y el stock del producto. Se debe validar que las dos cantidades no queden en negativo.

-- No sé qué vendría a ser "estantería"
    
    
    
#2.
-- Crear una transacción utilizando un procedimiento que reciba el id de una categoria y
-- el porcentajeAumento. El procedimiento debe aplicar el aumento a todos los productos
-- que pertenezcan a esa categoría en la tabla producto. Se debe verificar si la categoría
-- existe y si tiene productos asociados. Si no existe debe lanzar el error: “Error: categoría inexistente”.
delimiter //
CREATE PROCEDURE categoria_aumento(in id_categoria int, in porcentaje_aumento float)
begin
	declare existe, prod_asociados int;
    
    start transaction;
	SELECT 1 INTO existe
    FROM categoria
    WHERE idCategoria = id_categoria FOR UPDATE;
    
    SELECT COUNT(*) INTO prod_asociados
    FROM producto
    WHERE Categoria_idCategoria = id_categoria FOR UPDATE;
    
    IF existe = 0 THEN
        rollback;
        signal sqlstate '45000'
        SET MESSAGE_TEXT = 'Error: categoría inexistente';
    ELSE IF prod_asociados = 0 THEN
        rollback;
        signal sqlstate '45000'
        SET MESSAGE_TEXT = 'Error: La categoría no tiene productos asociados';
    ELSE
        UPDATE producto
        SET precio = precio * (1 + (p_porcentajeAumento / 100))
        WHERE id_categoria = p_id_categoria;
        commit;
    END IF;
    END IF;
end //
delimiter ;

call categoria_aumento(3, 25);



#3.
-- Crear una transacción utilizando un procedimiento que reciba el id de un proveedor, un
-- código de producto, provincia y la cantidad que llegó en el camión. El procedimiento
-- debe registrar el ingreso en las tablas ingresostock e ingresostock_producto, actualizar
-- el stock general del producto y validar que la provincia del proveedor sea la misma que
-- la que se recibe por parámetro. Si no lo es, debe lanzar el error: "Ingreso rechazado: el
-- proveedor no está habilitado para operar en esta provincia".
delimiter //
CREATE PROCEDURE registrar_ingreso(in id_proveedor int, in cod_prod int, in id_provincia int, in v_cantidad int)
begin
	declare v_item int;
    declare v_idIngreso int;
    declare v_provincia int;
    declare v_stock int;
    
    start transaction;
    SELECT idProvincia INTO v_provincia
    FROM provincia p
    JOIN proveedor pv ON p.idProvincia = pv.Provincia_idProvincia
    WHERE pv.idProveedor = id_proveedor FOR UPDATE;
    
    SELECT stock INTO v_stock
    FROM producto
    WHERE codProducto = cod_prod FOR UPDATE;
    
    SELECT IFNULL(MAX(idIngreso), 0)+1 INTO v_idIngreso
    FROM ingresostock;
    
    SELECT IFNULL(MAX(item), 0)+1 INTO v_item
    FROM ingresostock_producto
    WHERE Ingreso_idIngreso = v_idIngreso;
    
    INSERT INTO ingresostock(idIngreso, fecha, Proveedor_idProveedor)
    VALUES(v_idIngreso, date(now()), id_proveedor);
    INSERT INTO ingresostock_producto(item, cantidad, Ingreso_idIngreso, Producto_codProducto)
    VALUES(v_item, v_cantidad, v_idIngreso, cod_prod);
    
    UPDATE producto SET stock = stock + v_cantidad
    WHERE codProducto = cod_prod;
    
    IF v_provincia != id_provincia THEN
		rollback;
        signal sqlstate '45000'
        SET MESSAGE_TEXT = "Ingreso rechazado: el proveedor no está habilitado para operar en esta provincia";
	END IF;
    commit;
end //
delimiter ;
USE stock;

#1.
-- Crear una transacción utilizando un procedimiento que reciba el id de un producto, una estantería y una cantidad que se desea retirar.
-- Se debe modificar la cantidad presente en la estantería y el stock del producto. Se debe validar que las dos cantidades no queden en negativo.
delimiter //
CREATE PROCEDURE RegistraIngreso(in ingreso_id int, in proveedor_id int,in codProducto int, in provincia text, in cantidad int)
begin
	declare provincia_proveedor text;
	declare existe int;
    declare numItem int;
    
    start transaction;
    SELECT provincia INTO provincia_proveedor
    FROM proveedor
    WHERE idProveedor = proveedor_id FOR UPDATE;
    
    SELECT COUNT(*) INTO existe
    FROM ingresostock
    WHERE idIngreso = ingreso_id;
    
    IF existe = 0 THEN
		INSERT INTO ingresostock(idIngreso, fecha, proveedor_idProveedor)
        VALUE (NULL, now(), proveedor_id);
	END IF;
    ....
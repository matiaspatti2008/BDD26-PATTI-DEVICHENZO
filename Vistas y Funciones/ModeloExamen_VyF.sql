USE examen1;

-- Stored functions

#1-
-- Crear una función que reciba una compra y retorne si está completamente paga o no. Tener en
-- cuenta que una compra se puede pagar con diferentes métodos de pago y en diferentes días.
delimiter //
CREATE FUNCTION PAGADO(idCompra int) returns bool deterministic
begin
	declare estaPago bool default false;
    declare montoTotal decimal(10,2);
    declare precioTotal decimal(10,2);
    
    SELECT SUM(p.monto) INTO montoTotal
    FROM pago p
    WHERE p.compra_id = idCompra
    GROUP BY p.compra_id;
    
    SELECT c.precio INTO precioTotal
    FROM compra c
    WHERE c.id = idCompra;
    
    if montoTotal < precioTotal then
		return estaPago;
	else
		SET estaPago = true;
        return estaPago;
	end if;
end//
delimiter ;

select PAGADO(101);    



#2-
-- Crear una función que reciba un empleado y calcule la comisión. La comisión representa un
-- porcentaje de lo vendido en el mes por ese empleado. Si el empleado tiene menos de 5 años de
-- antigüedad la comisión es del 5%, si tiene entre 5 y 10 es del 7% y si supera los 10 años es del 10%.
delimiter //
CREATE FUNCTION COMISION_EMP(dniEmpleado int) returns float deterministic
begin
	declare comision float;
    declare totalVendido float;
    declare antiguedad int;
    
    SELECT SUM(c.precio) INTO totalVendido
    FROM compra c
    WHERE c.empleado_id = dniEmpleado
    AND MONTH(c.fecha) = MONTH(CURRENT_DATE());
    
    SELECT TIMESTAMPDIFF(YEAR, e.fechaIngreso, CURRENT_DATE()) INTO antiguedad
    FROM empleado e
    WHERE e.id = dniEmpleado;
    
    if antiguedad < 5 then
		SET comision = totalVendido * 0.05;
	else if antiguedad < 10 then
		SET comision = totalVendido * 0.07;
	else
		SET comision = totalVendido * 0.1;
	end if;
    end if;
    return comision;
end //
delimiter ;

SELECT COMISION_EMP(1)


#3-
-- Crear una función que reciba el modelo de un auto y un mes, y devuelva la cantidad de autos
-- de ese modelo vendidos en ese mes.
delimiter //
CREATE FUNCTION CANT_AUTOS(modeloAuto int, mes int) returns int deterministic
begin
	declare cantAutos int;
    SELECT COUNT(*) INTO cantAutos
    FROM compra c
    JOIN auto a ON c.auto_patente = a.patente
    WHERE a.modelo_id = modeloAuto
    AND MONTH(c.fecha) = mes;
    return cantAutos;
end //
delimiter ;

SELECT CANT_AUTOS(1, 4);


-- Vistas

#1-
-- Crear una vista que muestre el resumen de todas las ventas, incluyendo dni y mail del cliente, fecha de compra, patente, marca y color del auto,
-- y si está completamente paga o no. Utilizar la función del punto 1).
CREATE VIEW Resumen AS
	SELECT c.id AS VENTA,
		   c.cliente_dni AS DNI_CLIENTE,
           cl.mail AS MAIL_CLIENTE,
           c.fecha AS FECHA_COMPRA,
           c.auto_patente AS PATENTE_AUTO,
           m.marca AS MARCA_AUTO,
           a.color AS COLOR_AUTO,
           PAGADO(c.id) AS 'PAGADO? (1-SI, 2-NO)'
	FROM compra c
    JOIN cliente cl ON c.cliente_dni = cl.dni
    JOIN auto a ON c.auto_patente = a.patente
    JOIN modelo m ON a.modelo_id = m.id;

SELECT * FROM Resumen;



#2-
-- Crear una vista que muestre un resumen de las ventas por mes. El resumen debe listar el nombre del modelo de auto, la cantidad de ventas,
-- la ganancia en pesos y el día en el que se vendieron más autos de ese modelo. Utilizar la función del punto 3)


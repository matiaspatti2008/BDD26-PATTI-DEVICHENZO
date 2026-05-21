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
    WHERE paymentsDate > (CURRENT_DATE() - INTERVAL 5 MONTH);

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


end //

CREATE EVENT clientesPedidos on schedule EVERY 1 MONTH starts now() ends (CURRENT_DATE() - INTERVAL 1 YEAR) do
begin
	call clientesPedidosAños;
 end //
 delimiter ;
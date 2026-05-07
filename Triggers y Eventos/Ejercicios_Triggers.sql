USE classicmodels;

#1
create table customers_audit (
IdAudit int auto_increment not null primary key,
Operacion char(6),
`User` int,
Last_date_modified datetime,
`customername` varchar(50) not null );


-- a)
--  Definir un trigger que se dispare después de insertar en la tabla de customers y que
-- inserte la información necesaria en customers_audit.
delimiter// 
create trigger insert_customers_audit after insert on customers for each row
begin
	insert into customers_audit values("insert", new.customerNumber, new.now(), new.customerName)
end//
delimiter ;


#3
-- Hacer un trigger que ante el intento de borrar un producto verifique que dicho producto
-- no exista en las órdenes cuya orderDate sea menor a dos meses. Si existe debe tirar un
-- error que diga “Error, tiene órdenes asociadas”.
DELIMITER //
CREATE TRIGGER before_delete_product BEFORE DELETE ON products FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM orderdetails od
    JOIN orders o ON od.orderNumber = o.orderNumber
    WHERE od.productCode = OLD.productCode
	AND o.orderDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH);

    IF v_count > 0 THEN
		SET MESSAGE_TEXT = 'Error, tiene órdenes asociadas';
    END IF;
END //
DELIMITER ;
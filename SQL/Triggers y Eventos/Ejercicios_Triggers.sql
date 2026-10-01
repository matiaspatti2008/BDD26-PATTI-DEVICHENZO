USE classicmodels;

#1.
--  Crear una tabla llamada customers_audit con el siguiente diseño:
-- IdAudit, int auto_increment not null primary key
-- Operacion char(6), (Para indicar la operación realizada sobre la tabla, delete, update, insert)
-- User
-- Last_date_modified,
-- Campos más relevantes de la tabla customers
CREATE TABLE IF NOT EXISTS customers_audit (
	IdAudit INT NOT NULL AUTO_INCREMENT,
	Operacion CHAR(6) NOT NULL,
	`User` VARCHAR(100) NOT NULL,
	Last_date_modified DATETIME NOT NULL,
	customerNumber INT NOT NULL,
	customerName VARCHAR(50) NOT NULL,
	contactLastName VARCHAR(50) NOT NULL,
	contactFirstName VARCHAR(50) NOT NULL,
	phone VARCHAR(50) NOT NULL,
	creditLimit DECIMAL(10,2) DEFAULT NULL,
	PRIMARY KEY (IdAudit)
);


-- a- Definir un trigger que se dispare después de insertar en la tabla de customers y que
-- inserte la información necesaria en customers_audit.
delimiter //
CREATE TRIGGER after_insert_customers_audit after insert on customers for each row
begin
	INSERT INTO customers_audit(Operacion, User, Last_date_modified, customerNumber, customerName,
								contactLastName, contactFirstName, phone, creditLimit)
	VALUES ('INSERT', CURRENT_USER(), NOW(), NEW.customerNumber, NEW.customerName,
			NEW.contactLastName, NEW.contactFirstName, NEW.phone, NEW.creditLimit);
end //
delimiter ;


-- b- Definir un trigger que se dispare antes de una modificación en la tabla customers que
-- deje los datos antes de ser modificados en la tabla customers_audit.
delimiter //
CREATE TRIGGER before_update_customers_audit before update on customers for each row
begin
	INSERT INTO customers_audit(Operacion, User, Last_date_modified, customerNumber, customerName,
								contactLastName, contactFirstName, phone, creditLimit)
	VALUES('UPDATE', CURRENT_USER(), NOW(), OLD.customerNumber, OLD.customerName,
			OLD.contactLastName, OLD.contactFirstName, OLD.phone, OLD.creditLimit);
end //
delimiter ;


-- c- Definir un trigger que, antes de borrar una fila en la tabla de customers, inserte los
-- datos anteriores en la tabla customes_audit.
delimiter //
CREATE TRIGGER before_delete_customers_audit before delete on customers for each row
begin
	INSERT INTO customers_audit(Operacion, User, Last_date_modified, customerNumber, customerName,
								contactLastName, contactFirstName, phone, creditLimit)
	VALUES('DELETE', CURRENT_USER(), NOW(), OLD.customerNumber, OLD.customerName,
			OLD.contactLastName, OLD.contactFirstName, OLD.phone, OLD.creditLimit);
end //
delimiter ;



#2.
-- Hacer lo mismo con la tabla de empleados. Crear una tabla de auditoría que contenga los
-- campos de la tabla employees más un id, operación, usuario y fecha de última modificación.
-- Definir un trigger para cada operación de insert, delete y update sobre la tabla.
CREATE TABLE IF NOT EXISTS employees_audit (
  id_audit INT NOT NULL AUTO_INCREMENT,
  operacion VARCHAR(10) NOT NULL,
  `user` VARCHAR(100) NOT NULL,
  last_date_modified DATETIME NOT NULL,
  employeeNumber INT NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  firstName VARCHAR(50) NOT NULL,
  extension VARCHAR(10) NOT NULL,
  email VARCHAR(100) NOT NULL,
  officeCode VARCHAR(10) NOT NULL,
  reportsTo INT DEFAULT NULL,
  jobTitle VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_audit)
);

-- a)
delimiter //
CREATE TRIGGER after_insert_employees_audit after insert on employees for each row
begin
	INSERT INTO employees_audit(operacion, user, last_date_modified, employeeNumber, lastName, firstName,
                                extension, email, officeCode, reportsTo, jobtitle)
	VALUES ('INSERT', CURRENT_USER(), NOW(), NEW.employeeNumber, NEW.lastName, NEW.firstName,
            NEW.extension, NEW.email, NEW.officeCode, NEW.reportsTo, NEW.jobtitle);
end //
delimiter ;

-- b)
delimiter //
CREATE TRIGGER before_update_employees_audit before update on employees for each row
begin
	INSERT INTO employees_audit(operacion, user, last_date_modified, employeeNumber, lastName, firstName,
                                extension, email, officeCode, reportsTo, jobtitle)
	VALUES ('INSERT', CURRENT_USER(), NOW(), OLD.employeeNumber, OLD.lastName, OLD.firstName,
            OLD.extension, OLD.email, OLD.officeCode, OLD.reportsTo, OLD.jobtitle);
end //
delimiter ;

-- c)
delimiter //
CREATE TRIGGER before_delete_employees_audit before delete on employees for each row
begin
	INSERT INTO employees_audit(operacion, user, last_date_modified, employeeNumber, lastName, firstName,
                                extension, email, officeCode, reportsTo, jobtitle)
	VALUES ('INSERT', CURRENT_USER(), NOW(), OLD.employeeNumber, OLD.lastName, OLD.firstName,
            OLD.extension, OLD.email, OLD.officeCode, OLD.reportsTo, OLD.jobtitle);
end //
delimiter ;



#3.
-- Hacer un trigger que ante el intento de borrar un producto verifique que dicho producto no exista en las órdenes
-- cuya orderDate sea menor a dos meses. Si existe debe tirar un error que diga “Error, tiene órdenes asociadas”.
delimiter //
CREATE TRIGGER before_delete_orden_vieja before delete on products for each row
begin
	declare v_contador int;
    SELECT COUNT(*) INTO V_CONTADOR
    FROM orderdetails od
    JOIN orders o ON od.orderNumber = o.orderNUmber
    WHERE productCode = OLD.productCode
    AND o.orderDate > DATE_SUB(CURDATE(), INTERVAL 2 MONTH);
    
    IF v_contador > 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error, tiene órdenes asociadas';        
	END IF;
end //
delimiter ;
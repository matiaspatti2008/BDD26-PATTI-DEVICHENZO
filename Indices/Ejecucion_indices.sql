USE stock;

-- paso 1
DROP PROCEDURE IF EXISTS insertar_20k_pedidos;

DELIMITER //
CREATE PROCEDURE insertar_20k_pedidos()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_id INT DEFAULT 0;
    
    -- Variables para almacenar los IDs en memoria
    DECLARE lista_clientes TEXT;
    DECLARE lista_estados TEXT;
    
    DECLARE cant_clientes INT;
    DECLARE cant_estados INT;
    
    DECLARE cliente_elegido VARCHAR(20);
    DECLARE estado_elegido INT;
    DECLARE fecha_aleatoria DATETIME;

    -- Forzar a que no falle por tiempos de espera en esta sesión
    SET @@SESSION.max_execution_time = 0; -- MySQL 5.7.8+ (0 = infinito)
    SET @@SESSION.net_read_timeout = 300;
    SET @@SESSION.net_write_timeout = 300;
    
    -- Optimización de inserción masiva
    SET @@SESSION.unique_checks = 0;
    SET @@SESSION.foreign_key_checks = 0;

    -- 1. Agrupamos todos los códigos de clientes y estados en un string
    SELECT GROUP_CONCAT(codCliente) INTO lista_clientes FROM cliente;
    SELECT GROUP_CONCAT(idEstado) INTO lista_estados FROM estado;
    
    -- Contamos cuántos tenemos de cada uno
    SET cant_clientes = CHAR_LENGTH(lista_clientes) - CHAR_LENGTH(REPLACE(lista_clientes, ',', '')) + 1;
    SET cant_estados = CHAR_LENGTH(lista_estados) - CHAR_LENGTH(REPLACE(lista_estados, ',', '')) + 1;

    -- Control de seguridad: Si no hay datos, salimos para evitar bucle infinito
    IF lista_clientes IS NULL OR lista_estados IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Las tablas cliente o estado están vacías.';
    END IF;

    -- Obtener el ID máximo inicial de pedido
    SELECT COALESCE(MAX(idPedido), 0) INTO max_id FROM pedido;

    -- Iniciar una transacción para que guarde todo de golpe en memoria antes de escribir en disco
    START TRANSACTION;

    -- Bucle super veloz
    WHILE i <= 20000 DO
        
        -- Elegir cliente de la lista en memoria
        SET cliente_elegido = SUBSTRING_INDEX(SUBSTRING_INDEX(lista_clientes, ',', FLOOR(1 + RAND() * cant_clientes)), ',', -1);
        
        -- Elegir estado de la lista en memoria
        SET estado_elegido = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(lista_estados, ',', FLOOR(1 + RAND() * cant_estados)), ',', -1) AS UNSIGNED);
        
        -- Fecha aleatoria
        SET fecha_aleatoria = NOW() - INTERVAL FLOOR(RAND() * 365) DAY - INTERVAL FLOOR(RAND() * 86400) SECOND;
        
        SET max_id = max_id + 1;

        INSERT INTO pedido (idPedido, fecha, Estado_idEstado, Cliente_codCliente)
        VALUES (max_id, fecha_aleatoria, estado_elegido, cliente_elegido);

        SET i = i + 1;
    END WHILE;

    -- Confirmar todos los cambios juntos
    COMMIT;

    -- Restaurar configuraciones de seguridad
    SET @@SESSION.unique_checks = 1;
    SET @@SESSION.foreign_key_checks = 1;
    
END//
DELIMITER ;

CALL insertar_20k_pedidos();



-- paso 2
EXPLAIN ANALYZE SELECT * FROM pedido WHERE idPedido = 19999;

-- paso 3
EXPLAIN ANALYZE SELECT * FROM pedido WHERE fecha = '2025-08-16';
select count(*) from pedido;
/*
'-> Filter: (pedido.fecha = TIMESTAMP\'2025-08-16 00:00:00\')  
(cost=6072 rows=6032) (actual time=16..16 rows=0 loops=1)\n    
-> Table scan on pedido  (cost=6072 rows=60320) (actual time=0.273..13.5 rows=60009 loops=1)\n'
*/

-- paso 4
CREATE INDEX INDICE_FECHA ON pedido(fecha);

-- paso 5
EXPLAIN ANALYZE SELECT * FROM pedido WHERE fecha = '2025-08-16';
/*
'-> Index lookup on pedido using INDICE_FECHA (fecha=TIMESTAMP\'2025-08-16 00:00:00\')  
(cost=0.35 rows=1) (actual time=0.0433..0.0433 rows=0 loops=1)\n'
*/

-- paso 6
CREATE INDEX INDICE_CLIENTE_ESTADO ON pedido(Cliente_codCliente, Estado_idEstado);

-- paso 7
EXPLAIN ANALYZE SELECT * FROM pedido WHERE Cliente_codCliente = 'C07' AND Estado_idEstado = 2;
/*
'-> Index lookup on pedido using INDICE_CLIENTE_ESTADO (Cliente_codCliente=\'C07\', Estado_idEstado=2) 
(cost=270 rows=1491) (actual time=0.282..3.03 rows=1491 loops=1)\n'
*/

EXPLAIN ANALYZE SELECT * FROM pedido WHERE Cliente_codCliente = 'C07';
/*
'-> Index lookup on pedido using fk_Pedido_Cliente1_idx (Cliente_codCliente=\'C07\') 
(cost=727 rows=6059) (actual time=1.18..12.8 rows=6059 loops=1)\n'
*/

EXPLAIN ANALYZE SELECT * FROM pedido WHERE Estado_idEstado = 2;
/*
'-> Index lookup on pedido using fk_Pedido_Estado1_idx (Estado_idEstado=2)
(cost=2784 rows=26630) (actual time=6.23..29.4 rows=15052 loops=1)\n'
*/
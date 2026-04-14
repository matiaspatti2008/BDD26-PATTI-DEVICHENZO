USE examen1;

-- Modelos de autos
INSERT INTO `modelo` (`id`, `marca`, `potencia`) VALUES 
(1, 'Toyota Corolla', '170 HP'),
(2, 'Ford Mustang', '450 HP'),
(3, 'Honda Civic', '155 HP'),
(4, 'Volkswagen Golf', '110 HP'),
(5, 'Tesla Model 3', '283 HP');

-- Métodos de pago
INSERT INTO `metodoPago` (`id`, `nombre`) VALUES 
(1, 'Efectivo'),
(2, 'Transferencia Bancaria'),
(3, 'Crédito Prendario'),
(4, 'Cripto');

-- Empleados
INSERT INTO `empleado` (`id`, `nombre`, `apellido`, `numeroTel`, `direccion`, `mail`, `fechaIngreso`) VALUES 
(1, 'Carlos', 'Perez', 44556677, 'Av. Siempre Viva 123', 'cperez@concesionaria.com', '2020-01-15'),
(2, 'Marta', 'Gomez', 22334455, 'Calle Falsa 456', 'mgomez@concesionaria.com', '2021-06-10'),
(3, 'Juan', 'Rodriguez', 55998811, 'Ruta 9 Km 50', 'jrodriguez@concesionaria.com', '2023-02-20');

-- Clientes
INSERT INTO `cliente` (`dni`, `nombre`, `apellido`, `mail`, `fechaNacimiento`) VALUES 
(35123456, 'Lucia', 'Fernandez', 'luciaf@gmail.com', '1990-05-12'),
(28987654, 'Roberto', 'Sánchez', 'rober_s@yahoo.com', '1982-11-25'),
(40111222, 'Esteban', 'Quito', 'equito@gmail.com', '1998-03-08');

-- Autos
INSERT INTO `auto` (`patente`, `anioFabricacion`, `observaciones`, `color`, `modelo_id`, `precio`) VALUES 
('AA123BB', '2023', 'Nuevo - 0km', 'Blanco', 1, 25000000),
('BC456DF', '2022', 'Poco uso', 'Rojo', 2, 85000000),
('CC789GG', '2021', 'Service al día', 'Gris', 3, 22000000),
('DD012HH', '2020', 'Detalle en puerta', 'Azul', 4, 18000000),
('EE345II', '2024', 'Importado', 'Negro', 5, 95000000);

-- Compras
INSERT INTO `compra` (`id`, `fecha`, `auto_patente`, `cliente_dni`, `empleado_id`, `precio`) VALUES 
(101, '2024-04-01', 'AA123BB', 35123456, 1, 25000000),
(102, '2024-04-05', 'BC456DF', 28987654, 2, 85000000),
(103, '2024-04-10', 'CC789GG', 35123456, 3, 22000000);

-- Pagos
INSERT INTO `pago` (`id`, `monto`, `compra_id`, `metodoPago_id`) VALUES 
(1, 10000000, 101, 1), 
(2, 15000000, 101, 2),
(3, 85000000, 102, 3),
(4, 7000000, 103, 2),
(5, 7000000, 103, 2),
(6, 8000000, 103, 2);
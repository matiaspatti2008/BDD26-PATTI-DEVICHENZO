use stock;

-- PROVINCIAS (5 registros)
INSERT INTO `provincia` (`idProvincia`, `nombre`) VALUES 
(1, 'Buenos Aires'),
(2, 'Córdoba'), (3, 'Santa Fe'), (4, 'Mendoza'), (5, 'Tucumán');

-- CATEGORIAS (5 registros)
INSERT INTO `categoria` (`idCategoria`, `nombre`) VALUES 
(1, 'Hardware'), (2, 'Periféricos'), (3, 'Almacenamiento'), (4, 'Monitores'), (5, 'Networking');

-- ESTADOS (4 registros)
INSERT INTO `estado` (`idEstado`, `nombre`) VALUES 
(1, 'Pendiente'), (2, 'En Preparación'), (3, 'Enviado'), (4, 'Entregado');

-- PRODUCTOS (12 registros - Repitiendo categorías)
INSERT INTO `producto` (`codProducto`, `descripcion`, `precio`, `Categoria_idCategoria`, `stock`) VALUES 
(1, 'SSD 480GB Kingston', 35000.00, 3, 100), (2, 'SSD 960GB Kingston', 65000.00, 3, 50),
(3, 'Monitor 22 Samsung', 120000.00, 4, 20), (4, 'Monitor 24 LG', 150000.00, 4, 15),
(5, 'Mouse Logitech M185', 12000.00, 2, 200), (6, 'Teclado Genius USB', 8000.00, 2, 150),
(7, 'Router TP-Link Archer', 45000.00, 5, 30), (8, 'Switch 8 Puertos', 25000.00, 5, 40),
(9, 'RAM 8GB DDR4 Crucial', 28000.00, 1, 80), (10, 'RAM 16GB DDR4 Crucial', 52000.00, 1, 60),
(11, 'Gabinete Kit Sentey', 40000.00, 1, 25), (12, 'Fuente 600W 80 Plus', 55000.00, 1, 30);

-- CLIENTES (10 registros - Repitiendo provincias y categorías de cliente)
INSERT INTO `cliente` (`codCliente`, `razonSocial`, `contacto`, `direccion`, `telefono`, `codPost`, `porcDescuento`, `Provincia_idProvincia`, `categoria`) VALUES 
('C01', 'Soft S.A.', 'Juan Cruz', 'Calle 1', '111', '1000', 10.00, 1, 'A'),
('C02', 'Hard S.R.L.', 'Ana Luz', 'Calle 2', '222', '2000', 5.00, 2, 'B'),
('C03', 'Byte S.A.', 'Pedro Paz', 'Calle 3', '333', '3000', 10.00, 1, 'A'),
('C04', 'Mega Tech', 'Sonia Mar', 'Calle 4', '444', '4000', 0.00, 4, 'C'),
('C05', 'Giga Insumos', 'Luis Sol', 'Calle 5', '555', '5000', 5.00, 2, 'B'),
('C06', 'Tera System', 'Mara Rio', 'Calle 6', '666', '1000', 15.00, 1, 'A'),
('C07', 'Kilo Bits', 'Jose Rey', 'Calle 7', '777', '2000', 5.00, 2, 'B'),
('C08', 'Mundo IT', 'Rosa Oro', 'Calle 8', '888', '3000', 0.00, 3, 'C'),
('C09', 'E-Shop', 'Pilar Fe', 'Calle 9', '999', '4000', 10.00, 4, 'A'),
('C10', 'Zona Gamer', 'Alex Paz', 'Calle 10', '000', '5000', 20.00, 5, 'A');

-- PROVEEDORES (10 registros)
INSERT INTO `proveedor` (`idProveedor`, `razonSocial`, `contacto`, `direccion`, `telefono`, `codPost`, `Provincia_idProvincia`) VALUES 
(1, 'Mayorista 1', 'Carlos', 'Av A', '11', '1000', 1), (2, 'Mayorista 2', 'Diego', 'Av B', '22', '2000', 2),
(3, 'Importadora X', 'Fabio', 'Av C', '33', '1000', 1), (4, 'Tech Supply', 'Gabi', 'Av D', '44', '3000', 3),
(5, 'Distribuidora Z', 'Hugo', 'Av E', '55', '2000', 2), (6, 'Global Part', 'Ivan', 'Av F', '66', '4000', 4),
(7, 'Mega Part', 'Kiko', 'Av G', '77', '1000', 1), (8, 'Sud Insumos', 'Leo', 'Av H', '88', '5000', 5),
(9, 'Norte Tech', 'Mery', 'Av I', '99', '5000', 5), (10, 'Oeste Hard', 'Nico', 'Av J', '00', '2000', 2);

-- PEDIDOS (10 registros - Repitiendo clientes y estados)
INSERT INTO `pedido` (`idPedido`, `fecha`, `Estado_idEstado`, `Cliente_codCliente`) VALUES 
(1, NOW(), 4, 'C01'), (2, NOW(), 4, 'C01'), (3, NOW(), 1, 'C02'),
(4, NOW(), 2, 'C03'), (5, NOW(), 3, 'C04'), (6, NOW(), 1, 'C05'),
(7, NOW(), 2, 'C06'), (8, NOW(), 4, 'C07'), (9, NOW(), 1, 'C01'),
(10, NOW(), 3, 'C02');

-- DETALLE DE PEDIDOS (12 registros - Varios productos por pedido)
INSERT INTO `pedido_producto` (`cantidad`, `precioUnitario`, `Producto_codProducto`, `Pedido_idPedido`) VALUES 
(2, 35000, 1, 1), (1, 120000, 3, 1), (5, 12000, 5, 2), (1, 45000, 7, 3),
(2, 28000, 9, 4), (1, 40000, 11, 5), (3, 8000, 6, 6), (1, 150000, 4, 7),
(2, 65000, 2, 8), (4, 12000, 5, 9), (1, 25000, 8, 10), (2, 52000, 10, 10);

-- INGRESOS DE STOCK (10 registros)
INSERT INTO `ingresostock` (`idIngreso`, `fecha`, `remitoNro`, `Proveedor_idProveedor`) VALUES 
(1, NOW(), 'R001', 1), (2, NOW(), 'R002', 1), (3, NOW(), 'R003', 2),
(4, NOW(), 'R004', 3), (5, NOW(), 'R005', 4), (6, NOW(), 'R006', 5),
(7, NOW(), 'R007', 1), (8, NOW(), 'R008', 2), (9, NOW(), 'R009', 3),
(10, NOW(), 'R010', 10);

INSERT INTO `ingresostock_producto` (`item`, `cantidad`, `IngresoStock_idIngreso`, `Producto_codProducto`) VALUES 
(1, 100, 1, 1),   -- 100 SSDs en el Ingreso 1
(2, 50, 1, 2),    -- 50 SSDs adicionales en el mismo Ingreso 1
(1, 20, 2, 3),    -- 20 Monitores en el Ingreso 2
(1, 200, 3, 5),   -- 200 Mouse en el Ingreso 3
(2, 150, 3, 6),   -- 150 Teclados en el mismo Ingreso 3[cite: 1]
(1, 30, 4, 7),    -- 30 Routers en el Ingreso 4[cite: 1]
(1, 40, 5, 8),    -- 40 Switches en el Ingreso 5[cite: 1]
(1, 80, 6, 9),    -- 80 RAMs en el Ingreso 6[cite: 1]
(2, 60, 6, 10),   -- 60 RAMs de 16GB en el mismo Ingreso 6[cite: 1]
(1, 25, 7, 11),   -- 25 Gabinetes en el Ingreso 7[cite: 1]
(2, 30, 7, 12),   -- 30 Fuentes en el mismo Ingreso 7[cite: 1]
(1, 10, 8, 1);

-- PRODUCTO_PROVEEDOR (10 registros)
INSERT INTO `producto_proveedor` (`Proveedor_idProveedor`, `Producto_codProducto`, `precio`, `demoraEntrega`) VALUES 
(1, 1, 30000, 3), (1, 2, 58000, 3), (2, 3, 110000, 5), (3, 5, 10000, 2),
(4, 7, 40000, 7), (5, 9, 25000, 4), (1, 10, 48000, 3), (2, 4, 140000, 5),
(6, 11, 35000, 10), (10, 12, 50000, 2);

-- PRODUCTO_UBICACION (10 registros)
INSERT INTO `producto_ubicacion` (`idProducto_Ubicacion`, `cantidad`, `estanteria`, `Producto_codProducto`) VALUES 
(1, 50, 'A1', 1), (2, 50, 'A2', 1), (3, 50, 'B1', 2), (4, 20, 'C1', 3),
(5, 15, 'C2', 4), (6, 100, 'D1', 5), (7, 100, 'D2', 5), (8, 150, 'E1', 6),
(9, 30, 'F1', 7), (10, 40, 'G1', 8);
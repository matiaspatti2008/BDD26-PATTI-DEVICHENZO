USE stock;

-- Inserciones para 'provincia'
INSERT INTO `provincia` (`idProvincia`, `nombre`) VALUES
(1, 'Buenos Aires'),
(2, 'Córdoba'),
(3, 'Santa Fe'),
(4, 'Mendoza'),
(5, 'Tucumán'),
(6, 'Entre Ríos'),
(7, 'Salta'),
(8, 'Misiones');

-- Inserciones para 'categoria'
INSERT INTO `categoria` (`idCategoria`, `nombre`) VALUES
(1, 'Electrónica'),
(2, 'Hogar y Muebles'),
(3, 'Herramientas'),
(4, 'Indumentaria'),
(5, 'Alimentos y Bebidas'),
(6, 'Bazar');

-- Inserciones para 'estado'
INSERT INTO `estado` (`idEstado`, `nombre`) VALUES
(1, 'Pendiente'),
(2, 'En Proceso'),
(3, 'Enviado'),
(4, 'Entregado'),
(5, 'Cancelado');

-- Inserciones para 'cliente'
INSERT INTO `cliente` (`codCliente`, `razonSocial`, `contacto`, `direccion`, `telefono`, `codPost`, `porcDescuento`, `Provincia_idProvincia`, `categoria`) VALUES
('CLI001', 'Logística Norte S.A.', 'Juan Pérez', 'Av. Santa Fe 1234', '1145551234', '1425', 10.00, 1, 'Mayorista'),
('CLI002', 'Distribuidora Córdoba', 'María Belén', 'Colón 456', '3514223344', '5000', 5.00, 2, 'Minorista'),
('CLI003', 'Almacén Central', 'Carlos Gómez', 'San Martín 789', '3414889900', '2000', 15.00, 3, 'Mayorista'),
('CLI004', 'TecnoMundo SRL', 'Andrés Rossi', 'Las Heras 321', '2614556677', '5500', 0.00, 4, 'Minorista'),
('CLI005', 'Hipermercado Tucumán', 'Patricia Sosa', 'Av. Mitre 950', '3814112233', '4000', 12.50, 5, 'Grandes Cuentas'),
('CLI006', 'Ferretería El Puente', 'Jorge Peña', 'Urquiza 150', '3434998877', '3100', 8.00, 6, 'Minorista'),
('CLI007', 'Kiosco Norte', 'Laura Juárez', 'Balcarce 88', '3874332211', '4400', 0.00, 7, 'Minorista'),
('CLI008', 'Mercado Posadas', 'Enrique Selva', 'Ayacucho 540', '3764554433', '3300', 5.00, 8, 'Minorista');

-- Inserciones para 'proveedor'
INSERT INTO `proveedor` (`idProveedor`, `razonSocial`, `contacto`, `direccion`, `telefono`, `codPost`, `Provincia_idProvincia`) VALUES
(101, 'Importadora Tech S.A.', 'Roberto Plaza', 'Av. Corrientes 4500', '1147778888', '1199', 1),
(102, 'Fábrica de Muebles S.R.L.', 'Luis Madera', 'Ruta 9 Km 40', '3514991122', '5123', 2),
(103, 'Herramientas Argentinas', 'Metalúrgica José', 'Av. Facundo Zuviría 5500', '3424119988', '3000', 3),
(104, 'Textiles del Sur', 'Ana Tejedo', 'San Juan 450', '2614332211', '5500', 4),
(105, 'Distribuidora de Bebidas NOA', 'Marcos Vino', 'Belgrano 120', '3814556611', '4000', 5);

-- Inserciones para 'producto'
INSERT INTO `producto` (`codProducto`, `descripcion`, `precio`, `Categoria_idCategoria`, `stock`) VALUES
(10, 'Smart TV 50 pulg 4K UHD', 450000.00, 1, 35),
(11, 'Notebook Intel i5 16GB RAM', 890000.00, 1, 15),
(12, 'Smartphone 128GB Android', 299000.00, 1, 60),
(13, 'Mesa de Comedor de Paraíso', 120000.00, 2, 8),
(14, 'Silla de Pana Gris x4 unidades', 180000.00, 2, 12),
(15, 'Taladro Percutor 750W', 65000.00, 3, 25),
(16, 'Caja de Herramientas 22 Pulgadas', 28000.00, 3, 40),
(17, 'Remera Básica Algodón Negra L', 15000.00, 4, 150),
(18, 'Pantalón Jean Clásico Talle 42', 35000.00, 4, 90),
(19, 'Pack Cerveza IPAs Premium x6', 12000.00, 5, 200),
(20, 'Café Tostado en Granos 1Kg', 22000.00, 5, 85),
(21, 'Set de Ollas de Acero Inoxidable x5', 135000.00, 6, 18);

-- Inserciones para 'producto_proveedor' (Relación Muchos a Muchos)
INSERT INTO `producto_proveedor` (`Proveedor_idProveedor`, `Producto_codProducto`, `precio`, `demoraEntrega`) VALUES
(101, 10, 380000.00, 5),
(101, 11, 750000.00, 7),
(101, 12, 240000.00, 4),
(102, 13, 90000.00, 15),
(102, 14, 140000.00, 12),
(103, 15, 48000.00, 3),
(103, 16, 19000.00, 3),
(104, 17, 9500.00, 10),
(104, 18, 22000.00, 10),
(105, 19, 8000.00, 2),
(105, 20, 15000.00, 2);

-- Inserciones para 'producto_ubicacion' (Stock físico en depósito)
INSERT INTO `producto_ubicacion` (`idProducto_Ubicacion`, `cantidad`, `estanteria`, `Producto_codProducto`) VALUES
(1, 20, 'Estante A-01', 10),
(2, 15, 'Estante A-02', 10),
(3, 15, 'Estante A-03', 11),
(4, 60, 'Estante B-01', 12),
(5, 8, 'Depósito Posterior Muebles', 13),
(6, 12, 'Depósito Posterior Muebles', 14),
(7, 25, 'Estante C-01', 15),
(8, 40, 'Estante C-02', 16),
(9, 150, 'Sector Textil Rack 1', 17),
(10, 90, 'Sector Textil Rack 2', 18),
(11, 200, 'Cámara Frigorífica 2', 19),
(12, 85, 'Estante D-05', 20),
(13, 18, 'Estante B-12', 21);

-- Inserciones para 'ingresostock'
INSERT INTO `ingresostock` (`idIngreso`, `fecha`, `remitoNro`, `Proveedor_idProveedor`) VALUES
(501, '2026-01-10 09:30:00', 'R-0001-00023451', 101),
(502, '2026-02-15 11:15:00', 'R-0003-00089221', 103),
(503, '2026-03-01 14:00:00', 'R-0002-00011400', 105),
(504, '2026-04-20 08:45:00', 'R-0005-00004566', 104);

-- Inserciones para 'ingresostock_producto'
INSERT INTO `ingresostock_producto` (`item`, `cantidad`, `IngresoStock_idIngreso`, `Producto_codProducto`) VALUES
(1, 10, 501, 10),
(2, 5, 501, 11),
(3, 20, 501, 12),
(1, 15, 502, 15),
(2, 30, 502, 16),
(1, 100, 503, 19),
(2, 50, 503, 20),
(1, 80, 504, 17),
(2, 40, 504, 18);

-- Inserciones para 'pedido'
INSERT INTO `pedido` (`idPedido`, `fecha`, `Estado_idEstado`, `Cliente_codCliente`) VALUES
(1001, '2026-05-02 10:00:00', 4, 'CLI001'),
(1002, '2026-05-05 15:30:00', 3, 'CLI003'),
(1003, '2026-05-10 11:20:00', 2, 'CLI005'),
(1004, '2026-05-14 09:10:00', 1, 'CLI002'),
(1005, '2026-05-15 17:45:00', 1, 'CLI006'),
(1006, '2026-05-16 12:00:00', 5, 'CLI004');

-- Inserciones para 'pedido_producto'
INSERT INTO `pedido_producto` (`item`, `cantidad`, `precioUnitario`, `Producto_codProducto`, `Pedido_idPedido`) VALUES
(1, 2, 450000.00, 10, 1001),
(2, 1, 890000.00, 11, 1001),
(3, 5, 15000.00, 17, 1001),
(1, 1, 120000.00, 13, 1002),
(2, 4, 180000.00, 14, 1002),
(1, 3, 299000.00, 12, 1003),
(2, 10, 22000.00, 20, 1003),
(3, 2, 135000.00, 21, 1003),
(1, 1, 65000.00, 15, 1004),
(2, 2, 28000.00, 16, 1004),
(1, 24, 12000.00, 19, 1005),
(1, 1, 890000.00, 11, 1006);
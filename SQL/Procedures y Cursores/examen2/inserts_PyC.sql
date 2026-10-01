USE `examen2`;

INSERT INTO `Empleado` (`id_empleado`, `nombre`, `apellido`, `sector`) VALUES
(1, 'Gonzalo', 'Fernández', 'Línea de Ensamblado A'),
(2, 'Martina', 'Gómez', 'Control de Calidad'),
(3, 'Lucas', 'Rodríguez', 'Línea de Ensamblado B'),
(4, 'Sofía', 'Benítez', 'Embalaje y Despacho'),
(5, 'Nicolás', 'Álvarez', 'Línea de Ensamblado A'),
(6, 'Valentina', 'Díaz', 'Matricería y Moldes'),
(7, 'Mateo', 'Romero', 'Control de Calidad'),
(8, 'Camila', 'López', 'Línea de Ensamblado B');

INSERT INTO `Producto` (`id_producto`, `nombre`, `categoria`, `requiere_revision`) VALUES
(101, 'Sensor de Proximidad Industrial X-10', 'Componentes Electrónicos', 1),
(102, 'Microcontrolador Programable AT-90', 'Componentes Electrónicos', 0),
(103, 'Placa de Circuito Impreso PCB-V2', 'Componentes Electrónicos', 1),
(104, 'Carcasa de Aluminio Inyectado L', 'Estructuras', 0),
(105, 'Soporte de Acero Reforzado KW', 'Estructuras', 0),
(106, 'Cableado de Cobre Alta Resistencia 1m', 'Conectividad', 0),
(107, 'Módulo Relé de 4 Canales Optoacoplado', 'Componentes Electrónicos', 1),
(108, 'Tornillería de Precisión M4 (Pack x100)', 'Fijaciones', 0);

INSERT INTO `ReporteProduccion` (`id_empleado`, `total_producido`, `total_defectuosos`) VALUES
(1, 1450, 25),
(2, 0, 0), -- Personal de calidad, no produce piezas directamente
(3, 2100, 84),
(4, 5200, 12), -- Embalaje suele procesar mucho volumen con bajo descarte
(5, 1180, 45),
(6, 450, 8),
(7, 0, 0),
(8, 1890, 50);

INSERT INTO `OrdenProduccion` (`id_orden`, `fecha`, `id_empleado`) VALUES
(5001, '2026-05-01', '1'),
(5002, '2026-05-02', '3'),
(5003, '2026-05-02', '5'),
(5004, '2026-05-03', '6'),
(5005, '2026-05-04', '1'),
(5006, '2026-05-05', '8'),
(5007, '2026-05-05', '3'),
(5008, '2026-05-06', '5'),
(5009, '2026-05-10', '6'),
(5010, '2026-05-12', '8'),
(5011, '2026-05-15', '1'),
(5012, '2026-05-18', '3');

INSERT INTO `DetalleOrden` (`id_orden`, `id_producto`, `cantidad`, `defectuosos`) VALUES
(5001, 101, 150, 2),
(5001, 102, 200, 0),
(5001, 106, 150, 5),
(5002, 103, 300, 12),
(5002, 107, 100, 4),
(5003, 104, 80, 1),
(5003, 105, 80, 0),
(5004, 104, 150, 3),
(5005, 101, 100, 1),
(5005, 108, 500, 10),
(5006, 102, 400, 8),
(5006, 106, 400, 2),
(5007, 103, 250, 15),
(5008, 105, 120, 2),
(5008, 108, 600, 0),
(5009, 104, 200, 5),
(5010, 107, 150, 3),
(5011, 101, 120, 0),
(5012, 103, 350, 20),
(5012, 106, 200, 1);
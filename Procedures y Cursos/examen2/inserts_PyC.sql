USE examen2;

INSERT INTO `Producto` (`id_producto`, `nombre`, `categoria`, `requiere_revision`, `Productocol`) VALUES
(1, 'Eje de Transmisión', 'Mecánica', 'Sí', 1),
(2, 'Válvula de Seguridad', 'Hidráulica', 'No', 1),
(3, 'Sensor de Humedad', 'Electrónica', 'Sí', 1),
(4, 'Abrazadera Acero', 'Ferretería', 'No', 0),
(5, 'Controlador Lógico', 'Electrónica', 'Sí', 1),
(6, 'Bomba de Vacío', 'Hidráulica', 'Sí', 1),
(7, 'Rodamiento Esférico', 'Mecánica', 'No', 1),
(8, 'Cable de Alta Tensión', 'Electrónica', 'Sí', 1);

INSERT INTO `Empleado` (`id_empleado`, `nombre`, `apellido`, `sector`) VALUES
(1, 'Roberto', 'Gómez', 'Producción'),
(2, 'Elena', 'Martínez', 'Producción'),
(3, 'Mario', 'Paz', 'Calidad'),
(4, 'Lucía', 'Fernández', 'Producción'),
(5, 'Ricardo', 'Torres', 'Ensamblaje');

INSERT INTO `OrdenProduccion` (`id_orden`, `fecha`, `id_empleado`) VALUES
(1001, '2026-05-01', 1),
(1002, '2026-05-01', 2),
(1003, '2026-05-02', 1),
(1004, '2026-05-02', 4),
(1005, '2026-05-03', 2),
(1006, '2026-05-04', 5),
(1007, '2026-05-05', 1),
(1008, '2026-05-05', 4),
(1009, '2026-05-06', 2),
(1010, '2026-05-06', 5);

INSERT INTO `DetalleOrden` (`id_orden`, `id_producto`, `cantidad`, `defectuosos`) VALUES
(1001, 1, 50, 2),
(1001, 2, 30, 0),
(1002, 3, 100, 5),
(1002, 1, 40, 1),
(1003, 1, 60, 3),
(1003, 5, 20, 2),
(1004, 4, 500, 10),
(1004, 2, 45, 1),
(1005, 3, 110, 8),
(1005, 6, 15, 0),
(1006, 7, 200, 4),
(1007, 1, 55, 2),
(1007, 8, 10, 1),
(1008, 4, 300, 5),
(1008, 2, 25, 0),
(1009, 3, 90, 4),
(1010, 7, 150, 2),
(1010, 6, 20, 1);

INSERT INTO `ReporteProduccion` (`id_empleado`, `total_producido`, `total_defectuosos`) VALUES
(1, 195, 8),
(2, 340, 18),
(4, 870, 16),
(5, 370, 7),
(3, 0, 0);
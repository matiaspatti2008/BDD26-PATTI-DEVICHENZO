-- Tablas TP INTEGRADOR
CREATE DATABASE tp_ecommerce;
USE tp_ecommerce;

-- 1. Tabla de Catálogo de Niveles
CREATE TABLE nivel_usuario (
    nivel_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    ventas_min INT NOT NULL,
    facturacion_min DECIMAL(15, 2) NOT NULL
);


-- 2. Tabla de Usuarios
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contasena VARCHAR(255) NOT NULL,
    nivel_usuario_id INT DEFAULT NULL,
    reputacion_actual DECIMAL(5, 2) DEFAULT 0,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nivel FOREIGN KEY (nivel_usuario_id) REFERENCES nivel_usuario(nivel_id)
);


-- 3. Catálogo de Niveles de Publicaciones
CREATE TABLE tipos_publicacion (
    tipo_publicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    prioridad_exposicion INT NOT NULL
);


-- 4. Tabla de Categorías de Productos
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);


-- 5. Tabla de Productos
CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    categoria_id INT DEFAULT NULL,
    CONSTRAINT fk_producto_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE SET NULL
);


-- 6. Catálogo de Medios de Pago
CREATE TABLE medios_pago (
    medio_pago_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);


-- 7. Catálogo de Medios de Envío
CREATE TABLE medios_envio (
    medio_envio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);


-- 8. Tabla de Publicaciones
CREATE TABLE publicaciones (
    publicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    producto_id INT NOT NULL,
    tipo_publicacion_id INT NOT NULL,
    modalidad VARCHAR(20) NOT NULL,
    precio_base DECIMAL(15, 2) NOT NULL,
    precio_actual DECIMAL(15, 2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activa',
    fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    medio_pago_id INT NULL,
    stock INT NOT NULL,
    CONSTRAINT fk_pub_medio_pago FOREIGN KEY (medio_pago_id) REFERENCES medios_pago(medio_pago_id),
    CONSTRAINT fk_pub_vendedor FOREIGN KEY (vendedor_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_pub_producto FOREIGN KEY (producto_id) REFERENCES productos(producto_id) ON DELETE RESTRICT,
    CONSTRAINT fk_pub_tipo FOREIGN KEY (tipo_publicacion_id) REFERENCES tipos_publicacion(tipo_publicacion_id)
);


-- 9. Tabla de Ofertas (Exclusiva para Subasta)
CREATE TABLE ofertas_subasta (
    oferta_id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    comprador_id INT NOT NULL,
    monto_ofertado DECIMAL(15, 2) NOT NULL,
    fecha_oferta DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_oferta_pub FOREIGN KEY (publicacion_id) REFERENCES publicaciones(publicacion_id),
    CONSTRAINT fk_oferta_comprador FOREIGN KEY (comprador_id) REFERENCES usuarios(usuario_id)
);


-- 10. Tabla de Preguntas
CREATE TABLE preguntas (
    pregunta_id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    usuario_pregunta_id INT NOT NULL,
    pregunta TEXT NOT NULL,
    fecha_pregunta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(publicacion_id),
    FOREIGN KEY (usuario_pregunta_id) REFERENCES usuarios(usuario_id)
);


-- 11. Tabla de Respuestas
CREATE TABLE respuestas (
    respuesta_id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta_id INT NOT NULL UNIQUE,
    usuario_respuesta_id INT NOT NULL,
    respuesta TEXT NOT NULL,
    fecha_respuesta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pregunta_id) REFERENCES preguntas(pregunta_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_respuesta_id) REFERENCES usuarios(usuario_id)
);


-- 12. Tabla de Transacciones
CREATE TABLE transacciones (
    transaccion_id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    comprador_id INT NOT NULL,
    medio_pago_id INT NULL,
    medio_envio_id INT NULL,
    monto DECIMAL(15, 2) NOT NULL,
    cantidad INT NOT NULL,
    fecha_transaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    es_concretada BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_trans_publicacion FOREIGN KEY (publicacion_id) REFERENCES publicaciones(publicacion_id),
    CONSTRAINT fk_trans_vendedor FOREIGN KEY (vendedor_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_trans_comprador FOREIGN KEY (comprador_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_trans_pago FOREIGN KEY (medio_pago_id) REFERENCES medios_pago(medio_pago_id),
    CONSTRAINT fk_trans_envio FOREIGN KEY (medio_envio_id) REFERENCES medios_envio(medio_envio_id)
);


-- 13. Tabla de Calificaciones
CREATE TABLE calificaciones (
    calificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    transaccion_id INT NOT NULL,
    usuario_evaluado_id INT NOT NULL,
    puntaje INT NOT NULL,
    comentario TEXT,
    CONSTRAINT fk_transaccion FOREIGN KEY (transaccion_id) REFERENCES transacciones(transaccion_id),
    CONSTRAINT fk_evaluado FOREIGN KEY (usuario_evaluado_id) REFERENCES usuarios(usuario_id)
);


-- 14. Tabla de Notificaciones
CREATE TABLE notificaciones (
    notificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);


-- 15. Tabla de estadísticas
CREATE TABLE estadisticas_diarias (
    estadistica_id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    total_vendedores_activos INT NOT NULL,
    total_compradores_activos INT NOT NULL,
    total_productos_vendidos INT NOT NULL,
    facturacion_dia DECIMAL(15, 2) NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);



-- INSERTS
-- 1. Catálogo de Niveles de Usuario
INSERT INTO nivel_usuario (nombre, ventas_min, facturacion_min) VALUES
('Normal', 1, 0.00),
('Platinum', 6, 100000.00),
('Gold', 11, 1000000.00);

-- 2. Catálogo de Niveles de Publicaciones
INSERT INTO tipos_publicacion (nombre, prioridad_exposicion) VALUES
('Gratuita', 1),
('Clásica', 2),
('Premium', 3);

-- 3. Catálogo de Categorías
INSERT INTO categorias (nombre) VALUES
('Electrónica'),
('Consolas y Videojuegos'),
('Computación'),
('Indumentaria'),
('Hogar y Muebles'),
('Deportes');

-- 4. Catálogo de Medios de Pago
INSERT INTO medios_pago (nombre) VALUES
('Mercado Pago'),
('Tarjeta de Crédito'),
('Transferencia Bancaria'),
('Efectivo');

-- 5. Catálogo de Medios de Envío
INSERT INTO medios_envio (nombre) VALUES
('Mercado Envíos'),
('Correo Argentino'),
('Retiro en Persona');

-- 6. Usuarios
INSERT INTO usuarios (nombre, email, contasena, nivel_usuario_id, reputacion_actual, fecha_registro) VALUES
('Juan Pérez', 'juan.perez@email.com', 'pass123', 3, 100.00, '2025-01-10 10:00:00'),
('María Gómez', 'maria.gomez@email.com', 'pass456', 2, 80.00, '2025-02-15 11:30:00'),
('Carlos López', 'carlos.lopez@email.com', 'pass789', 1, 60.00, '2025-03-01 14:20:00'),
('Ana Martínez', 'ana.martinez@email.com', 'passabc', 1, 0.00, '2025-03-10 09:15:00'),
('Pedro Rodríguez', 'pedro.rodriguez@email.com', 'passxyz', NULL, 0.00, '2025-03-12 16:45:00'),
('Laura Fernández', 'laura.f@email.com', 'passlaura', 3, 95.00, '2025-01-05 08:00:00'),
('Diego Torres', 'diego.t@email.com', 'passdiego', 2, 85.00, '2025-02-01 12:10:00'),
('Sofia Benítez', 'sofia.b@email.com', 'passsofia', 1, 40.00, '2025-03-15 17:30:00'),
('Lucas Castro', 'lucas.c@email.com', 'passlucas', NULL, 0.00, '2025-03-20 19:00:00'),
('Lucía Morales', 'lucia.m@email.com', 'passlucia', 2, 90.00, '2025-01-20 11:11:00');

-- 7. Productos
INSERT INTO productos (usuario_id, nombre, descripcion, categoria_id) VALUES
(1, 'PlayStation 5', 'Consola Sony PS5 825GB con Joystick', 2),
(1, 'iPhone 13', 'Apple iPhone 13 128GB Color Negro', 1),
(2, 'Notebook Gamer Lenovo', 'Lenovo Legion 5 Ryzen 7 16GB RAM', 3),
(3, 'Remera Algodón', 'Remera lisa 100% algodón talle M', 4),
(2, 'Monitor LG 24', 'Monitor IPS Full HD 75Hz', 3),
(6, 'Silla Gamer Pro', 'Silla ergonómica reclinable con almohadones', 5),
(6, 'Smart TV Samsung 55', 'Televisor 4K UHD Smart TV HDR', 1),
(7, 'Bicicleta de Montaña', 'Bicicleta Rodado 29 21 Cambios Shimano', 6),
(7, 'Xbox Series X', 'Consola Microsoft Xbox Series X 1TB', 2),
(10, 'Placa de Video RTX 3060', 'NVIDIA GeForce RTX 3060 12GB GDDR6', 3),
(3, 'Zapatillas Deportivas', 'Zapatillas para running talle 42', 6),
(2, 'Escritorio de Madera', 'Escritorio industrial 120x60cm', 5);

-- 8. Publicaciones (Con precio_actual = precio_base para habilitar las ofertas)
INSERT INTO publicaciones (vendedor_id, producto_id, tipo_publicacion_id, modalidad, precio_base, precio_actual, estado, fecha_inicio, fecha_fin, medio_pago_id, stock) VALUES
(1, 1, 3, 'Venta Directa', 500000.00, 500000.00, 'Activa', NOW(), NULL, 1, 5),
(1, 2, 3, 'Subasta', 300000.00, 300000.00, 'Activa', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 2, 1),
(2, 3, 2, 'Venta Directa', 800000.00, 800000.00, 'Pausada', '2024-11-01 10:00:00', NULL, 1, 2),
(3, 4, 1, 'Venta Directa', 15000.00, 15000.00, 'Activa', NOW(), NULL, NULL, 10),
(2, 5, 2, 'Subasta', 200000.00, 200000.00, 'Finalizada', '2025-02-01 10:00:00', '2025-02-08 10:00:00', 1, 0),
(6, 6, 3, 'Venta Directa', 180000.00, 180000.00, 'Activa', NOW(), NULL, 1, 8),
(6, 7, 3, 'Venta Directa', 650000.00, 650000.00, 'Activa', NOW(), NULL, 2, 3),
(7, 8, 2, 'Venta Directa', 250000.00, 250000.00, 'Activa', NOW(), NULL, 1, 4),
(7, 9, 3, 'Subasta', 450000.00, 450000.00, 'Activa', NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), 1, 1),
(10, 10, 3, 'Venta Directa', 400000.00, 400000.00, 'Activa', NOW(), NULL, 3, 6),
(3, 11, 1, 'Venta Directa', 45000.00, 45000.00, 'Activa', NOW(), NULL, 4, 12),
(2, 12, 2, 'Venta Directa', 75000.00, 75000.00, 'Pausada', NOW(), NULL, 1, 2);

-- 9. Ofertas en Subastas (Superan el precio_base de cada publicación)
INSERT INTO ofertas_subasta (publicacion_id, comprador_id, monto_ofertado, fecha_oferta) VALUES
(2, 2, 320000.00, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 3, 350000.00, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(5, 3, 220000.00, '2025-02-05 15:30:00'),
(9, 4, 460000.00, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(9, 5, 480000.00, NOW());

-- 10. Preguntas
-- Incluye preguntas creadas en el día (CURRENT_DATE) para probar la Vista 3 (tendencia).
INSERT INTO preguntas (publicacion_id, usuario_pregunta_id, pregunta, fecha_pregunta) VALUES
(1, 2, '¿Tiene garantía de fábrica oficial?', NOW()),
(1, 3, '¿Haces envíos en el día?', NOW()),
(4, 2, '¿Qué colores tenés disponibles?', NOW()),
(6, 4, '¿Soporta hasta cuántos kilos?', NOW()),
(7, 5, '¿Es compatible con soporte de pared VESA?', NOW()),
(10, 8, '¿Es la versión LHR o no?', NOW()),
(1, 4, '¿Trae un solo mando o dos?', NOW()),
(6, 8, '¿Tienen stock para retirar mañana por el local?', NOW());

-- 11. Respuestas
-- Deja preguntas de publicaciones activas sin responder para probar la Vista 1 y Evento 3.
INSERT INTO respuestas (pregunta_id, usuario_respuesta_id, respuesta, fecha_respuesta) VALUES
(1, 1, 'Hola, sí, cuenta con 12 meses de garantía oficial.', NOW()),
(4, 6, 'Hola, soporta hasta 150 kg sin problemas.', NOW()),
(5, 6, 'Hola, sí, es compatible con soportes VESA 200x200.', NOW());

-- 12. Transacciones
INSERT INTO transacciones (publicacion_id, vendedor_id, comprador_id, medio_pago_id, medio_envio_id, monto, cantidad, fecha_transaccion, es_concretada) VALUES
(1, 1, 2, 1, 1, 500000.00, 1, '2025-03-01 15:00:00', TRUE),
(1, 1, 3, 2, 2, 1000000.00, 2, '2025-03-05 18:20:00', TRUE),
(5, 2, 3, 1, 1, 220000.00, 1, '2025-02-08 11:00:00', TRUE),
(6, 6, 4, 1, 1, 180000.00, 1, '2025-03-10 10:15:00', TRUE),
(7, 6, 5, 2, 1, 650000.00, 1, '2025-03-12 14:00:00', TRUE),
(8, 7, 8, 1, 3, 250000.00, 1, '2025-03-14 16:30:00', TRUE),
(10, 10, 2, 3, 2, 400000.00, 1, '2025-03-16 09:45:00', TRUE),
(11, 3, 9, 4, 3, 45000.00, 1, '2025-03-18 12:00:00', FALSE);

-- 13. Calificaciones
INSERT INTO calificaciones (transaccion_id, usuario_evaluado_id, puntaje, comentario) VALUES
(1, 1, 5, 'Excelente vendedor, el producto llegó imprevistamente rápido.'),
(2, 1, 4, 'Todo bien, muy buena atención.'),
(3, 2, 5, 'Subasta transparente, envío impecable.'),
(4, 6, 5, 'Excelente producto y calidad de atención.'),
(5, 6, 4, 'Todo en orden, llegó bien embalado.'),
(6, 7, 3, 'Demoró un poco el despacho pero la bici excelente.'),
(7, 10, 5, 'Placa en excelente estado y empaque original.');

-- 14. Notificaciones
INSERT INTO notificaciones (usuario_id, mensaje, fecha_envio) VALUES
(1, 'Bienvenido a la plataforma tp_ecommerce.', NOW()),
(2, 'Tienes una pregunta sin responder en tu publicación.', NOW()),
(6, 'Tu transacción #4 ha sido completada con éxito.', NOW());

-- 15. Estadísticas Diarias
INSERT INTO estadisticas_diarias (fecha, total_vendedores_activos, total_compradores_activos, total_productos_vendidos, facturacion_dia) VALUES
(DATE_SUB(CURDATE(), INTERVAL 2 DAY), 2, 2, 2, 830000.00),
(DATE_SUB(CURDATE(), INTERVAL 1 DAY), 4, 4, 4, 1550000.00);

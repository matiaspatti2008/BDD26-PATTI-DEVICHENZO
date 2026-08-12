-- Tablas TP INTEGRADOR

-- 1. Tabla de Catálogo de Niveles
CREATE TABLE niveles_usuario (
    nivel_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre ENUM('Normal', 'Platinum', 'Gold') NOT NULL,
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
    reputacion_actual DECIMAL(5, 2) DEFAULT 0.00,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nivel FOREIGN KEY (nivel_usuario_id) REFERENCES niveles_usuario(nivel_id)
);


-- 3. Tabla de Transacciones
CREATE TABLE transacciones (
    transaccion_id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    comprador_id INT NOT NULL,
    medio_pago_id INT NULL,
    medio_envio_id INT NULL,
    monto DECIMAL(15, 2) NOT NULL,
    fecha_transaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    es_concretada BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_trans_publicacion FOREIGN KEY (publicacion_id) REFERENCES publicaciones(publicacion_id),
    CONSTRAINT fk_trans_vendedor FOREIGN KEY (vendedor_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_trans_comprador FOREIGN KEY (comprador_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_trans_pago FOREIGN KEY (medio_pago_id) REFERENCES medios_pago(medio_pago_id),
    CONSTRAINT fk_trans_envio FOREIGN KEY (medio_envio_id) REFERENCES medios_envio(medio_envio_id)
);


-- 4. Tabla de Calificaciones
CREATE TABLE calificaciones (
    calificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    transaccion_id INT NOT NULL,
    usuario_evaluado_id INT NOT NULL,
    puntaje INT NOT NULL,
    comentario TEXT,
    CONSTRAINT fk_transaccion FOREIGN KEY (transaccion_id) REFERENCES transacciones(transaccion_id),
    CONSTRAINT fk_evaluado FOREIGN KEY (usuario_evaluado_id) REFERENCES usuarios(usuario_id)
);


-- 5. Catálogo de Niveles de Publicaciones
CREATE TABLE tipos_publicacion (
    tipo_publicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre ENUM('Bronce', 'Plata', 'Oro', 'Platino') NOT NULL,
    prioridad_exposicion INT NOT NULL
);


-- 6. Tabla de Categorías de Productos
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);


-- 7. Tabla de Productos
CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    categoria_id INT DEFAULT NULL,
    CONSTRAINT fk_producto_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE SET NULL
);


-- 8. Tabla de Publicaciones
CREATE TABLE publicaciones (
    publicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    producto_id INT NOT NULL,
    tipo_publicacion_id INT NOT NULL,
    modalidad ENUM('Venta Directa', 'Subasta') NOT NULL,
    precio_base DECIMAL(15, 2) NOT NULL,
    precio_actual DECIMAL(15, 2) NOT NULL,
    estado ENUM('Activa', 'Pausada', 'Finalizada') DEFAULT 'Activa',
    fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
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


-- 10. Tabla de Preguntas y Respuestas
CREATE TABLE preguntas_respuestas (
    pregunta_id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    usuario_pregunta_id INT NOT NULL,
    pregunta TEXT NOT NULL,
    fecha_pregunta DATETIME DEFAULT CURRENT_TIMESTAMP,
    respuesta TEXT NULL,
    fecha_respuesta DATETIME NULL,
    CONSTRAINT fk_pr_publicacion FOREIGN KEY (publicacion_id) REFERENCES publicaciones(publicacion_id),
    CONSTRAINT fk_pr_usuario FOREIGN KEY (usuario_pregunta_id) REFERENCES usuarios(usuario_id)
);


-- 11. Catálogo de Medios de Pago
CREATE TABLE medios_pago (
    medio_pago_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre ENUM('Tarjeta de Crédito', 'Tarjeta de Débito', 'Pago Fácil', 'Rapipago') NOT NULL
);


-- 12. Catálogo de Medios de Envío
CREATE TABLE medios_envio (
    medio_envio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre ENUM('OCA', 'Correo Argentino') NOT NULL
);
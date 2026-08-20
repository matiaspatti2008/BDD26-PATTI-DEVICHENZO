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
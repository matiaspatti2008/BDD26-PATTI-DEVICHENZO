#1.
-- Crear seis usuarios diferentes con contraseñas seguras: uno para analista de stock,
-- otro para gestor de productos, uno para analista de órdenes, uno para usuario de reportes,
-- uno para desarrollo y finalmente un administrador de base de datos. Una vez creados,
-- verificar que se hayan creado correctamente consultando la tabla de usuarios del sistema.
CREATE USER analista_stock@localhost IDENTIFIED BY 'anst_loho123';
CREATE USER gestor_productos@localhost IDENTIFIED BY 'gepr_loho456';
CREATE USER analista_ordenes@localhost IDENTIFIED BY 'anor_loho789';
CREATE USER usuario_reportes@localhost IDENTIFIED BY 'usre_loho987';
CREATE USER usuario_desarrollo@localhost IDENTIFIED BY 'usde_loho654';
CREATE USER administrador_base_datos@localhost IDENTIFIED BY 'adbd_loho321';

SELECT * FROM mysql.user;

#2.
-- Crear cinco roles diferentes.
-- El primero debe tener permisos de ejecución sobre los procedimientos de stock (actualizarStock, reducirPrecio,
-- actualizarPrecioPorProveedor) y permisos de lectura en toda la base de datos stock.
-- El segundo debe permitir ejecutar procedimientos de gestión de órdenes (borrarOrden, borrarLineaProductos,
-- actualizarComentarios) y leer las tablas orders y orderdetails.
-- El tercero debe ser un rol de solo lectura para reportes que permita select en ambas bases de datos y
-- ejecución de funciones de consulta.
-- El cuarto debe ser un rol para desarrollo que permita realizar todas las sentencias de DML, creación y ejecución
-- de todas las rutinas, triggers y eventos. Finalmente, crear un rol de administrador con acceso casi total.
-- Una vez creados, verificar que los roles existan consultando las relaciones de roles en el sistema.
CREATE ROLE 'rol_stock';
GRANT EXECUTE ON PROCEDURE stock.actualizarStock TO 'rol_stock'; -- Estos para procedimientos
GRANT EXECUTE ON PROCEDURE stock.reducirPrecio TO 'rol_stock';
GRANT EXECUTE ON PROCEDURE stock.actualizarPrecioUnitario TO 'rol_stock';
GRANT SELECT ON stock.* TO 'rol_stock'; -- Estp seria para permisos de lectura
-- --------------------
CREATE ROLE 'rol_gestion';
GRANT EXECUTE ON PROCEDURE classicmodels.Eliminar_Orden TO 'rol_stock'; -- Para procedimiento
GRANT EXECUTE ON PROCEDURE classicmodels.Eliminar_LineaProducto TO 'rol_stock';
GRANT EXECUTE ON PROCEDURE classicmodels.Modificar_Comment TO 'rol_stock';
GRANT SELECT ON classicmodels.orders TO 'rol_gestion'; -- Para leer tablas especificas
GRANT SELECT ON classicmodels.orderdetails TO 'rol_gestion';
-- --------------------
CREATE ROLE 'rol_reporte';
GRANT SELECT ON classicmodels.* TO 'rol_reporte'; -- Para lectura
GRANT SELECT ON stock.* TO 'rol_reporte';
GRANT EXECUTE ON FUNCTION classicmodels.* TO 'rol_reporte'; -- para realizar funciones // CAMBIAR
GRANT EXECUTE ON FUNCTION stock.* TO 'rol_reporte';
-- --------------------
CREATE ROLE 'rol_desarrollo';
GRANT SELECT ON classicmodels.* TO 'rol_desarrollo';
GRANT SELECT ON stock.* TO 'rol_desarrollo';
GRANT INSERT ON classicmodels.* TO 'rol_desarrollo';
GRANT INSERT ON stock.* TO 'rol_desarrollo';
GRANT UPDATE ON classicmodels.* TO 'rol_desarrollo';
GRANT UPDATE ON stock.* TO 'rol_desarrollo';
GRANT DELETE ON classicmodels.* TO 'rol_desarrollo';
GRANT DELETE ON stock.* TO 'rol_desarrollo';

GRANT CREATE ON classicmodels.* TO 'rol_desarrollo';
GRANT CREATE ON stock.* TO 'rol_desarrollo';

GRANT TRIGGER ON classicmodels.* TO 'rol_desarrollo';
GRANT TRIGGER ON stock.* TO 'rol_desarrollo';
GRANT EVENT ON classicmodels.* TO 'rol_desarrollo';
GRANT EVENT ON stock.* TO 'rol_desarrollo';
-- --------------------
CREATE ROLE 'rol_admin';
GRANT ALL PRIVILEGES ON classicmodels.* TO 'rol_admin';
GRANT ALL PRIVILEGES ON stock.* TO 'rol_admin';
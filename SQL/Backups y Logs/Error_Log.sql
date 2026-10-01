#7)
SELECT * FROM performance_schema.error_log
order by LOGGED desc LIMIT 20;

-- resultados
/* '2026-08-06 07:52:44.039128', '8', 'Warning', 'MY-013360', 'Server', 'Plugin mysql_native_password reported: \'\'mysql_native_password\' is deprecated and will be removed in a future release. Please use caching_sha2_password instead\''
'2026-08-06 07:46:07.343099', '0', 'System', 'MY-010931', 'Server', '/usr/sbin/mysqld: ready for connections. Version: \'8.0.46-0ubuntu0.24.04.3\'  socket: \'/var/run/mysqld/mysqld.sock\'  port: 3306  (Ubuntu).'
'2026-08-06 07:46:07.343036', '0', 'System', 'MY-011323', 'Server', 'X Plugin ready for connections. Bind-address: \'127.0.0.1\' port: 33060, socket: /var/run/mysqld/mysqlx.sock'
'2026-08-06 07:46:05.555883', '0', 'System', 'MY-013602', 'Server', 'Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.'
'2026-08-06 07:46:05.555850', '0', 'Warning', 'MY-010068', 'Server', 'CA certificate ca.pem is self signed.'
'2026-08-06 07:46:05.290332', '1', 'System', 'MY-013577', 'InnoDB', 'InnoDB initialization has ended.'
'2026-08-06 07:46:03.466266', '1', 'System', 'MY-013576', 'InnoDB', 'InnoDB initialization has started.'
'2026-08-06 07:46:03.452004', '0', 'System', 'MY-010116', 'Server', '/usr/sbin/mysqld (mysqld 8.0.46-0ubuntu0.24.04.3) starting as process 1745'
*/
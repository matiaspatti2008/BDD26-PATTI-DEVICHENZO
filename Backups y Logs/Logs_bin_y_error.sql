#6)
SHOW MASTER STATUS;
SHOW BINLOG EVENTS in 'binlog.000255' LIMIT 10;

#7)
USE mysql;
SELECT * FROM performance_schema.error_log
order by LOGGED desc
LIMIT 20;
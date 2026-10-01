#6)
SHOW MASTER STATUS;
SHOW BINLOG EVENTS in 'binlog.000255' LIMIT 10;

-- resultados
/* 'binlog.000255', '4', 'Format_desc', '1', '126', 'Server ver: 8.0.46-0ubuntu0.24.04.3, Binlog ver: 4'
'binlog.000255', '126', 'Previous_gtids', '1', '157', ''
'binlog.000255', '157', 'Anonymous_Gtid', '1', '237', 'SET @@SESSION.GTID_NEXT= \'ANONYMOUS\''
'binlog.000255', '237', 'Query', '1', '321', 'BEGIN'
'binlog.000255', '321', 'Table_map', '1', '399', 'table_id: 105 (classicmodels.orderdetails)'
'binlog.000255', '399', 'Delete_rows', '1', '8593', 'table_id: 105'
'binlog.000255', '8593', 'Delete_rows', '1', '16789', 'table_id: 105'
'binlog.000255', '16789', 'Delete_rows', '1', '24982', 'table_id: 105'
'binlog.000255', '24982', 'Delete_rows', '1', '33178', 'table_id: 105'
'binlog.000255', '33178', 'Delete_rows', '1', '41374', 'table_id: 105'
*/
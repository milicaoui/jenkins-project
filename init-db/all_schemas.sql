CREATE DATABASE IF NOT EXISTS upmonthdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS upmsearch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS upmonth_query_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `upmonth-text-extraction` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON upmonthdb.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON upmsearch.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON upmonth_query_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON `upmonth-text-extraction`.* TO 'root'@'%';

GRANT ALL PRIVILEGES ON upmonthdb.* TO 'upmonth'@'%';
GRANT ALL PRIVILEGES ON upmsearch.* TO 'upmonth'@'%';
GRANT ALL PRIVILEGES ON upmonth_query_db.* TO 'upmonth'@'%';
GRANT ALL PRIVILEGES ON `upmonth-text-extraction`.* TO 'upmonth'@'%';

FLUSH PRIVILEGES;
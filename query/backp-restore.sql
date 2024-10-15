
SELECT name from sys.databases;

use master; CREATE DATABASE demo;

use master; DROP database demo;

--Insert Data
use demo; CREATE TABLE Data (ID INT, NAME NVARCHAR(255), AGE INT); INSERT INTO Data(ID, Name, Age) VALUES (1, 'John Doe', 25), (2, 'Jane Smith', 30), (3, 'Bob Johnson', 22); Select * from data;

use master; BACKUP DATABASE [demo] to DISK='/var/opt/mssql/backup-dir/full.bak';

--Insert Another Data for log1
use demo; INSERT INTO Data(ID, Name, Age) VALUES (4, 'Anisur Rahman', 26); Select * from data;

use master; BACKUP LOG [demo] to DISK='/var/opt/mssql/backup-dir/log1.bak'

--Insert Another Data for log2
use demo; INSERT INTO Data(ID, Name, Age) VALUES (4, 'Ishtiaq Bhai', 26); Select * from data;

use master; BACKUP LOG [demo] to DISK='/var/opt/mssql/backup-dir/log2.bak'

--Insert Another Data for log3
use demo; INSERT INTO Data(ID, Name, Age) VALUES (4, 'Rasel Bhai', 26); Select * from data;

use master; BACKUP LOG [demo] to DISK='/var/opt/mssql/backup-dir/log3.bak'

--Insert Another Data for log3
use demo; INSERT INTO Data(ID, Name, Age) VALUES (4, 'Arnob Bhai', 26); Select * from data;

use master; BACKUP LOG [demo] to DISK='/var/opt/mssql/backup-dir/log4.bak'


----------Restore------
use master; RESTORE DATABASE [demo] FROM DISK='/var/opt/mssql/backup-dir/full.bak' WITH NORECOVERY;

use master; RESTORE LOG [demo] FROM DISK='/var/opt/mssql/backup-dir/log1.bak' WITH NORECOVERY;


```bash
Msg 4305, Level 16, State 1, Line 1
The log in this backup set begins at LSN 39000000028900001, which is too recent to apply to the database. An earlier log backup that includes LSN 39000000025800001 can be restored. 
	
	Msg 3013, Level 16, State 1, Line 1
RESTORE LOG is terminating abnormally.
```
--Link: https://dba.stackexchange.com/questions/55418/missing-transaction-log-in-chain-possible-to-skip/55445#55445

--Print table
use demo; SELECT * from data;


---CHECK log apply or not

--- Restore HEADERONLY
RESTORE HEADERONLY FROM DISK='/var/opt/mssql/backup-dir/full.bak'

---GetDBRestoreLSN
SELECT MAX(redo_start_lsn) 
        FROM sys.master_files
        WHERE database_id=DB_ID('demo') 



--- Full  Restore
use master; RESTORE DATABASE [demo] FROM DISK='/var/opt/mssql/backup-dir/demo.bak' WITH NORECOVERY;

--- Log Restore
use master; RESTORE LOG [demo] FROM DISK='/var/opt/mssql/backup-dir/demo-log.bak' WITH RECOVERY;



use master; drop database demo;




SELECT * FROM sys.master_files WHERE database_id=DB_ID('demo') > query_result2.txt


--------------------WALG-----------------------------
from URL = 'https://backup.local/basebackups_005/base_20240611T062155Z/demo/blob_000'

use master; RESTORE DATABASE [demo] from URL = 'https://backup.local/basebackups_005/base_20240611T062155Z/demo/blob_000' WITH NORECOVERY;

use master; RESTORE LOG [demo] from URL = 'https://backup.local/wal_005/wal_20240611T062801Z/demo/blob_000' WITH RECOVERY;

RESTORE DATABASE [demo] WITH RECOVERY;




---------------------COPY_ONLY POC--------------------

--Insert Data
use demo; CREATE TABLE Data (ID INT, NAME NVARCHAR(255), AGE INT); INSERT INTO Data(ID, Name, Age) VALUES (1, 'John Doe', 25), (2, 'Jane Smith', 30), (3, 'Bob Johnson', 22); Select * from data;

use master; BACKUP DATABASE [demo] to DISK='/var/opt/mssql/backup-dir/full.bak';

use demo; INSERT INTO Data(ID, Name, Age) VALUES (4, 'Anisur Rahman', 26); Select * from data;

use master; BACKUP DATABASE [demo] to DISK='/var/opt/mssql/backup-dir/copy_full.bak' WITH COPY_ONLY;

use master; BACKUP LOG [demo] to DISK='/var/opt/mssql/backup-dir/log1.bak'


---Observation:
BACKUPTYPE      FIRST_LSN                       LAST_LSN
FULL_BACKUP     39000000025000001               39000000025300001
COPY_ONLY       39000000028400001               39000000028700001
LOG_BACKUP      39000000025000001               39000000028700001

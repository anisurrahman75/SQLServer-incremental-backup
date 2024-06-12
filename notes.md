
# https://www.sqlshack.com/understanding-sql-server-backup-types/
    - Transaction Log Backup is possible only with full or bulk-logged recovery models.
    - A transaction log backup contains all log records that have not been included in the last transaction log backup.
    - If you want to restore the database to a specific point in time, you need restore a full, recent differential, and all the corresponding transaction log records which are necessary to build the database up to that specific point, or to a point very close to the desired point in time, just before the occurrence of the accident that resulted in the data loss.

# Full + Differential + Transaction Log
    Full – every 24 hours
    Differential – every 3 hours
    Transaction Log – every 15 minutes

    Full – every 24 hours
    Differential – every 6 hours
    Transaction Log – every 1 hour

    Full – every 168 hours
    Differential – every 24 hours
    Transaction Log – every 3 hours
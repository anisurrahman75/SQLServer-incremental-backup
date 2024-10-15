# MSSQLServer Incremental Backup & Recovery POC

## Build Docker Image
```bash
$ docker build . --tag sql-incremental-backup:latest
```

## Run Docker Image
```bash
$ docker run -d -it --privileged -v \
  ~/go/src/github.com/anisurrahman75/SQLServer-incremental-backup:/incremental-backup \
  sql-incremental-backup:latest
```

## Verify SQLServer is running if not run it:

```bash
$ systemctl status mssql-server --no-pager
$ systemctl restart mssql-server 
```
## Setup SQLServer

```bash
$ /opt/mssql/bin/mssql-conf setup
```

## Generate Necessary Secrets
```bash
$ chmod +x ./certs/generate.sh
$ ./certs/generate.sh
```
## Set Envs For WalG
```bash
$ source ./walg/walg-conf.env
```

## Create Secret for WalG

```bash
$ sqlcmd -S localhost -U sa -P "Pa55w0rd!" -Q "CREATE CREDENTIAL [https://backup.local/basebackups_005] WITH IDENTITY='SHARED ACCESS SIGNATURE', SECRET = 'does_not_matter';"
$ sqlcmd -S localhost -U sa -P "Pa55w0rd!" -Q "CREATE CREDENTIAL [https://backup.local/wal_005] WITH IDENTITY='SHARED ACCESS SIGNATURE', SECRET = 'does_not_matter';"
```
### UTILS
```bash
$ sqlcmd -S localhost -U sa -P "Pa55w0rd!" -Q "CREATE DATABASE demo;"
$ wal-g backup-push -d demo
```


## REFERENCE
- https://www.mssqltips.com/sqlservertip/3209/understanding-sql-server-log-sequence-numbers-for-backups/
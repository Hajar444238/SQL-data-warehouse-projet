/*
===================================================
Create Database and Schema
===================================================
Script Purpose:
   This script creates a new database named 'Datawarehouse' after checking if it already exists.
   If the database exists, it is dropped and recreated.Additionalyy, the script sets up three schema
   Within the databasr: 'bronze', 'silver', and 'gold'.

WARNING:
   Running this scrit will drop the netire 'Datawarehouse' database if it exists.
   All data in the database will be permanently deleted. Proceed with caution
   and ensure you have proper backups before runnings this script.
*/


USE master;
go
create database DataWarehouse;
use DataWarehouse;
--create schema
create schema bronze;
go
create schema silver;
go
create schema gold;
go



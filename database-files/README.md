# `database-files` Folder

Contains the SQL schema and sample data used to initialize the CafeCoin project. 

The `CafeCoinFinal.sql` file sets up the schema for all tables and inserts all of the sample data from Mockaroo. 

### How to restrap

### 1. Stop and Remove Containers & Volumes

This will stop all containers and delete the database volume:

```bash
docker compose down -v
```

### 2. Build and Start Fresh 

Run the following to rebuild the images and reinitialize the database:

```bash
docker compose up --build
```

# `database-files` Folder

Contains the SQL schema and sample data used to initialize the CafeCoin project. 

The `CafeCoinFinal.sql` file sets up the schema for all tables and inserts all of the sample data from Mockaroo. 

### How to restrap

## 1. Stop and Remove Containers & Volumes

This will stop all containers and delete the database volume:

```bash
docker compose down -v
```

## 2. Build and Start Fresh 

Run the following to rebuild the images and reinitialize the database:

```bash
docker compose up --build
```

## 3. Rebuild the database from scratch

If you want to completely rebuild the database in your own .sql file, please feel free to reference our entity-relationship model and database diagram [here](https://miro.com/welcomeonboard/Z04zR3lsNVJMZ3ZIMkIyeEhrYkl4NjhiRTFiWSs5Q25pOUZvNVpJdmxsbGJXSkVOS2czYXQ4Qm5uR0pQOGRCejd0L2FxZ3hKb2dEc3BIdWNKNkd2VURUQ0ZaLy8rbEVTaWVZcXIvbGV0TjU1SGFnblpmYitROW5sdlBraUZpSE5Bd044SHFHaVlWYWk0d3NxeHNmeG9BPT0hdjE=?share_link_id=419666483781). 
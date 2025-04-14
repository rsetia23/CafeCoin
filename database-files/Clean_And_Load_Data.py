import os
import csv
import pymysql
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
env_path = Path(__file__).resolve().parent.parent / 'api' / '.env'
load_dotenv(dotenv_path=env_path)

# MySQL connection
connection = pymysql.connect(
    host='localhost',
    port=3200,
    user='root',
    password=os.getenv("MYSQL_ROOT_PASSWORD"),
    database='CafeCoin'
)
cursor = connection.cursor()

# Directory paths
original_csv_folder = './database-files/Data for CafeCoin Database - Mockaroo'
cleaned_csv_folder = './database-files/cleaned-data'
os.makedirs(cleaned_csv_folder, exist_ok=True)

# File to table map and load order
file_table_map = {
    'Merchants.csv': 'Merchants',
    'Customers.csv': 'Customers',
    'Employees.csv': 'Employees',
    'Amenities.csv': 'Amenities',
    'DigitalPaymentMethods.csv': 'DigitalPaymentMethods',
    'MenuItems.csv': 'MenuItems',
    'Transactions.csv': 'Transactions',
    'RewardItems.csv': 'RewardItems',
    'OrderDetails.csv': 'OrderDetails',
    'ComplaintTickets.csv': 'ComplaintTickets',
    'Surveys.csv': 'Surveys',
    'SurveyResponses.csv': 'SurveyResponses',
    'CustomerComms.csv': 'CustomerComms',
    'CommsSubscribers.csv': 'CommsSubscribers',
    'Leads.csv': 'Leads',
    'FraudTickets.csv': 'FraudTickets',
    'Alerts.csv': 'Alerts',
    'StoreAmenities.csv': 'StoreAmenities',
    'CustAmenityPrefs.csv': 'CustAmenityPrefs'
}

# Fix known column mismatches
column_fix_map = {
    'Leads.csv': {'Address': 'StreetAddress'},
    'Alerts.csv': {'CreatedBy': 'CreatedByEmp'},
    'ComplaintTickets.csv': {'AssignedToEmp': 'AssignedToEmployeeID'},
    'Transactions.csv': {'Time': None}  # Drop this column
}

# Execute the schema before insert
with open('database-files/CafeCoinFinal.sql', 'r', encoding='utf-8') as f:
    sql_script = f.read()
    for statement in sql_script.split(';'):
        stmt = statement.strip()
        if stmt:
            try:
                cursor.execute(stmt)
            except Exception as e:
                print(f"❌ Error executing statement: {e}")
print("✅ Executed CafeCoinFinal.sql")

# Clean and save each CSV
def clean_and_save_csv(file_name):
    src_path = os.path.join(original_csv_folder, file_name)
    dest_path = os.path.join(cleaned_csv_folder, file_name)

    with open(src_path, 'r', encoding='utf-8') as infile, open(dest_path, 'w', newline='', encoding='utf-8') as outfile:
        reader = csv.DictReader(infile)
        # Adjust headers
        if file_name in column_fix_map:
            reader.fieldnames = [column_fix_map[file_name].get(h, h) for h in reader.fieldnames if column_fix_map[file_name].get(h, h) is not None]
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
        writer.writeheader()

        for row in reader:
            clean_row = {}
            for key in reader.fieldnames:
                value = row.get(key, '')
                if value == '':
                    clean_row[key] = 0 if 'IsActive' in key or 'CardUsed' in key else None
                elif value.lower() in ['true', 'false']:
                    clean_row[key] = 1 if value.lower() == 'true' else 0
                elif 'Date' in key or 'At' in key:
                    try:
                        parts = value.replace('/', '-').split('-')
                        if len(parts) == 3:
                            mm, dd, yy = parts[0].zfill(2), parts[1].zfill(2), parts[2]
                            if len(yy) == 2:
                                yy = '20' + yy
                            clean_row[key] = f"{yy}-{mm}-{dd}"
                        else:
                            clean_row[key] = None
                    except:
                        clean_row[key] = None
                elif key == 'Website' and len(value) > 255:
                    clean_row[key] = value[:255]
                else:
                    clean_row[key] = value
            writer.writerow(clean_row)
    print(f"✅ Cleaned and saved: {file_name}")
    return dest_path

# Load CSV into DB table
def load_csv_to_table(file_path, table_name):
    try:
        with open(file_path, mode='r', encoding='utf-8') as f:
            reader = csv.reader(f)
            headers = next(reader)
            columns = ','.join(headers)
            placeholders = ','.join(['%s'] * len(headers))
            insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
            print(f"Inserting into {table_name} from {os.path.basename(file_path)}...")

            for row in reader:
                try:
                    cursor.execute(insert_query, row)
                except pymysql.MySQLError as e:
                    print(f"⚠️ Skipped row in {table_name}: {e}")
            connection.commit()
            print(f"✅ Finished: {table_name}")
    except Exception as e:
        print(f"❌ Failed to insert into {table_name}: {e}")

# Run cleaning and loading
for file_name, table_name in file_table_map.items():
  #  cleaned_path = clean_and_save_csv(file_name)
    cleaned_path = os.path.join(cleaned_csv_folder, file_name)
    load_csv_to_table(cleaned_path, table_name)

# file_name = 'Customers.csv'
# table_name = 'Customers'
# cleaned_path = os.path.join(cleaned_csv_folder, file_name)
# load_csv_to_table(cleaned_path, table_name)

cursor.close()
connection.close()

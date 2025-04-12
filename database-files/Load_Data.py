import os
import pymysql
import csv

connection = pymysql.connect(
    host='db',
    user='root',
    password='password',
    database='CafeCoin'
)
cursor = connection.cursor()


def load_csv_to_table(csv_file, table_name):
    with open(csv_file, 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        headers = next(reader)
        columns = ','.join(headers)
        placeholders = ','.join(['%s'] * len(headers))

        insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        print(f"Inserting into {table_name}...")

        for row in reader:
            cursor.execute(insert_query, row)

        connection.commit()
        print(f"Finished inserting into {table_name}")


csv_dir = './app/database-files'  

table_files = [
    ('Customers.csv', 'Customers'),
    ('Merchants.csv', 'Merchants'),
    ('Employees.csv', 'CafeCoinEmployees'),
    ('Amenities.csv', 'Amenities'),
    ('DigitalPaymentMethods.csv', 'DigitalPaymentMethods'),
    ('MenuItems.csv', 'MenuItems'),
    ('Transactions.csv', 'Transactions'),
    ('RewardItems.csv', 'RewardItems'),
    ('OrderDetails.csv', 'OrderDetails'),
    ('CommsSubscribers.csv', 'CommsSubscribers'),
    ('ComplaintTickets.csv', 'ComplaintTickets'),
    ('Surveys.csv', 'Surveys'),
    ('SurveyResponses.csv', 'SurveyResponses'),
    ('CustomerComms.csv', 'CustomerComms'),
    ('Leads.csv', 'Leads'),
    ('FraudTickets.csv', 'FraudTickets'),
    ('Alerts.csv', 'Alerts'),
    ('StoreAmenities.csv', 'StoreAmenities'),
    ('CustAmenityPrefs.csv', 'CustAmenityPrefs')
]

for file_name, table in table_files:
    file_path = os.path.join(csv_dir, file_name)
    load_csv_to_table(file_path, table)

cursor.close()
connection.close()

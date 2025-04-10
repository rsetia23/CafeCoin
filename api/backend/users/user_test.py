from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app

#------------------------------------------------------------
# This file creates a shared DB connection resource
#------------------------------------------------------------
from flaskext.mysql import MySQL
from pymysql import cursors


# the parameter instructs the connection to return data 
# as a dictionary object. 
db = MySQL(cursorclass=cursors.DictCursor)

cursor = db.get_db().cursor()

coin_query = 'SELECT CoinBalance FROM Customers WHERE CustomerID = 1'
cursor.execute(coin_query)
coin_data = cursor.fetchall()
coin_data

# cursor = db.get_db().cursor()
# stats_query = '''
# SELECT c.CustomerID, c.FirstName, c.LastName, sum(t.AmountPaid) as TotalSpent, avg(t.AmountPaid) as AvgSpend, max(AmountPaid) as LargestOrder, 
# count(t.TransactionID) as NumOrders, count(DISTINCT od.ItemID) AS UniqueItemsPurchased, sum(od.Discount) AS TotalSavings
# FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID
# WHERE t.TransactionType != 'Balance Reload' AND t.Date >= DATE_ADD(NOW(), INTERVAL -1 MONTH)
# GROUP BY c.CustomerID, c.FirstName, c.LastName
# HAVING c.CustomerID = 1
# '''
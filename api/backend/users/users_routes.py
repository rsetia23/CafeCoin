from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

users_bp = Blueprint('customers', __name__)

@users_bp.route('/paymethods/<userID>', methods=['GET'])
def get_user_pay_methods(userID):
    current_app.logger.info('GET /balanceupdate/<userID> route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT MethodID, CardNumber FROM DigitalPaymentMethods WHERE CustomerID = {0}'.format(userID))
    theData = cursor.fetchall()
    the_response = make_response(jsonify(theData))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@users_bp.route('/balanceupdate', methods=['POST'])
def record_transaction():
    
    # In a POST request, there is a 
    # collecting data from the request object 
    the_data = request.json 
    current_app.logger.info(the_data)

    #extracting the variable
    customerID = the_data['CustomerID']
    merchantID = the_data['MerchantID']
    date = the_data['Date']
    paymentMethod = the_data['PaymentMethod']
    cardUsed = the_data['CardUsed']
    transactionType = the_data['TransactionType']
    amountPaid = the_data['AmountPaid']

    queryDate = "DEFAULT" if date is None else date
    
    # query = f'''
    #     INSERT INTO Transactions (CustomerID,
    #                           MerchantID,
    #                           TransactionDate, 
    #                           PaymentMethod,
    #                           CardUsed,
    #                           TransactionType,
    #                           AmountPaid)
    #     VALUES ({customerID}, {merchantID}, '{queryDate}', '{paymentMethod}',
    #     {cardUsed if cardUsed is not None else 'NULL'}, '{transactionType}', {amountPaid})
    # '''

    query = f'''
        INSERT INTO Transactions (CustomerID,
                             MerchantID, 
                              PaymentMethod,
                              CardUsed,
                              TransactionType,
                              AmountPaid)
        VALUES ({customerID}, {merchantID}, '{paymentMethod}',
        {cardUsed if cardUsed is not None else 'NULL'}, '{transactionType}', {amountPaid})
    '''

    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    
    response = make_response("Successfully added transaction")
    response.status_code = 200
    return response

@users_bp.route('/balanceupdate/<userID>/<amt>', methods=['PUT'])
def update_customer(userID, amt):
    current_app.logger.info('PUT /balanceupdate/<userID>/<amt>')

    query = f'''
        UPDATE Customers
        SET AccountBalance = AccountBalance + {amt}
        WHERE CustomerID = {userID}
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    return 'customer balance updated!'

@users_bp.route('/summary/<userID>', methods = ['GET'])
def customer_summary(userID):
    current_app.logger.info('GET /balanceupdate/<userID> route')
    cursor = db.get_db().cursor()

    coin_query = 'SELECT CoinBalance, AccountBalance FROM Customers WHERE CustomerID = {0}'.format(userID)
    cursor.execute(coin_query)
    coin_data = cursor.fetchall()
    
    cursor = db.get_db().cursor()
    # stats_query = '''
    # SELECT c.CustomerID, c.FirstName, c.LastName, sum(t.AmountPaid) as TotalSpent, avg(t.AmountPaid) as AvgSpend, max(AmountPaid) as LargestOrder, 
    # count(t.TransactionID) as NumOrders, count(DISTINCT od.ItemID) AS UniqueItemsPurchased, sum(od.Discount) AS TotalSavings
    # FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID
    # WHERE t.TransactionType != 'Balance Reload' AND t.TransactionDate >= DATE_ADD(NOW(), INTERVAL -1 MONTH)
    # GROUP BY c.CustomerID, c.FirstName, c.LastName
    # HAVING c.CustomerID = {0}
    # '''.format(userID)

    stats_query = '''
    SELECT t.TransactionDate, t.PaymentMethod, t.AmountPaid as OrderTotal, t.TransactionID as OrderNum, od.ItemID AS ItemNum, m.ItemName, od.Price AS ItemPrice, od.Discount
    FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID JOIN MenuItems m ON od.ItemID = m.ItemID
    WHERE t.TransactionType != 'Balance Reload' AND c.CustomerID = {0}
    '''.format(userID)

    cursor.execute(stats_query)
    stats_data = cursor.fetchall()

    the_response = make_response(jsonify(coin_data, stats_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response


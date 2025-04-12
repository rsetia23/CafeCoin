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
    SELECT t.TransactionDate, t.MerchantID, m.MerchantName, t.PaymentMethod, t.AmountPaid as OrderTotal, t.TransactionID as OrderNum, od.ItemID AS ItemNum, mi.ItemName, od.Price AS ItemPrice, od.RewardRedeemed, od.Discount
    FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID JOIN Merchants m on t.MerchantID = m.MerchantID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID JOIN MenuItems mi ON od.ItemID = mi.ItemID
    WHERE t.TransactionType != 'Balance Reload' AND c.CustomerID = {0}
    '''.format(userID)

    cursor.execute(stats_query)
    stats_data = cursor.fetchall()

    the_response = make_response(jsonify(coin_data, stats_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@users_bp.route('/stores', methods = ['GET'])
def store_locations():
    current_app.logger.info('GET /stores route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT m.MerchantID, m.MerchantName, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Lat, m.Lon, m.Website, m.OwnerComment FROM Merchants m')
    merchant_data = cursor.fetchall()
    merchant_response = make_response(jsonify(merchant_data))
    merchant_response.status_code = 200
    merchant_response.mimetype = 'application/json'
    return merchant_response

@users_bp.route('/storerecs/<userID>', methods = ['GET'])
def store_recommendations(userID):
    current_app.logger.info('GET /storerecs/<userID> route')
    cursor = db.get_db().cursor()
    cursor.execute('''SELECT c.CustomerID, c.FirstName, c.LastName, m.MerchantName, m.Lat, m.Lon, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Website, m.OwnerComment
                   FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID JOIN Customers c on cap.CustomerID = c.CustomerID JOIN Merchants m ON sa.MerchantID = m.MerchantID JOIN Amenities a ON cap.AmenityID = a.AmenityID
                   WHERE c.CustomerID = {0}
                   GROUP BY m.MerchantName, c.CustomerID, c.FirstName, c.LastName, m.Lat, m.Lon, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Website, m.OwnerComment
                   HAVING count(distinct cap.AmenityID) = (SELECT COUNT(DISTINCT cap2.AmenityID)
                                        FROM CustAmenityPrefs cap2 JOIN Customers c2 ON cap2.CustomerID = c2.CustomerID
                                        WHERE c2.CustomerID = {0} AND c2.CustomerID = {0});
                   '''.format(userID))
    rec_data = cursor.fetchall()
    rec_response = make_response(jsonify(rec_data))
    rec_response.status_code = 200
    rec_response.mimetype = 'application/json'
    return rec_response
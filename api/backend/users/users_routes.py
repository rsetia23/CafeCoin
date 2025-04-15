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

    # constructing and executing the cursor with the query
    cursor = db.get_db().cursor()
    cursor.execute('SELECT MethodID, CardNumber FROM DigitalPaymentMethods WHERE CustomerID = {0}'.format(userID))
    
    # retrieving the data
    theData = cursor.fetchall()

    # formatting the data as json, returning status code
    the_response = make_response(jsonify(theData))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'

    # returning data
    return the_response

@users_bp.route('/balanceupdate', methods=['POST'])
def record_transaction():
    
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

    # storing query    
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
    
    # logging query
    current_app.logger.info(query)

    # constructing cursor object and executing on query
    cursor = db.get_db().cursor()
    cursor.execute(query)

    # commiting posted transaction to DB
    db.get_db().commit()
    
    # building the response, setting status code
    response = make_response("Successfully added transaction")
    response.status_code = 200

    # returning the response
    return response

@users_bp.route('/balanceupdate/<userID>/<amt>', methods=['PUT'])
def update_customer(userID, amt):
    current_app.logger.info('PUT /balanceupdate/<userID>/<amt>')

    # storing query, including variables for user and amount
    query = f'''
        UPDATE Customers
        SET AccountBalance = AccountBalance + {amt}
        WHERE CustomerID = {userID}
    '''

    # constructing cursor object and executing query
    cursor = db.get_db().cursor()
    cursor.execute(query)

    # committing update to database
    db.get_db().commit()

    # returning success message
    return 'customer balance updated!'

@users_bp.route('/summary/<userID>', methods = ['GET'])
def customer_summary(userID):
    current_app.logger.info('GET /balanceupdate/<userID> route')

    # construct first cursor object
    cursor = db.get_db().cursor()

    # store first query
    coin_query = 'SELECT CoinBalance, AccountBalance FROM Customers WHERE CustomerID = {0}'.format(userID)

    # execute first cursor object and retrieve data
    cursor.execute(coin_query)
    coin_data = cursor.fetchall()
    
    # construct second cursor object
    cursor = db.get_db().cursor()

    # store second query (note: balance reload transactions do not contribute to user's stats as they aren't yet purchases of goods)
    stats_query = '''
    SELECT t.TransactionDate, t.MerchantID, m.MerchantName, t.PaymentMethod, t.AmountPaid as OrderTotal, t.TransactionID as OrderNum, od.ItemID AS ItemNum, mi.ItemName, od.Price AS ItemPrice, od.RewardRedeemed, od.Discount
    FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID JOIN Merchants m on t.MerchantID = m.MerchantID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID JOIN MenuItems mi ON od.ItemID = mi.ItemID
    WHERE t.TransactionType != 'balancereload' AND c.CustomerID = {0}
    '''.format(userID)

    # execute second cursor object with second query and retrieve data
    cursor.execute(stats_query)
    stats_data = cursor.fetchall()

    # jsonify all data at once
    the_response = make_response(jsonify(coin_data, stats_data))

    # return status code
    the_response.status_code = 200
    the_response.mimetype = 'application/json'

    # return the data
    return the_response

@users_bp.route('/stores', methods = ['GET'])
def store_locations():
    current_app.logger.info('GET /stores route')

    # construct the cursor object and execute
    cursor = db.get_db().cursor()
    cursor.execute("""
                   SELECT m.MerchantID, m.MerchantName, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Lat, m.Lon, m.Website, m.OwnerComment, GROUP_CONCAT(Name SEPARATOR ', ') AS Amenities 
                   FROM Merchants m LEFT JOIN StoreAmenities sa ON m.MerchantID = sa.MerchantID LEFT JOIN Amenities ON sa.AmenityID = Amenities.AmenityID
                   GROUP BY m.MerchantID, m.MerchantName, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Lat, m.Lon, m.Website, m.OwnerComment
                   """)
    
    # retrieve the data
    merchant_data = cursor.fetchall()

    # jsonify the data
    merchant_response = make_response(jsonify(merchant_data))

    # return status code
    merchant_response.status_code = 200
    merchant_response.mimetype = 'application/json'

    # return data
    return merchant_response

@users_bp.route('/storerecs/<userID>', methods = ['GET'])
def store_recommendations(userID):
    current_app.logger.info('GET /storerecs/<userID> route')

    # construct cursor object and execute on amenity preferences/store recs query 
    # note: we went with the 2nd interation of this query from our CRUD; more complicated, but more intuitive result, eg stores that match ALL preferences instead of ANY preference
    cursor = db.get_db().cursor()
    cursor.execute('''SELECT c.CustomerID, c.FirstName, c.LastName, m.MerchantName, m.Lat, m.Lon, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Website, m.OwnerComment
                   FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID JOIN Customers c on cap.CustomerID = c.CustomerID JOIN Merchants m ON sa.MerchantID = m.MerchantID JOIN Amenities a ON cap.AmenityID = a.AmenityID
                   WHERE c.CustomerID = {0}
                   GROUP BY m.MerchantName, c.CustomerID, c.FirstName, c.LastName, m.Lat, m.Lon, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode, m.Website, m.OwnerComment
                   HAVING count(distinct cap.AmenityID) = (SELECT COUNT(DISTINCT cap2.AmenityID)
                                        FROM CustAmenityPrefs cap2 JOIN Customers c2 ON cap2.CustomerID = c2.CustomerID
                                        WHERE c2.CustomerID = {0} AND c2.CustomerID = {0});
                   '''.format(userID))
    
    # retrieve data
    rec_data = cursor.fetchall()

    # jsonify data
    rec_response = make_response(jsonify(rec_data))

    # return status code
    rec_response.status_code = 200
    rec_response.mimetype = 'application/json'

    # return response
    return rec_response
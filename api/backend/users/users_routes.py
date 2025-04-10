from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

users_bp = Blueprint('customers', __name__)

@users_bp.route('/balanceupdate', methods=['POST'])
def add_transaction():
    
    # In a POST request, there is a 
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    customerID = the_data['CustomerID']
    merchantID = the_data['MerchantID']
    date = the_data['Date']
    time = the_data['Time']
    paymentMethod = the_data['PaymentMethod']
    cardUsed = the_data['CardUsed']
    transactionType = the_data['TransactionType']
    amountPaid = the_data['AmountPaid']
    
    query = f'''
        INSERT INTO Transactions (CustomerID,
                              MerchantID,
                              Date, 
                              Time, 
                              PaymentMethod,
                              CardUsed,
                              TransactionType,
                              AmountPaid)
        VALUES ({customerID}, {merchantID}, '{date}', '{time}', '{paymentMethod}',
        {cardUsed if cardUsed is not None else 'NULL'}, '{transactionType}', {amountPaid})
    '''
    # TODO: Make sure the version of the query above works properly
    # Constructing the query
    # query = 'insert into products (product_name, description, category, list_price) values ("'
    # query += name + '", "'
    # query += description + '", "'
    # query += category + '", '
    # query += str(price) + ')'
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    
    response = make_response("Successfully added transaction")
    response.status_code = 200
    return response

@users_bp.route('/balanceupdate', methods=['PUT'])
def update_customer():
    current_app.logger.info('PUT /customers')
    cust_info = request.json
    cust_id = cust_info['CustomerID']
    custom_amt = cust_info['AmountToAdd']
    
    query = f'''
        UPDATE Customers
        SET AccountBalance = AccountBalance + {custom_amt}
        WHERE CustomerID = {cust_id}
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    return 'customer balance updated!'

@users_bp.route('/balanceupdate/<userID>', methods=['GET'])
def get_user_pay_methods(userID):
    current_app.logger.info('GET /balanceupdate/<userID> route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT MethodID, CardNumber FROM DigitalPaymentMethods WHERE CustomerID = {0}'.format(userID))
    theData = cursor.fetchall()
    the_response = make_response(jsonify(theData))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

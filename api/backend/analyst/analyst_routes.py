from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

# Create Bluepring for the analyst
analyst_bp = Blueprint('analyst', __name__)

# Route for getting transaction data of all customers
@analyst_bp.route('/transactions', methods=['GET'])
def get_analyst_transactions():
    current_app.logger.info('GET /transactions route')
    cursor = db.get_db().cursor()
    cursor.execute(
    'SELECT M.MerchantName, TransactionID, CustomerID, T.MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid '
    'FROM Transactions T JOIN CafeCoin.Merchants M on M.MerchantID = T.MerchantID')
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Route for viewing all the Order details
@analyst_bp.route('/orderdetails', methods=['GET'])
def get_analyst_orderdetails():
    current_app.logger.info('GET /orderdetails route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT OrderItemNum, TransactionID, ItemID, Price, RewardRedeemed, Discount FROM OrderDetails')
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@analyst_bp.route('/transactions/<int:merchant1>', methods=['GET'])
def get_transactions_for_merchants(merchant1):
    current_app.logger.info(f'GET /transactions/{merchant1}')
    cursor = db.get_db().cursor()

    # Query using equality check for a single MerchantID
    query = '''
        SELECT TransactionID, CustomerID, MerchantID, PaymentMethod,  CardUsed, TransactionDate, TransactionType, AmountPaid
        FROM Transactions T
        WHERE MerchantID = %s
    '''

    # Execute the query for merchant1 (note the trailing comma for a one-element tuple)
    cursor.execute(query, (merchant1,))
    the_data = cursor.fetchall()

    # Create the response with correct variable and status code
    the_response = make_response(jsonify(the_data), 200)
    the_response.mimetype = 'application/json'
    return the_response

@analyst_bp.route('/orderdetails/<int:merchant1>', methods=['GET'])
def get_orderdetails_for_merchant(merchant1):
    current_app.logger.info(f'GET /orderdetails/{merchant1}')
    cursor = db.get_db().cursor()

    query = '''
        SELECT
            od.OrderItemNum,
            od.TransactionID,
            od.ItemID,
            od.Price,
            od.RewardRedeemed,
            od.Discount,
            t.MerchantID
        FROM OrderDetails od
        JOIN Transactions t
          ON od.TransactionID = t.TransactionID
        WHERE t.MerchantID = %s
    '''
    cursor.execute(query, (merchant1,))
    the_data = cursor.fetchall()

    the_response = make_response(jsonify(the_data), 200)
    the_response.mimetype = 'application/json'
    return the_response

@analyst_bp.route('/leadsinfo', methods=['GET'])
def get_analyst_leadsinfo():
    current_app.logger.info('GET /leadsinfo route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT LeadID, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, '
     'PhoneNumber, StreetAddress, Suite, City, State, ZipCode, Website, Status, Notes, LastContactedAt  FROM Leads')
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response
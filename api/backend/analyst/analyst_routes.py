from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

analyst_bp = Blueprint('analyst', __name__)

@analyst_bp.route('/transactions', methods=['GET'])
def get_analyst_transactions():
    current_app.logger.info('GET /transactions route')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionType, AmountPaid FROM Transactions')
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

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

@analyst_bp.route('/transactions/<int:merchant1>/<int:merchant2>', methods=['GET'])
def get_transactions_for_merchants(merchant1, merchant2):
    current_app.logger.info(f'GET /transactions/{merchant1}/{merchant2}')
    cursor = db.get_db().cursor()
    query = '''
        SELECT
            TransactionID,
            CustomerID,
            MerchantID,
            PaymentMethod,
            CardUsed,
            TransactionType,
            AmountPaid
        FROM Transactions
        WHERE MerchantID IN (%s, %s)
    '''
    cursor.execute(query, (merchant1, merchant2))
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@analyst_bp.route('/orderdetails/<int:merchant1>/<int:merchant2>', methods=['GET'])
def get_orderdetails_for_merchants(merchant1, merchant2):
    current_app.logger.info(f'GET /orderdetails/{merchant1}/{merchant2}')

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
        WHERE t.MerchantID IN (%s, %s)
    '''
    cursor.execute(query, (merchant1, merchant2))
    theData = cursor.fetchall()
    the_response = make_response(theData)
    the_response.status_code = 200
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
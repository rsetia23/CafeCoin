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
    cursor.execute('SELECT TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, Time, TransactionType, AmountPaid FROM Transactions)
    theData = cursor.fetchall()
    the_response = make_response(jsonify(theData))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response
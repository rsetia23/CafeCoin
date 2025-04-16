from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

admin_bp = Blueprint('admin', __name__)

# updating the active status of a merchant or customer
@admin_bp.route('/<resource>/<int:itemID>/status', methods=['PUT'])
def deprecate_resource(resource, itemID):
    current_app.logger.info(f'PUT /admin/{resource}/{itemID}')

    valid_resources = {
        'customer':  ('Customers', 'CustomerID'),
        'merchant':  ('Merchants', 'MerchantID'),
    }

    if resource.lower() not in valid_resources:
        return make_response(jsonify({'error': 'Invalid resource type'}), 400)

    table, pk = valid_resources[resource.lower()]

    query = f'''
        UPDATE {table}
        SET IsActive = FALSE
        WHERE {pk} = %s
    '''

    current_app.logger.info(f'Executing: {query} with ID={itemID}')

    cursor = db.get_db().cursor()
    result = cursor.execute(query, (itemID,))
    db.get_db().commit()
    
    if result == 0:
        return make_response(jsonify({'message': f'{resource.capitalize()} already inactive'}), 404)

    return make_response(jsonify({'message': f'{resource.capitalize()} {itemID} marked as inactive'}), 200)

# hard deleting a merchant or customer's data from the database
@admin_bp.route('/<resource>/<int:itemID>', methods=['DELETE'])
def delete_resource(resource, itemID):
    current_app.logger.info(f'DELETE /admin/delete/{resource}/{itemID}')

    valid_resources = {
        'customer':  ('Customers', 'CustomerID'),
        'merchant':  ('Merchants', 'MerchantID'),
    }

    if resource.lower() not in valid_resources:
        return make_response(jsonify({'error': 'Invalid resource type'}), 400)

    table, pk = valid_resources[resource.lower()]

    query = f'''
        DELETE FROM {table}
        WHERE {pk} = %s
    '''

    current_app.logger.info(f'Executing DELETE: {query} with ID={itemID}')

    cursor = db.get_db().cursor()
    result = cursor.execute(query, (itemID,))
    db.get_db().commit()

    if result == 0:
        return make_response(jsonify({'message': f'{resource.capitalize()} not found'}), 404)

    return make_response(jsonify({'message': f'{resource.capitalize()} {itemID} deleted successfully'}), 200)

# getting all customer names
@admin_bp.route('/customers', methods=['GET'])
def get_active_customers():
    current_app.logger.info("GET /admin/customers")

    query = '''
        SELECT CustomerID, CONCAT(FirstName, ' ', LastName) AS Name
        FROM Customers
        WHERE IsActive = TRUE
        ORDER BY FirstName, LastName
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    results = cursor.fetchall()

    return jsonify(results), 200

# getting all merchant names
@admin_bp.route('/merchants', methods=['GET'])
def get_active_merchants():
    current_app.logger.info("GET /admin/merchants")

    query = '''
        SELECT MerchantID, MerchantName AS Name
        FROM Merchants
        WHERE IsActive = TRUE
        ORDER BY MerchantName
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query)
    results = cursor.fetchall()

    return jsonify(results), 200

# view all alerts
@admin_bp.route('/alerts/<audience>', methods=['GET'])
def get_alerts(audience):
    current_app.logger.info(f'GET /admin/alerts/{audience}')

    query = '''
        SELECT * FROM Alerts
        WHERE Audience = %s
        '''

    cursor = db.get_db().cursor()
    cursor.execute(query, (audience,))
    alerts = cursor.fetchall()
    return jsonify(alerts), 200

# create a new alert
@admin_bp.route('/alerts', methods=['POST'])
def create_alert():
    alert_data = request.json
    current_app.logger.info(f"POST /admin/alerts → {alert_data}")

    query = '''
        INSERT INTO Alerts (CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority)
        VALUES (%s, %s, %s, NOW(), %s, %s, %s)
    '''

    values = (
        alert_data['CreatedByEmp'],
        alert_data['Title'],
        alert_data['Message'],
        alert_data['Audience'],
        alert_data['Status'],
        alert_data['Priority']
    )

    try:
        cursor = db.get_db().cursor()
        cursor.execute(query, values)
        db.get_db().commit()

        return make_response(jsonify({'message': 'Alert created successfully!'}), 200)
    except Exception as e:
        current_app.logger.error(f"Error inserting alert: {e}")
        return make_response(jsonify({'error': str(e)}), 500)

# view all complaint tickets
@admin_bp.route('/complaints', methods=['GET'])
def get_complaints():
    query = '''
        SELECT TicketID, CustomerID, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority
        FROM ComplaintTickets
        ORDER BY CreatedAt DESC
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query)
    data = cursor.fetchall()
    return jsonify(data), 200

# update the status of a complaint ticket
@admin_bp.route('/complaints/<int:ticketID>/status', methods=['PUT'])
def resolve_complaint(ticketID):
    query = '''
        UPDATE ComplaintTickets
        SET Status = 'Resolved'
        WHERE TicketID = %s
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (ticketID,))
    db.get_db().commit()

    if cursor.rowcount == 0:
        return jsonify({'message': 'Ticket not found'}), 404

    return jsonify({'message': f'Ticket {ticketID} marked as resolved'}), 200

# getting customer emails
@admin_bp.route('/customers/<int:customerID>/email', methods=['GET'])
def get_customer_email(customerID):
    current_app.logger.info(f"GET /admin/customers/{customerID}/email")

    query = '''
        SELECT Email FROM Customers
        WHERE CustomerID = %s
    '''

    try:
        cursor = db.get_db().cursor()
        cursor.execute(query, (customerID,))
        result = cursor.fetchone()

        if result is None:
            return make_response(jsonify({'error': 'User not found'}), 404)

        return jsonify(result), 200
    except Exception as e:
        current_app.logger.error(f"Error fetching email: {e}")
        return make_response(jsonify({'error': str(e)}), 500)

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import make_response
from flask import current_app
from backend.db_connection import db

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/admin/deprecate/<resource>/<int:item_id>', methods=['PUT'])
def deprecate_resource(resource, item_id):
    current_app.logger.info(f'PUT /admin/deprecate/{resource}/{item_id}')

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

    current_app.logger.info(f'Executing: {query} with ID={item_id}')

    cursor = db.get_db().cursor()
    result = cursor.execute(query, (item_id,))
    db.get_db().commit()
    
    if result == 0:
        return make_response(jsonify({'message': f'{resource.capitalize()} already inactive'}), 404)

    return make_response(jsonify({'message': f'{resource.capitalize()} {item_id} marked as inactive'}), 200)


@admin_bp.route('/admin/delete/<resource>/<int:item_id>', methods=['DELETE'])
def delete_resource(resource, item_id):
    current_app.logger.info(f'DELETE /admin/delete/{resource}/{item_id}')

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

    current_app.logger.info(f'Executing DELETE: {query} with ID={item_id}')

    cursor = db.get_db().cursor()
    result = cursor.execute(query, (item_id,))
    db.get_db().commit()

    if result == 0:
        return make_response(jsonify({'message': f'{resource.capitalize()} not found'}), 404)

    return make_response(jsonify({'message': f'{resource.capitalize()} {item_id} deleted successfully'}), 200)


@admin_bp.route('/admin/customers', methods=['GET'])
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

@admin_bp.route('/admin/merchants', methods=['GET'])
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

# Manage Alerts
@admin_bp.route('/admin/alerts/<audience>', methods=['GET'])
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


@admin_bp.route('/admin/alerts', methods=['POST'])
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


@admin_bp.route('/admin/complaints', methods=['GET'])
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

@admin_bp.route('/admin/complaints/<int:ticket_id>/resolve', methods=['PUT'])
def resolve_complaint(ticket_id):
    query = '''
        UPDATE ComplaintTickets
        SET Status = 'Resolved'
        WHERE TicketID = %s
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (ticket_id,))
    db.get_db().commit()

    if cursor.rowcount == 0:
        return jsonify({'message': 'Ticket not found'}), 404

    return jsonify({'message': f'Ticket {ticket_id} marked as resolved'}), 200

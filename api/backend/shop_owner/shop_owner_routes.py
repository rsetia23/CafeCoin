from flask import Blueprint, request, jsonify, make_response, current_app
from backend.db_connection import db

shop_owner_bp = Blueprint('shop_owner', __name__)

# Constants for testing/dev - in future this could be based on session auth or JWT
DEFAULT_MERCHANT_ID = 1

#GET menu item
@shop_owner_bp.route('/shop_owner/menu', methods=['GET'])
def get_menu():
    current_app.logger.info("GET /shop_owner/menu")

    query = '''
        SELECT ItemID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive
        FROM MenuItems
        WHERE MerchantID = %s
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (DEFAULT_MERCHANT_ID,))
    results = cursor.fetchall()

    return jsonify(results), 200

#Add menu Item
@shop_owner_bp.route('/shop_owner/menu', methods=['POST'])
def add_menu_item():
    current_app.logger.info('POST /shop_owner/menu')
    
    data = request.get_json()

    required_fields = ['ItemName', 'CurrentPrice']
    for field in required_fields:
        if field not in data:
            return make_response(jsonify({'error': f'Missing field: {field}'}), 400)

    query = '''
        INSERT INTO MenuItems (MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    '''

    values = (
        DEFAULT_MERCHANT_ID,
        data['ItemName'],
        data['CurrentPrice'],
        data.get('Description', None),
        data.get('ItemType', None),
        data.get('IsRewardItem', False),
        True  # IsActive is always TRUE on create
    )

    try:
        cursor = db.get_db().cursor()
        cursor.execute(query, values)
        db.get_db().commit()
        return jsonify({'message': 'Menu item added successfully'}), 201
    except Exception as e:
        current_app.logger.error(f"Error adding menu item: {e}")
        return make_response(jsonify({'error': str(e)}), 500)


#Update Menu Item
@shop_owner_bp.route('/shop_owner/menu/<int:item_id>', methods=['PUT'])
def update_menu_item(item_id):
    current_app.logger.info(f"PUT /shop_owner/menu/{item_id}")
    update_data = request.json

    query = '''
        UPDATE MenuItems
        SET ItemName = %s,
            CurrentPrice = %s,
            Description = %s,
            ItemType = %s,
            IsRewardItem = %s,
            IsActive = %s
        WHERE ItemID = %s
    '''

    values = (
        update_data.get('ItemName'),
        update_data.get('CurrentPrice'),
        update_data.get('Description'),
        update_data.get('ItemType'),
        update_data.get('IsRewardItem'),
        update_data.get('IsActive'),
        item_id
    )

    cursor = db.get_db().cursor()
    cursor.execute(query, values)
    db.get_db().commit()

    if cursor.rowcount == 0:
        return jsonify({'message': f'No item found with ID {item_id}'}), 404

    return jsonify({'message': f'Menu item {item_id} updated successfully'}), 200


#Delete Menu Item
@shop_owner_bp.route('/shop_owner/menu/<int:item_id>', methods=['DELETE'])
def delete_menu_item(item_id):
    current_app.logger.info(f"DELETE /shop_owner/menu/{item_id}")

    query = '''
        DELETE FROM MenuItems
        WHERE ItemID = %s
    '''

    cursor = db.get_db().cursor()
    cursor.execute(query, (item_id,))
    db.get_db().commit()

    if cursor.rowcount == 0:
        return jsonify({'message': f'Menu item with ID {item_id} not found'}), 404

    return jsonify({'message': f'Menu item {item_id} deleted successfully'}), 200


#View all subscribers
@shop_owner_bp.route('/shop_owner/subscribers/<int:merchant_id>', methods=['GET'])
def get_subscribers(merchant_id):
    current_app.logger.info(f"GET /shop_owner/subscribers/{merchant_id}")
    query = '''
        SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone, 
               c.CoinBalance, c.DateJoined
        FROM Customers c
        JOIN CommsSubscribers cs ON c.CustomerID = cs.CustomerID
        WHERE cs.MerchantID = %s AND c.IsActive = TRUE
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (merchant_id,))
    results = cursor.fetchall()
    return jsonify(results), 200

#View Reward Item performance
@shop_owner_bp.route('/shop_owner/reward_items/history/<int:merchant_id>', methods=['GET'])
def get_reward_item_history(merchant_id):
    query = '''
        SELECT ri.RewardID, mi.ItemName, ri.StartDate, ri.EndDate
        FROM RewardItems ri
        JOIN MenuItems mi ON ri.ItemID = mi.ItemID
        WHERE ri.MerchantID = %s
        ORDER BY ri.StartDate DESC
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (merchant_id,))
    results = cursor.fetchall()
    return jsonify(results), 200

@shop_owner_bp.route('/shop_owner/reward_items/orders', methods=['GET'])
def get_reward_item_orders():
    item_id = request.args.get('item_id')
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')

    if not item_id or not start_date or not end_date:
        return jsonify({'error': 'Missing query parameters'}), 400

    query = '''
        SELECT 
        COUNT(*) AS TotalOrders,
        SUM(od.Price) AS TotalRevenue,
        AVG(od.Price) AS AveragePrice
    FROM OrderDetails od
    JOIN Transactions t ON od.TransactionID = t.TransactionID
    WHERE od.ItemID = %s AND t.TransactionDate BETWEEN %s AND %s
    '''
    cursor = db.get_db().cursor()
    cursor.execute(query, (item_id, start_date, end_date))
    results = cursor.fetchone()
    return jsonify(results), 200

from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

DB_CONFIG = {
    'dbname': 'tv_db',
    'user': 'username',
    'password': 'password',
    'host': 'localhost',
    'port': 5432
}

def get_db_connection():
    conn = psycopg2.connect(**DB_CONFIG)
    return conn

@app.route('/channels', methods=['POST'])
def create_channel():
    data = request.json
    sql = """
        INSERT INTO телеканалы (название_канала, страна_вещания, контактная_информация, способы_трансляции)
        VALUES (%s, %s, %s, %s) RETURNING channel_id
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute(sql, (
                data['название_канала'],
                data['страна_вещания'],
                data['контактная_информация'],
                data['способы_трансляции']
            ))
            channel_id = cursor.fetchone()[0]
            conn.commit()
        return jsonify({"message": "Channel added successfully!", "channel_id": channel_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/channels', methods=['GET'])
def read_channels():
    sql = "SELECT * FROM телеканалы"
    try:
        conn = get_db_connection()
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(sql)
            channels = cursor.fetchall()
        return jsonify(channels), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/channels/<int:channel_id>', methods=['GET'])
def read_channel(channel_id):
    sql = "SELECT * FROM телеканалы WHERE channel_id = %s"
    try:
        conn = get_db_connection()
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(sql, (channel_id,))
            channel = cursor.fetchone()
        if not channel:
            return jsonify({"error": "Channel not found"}), 404
        return jsonify(channel), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/channels/<int:channel_id>', methods=['PUT'])
def update_channel(channel_id):
    data = request.json
    sql = """
        UPDATE телеканалы
        SET название_канала = %s, страна_вещания = %s, контактная_информация = %s, способы_трансляции = %s
        WHERE channel_id = %s
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute(sql, (
                data.get('название_канала'),
                data.get('страна_вещания'),
                data.get('контактная_информация'),
                data.get('способы_трансляции'),
                channel_id
            ))
            if cursor.rowcount == 0:
                return jsonify({"error": "Channel not found"}), 404
            conn.commit()
        return jsonify({"message": "Channel updated successfully!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/channels/<int:channel_id>', methods=['DELETE'])
def delete_channel(channel_id):
    sql = "DELETE FROM телеканалы WHERE channel_id = %s"
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute(sql, (channel_id,))
            if cursor.rowcount == 0:
                return jsonify({"error": "Channel not found"}), 404
            conn.commit()
        return jsonify({"message": "Channel deleted successfully!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn

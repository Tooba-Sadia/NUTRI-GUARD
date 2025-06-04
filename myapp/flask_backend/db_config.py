import mysql.connector

def get_db_connection():
    connection = mysql.connector.connect(
        host='192.168.18.16',
        user='flutter_user',            # your MySQL username
        password='FlutterPass123!',            # your MySQL password
        database='flutter_auth' # use your actual DB name
    )
    return connection


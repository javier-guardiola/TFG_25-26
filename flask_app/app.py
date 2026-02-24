from flask import Flask, render_template
import pymysql

app = Flask(__name__)

db_config = {
    'host': '192.168.1.62',
    'user': 'tfg_user',
    'password': 'tfg_password_2026',
    'db': 'tfg_database',
    'cursorclass': pymysql.cursors.DictCursor
}

@app.route('/')
def index():
    context = {"db_status": "Desconectado", "db_data": [], "activos": []}
    try:
        connection = pymysql.connect(**db_config)
        context["db_status"] = "Conectado"
        with connection.cursor() as cursor:
            cursor.execute("SELECT VERSION() as version")
            context["db_data"] = cursor.fetchone()
            cursor.execute("SELECT * FROM activos")
            context["activos"] = cursor.fetchall()
        connection.close()
    except Exception as e:
        context["db_status"] = f"Error: {e}"
    
    return render_template('index.html', **context)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
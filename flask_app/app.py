from flask import Flask, render_template
import pymysql
import socket

app = Flask(__name__)

db_config = {
    'host': '192.168.1.62',
    'user': 'tfg_user',
    'password': 'tfg_password_2026',
    'db': 'tfg_database',
    'cursorclass': pymysql.cursors.DictCursor
}

def check_port(ip, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex((ip, port))
    sock.close()
    return result == 0

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
            activos_db = cursor.fetchall()
            
            for activo in activos_db:
                is_up = check_port(activo['direccion_ip'], activo['puerto'])
                activo['estado'] = "Activo" if is_up else "Caído"
                context["activos"].append(activo)
                
        connection.close()
    except Exception as e:
        context["db_status"] = f"Error: {e}"
    
    return render_template('index.html', **context)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
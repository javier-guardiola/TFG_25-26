from flask import Flask, render_template
import pymysql
import socket
import time

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
    start_time = time.time()
    result = sock.connect_ex((ip, port))
    end_time = time.time()
    sock.close()
    
    if result == 0:
        latency = (end_time - start_time) * 1000
        return True, latency
    return False, 0

@app.route('/')
def index():
    context = {
        "db_status": "Desconectado", 
        "db_data": [], 
        "activos": []
    }
    try:
        connection = pymysql.connect(**db_config)
        context["db_status"] = "Conectado"
        with connection.cursor() as cursor:
            cursor.execute("SELECT VERSION() as version")
            context["db_data"] = cursor.fetchone()
            
            cursor.execute("SELECT * FROM activos")
            activos_db = cursor.fetchall()
            
            for activo in activos_db:
                is_up, latency = check_port(activo['direccion_ip'], activo['puerto'])
                if is_up:
                    activo['estado'] = "Activo"
                    activo['latencia'] = f"{latency:.0f} ms"
                else:
                    activo['estado'] = "Caído"
                    activo['latencia'] = "-"
                context["activos"].append(activo)
                
        connection.close()
    except Exception as e:
        context["db_status"] = f"Error: {e}"
    
    return render_template('index.html', **context)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
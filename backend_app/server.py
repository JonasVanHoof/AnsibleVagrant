from flask import Flask
import random
# import MySQLdb

app = Flask(__name__)

@app.route("/")
def hello():
    # db = MySQLdb.connect(host="172.17.3.0", user="user", passwd="user", db="my_database")
    # db.close()
    return "This is a response from the backend!"

app.run(host="0.0.0.0")
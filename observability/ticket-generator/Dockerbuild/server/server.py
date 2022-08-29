import datetime
import hashlib
import random
import os
from flask import Flask, Response

app = Flask(__name__)

def html_error():
    now = datetime.datetime.now()
    if os.path.exists("./error"):
        return True
    if (now.weekday() == 1 or now.weekday() == 5):
        return True
    return False

@app.route('/getticket')
def ticket():
    rand_hash = hashlib.sha256(str(random.getrandbits(256)).encode('utf-8')).hexdigest()
    resp = Response("Ticket: " + rand_hash)
    if html_error():
        del resp.headers['Content-Type']
        resp.headers['text/plain'] = "Content-type"
    return resp

if __name__ == '__main__':
    app.run(debug=False,host='0.0.0.0', port=8080)

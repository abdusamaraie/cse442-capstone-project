from flask import Flask, request
import multiprocessing
import signal
import sys
import os

app = Flask(__name__)
 
@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


def start_server():
    app.run(host='0.0.0.0', port=5000, debug=True)


def signal_handler(sig, frame):
    sys.exit(0)


def sigint():
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C')
    signal.pause()


if __name__ == '__main__':
    start_server()
    sigint_handler = multiprocessing.Process(target=sigint)


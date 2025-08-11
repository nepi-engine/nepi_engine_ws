#
# Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
#
# This file is part of nepi-engine
# (see https://github.com/nepi-engine).
#
# License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
#
import os
import time
import socket

from flask import Flask, send_from_directory, send_file, jsonify, g
from flask_cors import CORS

from rui_webserver.config import APP_BUILD_PATH, DATA_PATH


app = Flask(__name__, static_folder=APP_BUILD_PATH)
CORS(app)


"""
Network info route
"""
@app.route('/api/networkinfo')
def network_info():
    return jsonify({
        "ipAddress": socket.gethostbyname(socket.gethostname())
    })

"""
Directory listing / file browsing
"""
@app.route('/files/', defaults={'path': ''})
@app.route('/files/<path:path>')
def files(path):
    req_path = os.path.join(DATA_PATH, path)

    # check against bad users
    if req_path != DATA_PATH and os.path.commonprefix((os.path.realpath(req_path), DATA_PATH)) != DATA_PATH:
        print('No access to files outside %s' % DATA_PATH)
        return Response(status=400)

    # check if path is a file and serve
    if os.path.isfile(req_path):
        r = send_file(req_path)
        r.headers["Pragma"] = "no-cache"
        r.headers["Expires"] = "0"
        r.headers['Cache-Control'] = 'public, max-age=0'
        return r

    # show directory contents
    dirlist = []
    for f in os.listdir(req_path):
        file_path = os.path.join(path, f)
        abs_file_path = os.path.join(req_path, f)
        is_file = os.path.isfile(abs_file_path)
        file_size = os.stat(abs_file_path).st_size if is_file else 0
        num_files = len(os.listdir(abs_file_path)) if not is_file else 0
        dirlist.append({
            "name": f,
            "path": file_path,
            "isFile": is_file,
            "size": file_size,
            "numItems": num_files
        })
    return jsonify(dirlist)



"""
Catchall, serve the frontend
"""
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    if path != "" and os.path.exists(os.path.join(APP_BUILD_PATH, path)):
        return send_from_directory(APP_BUILD_PATH, path)
    else:
        return send_from_directory(APP_BUILD_PATH, 'index.html')


@app.before_request
def before_request():
    g.start = time.time()
    g.end = None


@app.teardown_request
def teardown_request(exc):
    g.end = time.time()
    diff = g.end - g.start
    if app.debug:
        print("Request took {} secs".format(str(diff)))


def start_server():
    app.run(use_reloader=True, host='0.0.0.0',
            port=5003, threaded=True, debug=True)

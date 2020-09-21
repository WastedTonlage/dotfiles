#! /usr/bin/python3

import http.server
import json

class Handler(http.server.BaseHTTPRequestHandler):

    def __init__(self, request, client_address, server):
        super().__init__(request, client_address, server)
        
    def send_error(self):
        self.send_response(404)
        self.end_headers()
        self.wfile.write("Error".encode('UTF-8'))

    def do_POST(self):
        if (self.path != "/inwatech"):
            self.send_error()
            print("wrong path: {}".format(self.path))
            return

        length = int(self.headers['Content-Length'])
        raw_data = self.rfile.read(length)
        try:
            data = json.loads(raw_data)
        except json.decoder.JSONDecodeError:
            self.send_error()
            return
        print("Received data: {}".format(raw_data))
        if data['MessageId'] == 716:
            self.send_error()
            return

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write("""
{
\"Reply\": \"StackEntered\",
\"MessageId\": 714,
\"Status\": 0,
\"StatusText\": \"OK\"
}""".encode('UTF-8'))

PORT = 8081
server = http.server.HTTPServer(('', PORT), Handler)
server.serve_forever()

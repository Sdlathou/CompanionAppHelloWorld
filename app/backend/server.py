#!/usr/bin/env python3
"""
Minimal Hello World backend.
Serves GET /api/hello (JSON) and the static frontend on the same port.
No third-party packages required — only the Python 3 standard library.
"""

import datetime
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

FRONTEND_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "frontend")

MIME = {
    ".html": "text/html; charset=utf-8",
    ".js": "application/javascript",
    ".css": "text/css",
}


class HelloHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/hello":
            self._api_hello()
        else:
            self._serve_static()

    # ------------------------------------------------------------------ #

    def _api_hello(self):
        body = json.dumps(
            {
                "message": "Hello from backend",
                "ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            }
        ).encode()
        self._respond(200, "application/json", body)

    def _serve_static(self):
        rel = "/" if self.path in ("", "/") else self.path
        filepath = os.path.realpath(os.path.join(FRONTEND_DIR, rel.lstrip("/")))
        # safety: stay inside FRONTEND_DIR
        if not filepath.startswith(os.path.realpath(FRONTEND_DIR)):
            self._respond(403, "text/plain", b"Forbidden")
            return
        if os.path.isdir(filepath):
            filepath = os.path.join(filepath, "index.html")
        if not os.path.isfile(filepath):
            self._respond(404, "text/plain", b"Not found")
            return
        ext = os.path.splitext(filepath)[1]
        ctype = MIME.get(ext, "application/octet-stream")
        with open(filepath, "rb") as fh:
            content = fh.read()
        self._respond(200, ctype, content)

    def _respond(self, status, content_type, body: bytes):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):  # suppress noisy default access log
        pass


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("0.0.0.0", port), HelloHandler)
    print(f"Backend listening on http://0.0.0.0:{port}", flush=True)
    server.serve_forever()

#!/usr/bin/env python3
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
import sys

class MockVaultHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Suppress logging to keep output clean unless needed
        pass

    def do_GET(self):
        # 1. Config call: /where/is/my/secret<id>
        if "/where/is/my/secret" in self.path:
            secret_id = self.path.split("/")[-1]
            response_data = {
                "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
                "ROLE_NAME": f"role-{secret_id}"
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            return

        # 4. Get secret: /v1/secret/data/<path>
        if "/v1/secret/data/" in self.path:
            secret_path = self.path.replace("/v1/secret/data/", "")
            token = self.headers.get("X-Vault-Token", "missing-token")
            response_data = {
                "request_id": f"req-get-{secret_path}",
                "data": {
                    "data": {
                        "value": f"mock-secret-value-for-{secret_path}",
                        "retrieved_with_token": token
                    },
                    "metadata": {
                        "version": 1,
                        "created_time": "2026-07-08T12:00:00Z"
                    }
                }
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            return

        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length) if content_length > 0 else b""
        
        # 2. Vault Login call: /v1/auth/jwt/login
        if self.path == "/v1/auth/jwt/login":
            try:
                data = json.loads(post_data.decode("utf-8"))
                role = data.get("role", "default-role")
                jwt = data.get("jwt", "")
            except Exception:
                role = "unknown"
                jwt = ""
                
            # Create response structure containing client_token
            # We support both direct auth.client_token and nested auth.data.client_token
            response_data = {
                "auth": {
                    "client_token": f"hvs.mock_client_token_for_{role}",
                    "accessor": f"accessor_{role}",
                    "policies": ["default", role],
                    "metadata": {
                        "role": role,
                        "jwt_snippet": jwt[:20] if jwt else "none"
                    },
                    "lease_duration": 3600,
                    "renewable": True,
                    "data": {
                        "client_token": f"hvs.mock_client_token_for_{role}"
                    }
                }
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            return

        # 5. Post Secret: /v1/secret/data/<path>
        if "/v1/secret/data/" in self.path:
            secret_path = self.path.replace("/v1/secret/data/", "")
            token = self.headers.get("X-Vault-Token", "missing-token")
            try:
                payload = json.loads(post_data.decode("utf-8"))
            except Exception:
                payload = {}
            response_data = {
                "request_id": f"req-post-{secret_path}",
                "data": {
                    "status": "written",
                    "path": secret_path,
                    "payload_received": payload,
                    "token_used": token
                }
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            return

        # 6. Post Rotate: /v1/auth/token/renew-self
        if self.path == "/v1/auth/token/renew-self":
            token = self.headers.get("X-Vault-Token", "missing-token")
            response_data = {
                "auth": {
                    "client_token": token,
                    "lease_duration": 7200,
                    "renewable": True
                }
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            return

        self.send_response(404)
        self.end_headers()

def run(port=1717):
    server_address = ('127.0.0.1', port)
    httpd = HTTPServer(server_address, MockVaultHandler)
    print(f"Starting mock server on port {port}...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    print("Stopping mock server.")

if __name__ == '__main__':
    port = 1717
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    run(port)

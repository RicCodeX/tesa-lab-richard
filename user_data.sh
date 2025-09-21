#!/usr/bin/env bash
set -eux

apt-get update -y
apt-get install -y python3 python3-pip git

# Minimal Flask app on port 8000
mkdir -p /opt/richard-app
chown ubuntu:ubuntu /opt/richard-app

pip3 install flask

cat > /opt/richard-app/app.py << 'PY'
from flask import Flask
app = Flask(__name__)

@app.get("/")
def hello():
    return "Hello from Richard on EC2 via Terraform! 🚀 Listening on :8000"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
PY

# Systemd service to keep it running
cat > /etc/systemd/system/richard-app.service << 'EOF'
[Unit]
Description=Richard Flask App (port 8000)
Wants=network-online.target
After=network-online.target

[Service]
User=ubuntu
WorkingDirectory=/opt/richard-app
ExecStart=/usr/bin/python3 /opt/richard-app/app.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now richard-app

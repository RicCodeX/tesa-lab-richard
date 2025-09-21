from flask import Flask
app = Flask(__name__)

@app.get("/")
def hello():
    return "CI/CD ✅ Hello from Richard via GitHub Actions again → EC2 (port :8000)"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

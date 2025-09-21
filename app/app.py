from flask import Flask
app = Flask(__name__)

@app.get("/")
def hello():
    return "CI/CD ✅ Deployed by GitHub Actions (build #2)"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

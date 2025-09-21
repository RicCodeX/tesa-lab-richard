from flask import Flask, render_template
app = Flask(__name__)

@app.get("/")
def index():
    # renders templates/index.html
    return render_template("index.html")

if __name__ == "__main__":
    # bind to 0.0.0.0:8000 so it's reachable externally
    app.run(host="0.0.0.0", port=8000)

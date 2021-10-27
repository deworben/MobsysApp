from flask import Flask, request
from flask_cors import CORS
import json
import numpy as np

# Run this application
# flask run --host=0.0.0.0

app = Flask(__name__)
CORS(app)

count = 0

@app.route("/", methods=['GET', 'POST'])
def datalink():
    global count
    if count >= 50:
        print("Done")
        return "Done"
    with open(f"./test/{count}.mfcc", "w+") as f:
    # with open(f"./train/laugh/{count}.mfcc", "w+") as f:
    # with open(f"./train/talk/{count}.mfcc", "w+") as f:
        json.dump(request.get_json()["mfcc"], f)
    print(np.sum(np.array(request.get_json()["mfcc"])))
    print(np.array(request.get_json()["mfcc"]).shape)
    count += 1
    return "Access"

app.run(host="0.0.0.0")
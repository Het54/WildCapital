from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

data = {'value': 0}  # Initial JSON object

# Function to update the JSON data in a while loop
def update_data():
    while True:
        data['value'] += 1
        time.sleep(1)  # Wait for 1 second before updating again

# Start the thread to update data
update_thread = threading.Thread(target=update_data)
update_thread.start()

# Route to get the JSON data
@app.route('/data')
def get_data():
    return jsonify(data)

# Start the Flask app
if __name__ == '__main__':
    app.run(debug=True)